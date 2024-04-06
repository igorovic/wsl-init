vim.g.mapleader = " "

local keymap = vim.keymap -- for conciseness

keymap.set("i", "jk", "<ESC>", { desc = "Exit insert mode with jk" })

keymap.set("n", "<leader>nl", ":nohl<CR>", { desc = "Clear search highlights" })

-- increment/decrement numbers
keymap.set("n", "<leader>1", "<C-a>", { desc = "Increment number" })
keymap.set("n", "<leader>k", "<C-x>", { desc = "Decrement number" })

-- window management
keymap.set("n", "<leader>sl", "<C-w>v", { desc = "Split window vertically" })
keymap.set("n", "<leader>sk", "<C-w>s", { desc = "Split window horizontally" })
keymap.set("n", "<leader>ss", "<C-w>=", { desc = "Make splits equal size" })
keymap.set("n", "<leader>sq", "<cmd>close<CR>", { desc = "Close current split" })

keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tabl" })
keymap.set("n", "<leader>tq", "<cmd>tabclose<CR>", { desc = "Close current tab" })
keymap.set("n", "<leader>tl", "<cmd>tabn<CR>", { desc = "Go to next tab" })
keymap.set("n", "<leader>tj", "<cmd>tabp<CR>", { desc = "Go to previous tab" })
keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" })

keymap.set("n", "<leader>j", "<cmd>wincmd h<CR>", { desc = "Go to left split" })
keymap.set("n", "<leader>l", "<cmd>wincmd l<CR>", { desc = "Go to right split" })
keymap.set("n", "<leader>k", "<cmd>wincmd j<CR>", { desc = "Go to below split" })
keymap.set("n", "<leader>i", "<cmd>wincmd k<CR>", { desc = "Go to above split" })
