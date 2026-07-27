# config

## MacOS Setup
- Change capslock to ctrl
- Keyboard > Key repeat rate > Fastest
- Keyboard > Delay until repeat > Shortest
- Enable key repeats `defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false`

## Mouse Settings
- Thumb buttons: Desktop right/left
- Spin wheel: Mission control
- Top: Screen capture save to clipboard

# Code Setup
```
git clone https://github.com/rjparton/rjparton_config "$HOME/.rjparton_config"
"$HOME/.rjparton_config/install.sh"
```

`install.sh` is safe to re-run — it skips packages that are already installed and
backs up (rather than overwrites) any existing dotfile before symlinking. It:
- Installs Homebrew if missing, and wires up `brew shellenv` in `~/.zprofile`
- Installs `gh`, `git`, `tmux`, `warp`, `visual-studio-code`, `python`, `node`, `yarn`
- Sets the default shell to zsh (if it isn't already)
- Runs `gh auth login` (if not already authenticated)
- Initializes the `zsh/pure` submodule
- Symlinks `git/gitconfig`, `git/gitignore`, `tmux/tmux.conf`, `vim/vimrc`, `vim`,
  and `vim/init.vim` (for neovim) into `$HOME`

# Tmux
- Install TPM: `git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm`
- Install the plugins within tmux session `C-a I`


## VSCode
- `rm -rf "$HOME"/Library/Application\ Support/Code/User/settings.json`
- `ln -s "$HOME"/.rjparton_config/vscode/settings.json "$HOME"/Library/Application\ Support/Code/User/settings.json`
- Theme: Tokyo Night

### Install Extensions
- vim
- rewrap
- prettier
- black
- autopep8
- emmet jss
- eslint
- c/c++
- gitlens
- material icon theme
- tokyo night
- python
