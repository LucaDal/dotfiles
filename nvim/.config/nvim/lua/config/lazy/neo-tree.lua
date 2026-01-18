-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

return {
    'nvim-neo-tree/neo-tree.nvim',
    version = '*',
    dependencies = {
        'nvim-lua/plenary.nvim',
        'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
        'MunifTanjim/nui.nvim',
    },
    lazy = false,
    keys = {
        {"<leader>t", group = "Neotree", desc = "Neo[T]ree"},
        {'<leader>tt', ':Neotree toggle<CR>', desc = 'Neo[T]ree [T]oggle', silent = true },
        {'<leader>t\\', ':Neotree focus<CR>', desc = 'Neo[T]ree focus'},
        {'<leader>tb', ':Neotree focus buffers left<CR>', desc = 'Neo[T]ree [b]uffer'},
        {'<leader>tg', ':Neotree focus git_status left<CR>', desc = 'Neo[T]ree [g]it status'},
    },
    --    init = function()
    --        vim.api.nvim_create_autocmd('BufEnter', {
    --            -- make a group to be able to delete it later
    --            group = vim.api.nvim_create_augroup('NeoTreeInit', {clear = true}),
    --            callback = function()
    --                local f = vim.fn.expand('%:p')
    --                if vim.fn.isdirectory(f) ~= 0 then
    --                    vim.cmd('Neotree current dir=' .. f)
    --                    -- neo-tree is loaded now, delete the init autocmd
    --                    vim.api.nvim_clear_autocmds{group = 'NeoTreeInit'}
    --                end
    --            end
    --        })
    --        -- keymaps
    --    end,
    opts = {
        sources = { "filesystem", "buffers", "git_status" },
        open_files_do_not_replace_types = { "terminal", "Trouble", "trouble", "qf", "Outline" },
        filesystem = {
            bind_to_cwd = false,
            follow_current_file = { enabled = true },
            use_libuv_file_watcher = true,
        },
        window = {
            mappings = {
                ["l"] = "open",
                ["h"] = "close_node",
                ["<space>"] = "none",
                ["Y"] = {
                    function(state)
                        local node = state.tree:get_node()
                        local path = node:get_id()
                        vim.fn.setreg("+", path, "c")
                    end,
                    desc = "Copy Path to Clipboard",
                },
                ["O"] = {
                    function(state)
                        require("lazy.util").open(state.tree:get_node().path, { system = true })
                    end,
                    desc = "Open with System Application",
                },
            },
        },
        default_component_configs = {
            indent = {
                with_expanders = true, -- if nil and file nesting is enabled, will enable expanders
                expander_collapsed = "",
                expander_expanded = "",
                expander_highlight = "NeoTreeExpander",
            },
        },
    }}
