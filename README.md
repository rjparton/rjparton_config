# rjparton_config

My machine configuration. Nix (via nix-darwin and home-manager) declares the
system, the packages, and the dotfile links. Anything Nix cannot reach is listed
under [Manual steps](#manual-steps).

## Bootstrap a new machine

Install [Determinate Nix](https://determinate.systems/nix), then:

```bash
git clone https://github.com/rjparton/rjparton_config "$HOME/rjparton_config"
"$HOME/rjparton_config/rebuild.sh"
```

`rebuild.sh` points `~/.dotfiles` at whatever directory it runs from, then calls
`darwin-rebuild switch`. Every link in `home.nix` resolves through `~/.dotfiles`,
so the repo works from any path.

Afterwards, authenticate the GitHub CLI once: `gh auth login`.

## Daily use

Apply a config change:

```bash
./rebuild.sh
```

Update packages. Name the input, because a bare `nix flake update` also moves the
pinned stable branch:

```bash
nix flake update nixpkgs-unstable && ./rebuild.sh
```

Roll back a bad rebuild:

```bash
sudo darwin-rebuild --rollback
```

## Layout

| Path | Holds |
|------|-------|
| `flake.nix` | Inputs and the `mac` configuration. Also the opencode overlay. |
| `configuration.nix` | System settings: macOS defaults, Homebrew formulae and casks. |
| `home.nix` | User packages, zsh, starship, and every dotfile link. |
| `home/` | The actual config files. Symlinked into `$HOME`, so edits apply immediately. |

`home/AGENTS.md` is one file read by three tools: Claude Code, Codex, and
opencode each get a symlink to it.

## Versions

`nixpkgs` tracks the stable `26.05-darwin` branch. Stable freezes package
versions at release, which strands a tool that ships several times a week, so
`flake.nix` overlays **opencode alone** from `nixpkgs-unstable`. Nothing else
comes from unstable.

Rust has the same problem for the same reason: stable nixpkgs pins `rustc`
1.95.0, three releases behind upstream. The `rust-overlay` input supplies the
current stable toolchain instead, still pinned by `flake.lock`. Update it with
`nix flake update rust-overlay && ./rebuild.sh`.

`home.nix` declares the ambient toolchain only. A project needing a specific
version ships its own `flake.nix` with a `devShell`, which keeps the pin
reproducible in CI as well; `rust-toolchain.toml` on its own does nothing here,
because no `rustup` shim intercepts `cargo`. For the same reason, prefer adding
Rust CLI tools to `home.packages` over `cargo install`, which would write
unmanaged binaries to `~/.cargo/bin`.

## Manual steps

Nix cannot set these:

- Map caps lock to control: System Settings > Keyboard > Modifier Keys.
- Mouse: thumb buttons to desktop left/right, wheel to Mission Control, top
  button to screen capture.

Key repeat rate, dark mode, dock auto-hide, and Finder defaults are all declared
in `configuration.nix`.

## Credit

The Nix setup began as a fork of [kunchenguid/dotfiles](https://github.com/kunchenguid/dotfiles) (MIT-0).
The git aliases came from Tullie Murrell's dotfiles.
