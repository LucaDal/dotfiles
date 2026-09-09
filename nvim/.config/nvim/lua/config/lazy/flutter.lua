return {
    "nvim-flutter/flutter-tools.nvim",
    ft = "dart",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "neovim/nvim-lspconfig",
        "saghen/blink.cmp",
        "mfussenegger/nvim-dap",
    },
    init = function()
        vim.api.nvim_create_autocmd("FileType", {
            group = vim.api.nvim_create_augroup("FlutterKeymaps", { clear = true }),
            pattern = "dart",
            callback = function(event)
                local mappings = {
                    { "<leader>fr", "FlutterRun", "Flutter: run" },
                    { "<leader>fh", "FlutterReload", "Flutter: hot reload" },
                    { "<leader>fR", "FlutterRestart", "Flutter: hot restart" },
                    { "<leader>fq", "FlutterQuit", "Flutter: quit" },
                    { "<leader>fd", "FlutterDevices", "Flutter: select device" },
                    { "<leader>fe", "FlutterEmulators", "Flutter: select emulator" },
                    { "<leader>fo", "FlutterOutlineToggle", "Flutter: toggle widget outline" },
                    { "<leader>fl", "FlutterLspRestart", "Flutter: restart language server" },
                }
                for _, mapping in ipairs(mappings) do
                    vim.keymap.set("n", mapping[1], "<cmd>" .. mapping[2] .. "<cr>", {
                        buffer = event.buf,
                        silent = true,
                        desc = mapping[3],
                    })
                end
            end,
        })
    end,
    config = function()
        local capabilities = vim.lsp.protocol.make_client_capabilities()
        local ok_blink, blink = pcall(require, "blink.cmp")
        if ok_blink then
            capabilities = blink.get_lsp_capabilities(capabilities)
        end

        require("flutter-tools").setup({
            widget_guides = { enabled = true },
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
    end,
}
