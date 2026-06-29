local map = vim.keymap.set

map("n", "<leader>ic", ":!pio run -t compiledb<CR>", { desc = "PlatformIO: [C]ompile DB", silent = true })
map("n", "<leader>ir", ":!pio run<CR>", { desc = "PlatformIO: [R]un", silent = true })
map("n", "<leader>iu", ":!pio run -t upload<CR>", { desc = "PlatformIO: [U]pload", silent = true })
map("n", "<leader>im", ":!pio device monitor<CR>", { desc = "PlatformIO: [M]onitor", silent = true })

map("n", "<leader>itr", function()
    vim.cmd("split | terminal pio run")
    vim.cmd("startinsert")
end, { desc = "PlatformIO: [T]erminal [R]un", silent = true })

map("n", "<leader>itu", function()
    vim.cmd("split | terminal pio run -t upload")
    vim.cmd("startinsert")
end, { desc = "PlatformIO: [T]erminal [U]pload", silent = true })

map("n", "<leader>itm", function()
    vim.cmd("split | terminal pio device monitor")
    vim.cmd("startinsert")
end, { desc = "PlatformIO: [T]erminal [M]onitor", silent = true })
