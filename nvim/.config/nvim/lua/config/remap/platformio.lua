local map = vim.keymap.set
vim.g.mapleader = " "

map("n", "<leader>pcp", ":!pio run -t compiledb<CR>", { desc = 'PIO compile db', silent = true })
map("n", "<leader>pr", ":!pio run<CR>", { desc = 'PIO run', silent = true })
map("n", "<leader>pu", ":!pio run -t upload<CR>", { desc = 'PIO Upload', silent = true })
map("n", "<leader>pm", ":!pio device monitor<CR>", { desc = 'PIO monitor', silent = true })

map("n", "<leader>ptr", function()
    vim.cmd("split | terminal pio run")
    vim.cmd("startinsert") -- scrols down to end
end, { desc = 'PIO terminal run', silent = true })

map("n", "<leader>ptu", function()
    vim.cmd("split | terminal pio run -t upload")
    vim.cmd("startinsert") -- scrols down to end
end, { desc = 'PIO terminal upload', silent = true })

map("n", "<leader>ptm", function()
    vim.cmd("split | terminal pio device monitor")
    vim.cmd("startinsert") -- scrols down to end
end, { desc = 'PIO terminal monitor', silent = true })
