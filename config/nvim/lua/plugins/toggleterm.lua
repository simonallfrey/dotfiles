return {
  "akinsho/toggleterm.nvim",
  opts = function(_, opts)
    opts = opts or {}
    opts.direction = "horizontal"
    opts.size = 15
    opts.open_mapping = [[<c-\>]]
    opts.start_in_insert = true
    opts.auto_scroll = true
    opts.persist_mode = true

    local prev_on_create = opts.on_create
    local prev_on_close = opts.on_close

    opts.on_create = function(t)
      if prev_on_create then prev_on_create(t) end

      local log_dir = vim.fn.expand "~/toggleterm_logs"
      vim.fn.mkdir(log_dir, "p")

      local timestamp = os.date "%Y-%m-%d_%H-%M-%S"
      local hostname = os.getenv "HOSTNAME" or vim.fn.systemlist("hostname -s")[1] or "unknown"

      local log_file = string.format("%s/term_%s_%s.log", log_dir, timestamp, hostname)

      vim.api.nvim_buf_set_name(t.bufnr, log_file)

      if vim.fn.filereadable(log_file) == 1 then
        local lines = vim.fn.readfile(log_file)
        vim.api.nvim_buf_set_lines(t.bufnr, 0, -1, false, lines)
      end

      local save_output = function(_, _, data, _)
        if data and #data > 0 then
          local current_log = vim.api.nvim_buf_get_name(t.bufnr)
          if current_log ~= "" then
            vim.fn.writefile(data, current_log, "a")
          end
        end
      end

      t.on_stdout = save_output
      t.on_stderr = save_output
    end

    opts.on_close = function(t)
      if prev_on_close then prev_on_close(t) end

      local log_file = vim.api.nvim_buf_get_name(t.bufnr)
      if log_file ~= "" then
        local lines = vim.api.nvim_buf_get_lines(t.bufnr, 0, -1, false)
        vim.fn.writefile(lines, log_file)
      end
    end

    return opts
  end,
}
