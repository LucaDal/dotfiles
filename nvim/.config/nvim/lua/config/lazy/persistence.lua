return {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = {},
    keys = {
        {
            "<leader>ql",
            function()
                require("persistence").load({ last = true })
            end,
            desc = "[Q]uit: Load [L]ast session",
        },
        {
            "<leader>qs",
            function()
                require("persistence").load()
            end,
            desc = "[Q]uit: Load [S]ession",
        },
        {
            "<leader>qS",
            function()
                require("persistence").select()
            end,
            desc = "[Q]uit: [S]elect session",
        },
        {
            "<leader>qd",
            function()
                require("persistence").stop()
            end,
            desc = "[Q]uit: [D]isable session save",
        },
    },
}
