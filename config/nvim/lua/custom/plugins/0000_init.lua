-- ~/.config/nvim/lua/custom/plugins/0000_init.lua

-- Indentation
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.smartindent = true

-- Terminal scrollback — maximum practical value
vim.api.nvim_create_autocmd('TermOpen', {
  pattern = '*',
  callback = function()
    vim.opt_local.scrollback = -1 -- Unlimited (recommended)
    -- Or: vim.opt_local.scrollback = 100000  -- Hard max
  end,
})

-- Folding narrowing
vim.keymap.set('n', '<leader>n', ':v//fold<CR>zM', { desc = 'Narrow: fold non-matches' })
vim.keymap.set('n', '<leader>N', 'zR', { desc = 'Restore: open all folds' })

-- Folding defaults
vim.opt.foldmethod = 'manual'
vim.opt.foldenable = true
vim.opt.foldlevelstart = 99

-- Required to fix Lazy import error
return {}
