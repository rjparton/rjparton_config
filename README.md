# config

- Change capslock to ctrl
- `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`
  - `(echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> /Users/robertparton/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"`
- `brew install gh git tmux warp visual-studio-code`
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
- Install vim
- TODO: Copy `settings.json`
- 
