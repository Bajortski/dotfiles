return {
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufNewFile", "BufWritePre" },
    opts = {
      -- Events that trigger linting.
      events = { "BufWritePost", "BufReadPost", "InsertLeave" },
      -- Linters keyed by filetype. Binaries are installed via mason (see below).
      -- Use "*" to run linters on all filetypes, "_" for filetypes that have no
      -- other linters configured.
      linters_by_ft = {
        python   = { "ruff" },
        markdown = { "markdownlint" },
        css      = { "stylelint" },
        scss     = { "stylelint" },
        sh       = { "shellcheck" },
        bash     = { "shellcheck" },
        yaml     = { "yamllint" },
      },
      -- Override linter options or add custom linters. A linter may define a
      -- `condition(ctx)` to dynamically enable/disable itself, e.g.:
      --   stylelint = {
      --     condition = function(ctx)
      --       return vim.fs.find({ ".stylelintrc" }, { path = ctx.filename, upward = true })[1]
      --     end,
      --   }
      ---@type table<string,table>
      linters = {},
    },
    config = function(_, opts)
      local lint = require("lint")

      -- Merge any user linter overrides (supports prepend_args).
      for name, linter in pairs(opts.linters) do
        if type(linter) == "table" and type(lint.linters[name]) == "table" then
          lint.linters[name] = vim.tbl_deep_extend("force", lint.linters[name], linter)
          if type(linter.prepend_args) == "table" then
            lint.linters[name].args = lint.linters[name].args or {}
            vim.list_extend(lint.linters[name].args, linter.prepend_args)
          end
        else
          lint.linters[name] = linter
        end
      end
      lint.linters_by_ft = opts.linters_by_ft

      local function debounce(ms, fn)
        local timer = vim.uv.new_timer()
        return function(...)
          local argv = { ... }
          timer:start(ms, 0, function()
            timer:stop()
            vim.schedule_wrap(fn)(unpack(argv))
          end)
        end
      end

      local function run_lint()
        -- nvim-lint's own resolution: checks the full filetype first, then
        -- splits on "." and adds all matching linters.
        local names = lint._resolve_linter_by_ft(vim.bo.filetype)
        names = vim.list_extend({}, names)

        -- Fallback linters for filetypes with none configured.
        if #names == 0 then
          vim.list_extend(names, lint.linters_by_ft["_"] or {})
        end
        -- Global linters (run on every filetype).
        vim.list_extend(names, lint.linters_by_ft["*"] or {})

        local ctx = { filename = vim.api.nvim_buf_get_name(0) }
        ctx.dirname = vim.fn.fnamemodify(ctx.filename, ":h")
        names = vim.tbl_filter(function(name)
          local linter = lint.linters[name]
          if not linter then
            vim.notify("Linter not found: " .. name, vim.log.levels.WARN, { title = "nvim-lint" })
            return false
          end
          -- Skip linters whose binary isn't present yet (e.g. mason still
          -- installing), and respect any `condition`. `cmd` may be a function
          -- (resolved at runtime), so only probe it when it's a string.
          local cmd = type(linter) == "table" and linter.cmd or nil
          if type(cmd) == "function" then
            cmd = cmd()
          end
          if type(cmd) == "string" and vim.fn.executable(cmd) ~= 1 then
            return false
          end
          return not (type(linter) == "table" and linter.condition and not linter.condition(ctx))
        end, names)

        if #names > 0 then
          lint.try_lint(names)
        end
      end

      vim.api.nvim_create_autocmd(opts.events, {
        group = vim.api.nvim_create_augroup("user_nvim_lint", { clear = true }),
        callback = debounce(100, run_lint),
      })
    end,
  },

  -- Install the linter binaries through mason.
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "ruff",
        "markdownlint",
        "stylelint",
        "shellcheck",
        "yamllint",
      },
    },
  },
}
