return {
    "folke/trouble.nvim",
    cmd = "Trouble",
    opts = {},
    keys = {
        {
            "<leader>el",
            "<cmd>Trouble diagnostics toggle focus=true win.position=bottom<CR>",
            desc = "[E]rror [L]ist",
        },
        {
            "<leader>sr",
            "<cmd>Trouble lsp_references toggle focus=true win.position=right<CR>",
            desc = "[S]earch [R]eferences",
        },
    },
}
