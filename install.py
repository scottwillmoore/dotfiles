#!/usr/bin/env python


from argparse import ArgumentParser
import os
from pathlib import Path
import platform
import shutil


def ask_question(question):
    while True:
        answer = input(f"{question}? ").lower().strip()
        if answer in ("y", "yes"):
            return True
        if answer in ("n", "no"):
            return False
        print("You must answer yes or no")


def python_version():
    return tuple(map(int, platform.python_version_tuple()))


def is_windows():
    return platform.system() == "Windows"


if is_windows():
    import ctypes
    from ctypes import wintypes

    def is_administrator():
        return ctypes.windll.shell32.IsUserAnAdmin() != 0

    # https://stackoverflow.com/questions/41231586/how-to-detect-if-developer-mode-is-active-on-windows-10
    def is_developer_mode_enabled():
        HKEY_LOCAL_MACHINE = 0x80000002
        KEY_READ = 0x20019
        ERROR_SUCCESS = 0

        key = wintypes.HKEY()
        error = ctypes.windll.advapi32.RegOpenKeyExW(
            HKEY_LOCAL_MACHINE,
            r"SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock",
            0,
            KEY_READ,
            ctypes.byref(key),
        )
        if error != ERROR_SUCCESS:
            return False

        value = wintypes.DWORD()
        value_size = wintypes.DWORD(ctypes.sizeof(value))
        error = ctypes.windll.advapi32.RegQueryValueExW(
            key,
            r"AllowDevelopmentWithoutDevLicense",
            None,
            None,
            ctypes.byref(value),
            ctypes.byref(value_size),
        )
        if error != ERROR_SUCCESS:
            return False

        ctypes.windll.advapi32.RegCloseKey(key)

        return value != 0


def is_mac():
    return platform.system() == "Darwin"


def is_linux():
    return platform.system() == "Linux"


def is_posix_compliant():
    return is_mac() or is_linux()


if is_posix_compliant():

    def is_root():
        return os.getuid() == 0


class Platform:
    def __init__(self):
        self.platform = platform.system().lower()


class FilesystemError(Exception):
    pass


class Filesystem:
    def __init__(self, source=".", *, dry=False, force=False, verbose=False, interactive=False):
        self.scriptPath = Path(__file__)
        self.scriptDirectory = self.scriptPath.parent
        os.chdir(self.scriptDirectory)

        try:
            self.sourceDirectory = Path(source).resolve(strict=True)
        except FileNotFoundError:
            raise FilesystemError("The source directory could not be resolved")

        self.dry = dry
        self.force = force
        self.verbose = verbose
        self.interactive = interactive

    def resolve_source(self, source):
        source = Path(source)
        if source.is_absolute():
            raise FilesystemError("The source path must be a relative path")

        try:
            source = (self.sourceDirectory / source).resolve(strict=True)
        except FileNotFoundError:
            raise FilesystemError("The source path must exist")

        # 'is_relative_to' is only supported in Python 3.9+...
        # if not source.is_relative_to(self.sourceDirectory):
        #     raise FilesystemError("The source path must be relative to the source directory")

        return source

    def resolve_destination(self, destination):
        destination = Path(destination).expanduser()

        if not destination.is_absolute():
            raise FilesystemError("The destination path must be an absolute path")

        if destination.exists() or destination.is_symlink():
            response = None
            if not self.force:
                print("The destination path already exists")
                response = ask_question("Do you wish to overwrite the destination path")

            if response or self.force:
                if self.verbose:
                    print("Deleting destination path...")

                if not self.dry:
                    if destination.is_file() or destination.is_symlink():
                        os.remove(destination)
                    elif destination.is_dir():
                        shutil.rmtree(destination)

                if self.dry:
                    print("Dry: ", end="")
                if self.dry or self.verbose:
                    print("Deleted the destination path!")
            else:
                return None

        if not destination.parent.exists():
            if self.verbose:
                print("The parent directory of the destination path does not exist")
                print("Creating the parent directory of the destination path...")

            if not self.dry:
                os.makedirs(destination.parent)

            if self.dry:
                print("Dry: ", end="")
            if self.dry or self.verbose:
                print("Created the parent directory of the destination path!")

        return destination

    def resolve(self, source, destination):
        if self.verbose:
            print(f"Resolving the source path...")
        source = self.resolve_source(source)

        if self.verbose:
            print(f"Resolving the destination path...")
        destination = self.resolve_destination(destination)

        return source, destination

    def make(self, source, destination, action_name, action):
        print(f"\nCreating {action_name} from '{source}' to '{destination}'...")

        if self.interactive:
            response = ask_question("Do you wish to continue")
            if not response:
                print("Skipped!")
                return

        try:
            source, destination = self.resolve(source, destination)
        except FilesystemError as error:
            print(error)
            return

        if not destination:
            print("Skipped!")
            return

        if not self.dry:
            try:
                action(source, destination)
            except FilesystemError as error:
                print(error)
                return

        if self.dry:
            print("Dry: ", end="")
        print(f"Created the {action_name}!")

    def make_hard_link(self, source, destination):
        def action(source, destination):
            if not source.is_file():
                raise FilesystemError("Hard links can only be created to files")
            os.link(source, destination)

        self.make(source, destination, "hard link", action)

    def make_symbolic_link(self, source, destination):
        def action(source, destination):
            os.symlink(source, destination)

        self.make(source, destination, "symbolic link", action)

    def find(self, path):
        print(f"\nFinding path '{path}'...")

        path = Path(path).expanduser()
        glob = str(path.relative_to(path.anchor))
        matches = list(Path(path.anchor).glob(glob))

        if not matches:
            print("Could not find path")
            return None
        if len(matches) > 1:
            print("There is more than one match for the path")
            return None

        print(f"Found path '{matches[0]}'!")

        return matches[0]


# https://stackoverflow.com/questions/9042542/what-is-the-difference-between-ntfs-junction-points-and-symbolic-links/48586946#48586946
if __name__ == "__main__":
    parser = ArgumentParser()
    parser.add_argument("--dry", "-d", action="store_true")
    parser.add_argument("--force", "-f", action="store_true")
    parser.add_argument("--verbose", "-v", action="store_true")
    parser.add_argument("--interactive", "-i", action="store_true")
    arguments = parser.parse_args()

    if is_windows():
        if not (is_administrator() or (is_developer_mode_enabled() and python_version() > (3, 8, 0))):
            raise SystemExit("The script must be run as an administrator or with developer mode enabled")

    filesystem = Filesystem(
        "files",
        dry=arguments.dry,
        force=arguments.force,
        verbose=arguments.verbose,
        interactive=arguments.interactive,
    )

    filesystem.make_symbolic_link("gitconfig", "~/.gitconfig")
    filesystem.make_symbolic_link("starship.toml", "~/.config/starship.toml")
    filesystem.make_symbolic_link("vimrc", "~/.vimrc")

    if is_posix_compliant():
        filesystem.make_symbolic_link("bash_profile", "~/.bash_profile")
        filesystem.make_symbolic_link("bashrc", "~/.bashrc")
        filesystem.make_symbolic_link("dircolors", "~/.dircolors")
        filesystem.make_symbolic_link("inputrc", "~/.inputrc")
        filesystem.make_symbolic_link("tmux.conf", "~/.tmux.conf")

    if is_windows():
        filesystem.make_symbolic_link("alacritty.yml", "~/AppData/Roaming/alacritty/alacritty.yml")

        filesystem.make_symbolic_link(
            "powershell_profile.ps1",
            "~/Documents/WindowsPowerShell/Microsoft.Powershell_profile.ps1",
        )

        filesystem.make_symbolic_link("init.vim", "~/AppData/Local/nvim/init.vim")
        filesystem.make_symbolic_link("vsvimrc", "~/.vsvimrc")

        windowsTerminalPath = filesystem.find("~/AppData/Local/Packages/*WindowsTerminal*/LocalState")
        if windowsTerminalPath:
            filesystem.make_hard_link("windows_terminal.json", windowsTerminalPath / Path("settings.json"))

    print()
