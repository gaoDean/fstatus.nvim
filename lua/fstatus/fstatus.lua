local window = require("fstatus.window")
local config = require("fstatus.config")

local M = {}

-- local function in_git_repo()
--   local code = vim.fn.systemlist("if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then echo 0; else echo 1; fi")[1]
--   return code == "1"
-- end

-- -- if in git repo return relative to git root
-- -- else return relative to home
-- function M.get_relative_path()
--   local in_git = in_git_repo()
--   if in_git then
--     local git_dir = vim.fn.systemlist("git rev-parse --show-prefix")[1]
--     local git_root = vim.fn.systemlist("basename $(git rev-parse --show-toplevel)")[1]
--     local branch = vim.fn.systemlist("git branch --show-current")[1]
--     return git_root .. "/" .. git_dir .. vim.fn.expand("%:t")
--   else
--     return vim.fn.expand("%:p:~")
--   end
-- end

-- return <parent_dir>/<file>
function M.get_relative_path()
  local path = vim.fn.expand("%:p")
  local parent_dir = vim.fn.fnamemodify(path, ":h:t")
  local file = vim.fn.fnamemodify(path, ":t")
  return parent_dir .. "/" .. file
end

local function create_new_win(fwin)
  local path = M.get_relative_path()
  local modified = fwin and vim.api.nvim_buf_get_option(0, "modified")
  local text = path .. (modified and " " .. config.modified or "")
  local text_width = #text
  local window_width = text_width + 2
  if fwin and vim.api.nvim_win_is_valid(fwin.win) then
    vim.api.nvim_win_close(fwin.win, { force = true })
  end
  local new_win = window.new_window("fstatus", {
    style = "minimal",
    relative = "editor",
    width = window_width,
    height = 1,
    row = 0,
    col = vim.o.columns - window_width - 1,
    focusable = false,
    noautocmd = true
  }, false)
  vim.api.nvim_buf_set_lines(new_win.buf, 0, 1, false, { " " .. text })
  if modified then
    vim.api.nvim_buf_add_highlight(
      new_win.buf,
      -1,
      config.modified_highlight,
      0,
      text_width - string.len(config.modified),
      -1
    )
  end
  return new_win
end

function M.create()
  local fwin = create_new_win()
  vim.api.nvim_create_autocmd({"BufEnter", "BufModifiedSet"}, {
    callback = function()
      fwin = create_new_win(fwin)
    end
  })
end

return M
