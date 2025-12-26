-- lua/custom/plugins/100_toggleterm.lua (or any filename in custom/plugins/)

return {
  'akinsho/toggleterm.nvim',
  version = '*',
  opts = {
    direction = 'horizontal',
    size = 15,
    open_mapping = [[<c-\>]],
    start_in_insert = true,
    auto_scroll = true,
    persist_mode = true,

    -- Create timestamped + hostname logfile
    on_create = function(t)
      local log_dir = vim.fn.expand '~/toggleterm_logs'
      vim.fn.mkdir(log_dir, 'p')

      local timestamp = os.date '%Y-%m-%d_%H-%M-%S'
      local hostname = os.getenv 'HOSTNAME' or vim.fn.systemlist('hostname -s')[1] or 'unknown'

      local log_file = string.format('%s/term_%s_%s.log', log_dir, timestamp, hostname)

      vim.api.nvim_buf_set_name(t.bufnr, log_file)

      -- Load existing log if it exists
      if vim.fn.filereadable(log_file) == 1 then
        local lines = vim.fn.readfile(log_file)
        vim.api.nvim_buf_set_lines(t.bufnr, 0, -1, false, lines)
      end

      -- Save incrementally whenever the shell outputs something
      local save_output = function(_, _, data, _)
        if data and #data > 0 then
          local current_log = vim.api.nvim_buf_get_name(t.bufnr)
          if current_log ~= '' then
            vim.fn.writefile(data, current_log, 'a') -- append new lines
          end
        end
      end

      t.on_stdout = save_output
      t.on_stderr = save_output -- capture errors too
    end,

    -- Final full save on close/hide (safety net)
    on_close = function(t)
      local log_file = vim.api.nvim_buf_get_name(t.bufnr)
      if log_file ~= '' then
        local lines = vim.api.nvim_buf_get_lines(t.bufnr, 0, -1, false)
        vim.fn.writefile(lines, log_file)
      end
    end,
  },
}
