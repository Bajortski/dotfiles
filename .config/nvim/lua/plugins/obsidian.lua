return {
  "obsidian-nvim/obsidian.nvim",
  version = "*",
  ft = "markdown",
  opts = {
    -- explicit defaults
    legacy_commands = false,
    frontmatter = {
      enabled = false,
    },
    -- use wikilink text as filename
    note_id_func = function(title)
      return require("obsidian.builtin").title_id(title)
    end,
    -- new notes go to vault root
    new_notes_location = "notes_subdir",
    notes_subdir = "/",
    -- preferred link style
    link = {
      style = "wiki",
      auto_update = true,
    },
    -- control how notes are opened
    open_notes_in = "current",
    -- sort search results
    search = {
      sort_by = "modified",
      sort_reversed = true,
    },
    completion = {
      min_chars = 2,
    },
    -- attachments (images) defaults
    attachments = {
      folder = "attachments",
      img_name_func = nil,
      img_text_func = nil,
      confirm_img_paste = true,
    },
    -- templates defaults
    templates = {
      folder = nil,
      date_format = nil,
      time_format = nil,
    },
    -- workspace
    workspaces = {
      {
        name = "Vaulternative",
        path = "~/Documents/Vaulternative",
      },
    },

    picker = {
      name = "snacks-picker",
    },

    -- control built-in UI rendering
    ui = {
      enable = true,
    },

    -- callbacks
    callbacks = {
      enter_note = function(note)
        vim.opt_local.wrap = true
      end,
    },
  },
}
