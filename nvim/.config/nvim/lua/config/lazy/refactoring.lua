return {
    "ThePrimeagen/refactoring.nvim",
    dependencies = {
        "lewis6991/async.nvim",
        "nvim-lua/plenary.nvim",
        "nvim-treesitter/nvim-treesitter",
    },
    opts = {},
    keys = {
        {
            "<leader>ra",
            function()
                require("refactoring").select_refactor()
            end,
            mode = { "n", "x" },
            desc = "[R]efactor [A]ctions",
        },
        {
            "<leader>re",
            function()
                return require("refactoring").extract_func()
            end,
            mode = { "n", "x" },
            expr = true,
            desc = "[R]efactor [E]xtract function",
        },
        {
            "<leader>rE",
            function()
                return require("refactoring").extract_func_to_file()
            end,
            mode = { "n", "x" },
            expr = true,
            desc = "[R]efactor extract to fil[E]",
        },
        {
            "<leader>rv",
            function()
                return require("refactoring").extract_var()
            end,
            mode = { "n", "x" },
            expr = true,
            desc = "[R]efactor extract [V]ariable",
        },
        {
            "<leader>ri",
            function()
                return require("refactoring").inline_var()
            end,
            mode = { "n", "x" },
            expr = true,
            desc = "[R]efactor [I]nline variable",
        },
        {
            "<leader>rI",
            function()
                return require("refactoring").inline_func()
            end,
            mode = { "n", "x" },
            expr = true,
            desc = "[R]efactor inline [F]unction",
        },
    },
}
