import logging
import os
import optparse
import sys
import yaml
import subprocess

from typing import Any, Callable, Optional
from dataclasses import dataclass

_logger = logging.getLogger()
_venv_dir = ".devopslibs_venv"


def remote_ssh_url_builder(server: str, org: str, repo: str):
    return f'git@{server}:{org}/{repo}.git'


class YamlParserAdapter:
    @staticmethod
    def load_values_from_file(fp: str,
                              sections: list[str],
                              ) -> dict[str, dict[str, str]]:
        with open(fp, 'r') as f:
            contents = f.read()

        result: dict[str, Any] = {}

        try:
            file_artifacts = yaml.safe_load(contents)
        except yaml.YAMLError as exc:
            _logger.exception(exc)
            raise

        for s in sections:
            if s not in file_artifacts:
                continue
            result[s] = file_artifacts[s]
        return result


class Command:
    @staticmethod
    def run(cmds: list[str], **kwargs):
        return subprocess.check_output(
                cmds,
                **kwargs
        )


@dataclass
class PipPackage:
    library_dir: str
    pip_bin: str

    def __run(self, cmd: list[str], *args, **kwargs):
        return Command.run([self.pip_bin] + cmd, *args, **kwargs)

    def install_package(self):
        return self.__run(
                ["install", "-e", self.library_dir]
            )


@dataclass
class GitRepository:
    workspace_dir: str
    repository_dir: str
    remote_url: str

    def __run(self, cmd: list[str], *args, **kwargs):
        return Command.run(["git"] + cmd, *args, **kwargs)

    def clone(self):
        return self.__run(["clone", self.remote_url],
                          cwd=self.workspace_dir)

    def checkout(self, target_branch: str):
        return self.__run(["checkout", target_branch],
                          cwd=self.repository_dir)

    def current_branch(self):
        output = self.__run(["branch", "--show-current"],
                            cwd=self.repository_dir)
        return output.decode('utf-8').replace('\n', '')

    def pull(self):
        return self.__run(["pull", "--all"], cwd=self.repository_dir)


class BaseDevOpsLib(GitRepository):
    def __init__(self,
                 name: str,
                 workspace_dir: str,
                 remote_url: str) -> None:

        self.name: str = name

        super().__init__(
                workspace_dir=workspace_dir,
                repository_dir=os.path.join(workspace_dir, name),
                remote_url=remote_url,
            )

    def _check_if_directory_exists(self):
        return os.path.isdir(self.repository_dir)

    def clone_or_pull_from_remote_origin(self):
        if self._check_if_directory_exists():
            _logger.info("[GIT] Pulling all branches"
                         f" from repository {self.name}")
            self.pull()
            return
        _logger.info(f"[GIT] Cloning repository {self.name}")
        self.clone()


class DevOpsLibPipPackage(BaseDevOpsLib, PipPackage):
    def __init__(self,
                 name: str,
                 target_branch: str,
                 workspace_dir: str,
                 remote_url: str,
                 pip_bin: str) -> None:

        self.target_branch: str = target_branch

        # Initialize the superclasses
        BaseDevOpsLib.__init__(
                self,
                name=name,
                workspace_dir=workspace_dir,
                remote_url=remote_url,
            )
        PipPackage.__init__(self,
                            library_dir=self.repository_dir,
                            pip_bin=pip_bin)

    def install_package(self):
        # Checkout to the target branch before running pip install
        if self.current_branch() != self.target_branch:
            self.checkout(self.target_branch)
        _logger.info("[PIP] Installing the lib"
                     f" {self.name}/{self.target_branch}")
        super(DevOpsLibPipPackage, self).install_package()


@dataclass
class DevOpsLibsBatchInstaller:
    packages: list[DevOpsLibPipPackage]
    non_packages: list[BaseDevOpsLib]

    def clone_or_pull_from_remote_origin(self, *args, **kwargs):
        for lib in self.packages + self.non_packages:
            lib.clone_or_pull_from_remote_origin(*args, **kwargs)

    def install_packages(self, *args, **kwargs):
        for p in self.packages:
            p.install_package(*args, **kwargs)

    def sync_all(self, *args, **kwargs):
        self.clone_or_pull_from_remote_origin(*args, **kwargs)
        self.install_packages(*args, **kwargs)


def initialize_config(config_fname: str):
    if not os.path.exists(config_fname):
        raise FileNotFoundError("The configuration file"
                                " for this script does not exist,"
                                " create a file (.devopslib.cfg.yml) at"
                                " your home directory or pass as arg"
                                " to the script")

    c = YamlParserAdapter.load_values_from_file(
        config_fname,
        ["main", "git", "packages", "repositories"],
    )
    result = {}
    for section in ["main", "git"]:
        if section not in result:
            result[section] = {}
        for k, v in c.get(section, {}).items():
            result[section][k] = v

    # overwrite workspace_dir considering the expanded user
    result["main"]["workspace_dir"] = os.path.expanduser(
                c["main"]["workspace_dir"]
            )
    venv_dir = os.path.join(result["main"]["workspace_dir"], _venv_dir)
    result["venv_dir"] = venv_dir
    result["pip_bin"] = os.path.join(venv_dir, "bin", "pip")

    ssh_url_common_kwargs = {
        'server': result["git"]["server"],
        'org': result["git"]["organization"],
    }

    result["devopslibs_packages"] = []
    for lib, target_branch in c.get("packages", {}).items():
        result["devopslibs_packages"].append(
                DevOpsLibPipPackage(
                    name=lib,
                    workspace_dir=result["main"]["workspace_dir"],
                    target_branch=target_branch,
                    pip_bin=result["pip_bin"],
                    remote_url=remote_ssh_url_builder(
                        repo=lib,
                        **ssh_url_common_kwargs,
                    ),
                )
            )

    result["devopslibs"] = []
    for lib in c.get("repositories", []):
        result["devopslibs"].append(
            BaseDevOpsLib(
                name=lib,
                workspace_dir=result["main"]["workspace_dir"],
                remote_url=remote_ssh_url_builder(
                    repo=lib,
                    **ssh_url_common_kwargs,
                )
            )
        )

    return result


def run():
    parser = optparse.OptionParser()
    parser.add_option(
        "-c",
        "--config",
        dest="config",
        help="the config location",
    )
    (options, args) = parser.parse_args()

    method = args[0]
    if method not in ["clone_or_pull", "pip_install", "sync_all"]:
        raise ValueError("The option action is required")

    config_fname = options.config
    if not config_fname:
        config_fname = "~/.devopslibs.cfg.yml"
        _logger.warning("[CONFIG] No config file provided, using default"
                        f" at home directory {config_fname}")

    c = initialize_config(os.path.expanduser(config_fname))
    logging.basicConfig(level=logging.INFO)

    if c.get("main", {}).get("workspace_dir", None) is None:
        raise ValueError("No workspace_dir found, stopping"
                         " the script execution.")

    if not os.path.exists(c["main"]["workspace_dir"]):
        os.mkdir(path=c["main"]["workspace_dir"])

    venv_dir = c.get("venv_dir", None)
    if venv_dir is None:
        raise ValueError("No venv directory found, stopping"
                         " the script execution")

    if not os.path.exists(venv_dir):
        _logger.info(f"[CONFIG] Initializing venv as {venv_dir}...")
        Command.run(
            [sys.executable, "-m", "venv", venv_dir],
        )

    batch_installer = DevOpsLibsBatchInstaller(
            packages=c["devopslibs_packages"],
            non_packages=c["devopslibs"]
        )
    methods_dict: dict[str, Callable[[Optional[Any]], None]] = {
            "clone_or_pull": batch_installer.clone_or_pull_from_remote_origin,
            "pip_install": batch_installer.install_packages,
            "sync_all": batch_installer.sync_all,
    }
    method_func = methods_dict.get(method, None)
    if not isinstance(method_func, Callable):
        raise ValueError(f"No method {method} key found for the command"
                         " in the methods dictionary")
    method_func()  # type: ignore


def main():
    exit_code = 0
    try:
        run()
    except Exception as e:
        _logger.exception(str(e))
        exit_code = 1

    return exit_code


if __name__ == "__main__":
    sys.exit(main())
