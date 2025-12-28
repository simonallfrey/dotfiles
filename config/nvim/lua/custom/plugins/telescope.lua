return {
  --   'nvim-telescope/telescope.nvim',
  --   opts = function(_, opts)
  --     local actions = require 'telescope.actions'
  --
  --     -- We merge our custom mappings into the existing ones
  --     opts.defaults = vim.tbl_deep_extend('force', opts.defaults or {}, {
  --       mappings = {
  --         i = {
  --           ['<C-j>'] = actions.move_selection_next,
  --           ['<C-k>'] = actions.move_selection_previous,
  --           ['<C-y>'] = actions.select_default, -- Consistency with your completion muscle memory
  --         },
  --       },
  --     })
  --   end,
}
