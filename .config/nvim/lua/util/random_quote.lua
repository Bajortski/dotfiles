local M = {}

local function wrap(text, width)
  local lines = {}
  local line = ""
  for word in text:gmatch("%S+") do
    if #line == 0 then
      line = word
    elseif #line + 1 + #word <= width then
      line = line .. " " .. word
    else
      table.insert(lines, line)
      line = word
    end
  end
  if #line > 0 then
    table.insert(lines, line)
  end
  return lines
end

function M.from_markdown(path)
  math.randomseed(os.time())

  local file = io.open(vim.fn.expand(path), "r")
  if not file then
    return "quotes.md not found."
  end

  local content = file:read("*a")
  file:close()

  local quotes = vim.split(content, "%s*|%s*", { trimempty = true })
  if #quotes == 0 then
    return "No quotes available."
  end

  local quote = vim.trim(quotes[math.random(#quotes)])
  return table.concat(wrap(quote, 80), "\n")
end

return M
