vim.g.mapleader = " "

require("config.remap")
require("config.set")
require("config.autoreload").setup()
require("config.treesitter_compat").apply()
require("config.lazy_init")
local augroup = vim.api.nvim_create_augroup
local ThePrimeagenGroup = augroup('ThePrimeagen', {})

local autocmd = vim.api.nvim_create_autocmd
local yank_group = augroup('HighlightYank', {})

function R(name)
    require("plenary.reload").reload_module(name)
end

vim.filetype.add({
    extension = {
        templ = 'templ',
    }
})

autocmd('TextYankPost', {

    group = yank_group,
    pattern = '*',
    callback = function()
        vim.highlight.on_yank({
            higroup = 'IncSearch',
            timeout = 40,
        })
    end,
})

autocmd("LspAttach", {
    group = ThePrimeagenGroup,
    callback = function(e)
        vim.bo[e.buf].omnifunc = ""
        require("config.remap.lsp").on_attach(e.buf)
    end,
})
