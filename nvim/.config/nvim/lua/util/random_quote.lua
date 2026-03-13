local M = {}

function M.from_markdown(path)
  local file = io.open(vim.fn.expand(path), "r")
  if not file then
    return { "quotes.md not found." }
  end

  local content = file:read("*a")
  file:close()

  local quotes = vim.split(content, "%s*|%s*", { trimempty = true })
  if #quotes == 0 then
    return { "No quotes available." }
  end

  local quote = quotes[math.random(#quotes)]
  return vim.split(vim.trim(quote), "\n")
end

return M
