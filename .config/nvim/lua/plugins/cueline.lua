-- cueline: SRT/ASS transcript editor linked to IINA. Highlights the playing cue and
-- previews edits as a caption in the player (IINA side: ~/git/cueline/iina).
return {
  dir = "~/git/cueline",
  name = "cueline",
  ft = { "srt", "ssa" },
  cmd = { "CuelineConnect", "CuelineOpen" },
  opts = {},
}
