require("config.remap.remap")
require("config.remap.platformio")
require("config.set")
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

autocmd({ "BufWritePre" }, {
    group = ThePrimeagenGroup,
    pattern = "*",
    command = [[%s/\s\+$//e]],
})

autocmd('BufEnter', {
    group = ThePrimeagenGroup,
    callback = function()
        --  if vim.bo.filetype == "zig" then
        vim.cmd.colorscheme("tokyonight-night")
        --   else
        --        vim.cmd.colorscheme("rose-pine-moon")
        --         vim.cmd.colorscheme("catppuccin")
        --   end
        require('lualine').setup()
    end
})

autocmd("LspAttach", {
    group = ThePrimeagenGroup,
    callback = function(e)
        -- helper per non ripetere sempre buffer+desc
        local function opts(desc)
            return { buffer = e.buf, desc = desc }
        end
        -- se usi blink / altri completion, assicuriamoci di non usare omnifunc
        vim.bo[e.buf].omnifunc = ""
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts("Go to definition"))
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts("Hover documentation"))
        vim.keymap.set("n", "<leader>vws", vim.lsp.buf.workspace_symbol, opts("Search workspace symbols"))
        vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float, opts("Show line diagnostics"))
        vim.keymap.set("n", "<leader>vde", function()
            vim.diagnostic.setloclist({
                severity = vim.diagnostic.severity.ERROR,
            })
            vim.cmd("lopen")
        end, opts("Open buffer errors (loclist)"))
        vim.keymap.set("n", "<leader>vdw", function()
            vim.diagnostic.setloclist({
                severity = { min = vim.diagnostic.severity.WARN },
            })
            vim.cmd("lopen")
        end, opts("Open buffer warnings (loclist)"))
        vim.keymap.set("n", "<leader>vdqe", function()
            vim.diagnostic.setqflist({
                severity = vim.diagnostic.severity.ERROR,
            })
            vim.cmd("copen")
        end, opts("Open workspace errors (quickfix)"))
        -- Tutti gli errori del buffer corrente in location list
        vim.keymap.set("n", "<leader>vdl", function()
            vim.diagnostic.setloclist() -- riempie la location list
            vim.cmd("lopen")            -- la apre
        end, opts("Open buffer diagnostics list (loclist)"))


        vim.keymap.set("n", "<leader>vca", vim.lsp.buf.code_action, opts("Code actions"))
        vim.keymap.set("n", "<leader>vrr", vim.lsp.buf.references, opts("List references"))
        vim.keymap.set("n", "<leader>vrn", vim.lsp.buf.rename, opts("Rename symbol"))
        vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, opts("Signature help"))
        vim.keymap.set("n", "[d", vim.diagnostic.goto_next, opts("Next diagnostic"))
        vim.keymap.set("n", "]d", vim.diagnostic.goto_prev, opts("Previous diagnostic"))
        -- -- solo errori
        vim.keymap.set("n", "]e", function()
            vim.diagnostic.goto_next({
                severity = vim.diagnostic.severity.ERROR,
            })
        end, opts("Next error"))
        vim.keymap.set("n", "[e", function()
            vim.diagnostic.goto_prev({
                severity = vim.diagnostic.severity.ERROR,
            })
        end, opts("Previous error"))

        -- se vuoi invece warnings+errors:
        vim.keymap.set("n", "]w", function()
            vim.diagnostic.goto_next({
                severity = { min = vim.diagnostic.severity.WARN },
            })
        end, opts("Next warning/error"))

        vim.keymap.set("n", "[w", function()
            vim.diagnostic.goto_prev({
                severity = { min = vim.diagnostic.severity.WARN },
            })
        end, opts("Previous warning/error"))


        -- Tutti gli errori della workspace in quickfix
        vim.keymap.set("n", "<leader>vdq", function()
            vim.diagnostic.setqflist() -- riempie la quickfix
            vim.cmd("copen")           -- la apre
        end, opts("Open workspace diagnostics (quickfix)"))

        ----------------------------------------------------------------------
        -- QUALCHE FUNZIONE COMODA -------------------------------------------
        ----------------------------------------------------------------------

        -- Format del buffer tramite LSP (usa conform/clangd/ts_ls ecc.)
        vim.keymap.set("n", "<leader>vf", function() vim.lsp.buf.format({ async = true }) end,
            opts("Format buffer (LSP)"))
        -- Toggle degli errori inline (virtual text) on/off
        vim.keymap.set("n", "<leader>vT", function()
            local cfg = vim.diagnostic.config()
            local new_virtual_text = not cfg.virtual_text
            vim.diagnostic.config({
                virtual_text = new_virtual_text,
                signs = cfg.signs,
                underline = cfg.underline,
                update_in_insert = cfg.update_in_insert,
                severity_sort = cfg.severity_sort,
            })

            vim.notify("Diagnostics virtual text: " .. (new_virtual_text and "ON" or "OFF"))
        end, opts("Toggle inline diagnostics (virtual text)"))
    end,
})
