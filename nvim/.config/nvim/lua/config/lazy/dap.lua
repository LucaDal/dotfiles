return {
    -- NOTE: Yes, you can install new plugins here!
    'mfussenegger/nvim-dap',
    -- NOTE: And you can specify dependencies as well
    dependencies = {
        -- Creates a beautiful debugger UI
        'rcarriga/nvim-dap-ui',
        -- Required dependency for nvim-dap-ui
        'nvim-neotest/nvim-nio',
        -- Installs the debug adapters for you
        'mason-org/mason.nvim',
        'jay-babu/mason-nvim-dap.nvim',
        "theHamsta/nvim-dap-virtual-text",
        -- Add your own debuggers here
        'leoluz/nvim-dap-go',
    },
    keys = {
        -- Basic debugging keymaps, feel free to change to your liking!
        {
            "<leader>d",
            group = "Debugger",
            nowait = true,
            remap = false,
            desc = "Debugger",
        },
        {
            "<leader>dt",
            function()
                require("dap").toggle_breakpoint()
            end,
            desc = "Debug: Toggle Breakpoint",
            nowait = true,
            remap = false,
        },
        {
            "<F5>",
            function()
                require("dap").continue()
            end,
            desc = "Debug: Continue",
            nowait = true,
            remap = false,
        },
        {
            "<F7>",
            function()
                require("dap").step_into()
            end,
            desc = "Debug: Step Into",
            nowait = true,
            remap = false,
        },
        {
            "<F6>",
            function()
                require("dap").step_over()
            end,
            desc = "Debug: Step Over",
            nowait = true,
            remap = false,
        },
        {
            "<leader>du",
            function()
                require("dap").step_out()
            end,
            desc = "Debug: Step Out",
            nowait = true,
            remap = false,
        },
        {
            "<leader>dr",
            function()
                require("dap").repl.open()
            end,
            desc = "Debug: Open REPL",
            nowait = true,
            remap = false,
        },
        {
            "<leader>dl",
            function()
                require("dap").run_last()
            end,
            desc = "Debug: Run Last",
            nowait = true,
            remap = false,
        },
        {
            "<leader>dq",
            function()
                require("dap").terminate()
                require("dapui").close()
                require("nvim-dap-virtual-text").toggle()
            end,
            desc = "Debug: Terminate",
            nowait = true,
            remap = false,
        },
        {
            "<leader>db",
            function()
                require("dap").list_breakpoints()
            end,
            desc = "Debug: List Breakpoints",
            nowait = true,
            remap = false,
        },
        {
            "<leader>de",
            function()
                require("dap").set_exception_breakpoints({ "all" })
            end,
            desc = "Debug: Set Exception Breakpoints",
            nowait = true,
            remap = false,
        },
    },
    config = function()
        local dap = require 'dap'
        local dapui = require 'dapui'
        local dap_virtual_text = require("nvim-dap-virtual-text")

        dap_virtual_text.setup()

        require('mason-nvim-dap').setup {
            -- Makes a best effort to setup the various debuggers with
            -- reasonable debug configurations
            automatic_installation = true,

            -- You can provide additional configuration to the handlers,
            -- see mason-nvim-dap README for more information
            handlers = {},

            -- You'll need to check that you have the required things installed
            -- online, please don't ask me how to install them :)
            ensure_installed = {
                -- Update this to ensure that you have the debuggers for the langs you want
                'delve', 'python'
            },
        }

        -- Dap UI setup
        -- For more information, see |:help nvim-dap-ui|
        dapui.setup {
            -- Set icons to characters that are more likely to work in every terminal.
            --    Feel free to remove or use ones :wqthat you like more! :)
            --    Don't feel like these are good choices.
            icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
            controls = {
                icons = {
                    pause = '⏸',
                    play = '▶',
                    step_into = '⏎',
                    step_over = '⏭',
                    step_out = '⏮',
                    step_back = 'b',
                    run_last = '▶▶',
                    terminate = '⏹',
                    disconnect = '⏏',
                },
            },
        }

        --Change breakpoint icons
        vim.api.nvim_set_hl(0, 'DapBreak', { fg = '#e51400' })
        vim.api.nvim_set_hl(0, 'DapStop', { fg = '#ffcc00' })
        local breakpoint_icons = vim.g.have_nerd_font
        and { Breakpoint = '', BreakpointCondition = '', BreakpointRejected = '', LogPoint = '', Stopped = '' }
        or { Breakpoint = '●', BreakpointCondition = '⊜', BreakpointRejected = '⊘', LogPoint = '◆', Stopped = '⭔' }
        for type, icon in pairs(breakpoint_icons) do
            local tp = 'Dap' .. type
            local hl = (type == 'Stopped') and 'DapStop' or 'DapBreak'
            vim.fn.sign_define(tp, { text = icon, texthl = hl, numhl = hl })
        end

        dap.listeners.after.event_initialized['dapui_config'] = dapui.open
        dap.listeners.before.event_terminated['dapui_config'] = dapui.close
        dap.listeners.before.event_exited['dapui_config'] = dapui.close

        -- Install golang specific config
        require('dap-go').setup {
            delve = {
                -- On Windows delve must be run attached or it crashes.
                -- See https://github.com/leoluz/nvim-dap-go/blob/main/README.md#configuring
                detached = vim.fn.has 'win32' == 0,
            },
        }
    end,
}
