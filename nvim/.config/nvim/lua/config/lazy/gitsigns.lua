return {
    'lewis6991/gitsigns.nvim',
    opts = {
        on_attach = function(bufnr)
            local gitsigns = require 'gitsigns'
            local function open_diff(revision, label)
                return function()
                    vim.notify("Git diff: " .. label)
                    gitsigns.diffthis(revision)
                end
            end

            local function map(mode, l, r, opts)
                opts = opts or {}
                opts.buffer = bufnr
                vim.keymap.set(mode, l, r, opts)
            end
           -- Navigation
            map('n', ']c', function()
                if vim.wo.diff then
                    vim.cmd.normal { ']c', bang = true }
                else
                    gitsigns.nav_hunk 'next'
                end
            end, { desc = 'Jump to next git [c]hange' })

            map('n', '[c', function()
                if vim.wo.diff then
                    vim.cmd.normal { '[c', bang = true }
                else
                    gitsigns.nav_hunk 'prev'
                end
            end, { desc = 'Jump to previous git [c]hange' })

            -- normal mode
            map('n', '<leader>gd', open_diff('@', 'working tree vs HEAD (last commit)'), {
                desc = '[G]it [D]iff vs last commit',
            })
            map('n', '<leader>gD', open_diff(nil, 'working tree vs index (staged changes)'), {
                desc = '[G]it diff vs in[D]ex',
            })
            -- Toggles
        end,
        signs = {
                add = { text = '+' },
                change = { text = '~' },
                delete = { text = '_' },
                topdelete = { text = '‾' },
                changedelete = { text = '~' },
            },

    },

}
