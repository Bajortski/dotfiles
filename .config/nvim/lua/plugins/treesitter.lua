local LAZY_FILE = { "BufReadPost", "BufNewFile", "BufWritePre" }

return {

  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    version = false,
    build = ":TSUpdate",
    event = { LAZY_FILE[1], LAZY_FILE[2], "VeryLazy" },
    cmd = { "TSUpdate", "TSInstall", "TSLog", "TSUninstall" },
    opts_extend = { "ensure_installed" },
    opts = {
      ensure_installed = {
        "bash",
        "c",
        "css",
        "diff",
        "html",
        "javascript",
        "jsdoc",
        "json",
        "lua",
        "luadoc",
        "luap",
        "markdown",
        "markdown_inline",
        "printf",
        "python",
        "query",
        "regex",
        "toml",
        "tsx",
        "typescript",
        "vim",
        "vimdoc",
        "xml",
        "yaml",
      },
    },
    config = function(_, opts)
      local ts = require("nvim-treesitter")
      ts.setup(opts)

      -- main branch: setup() does NOT install parsers from ensure_installed.
      -- Install any that are missing (async, idempotent).
      local installed = ts.get_installed()
      local missing = vim.tbl_filter(function(lang)
        return not vim.tbl_contains(installed, lang)
      end, opts.ensure_installed or {})
      if #missing > 0 then
        ts.install(missing)
      end

      -- Enable highlight, indent, and folds per filetype
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("user_treesitter", { clear = true }),
        callback = function(ev)
          local lang = vim.treesitter.language.get_lang(ev.match)
          if not lang then return end
          local ok = pcall(vim.treesitter.start, ev.buf)
          if not ok then return end

          -- Indent
          if vim.tbl_contains({ "markdown", "text", "tex", "plaintex" }, ev.match) then
            -- Prose: copy the previous line's indentation via 'autoindent'.
            -- Treesitter has no useful indent here and would flatten nesting.
            vim.bo[ev.buf].indentexpr = ""
          else
            -- Code: use treesitter's real indent expression (the previous value
            -- returned a node-type string, which coerced to 0 and broke indent).
            vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end

          -- Folds
	  vim.wo.foldenable = false
          vim.wo.foldmethod = "expr"
          vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
	  vim.wo.foldlevel = 99

	  -- Conceal for Markdown
 	  if ev.match == "markdown" then
	    vim.opt_local.conceallevel = 2
	  end
        end,
      })
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    event = "VeryLazy",
    config = function()
      local to = require("nvim-treesitter-textobjects")
      to.setup({})

      -- Buffer-local move keymaps
      local moves = {
        goto_next_start     = { ["]f"] = "@function.outer", ["]c"] = "@class.outer", ["]a"] = "@parameter.inner" },
        goto_next_end       = { ["]F"] = "@function.outer", ["]C"] = "@class.outer", ["]A"] = "@parameter.inner" },
        goto_previous_start = { ["[f"] = "@function.outer", ["[c"] = "@class.outer", ["[a"] = "@parameter.inner" },
        goto_previous_end   = { ["[F"] = "@function.outer", ["[C"] = "@class.outer", ["[A"] = "@parameter.inner" },
      }

      local function attach(buf)
        local ft = vim.bo[buf].filetype
        local lang = vim.treesitter.language.get_lang(ft)
        if not lang then return end

        for method, keymaps in pairs(moves) do
          for key, query in pairs(keymaps) do
            vim.keymap.set({ "n", "x", "o" }, key, function()
              require("nvim-treesitter-textobjects.move")[method](query, "textobjects")
            end, { buffer = buf, silent = true, desc = method:gsub("_", " ") .. " " .. query })
          end
        end
      end

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("user_ts_textobjects", { clear = true }),
        callback = function(ev) attach(ev.buf) end,
      })
      vim.tbl_map(attach, vim.api.nvim_list_bufs())
    end,
  },

  -- Auto-close HTML/JSX tags
  {
    "windwp/nvim-ts-autotag",
    event = LAZY_FILE,
    opts = {},
  },
}
