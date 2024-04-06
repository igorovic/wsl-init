return {
  "kylechui/nvim-surround",
  event = { "BufReadPre", "BufNewFile" },
  version = "*", -- Use for stability; omit to use `main` branch for the latest features
  --[[
  -- use ys motion " - to surround with doublt quotes 
  --      example ysiw" surround word with double quotes
  -- remove double quotes use => ds"
  -- change use cs" 
  --]]
  config = true,
}
