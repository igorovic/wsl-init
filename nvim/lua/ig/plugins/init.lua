return {
  "nvim-lua/plenary.nvim", -- lua functions that many plugins use
  --[[
  { "christoomey/vim-tmux-navigator",
    cmd = {
    "TmuxNavigateLeft",
    "TmuxNavigateDown",
    "TmuxNavigateUp",
    "TmuxNavigateRight",
    "TmuxNavigatePrevious",
  },
  keys = {
    { "<c-j>", "<cmd><C-U>TmuxNavigateLeft<cr>" },
    { "<c-k>", "<cmd><C-U>TmuxNavigateDown<cr>" },
    { "<c-i>", "<cmd><C-U>TmuxNavigateUp<cr>" },
    { "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>" },
    { "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
  },

  }, -- tmux & split window navigator
  ]]--
}
