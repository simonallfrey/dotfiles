-- Fold "conversation logs" into speaker blocks like:
--   Someone said:
--   <lines...>
--   Another Person said:
--   ======
--
-- Fold text shows: "Speaker said: <first line of what they said>"
--
-- Keymaps:
--   <leader>cl  -> enable + fold (zM)
--   <leader>cL  -> enable + unfold (zR)
--
-- Commands:
--   :ChatLogFoldsOn
--   :ChatLogFoldsOpen

-- Any speaker header line of the form: "<anything> said:"
local SPEAKER_RE = "^(.+)%s+said:%s*$"

-- Separator lines like "======" or longer
local DELIM_RE = "^=+$"

_G.chatlog_foldexpr = function(lnum)
  local line = vim.fn.getline(lnum)

  if line:match(DELIM_RE) then
    return 0
  end

  if line:match(SPEAKER_RE) then
    return 1
  end

  for i = lnum - 1, 1, -1 do
    local up = vim.fn.getline(i)
    if up:match(DELIM_RE) then
      return 0
    end
    if up:match(SPEAKER_RE) then
      return 1
    end
  end

  return 0
end

_G.chatlog_foldtext = function()
  local fs = vim.v.foldstart
  local fe = vim.v.foldend

  local speaker = vim.fn.getline(fs):gsub("%s+$", "")
  local prefix = speaker:gsub(":%s*$", ":")

  local first = ""
  for l = fs + 1, fe do
    local s = vim.fn.getline(l)
    if not s:match "^%s*$" and not s:match(DELIM_RE) and not s:match(SPEAKER_RE) then
      first = s:gsub("^%s+", ""):gsub("%s+$", "")
      break
    end
  end

  if first == "" then
    return prefix
  end

  return prefix .. " " .. first
end

local function enable_chatlog_folds(opts)
  opts = opts or {}
  local start_folded = opts.start_folded
  if start_folded == nil then
    start_folded = true
  end

  vim.opt_local.foldmethod = "expr"
  vim.opt_local.foldexpr = "v:lua.chatlog_foldexpr(v:lnum)"
  vim.opt_local.foldtext = "v:lua.chatlog_foldtext()"
  vim.opt_local.foldenable = true
  vim.opt_local.foldlevel = start_folded and 0 or 99
end

vim.api.nvim_create_user_command("ChatLogFoldsOn", function()
  enable_chatlog_folds { start_folded = true }
  vim.cmd "normal! zM"
end, {})

vim.api.nvim_create_user_command("ChatLogFoldsOpen", function()
  enable_chatlog_folds { start_folded = false }
  vim.cmd "normal! zR"
end, {})

vim.keymap.set("n", "<leader>cl", "<cmd>ChatLogFoldsOn<cr>", { desc = "Chat log: fold by speaker" })
vim.keymap.set("n", "<leader>cL", "<cmd>ChatLogFoldsOpen<cr>", { desc = "Chat log: unfold (open) all" })

return {}
