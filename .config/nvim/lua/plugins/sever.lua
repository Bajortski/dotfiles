-- Sever: edit Final Cut Pro by cutting words out of a transcript. Cut words stay
-- dimmed in place (same deferred cut as ghost-cut), which keeps every word
-- pinned to its timecode. Needs CommandPost running with the bridge plugin in
-- ~/Library/Application Support/CommandPost/Plugins/sever/.
return {
  dir = "~/Projects/sever.nvim",
  cmd = { "Sever", "SeverIndex", "SeverCommit", "SeverStatus", "SeverFollow", "SeverRedo" },
  opts = {},
  config = function(_, opts)
    require("sever").setup(opts)
  end,
}
