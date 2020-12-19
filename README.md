# Dotfiles

![Screenshot of my personal dotfiles](screenshot.png)

These are my personal dotfiles for Windows and Linux.

-   Bash
-   Git
-   PowerShell
-   Starship
-   Tmux
-   Vim
-   VsVim
-   Windows Terminal

My Visual Studio Code settings and extensions are synced with the 'Settings Sync' with my GitHub account. I have also been experimenting with Neovim, however I am sadly still finding it difficult to replace the support and features of Visual Studio Code.

## Install

To use `install.py` Python 3 is required. The script should work on both Windows and POSIX compatible systems. In addition, the script should not require administator privileges on Windows provided that [Developer Mode](https://docs.microsoft.com/en-us/windows/apps/get-started/enable-your-device-for-development) is enabled and Python 3.8 or greater is used.

```
git clone git@github.com:scottwillmoore/dotfiles ~/Dotfiles
cd ~/Dotfiles
python ./install.py --verbose
```
