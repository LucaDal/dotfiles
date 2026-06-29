local map = vim.keymap.set
local utils = require("config.utils")

map({ "n", "v" }, "<leader>y", [["+y]], { desc = "[Y]ank to system clipboard" })
map("n", "<leader>Y", [["+Y]], { desc = "[Y]ank line to system clipboard" })
map("n", "<leader>p", [["+p]], { desc = "[P]aste from system clipboard" })
map("n", "<leader>P", [["+P]], { desc = "[P]aste before from system clipboard" })
map("v", "<leader>p", [["+p]], { desc = "[P]aste from system clipboard" })

map("v", "p", [["_dP]], { desc = "Paste without overwriting yank register" })
map({ "n", "v" }, "<leader>d", [["_d]], { desc = "[D]elete without yanking" })

map("n", "<leader>c", utils.comment_current_line, { desc = "[C]omment line" })
map("v", "<leader>c", utils.comment_visual_selection, { desc = "[C]omment selection" })
map("n", "<leader>u", utils.uncomment_current_line, { desc = "[U]ncomment line" })
map("v", "<leader>u", utils.uncomment_visual_selection, { desc = "[U]ncomment selection" })

map("n", "<leader>rw", utils.substitute_current_word, { desc = "[R]eplace current [W]ord" })
map("v", "<leader>rw", utils.substitute_visual_selection, { desc = "[R]eplace selected [W]ord" })
map("n", "<leader>rf", utils.replace_in_files, { desc = "[R]eplace in [F]iles" })
map("v", "<leader>rf", utils.replace_visual_in_files, { desc = "[R]eplace in [F]iles" })

map("n", "<A-j>", utils.move_line_down, { desc = "Move Down" })
map("n", "<A-k>", utils.move_line_up, { desc = "Move Up" })
map("i", "<A-j>", function()
    utils.move_line_down()
    vim.cmd("startinsert")
end, { desc = "Move Down" })
map("i", "<A-k>", function()
    utils.move_line_up()
    vim.cmd("startinsert")
end, { desc = "Move Up" })
map("v", "<A-j>", utils.move_selection_down, { desc = "Move Down" })
map("v", "<A-k>", utils.move_selection_up, { desc = "Move Up" })

map("n", "<leader>tw", function()
    local wo = vim.wo
    if wo.wrap then
        wo.wrap = false
        wo.linebreak = false
        wo.breakindent = false
        wo.showbreak = ""
        return
    end

    wo.wrap = true
    wo.linebreak = true
    wo.breakindent = true
    wo.showbreak = "↳ "
end, { desc = "[T]oggle [W]rap" })

map("n", "<leader>w", "<cmd>write<CR>", { desc = "[W]rite buffer" })
map("n", "<leader>a", "<cmd>wall<CR>", { desc = "Write [A]ll buffers" })
