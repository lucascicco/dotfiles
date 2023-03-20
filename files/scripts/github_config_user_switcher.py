import configparser
import logging
import subprocess

from dataclasses import dataclass, field
from itertools import cycle
from os import walk, path, system

_logger = logging.getLogger()

user_fields = ['name', 'email']
github_cfg_dir = path.expanduser('~/dotfiles/files/config/git/users')


@dataclass
class GithubConfigUser:
    _name: str = field(init=False, repr=False)
    _email: str = field(init=False, repr=False)

    @property
    def name(self) -> str:
        return self._name

    @name.setter
    def name(self, name: str) -> None:
        self._name = name

    @property
    def email(self) -> str:
        return self._email

    @email.setter
    def email(self, email: str) -> None:
        self._email = email


class GithubConfigFileOperator:
    def _build_git_cmd(self, key: str, **kwargs) -> str:
        cmd = 'git config --global'
        act = kwargs["action"]
        if act == "get":
            return f'{cmd} --{act} {key}'
        v = kwargs['value']
        return f'{cmd} {key} {v}'

    def update_keys(self, section: str, keys: list[dict[str, str]]) -> None:
        for k in keys:
            k_name, v = list(k.items())[0]
            cmd = self._build_git_cmd(f'{section}.{k_name}',
                                      value=v, action="set")
            system(cmd)

    def get_key_value(self, key: str) -> str:
        cmd = self._build_git_cmd(f'{key}', action="get")
        output = subprocess.run([cmd], stdout=subprocess.PIPE, shell=True)
        return output.stdout.decode('utf-8').replace('\n', '')


class GithubConfigUsersFileLoader:
    users: list[GithubConfigUser] = []

    @classmethod
    def load_users(cls):
        for top, _, files in walk(github_cfg_dir):
            for f_name in files:
                file_fp = path.join(top, f_name)
                parser = configparser.RawConfigParser()
                parser.read(file_fp)
                user = dict(parser.items('user'))
                if user is None:
                    _logger.info(f"Skipping file {f_name} "
                                 "since user is not defined")
                    continue
                gh_user = GithubConfigUser()
                for f in user_fields:
                    v = user.get(f)
                    if v is None:
                        _logger.info(f"Skipping user in file {f} "
                                     f"since the field {f} is missing")
                        continue
                    gh_user.__setattr__(f, v)
                cls.users.append(gh_user)
                parser.clear()


@dataclass
class GithubConfigUserSwitcher(GithubConfigFileOperator):
    users: list[GithubConfigUser]

    def next_user(self) -> GithubConfigUser | None:
        c_username = self.get_key_value('user.name')
        users = cycle(self.users)
        next_user: GithubConfigUser | None = None
        for _ in range(len(self.users)):
            u = next(users)
            if c_username == u.name:
                next_user = next(users)
                break

        return next_user

    def switch(self):
        u = self.next_user()
        if not isinstance(u, GithubConfigUser):
            _logger.warning("No user found to switch the main configuration")
            return
        keys: list[dict[str, str]] = []
        for f in user_fields:
            d: dict[str, str] = {}
            d[f] = u.__getattribute__(f)
            keys.append(d)
        self.update_keys("user", keys)
        _logger.info(f"Current user is now poiting to {u.name}")


def main():
    logging.basicConfig()
    _logger.setLevel(logging.INFO)

    gh_users_loader = GithubConfigUsersFileLoader()
    gh_users_loader.load_users()
    switcher = GithubConfigUserSwitcher(gh_users_loader.users)
    switcher.switch()


if __name__ == "__main__":
    main()
