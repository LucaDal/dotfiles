local map = vim.keymap.set

vim.g.mapleader = " "

map("n", "<C-h>", "<cmd>TmuxNavigateLeft<CR>", { desc = "Go to Left Window" })
map("n", "<C-j>", "<cmd>TmuxNavigateDown<CR>", { desc = "Go to Lower Window" })
map("n", "<C-k>", "<cmd>TmuxNavigateUp<CR>", { desc = "Go to Upper Window" })
map("n", "<C-l>", "<cmd>TmuxNavigateRight<CR>", { desc = "Go to Right Window" })

map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })
