local map = vim.keymap.set
vim.g.mapleader = " "
--map("n", "<leader>pv", vim.cmd.Ex, {desc = 'back to [P]roject [V]iew'})
--map("n", "<leader>pv", ":Neotree current<CR>" , {desc = 'Neotree [P]roject [V]iew'})

map({ "n", "v" }, "<leader>y", [["+y]])
map("n", "<leader>Y", [["+Y]])

map('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
map('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
map('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
map('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })
--tmux neovim navigator
map('n', 'C-h', ':TmuxNavigateLeft<CR>')
map('n', 'C-l', ':TmuxNavigateRight<CR>')
map('n', 'C-j', ':TmuxNavigateDown<CR>')
map('n', 'C-k', ':TmuxNavigateUp<CR>')

--permette di sostituire la stringa selezionata
map("n", "<leader>ss", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc =  "[S]ubstitute [s]tring"})
-- Move to window using the <ctrl> hjkl keys
map("n", "<C-h>", "<C-w>h", { desc = "Go to Left Window", remap = true })
map("n", "<C-j>", "<C-w>j", { desc = "Go to Lower Window", remap = true })
map("n", "<C-k>", "<C-w>k", { desc = "Go to Upper Window", remap = true })
map("n", "<C-l>", "<C-w>l", { desc = "Go to Right Window", remap = true })

-- Resize window using <ctrl> arrow keys
map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })

-- Move Lines
map("n", "<A-j>", "<cmd>execute 'move .+' . v:count1<cr>==", { desc = "Move Down" })
map("n", "<A-k>", "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = "Move Up" })
map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move Down" })
map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move Up" })
map("v", "<A-j>", ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = "Move Down" })
map("v", "<A-k>", ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = "Move Up" })

-- permette di mettere o togliere il wrap
-- vim.keymap.set("n", "<leader>w", function()
map("n", "<leader>w", function()
  local wo = vim.wo
  if wo.wrap then
    -- DISABILITA WRAP
    wo.wrap = false
    wo.linebreak = false
    wo.breakindent = false
    wo.showbreak = ""
  else
    -- ABILITA WRAP + SIMBOLINO
    wo.wrap = true
    wo.linebreak = true
    wo.breakindent = true
    wo.showbreak = "↳ "
  end
end, { desc = "Toggle wrap" })
