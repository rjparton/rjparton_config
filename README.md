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

Rust is the exception to Nix supplying the tool itself. `home.nix` installs `rustup` and
nothing else; the toolchains it downloads live in `~/.rustup`, outside the store
and outside this repo. That is a deliberate trade. A repo's `rust-toolchain.toml`
has to be honoured, because its CI reads the same file, and an ambient toolchain
of a different version makes local `cargo fmt --check` and `cargo clippy` results
disagree with CI. A Nix-built toolchain ignores that file entirely; a `rustup`
shim is what reads it.

So the version is a per-repo question, and `rustup` switches on `cd`. Update the
toolchains with `rustup update`, not `nix flake update`. The default toolchain
floats with upstream stable rather than being pinned here, which is the cost of
this arrangement: what `rustup` holds is not reproducible from a rebuild, so it
is listed under [Manual steps](#manual-steps).

Prefer adding Rust CLI tools to `home.packages` over `cargo install`. `rustup`
from nixpkgs puts its shims in the Nix profile, so nothing here needs
`~/.cargo/bin` and it does not exist until a `cargo install` creates it. A
binary installed there is then invisible to the shell, which never has that
directory on `PATH`, but visible to anything a rustup shim spawns, because a
shim prepends it for its children. Unmanaged and half-reachable is worse than
either, so keep tools in `home.packages`.

## Manual steps

Nix cannot set these:

- Install a Rust toolchain. Nix provides `rustup`, but nothing it downloads, so
  until this runs `rustc` is on `PATH` and errors:

  ```bash
  rustup default stable
  rustup component add rust-analyzer rust-src clippy rustfmt
  ```

  A repo whose `rust-toolchain.toml` sets `profile = "minimal"` gets its own
  toolchain without `rust-analyzer`, and the editor LSP then dies silently in
  that repo while `cargo` keeps working. Add the components per toolchain:
  `rustup component add rust-analyzer rust-src --toolchain <version>`.
- Map caps lock to control: System Settings > Keyboard > Modifier Keys.
- Mouse: thumb buttons to desktop left/right, wheel to Mission Control, top
  button to screen capture.

Key repeat rate, dark mode, dock auto-hide, and Finder defaults are all declared
in `configuration.nix`.

## Credit

The Nix setup began as a fork of [kunchenguid/dotfiles](https://github.com/kunchenguid/dotfiles) (MIT-0).
The git aliases came from Tullie Murrell's dotfiles.
