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
- `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`
  - `(echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> /Users/robertparton/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"`
- `brew install gh git tmux warp visual-studio-code pip node yarn`
- `gh auth login`
- `git clone https://github.com/rjparton/rjparton_config $HOME/.rjparton_config`
- `chsh -s /bin/zsh`
- `ln -s "$HOME"/.rjparton_config/git/gitconfig "$HOME"/.gitconfig`
- `ln -s "$HOME"/.rjparton_config/git/gitignore "$HOME"/.gitignore`
- `ln -s "$HOME"/.rjparton_config/tmux/tmux.conf "$HOME"/.tmux.conf`
- `ln -s "$HOME"/.rjparton_config/vim/vimrc "$HOME"/.vimrc`
- `ln -s "$HOME"/.rjparton_config/vim "$HOME"/.vim`
- `mkdir -p "$HOME"/.config/nvim && ln -s "$HOME"/.rjparton_config/vim/init.vim "$HOME"/.config/nvim/init.vim`

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
