local build_cmd ---@type string?
for _, cmd in ipairs({ "make", "cmake", "gmake" }) do
  if vim.fn.executable(cmd) == 1 then
    build_cmd = cmd
    break
  end
end

-- Helper: get project root
local function get_root()
  return vim.fs.root(0, { ".git", ".hg", ".svn" }) or vim.fn.getcwd()
end

-- Helper: wraps a telescope builtin into a callable, rooted unless root=false
local function pick(builtin, opts)
  opts = opts or {}
  return function()
    local o = vim.deepcopy(opts)
    o.follow = o.follow ~= false
    if o.root ~= false then
      o.cwd = get_root()
    end
    o.root = nil

    -- If cwd differs from actual cwd, attach <a-c> to reopen without root
    if o.cwd and o.cwd ~= vim.uv.cwd() then
      local base_attach = o.attach_mappings
      o.attach_mappings = function(bufnr, map)
        map("i", "<a-c>", function()
          local line = require("telescope.actions.state").get_current_line()
          pick(builtin, vim.tbl_extend("force", opts, { root = false, default_text = line }))()
        end, { desc = "Open cwd Directory" })
        if base_attach then return base_attach(bufnr, map) end
        return true
      end
    end

    require("telescope.builtin")[builtin](o)
  end
end

-- Helper: find config files
local function config_files()
  return function()
    require("telescope.builtin").find_files({ cwd = vim.fn.stdpath("config") })
  end
end

return {
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    version = false,
    dependencies = {
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = (build_cmd ~= "cmake") and "make"
          or "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
        enabled = build_cmd ~= nil,
        config = function(plugin)
          local function load_fzf()
            local ok, err = pcall(require("telescope").load_extension, "fzf")
            if not ok then
              local lib = plugin.dir .. "/build/libfzf." .. (vim.fn.has("win32") == 1 and "dll" or "so")
              if not vim.uv.fs_stat(lib) then
                vim.notify("telescope-fzf-native.nvim not built. Run the build command.", vim.log.levels.WARN)
              else
                vim.notify("Failed to load telescope-fzf-native.nvim:\n" .. err, vim.log.levels.ERROR)
              end
            end
          end
          -- Load after telescope is ready
          vim.api.nvim_create_autocmd("User", {
            pattern = "TelescopeLoaded",
            once = true,
            callback = load_fzf,
          })
          -- Fallback: load immediately if telescope is already up
          pcall(load_fzf)
        end,
      },
    },
    -- stylua: ignore
    keys = {
      { "<leader>,", "<cmd>Telescope buffers sort_mru=true sort_lastused=true<cr>", desc = "Switch Buffer" },
      { "<leader>/", pick("live_grep"), desc = "Grep (Root Dir)" },
      { "<leader>:", "<cmd>Telescope command_history<cr>", desc = "Command History" },
      { "<leader><space>", pick("find_files"), desc = "Find Files (Root Dir)" },
      -- find
      { "<leader>fb", "<cmd>Telescope buffers sort_mru=true sort_lastused=true ignore_current_buffer=true<cr>", desc = "Buffers" },
      { "<leader>fB", "<cmd>Telescope buffers<cr>", desc = "Buffers (all)" },
      { "<leader>fc", config_files(), desc = "Find Config File" },
      { "<leader>ff", pick("find_files"), desc = "Find Files (Root Dir)" },
      { "<leader>fF", pick("find_files", { root = false }), desc = "Find Files (cwd)" },
      { "<leader>fg", "<cmd>Telescope git_files<cr>", desc = "Find Files (git-files)" },
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent" },
      { "<leader>fR", pick("oldfiles", { cwd = vim.uv.cwd() }), desc = "Recent (cwd)" },
      -- git
      { "<leader>gc", "<cmd>Telescope git_commits<CR>", desc = "Commits" },
      { "<leader>gl", "<cmd>Telescope git_commits<CR>", desc = "Commits" },
      { "<leader>gs", "<cmd>Telescope git_status<CR>", desc = "Status" },
      { "<leader>gS", "<cmd>Telescope git_stash<cr>", desc = "Git Stash" },
      -- search
      { '<leader>s"', "<cmd>Telescope registers<cr>", desc = "Registers" },
      { "<leader>s/", "<cmd>Telescope search_history<cr>", desc = "Search History" },
      { "<leader>sa", "<cmd>Telescope autocommands<cr>", desc = "Auto Commands" },
      { "<leader>sb", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Buffer Lines" },
      { "<leader>sc", "<cmd>Telescope command_history<cr>", desc = "Command History" },
      { "<leader>sC", "<cmd>Telescope commands<cr>", desc = "Commands" },
      { "<leader>sd", "<cmd>Telescope diagnostics<cr>", desc = "Diagnostics" },
      { "<leader>sD", "<cmd>Telescope diagnostics bufnr=0<cr>", desc = "Buffer Diagnostics" },
      { "<leader>sg", pick("live_grep"), desc = "Grep (Root Dir)" },
      { "<leader>sG", pick("live_grep", { root = false }), desc = "Grep (cwd)" },
      { "<leader>sh", "<cmd>Telescope help_tags<cr>", desc = "Help Pages" },
      { "<leader>sH", "<cmd>Telescope highlights<cr>", desc = "Search Highlight Groups" },
      { "<leader>sj", "<cmd>Telescope jumplist<cr>", desc = "Jumplist" },
      { "<leader>sk", "<cmd>Telescope keymaps<cr>", desc = "Key Maps" },
      { "<leader>sl", "<cmd>Telescope loclist<cr>", desc = "Location List" },
      { "<leader>sM", "<cmd>Telescope man_pages<cr>", desc = "Man Pages" },
      { "<leader>sm", "<cmd>Telescope marks<cr>", desc = "Jump to Mark" },
      { "<leader>so", "<cmd>Telescope vim_options<cr>", desc = "Options" },
      { "<leader>sR", "<cmd>Telescope resume<cr>", desc = "Resume" },
      { "<leader>sq", "<cmd>Telescope quickfix<cr>", desc = "Quickfix List" },
      { "<leader>sw", pick("grep_string", { word_match = "-w" }), desc = "Word (Root Dir)" },
      { "<leader>sW", pick("grep_string", { root = false, word_match = "-w" }), desc = "Word (cwd)" },
      { "<leader>sw", pick("grep_string"), mode = "x", desc = "Selection (Root Dir)" },
      { "<leader>sW", pick("grep_string", { root = false }), mode = "x", desc = "Selection (cwd)" },
      { "<leader>uC", pick("colorscheme", { enable_preview = true }), desc = "Colorscheme with Preview" },
      { "<leader>ss", function() require("telescope.builtin").lsp_document_symbols() end, desc = "Goto Symbol" },
      { "<leader>sS", function() require("telescope.builtin").lsp_dynamic_workspace_symbols() end, desc = "Goto Symbol (Workspace)" },
    },
    opts = function()
      local actions = require("telescope.actions")

      local open_with_trouble = function(...)
        local ok, trouble = pcall(require, "trouble.sources.telescope")
        if ok then trouble.open(...) end
      end

      local find_files_no_ignore = function()
        local line = require("telescope.actions.state").get_current_line()
        pick("find_files", { no_ignore = true, default_text = line })()
      end

      local find_files_with_hidden = function()
        local line = require("telescope.actions.state").get_current_line()
        pick("find_files", { hidden = true, default_text = line })()
      end

      local function find_command()
        if vim.fn.executable("rg") == 1 then
          return { "rg", "--files", "--color", "never", "-g", "!.git" }
        elseif vim.fn.executable("fd") == 1 then
          return { "fd", "--type", "f", "--color", "never", "-E", ".git" }
        elseif vim.fn.executable("fdfind") == 1 then
          return { "fdfind", "--type", "f", "--color", "never", "-E", ".git" }
        elseif vim.fn.executable("find") == 1 and vim.fn.has("win32") == 0 then
          return { "find", ".", "-type", "f" }
        elseif vim.fn.executable("where") == 1 then
          return { "where", "/r", ".", "*" }
        end
      end

      return {
        defaults = {
          prompt_prefix = " ",
          selection_caret = " ",
          get_selection_window = function()
            local wins = vim.api.nvim_list_wins()
            table.insert(wins, 1, vim.api.nvim_get_current_win())
            for _, win in ipairs(wins) do
              local buf = vim.api.nvim_win_get_buf(win)
              if vim.bo[buf].buftype == "" then
                return win
              end
            end
            return 0
          end,
          mappings = {
            i = {
              ["<c-t>"] = open_with_trouble,
              ["<a-t>"] = open_with_trouble,
              ["<a-i>"] = find_files_no_ignore,
              ["<a-h>"] = find_files_with_hidden,
              ["<C-Down>"] = actions.cycle_history_next,
              ["<C-Up>"] = actions.cycle_history_prev,
              ["<C-f>"] = actions.preview_scrolling_down,
              ["<C-b>"] = actions.preview_scrolling_up,
            },
            n = {
              ["q"] = actions.close,
            },
          },
        },
        pickers = {
          find_files = {
            find_command = find_command,
            hidden = true,
          },
        },
      }
    end,
  },

  -- Flash integration
  {
    "nvim-telescope/telescope.nvim",
    optional = true,
    opts = function(_, opts)
      local ok = pcall(require, "flash")
      if not ok then return end
      local function flash(prompt_bufnr)
        require("flash").jump({
          pattern = "^",
          label = { after = { 0, 0 } },
          search = {
            mode = "search",
            exclude = {
              function(win)
                return vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= "TelescopeResults"
              end,
            },
          },
          action = function(match)
            local picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
            picker:set_selection(match.pos[1] - 1)
          end,
        })
      end
      opts.defaults = vim.tbl_deep_extend("force", opts.defaults or {}, {
        mappings = { n = { s = flash }, i = { ["<c-s>"] = flash } },
      })
    end,
  },

  -- better vim.ui
  {
    "stevearc/dressing.nvim",
    lazy = true,
    init = function()
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.select = function(...)
        require("lazy").load({ plugins = { "dressing.nvim" } })
        return vim.ui.select(...)
      end
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.input = function(...)
        require("lazy").load({ plugins = { "dressing.nvim" } })
        return vim.ui.input(...)
      end
    end,
  },

  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ["*"] = {
          -- stylua: ignore
          keys = {
            { "gd", function() require("telescope.builtin").lsp_definitions({ reuse_win = true }) end, desc = "Goto Definition", has = "definition" },
            { "gr", "<cmd>Telescope lsp_references<cr>", desc = "References", nowait = true },
            { "gI", function() require("telescope.builtin").lsp_implementations({ reuse_win = true }) end, desc = "Goto Implementation" },
            { "gy", function() require("telescope.builtin").lsp_type_definitions({ reuse_win = true }) end, desc = "Goto T[y]pe Definition" },
          },
        },
      },
    },
  },
}
