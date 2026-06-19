-- Diagnostic icons (nerd font)
local icons = {
  Error = " ",
  Warn  = " ",
  Hint  = " ",
  Info  = " ",
}

-- Helper: check if LSP client supports a method
local function has_capability(buf, method)
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = buf })) do
    if client:supports_method(method) then
      return true
    end
  end
  return false
end

-- Wire up LSP keymaps on attach
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("user_lsp_keymaps", { clear = true }),
  callback = function(args)
    local buf = args.buf
    local map = function(modes, lhs, rhs, desc, extra)
      extra = extra or {}
      vim.keymap.set(modes, lhs, rhs, vim.tbl_extend("force", { buffer = buf, desc = desc }, extra))
    end

    map("n", "<leader>cl", function() Snacks.picker.lsp_config() end, "Lsp Info")
    map("n", "gd",         vim.lsp.buf.definition,                    "Goto Definition")
    map("n", "gr",         vim.lsp.buf.references,                    "References", { nowait = true })
    map("n", "gI",         vim.lsp.buf.implementation,                "Goto Implementation")
    map("n", "gy",         vim.lsp.buf.type_definition,               "Goto T[y]pe Definition")
    map("n", "gD",         vim.lsp.buf.declaration,                   "Goto Declaration")
    map("n", "K",          vim.lsp.buf.hover,                         "Hover")
    map("n", "<leader>cr", vim.lsp.buf.rename,                        "Rename")
    map("n", "<leader>cm", "<cmd>Mason<cr>",                          "Mason")

    if has_capability(buf, "signatureHelp") then
      map("n", "gK",   vim.lsp.buf.signature_help, "Signature Help")
      map("i", "<c-k>", vim.lsp.buf.signature_help, "Signature Help")
    end

    if has_capability(buf, "codeAction") then
      map({ "n", "x" }, "<leader>ca", vim.lsp.buf.code_action, "Code Action")
      map("n", "<leader>cA", function()
        vim.lsp.buf.code_action({ context = { only = { "source" }, diagnostics = {} } })
      end, "Source Action")
      map("n", "<leader>co", function()
        vim.lsp.buf.code_action({
          context = { only = { "source.organizeImports" }, diagnostics = {} },
          apply = true,
        })
      end, "Organize Imports")
    end

    if has_capability(buf, "codeLens") then
      map({ "n", "x" }, "<leader>cc", vim.lsp.codelens.run,     "Run Codelens")
      map("n",           "<leader>cC", vim.lsp.codelens.refresh, "Refresh & Display Codelens")
    end

    -- Reference jumping via Snacks if available
    local ok = pcall(require, "snacks")
    if ok and Snacks.words and Snacks.words.is_enabled() and has_capability(buf, "documentHighlight") then
      map("n", "]]",   function() Snacks.words.jump(vim.v.count1) end,  "Next Reference")
      map("n", "[[",   function() Snacks.words.jump(-vim.v.count1) end, "Prev Reference")
      map("n", "<a-n>", function() Snacks.words.jump(vim.v.count1, true) end,  "Next Reference")
      map("n", "<a-p>", function() Snacks.words.jump(-vim.v.count1, true) end, "Prev Reference")
    end

    -- Rename file via Snacks if available
    if ok then
      map("n", "<leader>cR", function() Snacks.rename.rename_file() end, "Rename File")
    end

    -- Format via conform.nvim (see plugins/conform.lua)
  end,
})

-- Inlay hints: enable on servers that support it
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("user_lsp_inlay_hints", { clear = true }),
  callback = function(args)
    local buf = args.buf
    if vim.bo[buf].buftype ~= "" then return end
    local exclude = { "vue" }
    if vim.tbl_contains(exclude, vim.bo[buf].filetype) then return end
    if has_capability(buf, "textDocument/inlayHint") then
      vim.lsp.inlay_hint.enable(true, { bufnr = buf })
    end
  end,
})

-- Codelens: refresh on supported buffers
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("user_lsp_codelens", { clear = true }),
  callback = function(args)
    local buf = args.buf
    if not has_capability(buf, "textDocument/codeLens") then return end
    vim.lsp.codelens.refresh()
    vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
      buffer = buf,
      callback = vim.lsp.codelens.refresh,
    })
  end,
})

-- Folding: enable LSP folding on supported buffers
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("user_lsp_folding", { clear = true }),
  callback = function(args)
    local buf = args.buf
    if not has_capability(buf, "textDocument/foldingRange") then return end
    local wo = vim.wo[vim.api.nvim_get_current_win()]
    if wo.foldmethod == "manual" then
      wo.foldmethod = "expr"
      wo.foldexpr   = "v:lua.vim.lsp.foldexpr()"
    end
  end,
})

return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "mason.nvim",
      { "mason-org/mason-lspconfig.nvim", config = function() end },
    },
    opts = function()
      return {
        diagnostics = {
          underline = true,
          update_in_insert = false,
          virtual_text = {
            spacing = 4,
            source = "if_many",
            prefix = "●",
          },
          severity_sort = true,
          signs = {
            text = {
              [vim.diagnostic.severity.ERROR] = icons.Error,
              [vim.diagnostic.severity.WARN]  = icons.Warn,
              [vim.diagnostic.severity.HINT]  = icons.Hint,
              [vim.diagnostic.severity.INFO]  = icons.Info,
            },
          },
        },
        -- Global LSP client capabilities
        capabilities = {
          workspace = {
            fileOperations = {
              didRename  = true,
              willRename = true,
            },
          },
        },
        -- Per-server settings. Add servers here as needed.
        servers = {
          lua_ls = {
            settings = {
              Lua = {
                workspace = { checkThirdParty = false },
                codeLens  = { enable = true },
                completion = { callSnippet = "Replace" },
                doc = { privateName = { "^_" } },
                hint = {
                  enable    = true,
                  setType   = false,
                  paramType = true,
                  paramName = "Disable",
                  semicolon = "Disable",
                  arrayIndex = "Disable",
                },
              },
            },
          },
        },
        -- Optional per-server setup overrides.
        -- Return true to skip automatic lspconfig setup for that server.
        ---@type table<string, fun(server: string, opts: vim.lsp.Config): boolean?>
        setup = {},
      }
    end,
    config = function(_, opts)
      -- Diagnostics
      vim.diagnostic.config(vim.deepcopy(opts.diagnostics))

      -- Per-server config (merge global capabilities into each server)
      local mason_lspconfig = require("mason-lspconfig")
      local mason_exclude = {}

      for server, sopts in pairs(opts.servers) do
        if sopts == false or (type(sopts) == "table" and sopts.enabled == false) then
          mason_exclude[#mason_exclude + 1] = server
        else
          sopts = sopts == true and {} or sopts
          -- Merge global capabilities
          sopts.capabilities = vim.tbl_deep_extend(
            "force",
            opts.capabilities or {},
            sopts.capabilities or {}
          )
          local setup_fn = opts.setup[server] or opts.setup["*"]
          if setup_fn and setup_fn(server, sopts) then
            mason_exclude[#mason_exclude + 1] = server
          else
            -- Configure the server; mason-lspconfig automatic_enable handles the rest
            vim.lsp.config(server, sopts)
          end
        end
      end

      mason_lspconfig.setup({
        automatic_enable = { exclude = mason_exclude },
      })
    end,
  },

  {
    "mason-org/mason.nvim",
    cmd = "Mason",
    keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
    build = ":MasonUpdate",
    opts_extend = { "ensure_installed" },
    opts = {
      ensure_installed = {
        "stylua",
        "shfmt",
      },
    },
    config = function(_, opts)
      require("mason").setup(opts)
      local mr = require("mason-registry")
      mr:on("package:install:success", function()
        vim.defer_fn(function()
          require("lazy.core.handler.event").trigger({
            event = "FileType",
            buf = vim.api.nvim_get_current_buf(),
          })
        end, 100)
      end)
      mr.refresh(function()
        for _, tool in ipairs(opts.ensure_installed) do
          local p = mr.get_package(tool)
          if not p:is_installed() then
            p:install()
          end
        end
      end)
    end,
  },
}
