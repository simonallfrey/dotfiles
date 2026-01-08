return {
  "stevearc/conform.nvim",
  opts = function(_, opts)
    opts = opts or {}
    opts.formatters_by_ft = vim.tbl_deep_extend("force", opts.formatters_by_ft or {}, {
      nix = { "nixfmt" },
    })

    if opts.format_on_save == nil then
      opts.format_on_save = { timeout_ms = 500, lsp_fallback = true }
    elseif type(opts.format_on_save) == "table" then
      opts.format_on_save = vim.tbl_deep_extend("force", opts.format_on_save, {
        timeout_ms = 500,
        lsp_fallback = true,
      })
    end

    return opts
  end,
}
