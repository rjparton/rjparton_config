-- nvim 0.12 ships the markdown treesitter parsers, so no nvim-treesitter dependency is needed
return {
  {
    'MeanderingProgrammer/render-markdown.nvim',
    ft = 'markdown',
    cmd = 'RenderMarkdown',  -- so :RenderMarkdown log is reachable before a .md file is open
    opts = {
      sign = { enabled = false },   -- signs open and close the sign column while scrolling, shifting the text
      html = { enabled = false },   -- no parser for these three, so they only add checkhealth noise
      latex = { enabled = false },
      yaml = { enabled = false },
      heading = {
        width = 'block',  -- background stops at the text, not the window edge
        left_pad = 2,
        right_pad = 2,
      },
      code = {
        width = 'block',
        left_pad = 2,
        right_pad = 2,
      },
    },
    keys = { { '<leader>m', '<cmd>RenderMarkdown buf_toggle<cr>', ft = 'markdown', desc = 'Toggle Markdown Render' } },
  },
}
