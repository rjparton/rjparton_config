# config

- Change capslock to ctrl
- `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`
- `brew install git tmux warp visual-studio-code`
- `git clone https://github.com/rjparton/rjparton_config $HOME/.rjparton_config`
- chsh -s /bin/zsh
- ln -s "$HOME"/.rjparton_config/git/gitconfig "$HOME"/.gitconfig
- ln -s "$HOME"/.rjparton_config/git/gitignore "$HOME"/.gitignore
- ln -s "$HOME"/.rjparton_config/tmux/tmux.conf "$HOME"/.tmux.conf
- ln -s "$HOME"/.rjparton_config/vim/vimrc "$HOME"/.vimrc
- ln -s "$HOME"/.tullie_files/vim "$HOME"/.vim
- mkdir -p "$HOME"/.config/nvim && ln -s "$HOME"/.tullie_files/vim/init.vim "$HOME"/.config/nvim/init.vim

## VSCode
- Install vim
- TODO: Copy `settings.json`
- 
