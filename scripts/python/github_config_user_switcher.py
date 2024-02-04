import configparser
import logging
import subprocess
from dataclasses import dataclass
from itertools import cycle
from os import path, system, walk

_logger = logging.getLogger()

USER_FIELDS = ["name", "email"]
GITHUB_USERS_DIR = path.expanduser("~/dotfiles/config/git/users")


@dataclass(frozen=True)
class GithubConfigUser:
    name: str
    email: str


class GithubConfigFileOperator:
    def _build_git_cmd(self, key: str, **kwargs) -> str:
        cmd = "git config --global"
        act = kwargs["action"]
        if act == "get":
            return f"{cmd} --{act} {key}"
        v = kwargs["value"]
        return f"{cmd} {key} {v}"

    def update_keys(self, section: str, pairs: list[tuple[str, str]]) -> None:
        for p in pairs:
            k, v = p
            cmd = self._build_git_cmd(f"{section}.{k}", value=v, action="set")
            system(cmd)

    def get_key_value(self, key: str) -> str:
        cmd = self._build_git_cmd(f"{key}", action="get")
        output = subprocess.run([cmd], stdout=subprocess.PIPE, shell=True)
        return output.stdout.decode("utf-8").replace("\n", "")


class GithubConfigUsersFileLoader:
    users: list[GithubConfigUser] = []

    @classmethod
    def load_users(cls):
        for top, _, files in walk(GITHUB_USERS_DIR):
            for f_name in files:
                file_fp = path.join(top, f_name)
                parser = configparser.RawConfigParser()
                parser.read(file_fp)
                user = dict(parser.items("user"))
                if user is None:
                    _logger.warn(f"Skipping file {f_name} since user is not defined")
                    continue
                u_fields = {}
                for f in USER_FIELDS:
                    v = user.get(f)
                    if v is None:
                        _logger.warn(
                            f"Skipping user in file {f} "
                            f"since the field {f} is missing"
                        )
                        continue
                    u_fields[f] = v
                cls.users.append(
                    GithubConfigUser(
                        name=u_fields["name"],
                        email=u_fields["email"],
                    )
                )
                parser.clear()


@dataclass
class GithubConfigUserSwitcher(GithubConfigFileOperator):
    users: list[GithubConfigUser]

    def next_user(self) -> GithubConfigUser | None:
        c_email = self.get_key_value("user.email")
        c_name = self.get_key_value("user.name")
        users = cycle(self.users)
        next_user: GithubConfigUser | None = None
        for _ in range(len(self.users)):
            u = next(users)
            if c_email == u.email and c_name == u.name:
                next_user = next(users)
                break
        return next_user

    def switch(self):
        u = self.next_user()
        if not isinstance(u, GithubConfigUser):
            _logger.warning("No user found to switch the main configuration")
            return
        keys: list[tuple[str, str]] = []
        for f in USER_FIELDS:
            keys.append((f, getattr(u, f)))
        self.update_keys("user", keys)
        _logger.info(f"Current user is now pointing to {u.name} / {u.email}")


def main():
    logging.basicConfig()
    _logger.setLevel(logging.INFO)

    gh_users_loader = GithubConfigUsersFileLoader()
    gh_users_loader.load_users()
    switcher = GithubConfigUserSwitcher(gh_users_loader.users)
    switcher.switch()


if __name__ == "__main__":
    main()
