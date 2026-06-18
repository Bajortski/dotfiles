return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>cf",
        function()
          require("conform").format({ async = true, lsp_fallback = true })
        end,
        mode = { "n", "x" },
        desc = "Format",
      },
    },
    opts = {
      formatters_by_ft = {
        javascript      = { "prettier" },
        javascriptreact = { "prettier" },
        typescript      = { "prettier" },
        typescriptreact = { "prettier" },
        css             = { "prettier" },
        scss            = { "prettier" },
        html            = { "prettier" },
        json            = { "prettier" },
        jsonc           = { "prettier" },
        yaml            = { "prettier" },
        markdown        = { "prettier" },
        graphql         = { "prettier" },
        lua             = { "stylua" },
        sh              = { "shfmt" },
      },
      format_on_save = false,
    },
  },

  {
    "MunifTanjim/prettier.nvim",
    dependencies = { "stevearc/conform.nvim" },
    opts = {
      bin = "prettier",
      filetypes = {
        "css", "graphql", "html", "javascript", "javascriptreact",
        "json", "jsonc", "less", "markdown", "scss", "typescript",
        "typescriptreact", "yaml",
      },
    },
  },
}
