return {
    "nvim-flutter/flutter-tools.nvim",
    ft = "dart",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "neovim/nvim-lspconfig",
        "saghen/blink.cmp",
        "mfussenegger/nvim-dap",
    },
    config = function()
        local capabilities = vim.lsp.protocol.make_client_capabilities()
        local ok_blink, blink = pcall(require, "blink.cmp")
        if ok_blink then
            capabilities = blink.get_lsp_capabilities(capabilities)
        end

        require("flutter-tools").setup({
            debugger = {
                enabled = true,
                run_via_dap = true,
                exception_breakpoints = {},
            },
            lsp = {
                capabilities = capabilities,
                color = {
                    enabled = true,
                    background = false,
                    virtual_text = true,
                    virtual_text_str = "■",
                },
                settings = {
                    showTodos = true,
                    completeFunctionCalls = true,
                    renameFilesWithClasses = "prompt",
                    enableSnippets = true,
                    updateImportsOnRename = true,
                },
            },
        })

        vim.api.nvim_create_autocmd("FileType", {
            pattern = "dart",
            callback = function(event)
                local opts = { buffer = event.buf, silent = true }
                vim.keymap.set("n", "<leader>fr", "<cmd>FlutterRun<cr>", opts)
                vim.keymap.set("n", "<leader>fR", "<cmd>FlutterRestart<cr>", opts)
                vim.keymap.set("n", "<leader>fq", "<cmd>FlutterQuit<cr>", opts)
                vim.keymap.set("n", "<leader>fd", "<cmd>FlutterDevices<cr>", opts)
                vim.keymap.set("n", "<leader>fe", "<cmd>FlutterEmulators<cr>", opts)
                vim.keymap.set("n", "<leader>fo", "<cmd>FlutterOutlineToggle<cr>", opts)
                vim.keymap.set("n", "<leader>fl", "<cmd>FlutterLspRestart<cr>", opts)
            end,
        })
    end,
}
