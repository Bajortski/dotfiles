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
    -- where to put new notes
    new_notes_location = "current_dir",

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
			name = "snacks-picker"
		}
  },
}
