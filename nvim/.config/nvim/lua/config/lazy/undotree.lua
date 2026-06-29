return {
    "mbbill/undotree",

    config = function()
        vim.keymap.set("n", "<leader>td", vim.cmd.UndotreeToggle, { desc = "[T]oggle un[D]o tree" })
    end
}
