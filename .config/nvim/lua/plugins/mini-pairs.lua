-- Automatically insert the matching closing quote/bracket/paren when you type
-- the opening one, with smart skipping (treesitter strings, unbalanced pairs,
-- markdown code fences). Toggle with <leader>up.
return {
  "nvim-mini/mini.pairs",
  event = "VeryLazy",
  opts = {
    modes = { insert = true, command = true, terminal = false },
    -- skip autopair when next character is one of these
    skip_next = [=[[%w%%%'%[%"%.%`%$]]=],
    -- skip autopair when the cursor is inside these treesitter nodes
    skip_ts = { "string" },
    -- skip autopair when next character is closing pair
    -- and there are more closing pairs than opening pairs
    skip_unbalanced = true,
    -- better deal with markdown code blocks
    markdown = true,
  },
  config = function(_, opts)
    Snacks.toggle({
      name = "Mini Pairs",
      get = function()
        return not vim.g.minipairs_disable
      end,
      set = function(state)
        vim.g.minipairs_disable = not state
      end,
    }):map("<leader>up")

    local pairs = require("mini.pairs")
    pairs.setup(opts)
    local open = pairs.open
    pairs.open = function(pair, neigh_pattern)
      if vim.fn.getcmdline() ~= "" then
        return open(pair, neigh_pattern)
      end
      local o, c = pair:sub(1, 1), pair:sub(2, 2)
      local line = vim.api.nvim_get_current_line()
      local cursor = vim.api.nvim_win_get_cursor(0)
      local next = line:sub(cursor[2] + 1, cursor[2] + 1)
      local before = line:sub(1, cursor[2])
      if opts.markdown and o == "`" and vim.bo.filetype == "markdown" and before:match("^%s*``") then
        return "`\n```" .. vim.api.nvim_replace_termcodes("<up>", true, true, true)
      end
      if opts.skip_next and next ~= "" and next:match(opts.skip_next) then
        return o
      end
      if opts.skip_ts and #opts.skip_ts > 0 then
        local ok, captures = pcall(vim.treesitter.get_captures_at_pos, 0, cursor[1] - 1, math.max(cursor[2] - 1, 0))
        for _, capture in ipairs(ok and captures or {}) do
          if vim.tbl_contains(opts.skip_ts, capture.capture) then
            return o
          end
        end
      end
      if opts.skip_unbalanced and next == c and c ~= o then
        local _, count_open = line:gsub(vim.pesc(pair:sub(1, 1)), "")
        local _, count_close = line:gsub(vim.pesc(pair:sub(2, 2)), "")
        if count_close > count_open then
          return o
        end
      end
      return open(pair, neigh_pattern)
    end

    -- Backspace inside an EMPTY html/jsx tag pair (`<div>|</div>`) deletes both
    -- tags at once. Anywhere else, fall through to MiniPairs' own backspace.
    local START = { start_tag = true, jsx_opening_element = true }
    local END = { end_tag = true, jsx_closing_element = true }

    -- Returns {srow, scol, erow, ecol} (0-based) of the empty element under the
    -- cursor, or nil when the cursor isn't sitting in an empty tag pair.
    local function empty_tag_range()
      local got, range = pcall(function()
        local cur = vim.api.nvim_win_get_cursor(0)
        local row, col = cur[1] - 1, cur[2]
        local node = vim.treesitter.get_node({ pos = { row, col } })
        while node and node:type() ~= "element" and node:type() ~= "jsx_element" do
          node = node:parent()
        end
        if not node then
          return nil
        end
        local start_tag, end_tag
        for child in node:iter_children() do
          if START[child:type()] then
            start_tag = child
          elseif END[child:type()] then
            end_tag = child
          end
        end
        if not start_tag or not end_tag then
          return nil
        end
        -- Empty iff the start tag ends exactly where the end tag begins.
        local _, _, s_er, s_ec = start_tag:range()
        local e_sr, e_sc = end_tag:range()
        if s_er ~= e_sr or s_ec ~= e_sc then
          return nil
        end
        -- Only act when the cursor is actually at that gap.
        if row ~= s_er or col ~= s_ec then
          return nil
        end
        local sr, sc, er, ec = node:range()
        return { sr, sc, er, ec }
      end)
      return got and range or nil
    end

    vim.keymap.set("i", "<BS>", function()
      local r = empty_tag_range()
      if r then
        vim.schedule(function()
          vim.api.nvim_buf_set_text(0, r[1], r[2], r[3], r[4], { "" })
          vim.api.nvim_win_set_cursor(0, { r[1] + 1, r[2] })
        end)
        return ""
      end
      return require("mini.pairs").bs()
    end, { expr = true, replace_keycodes = false, desc = "Delete empty tag pair / MiniPairs <BS>" })
  end,
}
