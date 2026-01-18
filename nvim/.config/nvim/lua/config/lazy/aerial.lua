return {
    -- this cofiguration lists all functions in a file
    'stevearc/aerial.nvim',
    opts = {},
    -- Optional dependencies
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "nvim-tree/nvim-web-devicons"
    },
    config = function ()
        require("aerial").setup({
            -- optionally use on_attach to set keymaps when aerial has attached to a buffer
            on_attach = function(bufnr)
                -- Jump forwards/backwards with '{' and '}'
                vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { buffer = bufnr, desc = 'Jump forwards symbols' })
                vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr, desc = 'Jump backwards symbols' })
            end,
        })
        -- You probably also bant to set a keymap to toggle aerial
        vim.keymap.set("n", "<leader>a", "<cmd>AerialToggle!<CR>", {desc = '[A]erial: Functions view'})
    end
}
