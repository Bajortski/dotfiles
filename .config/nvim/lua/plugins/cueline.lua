-- cueline: SRT transcript editor linked to IINA. Highlights the playing cue and
-- previews edits as a caption in the player (IINA side: ~/git/cueline/iina).
return {
  dir = "~/git/cueline/nvim",
  name = "cueline",
  ft = "srt",
  cmd = { "CuelineConnect", "CuelineOpen" },
  opts = {},
}
