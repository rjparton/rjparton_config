-- Language servers, using Neovim's built-in LSP client (0.11+). No plugin:
-- nvim-lspconfig exists to ship definitions for ~300 servers, which is a
-- dependency for nothing when you run one.
--
-- Servers come from home.nix, so `cmd` is a bare name and PATH resolves it.
-- rust-analyzer is the exception: PATH finds a rustup shim, which resolves a
-- toolchain from the working directory. See the `cmd` below for why that has
-- to be the workspace root.
--
-- One consequence, once the pin is honoured: a repo pinning
-- `profile = "minimal"` has no rust-analyzer in its toolchain, so the shim
-- fails and no server attaches, while cargo keeps working. It says
-- `rust-analyzer is unavailable for the active toolchain` on stderr, which
-- goes to `:LspLog` rather than a notification, so it looks like silence.
-- Fix with `rustup component add rust-analyzer rust-src --toolchain <version>`.
--
-- Neovim already binds the usual actions once a server attaches, so there are
-- no keymaps here: K hover, grn rename, gra code action, grr references,
-- gri implementation, grt type definition, gO document symbols. `gd` comes
-- from the Snacks picker in plugins/navigation.lua.

-- Ask cargo where the workspace root is rather than guessing from marker
-- files. Guessing with `root_markers` finds the *nearest* Cargo.toml, which in
-- a workspace starts one server per member crate, each redundantly indexing
-- the whole workspace. Not calling `on_dir` skips activation, which is what a
-- .rs file belonging to no crate should get: rust-analyzer can do nothing with
-- one but report a failure to load.
--
-- Asynchronous because `on_dir` is a callback and blocking is therefore free
-- to avoid. `:wait()` here would freeze the editor for as long as cargo takes.
local function cargo_workspace_root(buffer, on_dir)
  local buffer_name = vim.api.nvim_buf_get_name(buffer)
  local buffer_directory = vim.fs.dirname(buffer_name)

  -- Unnamed buffers, and scheme-prefixed ones such as the `diffview://` paths
  -- neogit opens, have no real directory. Handing either to `vim.system` as a
  -- cwd raises ENOENT rather than returning an error code.
  if buffer_name == '' or not vim.uv.fs_stat(buffer_directory) then
    return
  end

  vim.system(
    { 'cargo', 'metadata', '--no-deps', '--format-version', '1' },
    { cwd = buffer_directory, text = true },
    function(metadata)
      if metadata.code ~= 0 then
        -- No manifest anywhere above is the ordinary case for a loose .rs
        -- file, so it stays quiet. Anything else is a real problem, usually a
        -- malformed Cargo.toml, and saying nothing would leave the language
        -- server mysteriously dead.
        if not metadata.stderr:find('could not find `Cargo.toml`', 1, true) then
          vim.schedule(function()
            vim.notify(metadata.stderr, vim.log.levels.WARN)
          end)
        end
        return
      end

      local decoded_ok, metadata_json = pcall(vim.json.decode, metadata.stdout)
      if not decoded_ok or type(metadata_json) ~= 'table' or not metadata_json.workspace_root then
        return
      end

      vim.schedule(function()
        on_dir(metadata_json.workspace_root)
      end)
    end
  )
end

vim.lsp.config('rust_analyzer', {
  -- Spawned at the workspace root rather than wherever nvim was started, so
  -- the rustup shim resolves this repo's rust-toolchain.toml. A table `cmd`
  -- would inherit nvim's cwd, and the shim would then pick the default
  -- toolchain and export RUSTUP_TOOLCHAIN to every cargo it runs, which beats
  -- the toolchain file. Editing a pinned repo from a nvim started elsewhere
  -- would silently check against the wrong compiler.
  cmd = function(dispatchers, config)
    -- Asserted because a nil cwd is not an error to vim.lsp.rpc.start, it
    -- silently inherits nvim's, which is the bug this exists to prevent.
    local workspace_root = assert(config.root_dir, 'rust_analyzer: no workspace root')
    return vim.lsp.rpc.start({ 'rust-analyzer' }, dispatchers, { cwd = workspace_root })
  end,
  filetypes = { 'rust' },
  root_dir = cargo_workspace_root,
  settings = {
    ['rust-analyzer'] = {
      -- Squiggles from clippy, not just rustc. Clippy is the best Rust teacher
      -- available and this puts it in the editor instead of a terminal.
      check = { command = 'clippy' },
      -- Its own target directory. Otherwise every save takes the lock on
      -- target/ and blocks the `cargo run` in your other terminal, and the two
      -- fingerprint crates differently so they rebuild each other's work.
      -- Costs disk, saves a stall on every save.
      cargo = { targetDir = true },
      -- Type and parameter hints are on by default. These three are not, and
      -- each shows something a Rust beginner otherwise has to infer: how a
      -- pattern bound its variable, where a lifetime was elided, and what a
      -- block-bodied closure returns. Deliberately omitted:
      -- expressionAdjustmentHints, which marks every implicit reborrow and so
      -- fires on nearly every line of iterator code.
      inlayHints = {
        bindingModeHints = { enable = true },
        lifetimeElisionHints = { enable = 'skip_trivial' },
        closureReturnTypeHints = { enable = 'with_block' },
      },
    },
  },
})

vim.lsp.enable('rust_analyzer')

-- Errors at the end of the line as you type. The default shows a gutter sign
-- and an underline, which tells you something is wrong but not what.
-- Clippy's messages run to several lines including a docs URL, so only the
-- first line goes inline; `<leader>d` shows the whole thing, `]d` and `[d`
-- jump between them. The pattern ends in `*` rather than `+` so an empty
-- message yields an empty string: returning nil drops the diagnostic silently.
vim.diagnostic.config({
  severity_sort = true,
  virtual_text = {
    spacing = 2,
    format = function(diagnostic)
      return diagnostic.message:match('^[^\n]*')
    end,
  },
})

vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float, { desc = 'Show Full Diagnostic' })

-- Inferred types shown inline. This is most of the value of running a language
-- server while learning a statically typed language.
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client:supports_method('textDocument/inlayHint') then
      vim.lsp.inlay_hint.enable(true, { bufnr = event.buf })
    end
  end,
})
