-- Shift-Tab on a list line indents the whole line instead of dropping a tab
-- character at the cursor. autolist ships this as :AutolistTab, but it only
-- fires when the cursor is on the line's last character — press it mid-word and
-- you get a literal tab wedged into the text. This works wherever the cursor is.
-- Wired in lua/plugins/blink.lua, since blink owns the key globally; a
-- buffer-local map would shadow its completion and cotyper's ghost entirely.

local api = vim.api

local M = {}

--- The list patterns autolist tracks for this buffer's filetype, or nil when the
--- filetype has no lists (so Shift-Tab is left alone everywhere else).
local function patterns_for(buf)
  local ok, config = pcall(require, "autolist.config")
  if not ok then
    return nil
  end
  return config.lists[vim.bo[buf].filetype]
end

--- True when the cursor line is a list item: bullet, ordered, checkbox, \item —
--- whatever autolist recognises for the filetype.
---@param buf integer|nil
---@return boolean
function M.on_list_line(buf)
  buf = buf or api.nvim_get_current_buf()
  local pats = patterns_for(buf)
  if not pats then
    return false
  end
  local is_list = require("autolist.utils").is_list(api.nvim_get_current_line(), pats)
  return is_list == true
end

--- Row of the enclosing list item — the nearest line above `row` that is a list
--- item indented less than `width`. Renumbering has to start there: a demoted
--- item leaves a hole in its old scope (3, 4 -> 3 becomes a child, 4 must become
--- 3), and autolist only ever recalculates downward from the cursor's own scope.
---@return integer
local function parent_row(row, width, pats)
  for r = row - 1, 1, -1 do
    local line = api.nvim_buf_get_lines(0, r - 1, r, false)[1]
    if not line or not (require("autolist.utils").is_list(line, pats) == true) then
      break
    end
    if vim.fn.strdisplaywidth(line:match("^[ \t]*")) < width then
      return r
    end
  end
  return row
end

--- Add one level of indent to the current line, leaving the cursor on the same
--- character. Mirrors insert-mode <C-t>, including its rounding up to the next
--- multiple of 'shiftwidth'.
function M.indent()
  local sw = vim.fn.shiftwidth()
  local line = api.nvim_get_current_line()
  local ws = line:match("^[ \t]*")
  local width = math.floor(vim.fn.strdisplaywidth(ws) / sw + 1) * sw

  local new_ws
  if vim.bo.expandtab then
    new_ws = string.rep(" ", width)
  else
    local ts = vim.bo.tabstop
    new_ws = string.rep("\t", math.floor(width / ts)) .. string.rep(" ", width % ts)
  end

  local row, col = unpack(api.nvim_win_get_cursor(0))
  local body = line:sub(#ws + 1)
  api.nvim_set_current_line(new_ws .. body)
  -- Track the character, not the column, so the cursor doesn't drift out of the
  -- word being typed.
  col = math.max(col + #new_ws - #ws, 0)
  api.nvim_win_set_cursor(0, { row, col })

  -- Demoting an item starts a new numbering scope; ordered lists need redoing.
  local pats = patterns_for(api.nvim_get_current_buf())
  if not pats then
    return
  end
  local tail = #api.nvim_get_current_line() - col -- markers renumber from the left
  local from = parent_row(row, width, pats)
  api.nvim_win_set_cursor(0, { from, 0 })
  pcall(function()
    require("autolist.auto").recalculate()
  end)
  local final = api.nvim_buf_get_lines(0, row - 1, row, false)[1] or ""
  api.nvim_win_set_cursor(0, { row, math.max(#final - tail, 0) })
end

--- Indent when the cursor sits on a list line. Returns true when it handled the
--- key, so it can be dropped into a blink.cmp keymap chain.
---@return boolean
function M.maybe_indent()
  if not M.on_list_line() then
    return false
  end
  M.indent()
  return true
end

return M
