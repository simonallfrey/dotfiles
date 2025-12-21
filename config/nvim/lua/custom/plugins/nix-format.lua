return {
  'stevearc/conform.nvim', -- The formatter plugin
  opts = {
    formatters_by_ft = {
      nix = { 'nixfmt' }, -- Uses 'nixfmt' command
    },
    format_on_save = {
      timeout_ms = 500,
      lsp_fallback = true,
    },
  },
}
