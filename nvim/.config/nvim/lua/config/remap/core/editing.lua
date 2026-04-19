local map = vim.keymap.set
local utils = require("config.utils")

vim.g.mapleader = " "

map({ "n", "v" }, "<leader>y", [["+y]])
map("n", "<leader>Y", [["+Y]])

map("n", "<leader>ss", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], {
    desc = "[S]ubstitute [s]tring",
})

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

map("n", "<leader>w", function()
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
end, { desc = "Toggle wrap" })
