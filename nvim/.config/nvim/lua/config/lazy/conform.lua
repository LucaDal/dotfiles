local formatting = require("config.formatting")

return{
    -- Autoformat
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
        {
            '<leader>tf',
            formatting.toggle,
            desc = 'Toggle format on save (buffer)',
        },
        {
            '<leader>fi',
            '<cmd>ConformInfo<cr>',
            desc = 'Formatter info',
        },
        {
            '<leader>fm',
            function()
                require("config.utils").format_buffer()
            end,
            mode = { 'n', 'v' },
            desc = '[F]ormat document or selection',
        },
    },
    opts = {
        notify_on_error = true,
        format_on_save = formatting.on_save,
        formatters = {
            stylua = {
                prepend_args = { "--indent-type", "Spaces", "--indent-width", "4" },
            },
            clang_format = {
                prepend_args = {
                    "--style={BasedOnStyle: LLVM, IndentWidth: 4, TabWidth: 4, UseTab: Never}",
                },
            },
        },
        formatters_by_ft = {
            c = { 'clang_format' },
            cpp = { 'clang_format' },
            objc = { 'clang_format' },
            objcpp = { 'clang_format' },
            cuda = { 'clang_format' },
            proto = { 'clang_format' },
            lua = { 'stylua' },
            -- Conform can also run multiple formatters sequentially
            -- python = { "isort", "black" },
            --
            -- You can use 'stop_after_first' to run the first available formatter from the list
            -- javascript = { "prettierd", "prettier", stop_after_first = true },
        },
    }
}
