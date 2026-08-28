{ config, pkgs, user, ... }:

let
  # rebuild.sh points ~/.dotfiles at whatever directory it was run from. That
  # indirection is what lets the repo be cloned to any path without editing
  # every link below.
  configRepo = "${config.home.homeDirectory}/.dotfiles";
in

{
  home.username = user;
  home.homeDirectory = "/Users/${user}";
  home.stateVersion = "24.11";
  home.packages = with pkgs; [
    # cli i use constantly
    ripgrep   # fast search
    fd        # fast find
    fzf       # fuzzy finder
    jq        # json on the command line
    lazygit
    neovim
    opencode  # overlaid from nixpkgs-unstable in flake.nix

    # The ambient Rust toolchain: rustc, cargo, clippy, rustfmt and the stdlib.
    # rust-src and rust-analyzer are what the nvim LSP config wants. Projects
    # needing a different version pin it in their own flake devShell rather
    # than switching this one.
    (rust-bin.stable.latest.default.override {
      extensions = [ "rust-src" "rust-analyzer" ];
    })

    # the font everything renders in
    nerd-fonts.hack
  ];
  fonts.fontconfig.enable = true;
  home.sessionVariables.EDITOR = "nvim";

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;      # ghost text from history
    syntaxHighlighting.enable = true;  # commands turn green when valid
    initContent = ''
      bindkey '^f' autosuggest-accept
      # zsh binds neither Home nor End by default, and terminals disagree on
      # how to encode them. Bind every common form rather than guess.
      bindkey '^[[H' beginning-of-line
      bindkey '^[OH' beginning-of-line
      bindkey '^[[1~' beginning-of-line
      bindkey '^[[7~' beginning-of-line
      bindkey '^[[F' end-of-line
      bindkey '^[OF' end-of-line
      bindkey '^[[4~' end-of-line
      bindkey '^[[8~' end-of-line
    '';
    shellAliases = {
      ".." = "cd ..";
      add = "git add .";
      commit = "git commit -m";
      push = "git push";
      pull = "git pull";
      m = "git switch main";
      cc = "claude --dangerously-skip-permissions";
      co = "codex --full-auto";
      oc = "opencode --auto";
      opencode = "opencode --auto";
      v = "nvim";
      vim = "nvim";
    };
  };

  # Configures the shell prompt.
  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      format = "$directory$git_branch$git_status$cmd_duration$line_break$character";
      character = {
        success_symbol = "[❯](purple)";
        error_symbol = "[❯](red)";
      };
      cmd_duration.format = "[$duration]($style) ";
    };
  };

  # Edit-in-place: the real file stays in my repo, ~/.config just points at it.
  home.file.".config/wezterm".source =
    config.lib.file.mkOutOfStoreSymlink "${configRepo}/home/.config/wezterm";
  home.file.".config/nvim".source =
    config.lib.file.mkOutOfStoreSymlink "${configRepo}/home/.config/nvim";

  # herdr writes logs, sockets and session state into this directory at
  # runtime. .gitignore keeps everything but config.toml out of the repo.
  home.file.".config/herdr".source =
    config.lib.file.mkOutOfStoreSymlink "${configRepo}/home/.config/herdr";

  home.file.".gitconfig".source =
    config.lib.file.mkOutOfStoreSymlink "${configRepo}/home/git/gitconfig";
  home.file.".gitignore".source =
    config.lib.file.mkOutOfStoreSymlink "${configRepo}/home/git/gitignore";

  # One agent instruction file, three tools reading it.
  home.file.".claude/CLAUDE.md".source =
    config.lib.file.mkOutOfStoreSymlink "${configRepo}/home/AGENTS.md";
  home.file.".codex/AGENTS.md".source =
    config.lib.file.mkOutOfStoreSymlink "${configRepo}/home/AGENTS.md";
  home.file.".config/opencode/AGENTS.md".source =
    config.lib.file.mkOutOfStoreSymlink "${configRepo}/home/AGENTS.md";

  # Linked file-by-file rather than as a directory: opencode also keeps
  # node_modules/, package.json and plugins/ in here, and those are not ours
  # to manage.
  home.file.".config/opencode/opencode.jsonc".source =
    config.lib.file.mkOutOfStoreSymlink
      "${configRepo}/home/.config/opencode/opencode.jsonc";

  # ~/.claude/settings.json is deliberately absent. Claude Code rewrites that
  # file itself, so a symlink here gets replaced with a real file and the
  # config silently detaches.
}
