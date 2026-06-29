local M = {}
local utils = require("config.utils")

local function opts(bufnr, desc)
    return { buffer = bufnr, desc = desc }
end

local function with_telescope(picker, fallback)
    return function(default_text)
        local ok, builtin = pcall(require, "telescope.builtin")
        if ok and builtin[picker] then
            builtin[picker](default_text and { default_text = default_text } or {})
            return
        end

        if fallback then
            fallback(default_text)
        end
    end
end

function M.on_attach(bufnr)
    local workspace_symbols = with_telescope("lsp_dynamic_workspace_symbols", function(query)
        vim.lsp.buf.workspace_symbol(query or "")
    end)
    local document_symbols = with_telescope("lsp_document_symbols", vim.lsp.buf.document_symbol)

    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts(bufnr, "Go to definition"))
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts(bufnr, "Hover documentation"))

    vim.keymap.set("n", "<leader>rr", vim.lsp.buf.rename, opts(bufnr, "[R]e[n]ame symbol"))
    vim.keymap.set({ "n", "x" }, "<leader>.", vim.lsp.buf.code_action, opts(bufnr, "Code actions"))
    vim.keymap.set("n", "<leader>sa", function()
        workspace_symbols()
    end, opts(bufnr, "[S]earch [A]ll symbols"))
    vim.keymap.set("x", "<leader>sa", function()
        workspace_symbols(utils.get_visual_selection())
    end, opts(bufnr, "[S]earch selected symbol"))
    vim.keymap.set("n", "<leader>sm", document_symbols, opts(bufnr, "[S]earch [M]embers"))
    vim.keymap.set("n", "<leader>st", vim.lsp.buf.type_definition, opts(bufnr, "[S]earch [T]ype definition"))
    vim.keymap.set("n", "<leader>rg", utils.organize_imports, opts(bufnr, "[R]emove unused usings / or[g]anize imports"))

    vim.keymap.set("n", "<leader>en", function()
        vim.diagnostic.goto_next({
            severity = vim.diagnostic.severity.ERROR,
        })
    end, opts(bufnr, "[E]rror [N]ext"))
    vim.keymap.set("n", "<leader>ep", function()
        vim.diagnostic.goto_prev({
            severity = vim.diagnostic.severity.ERROR,
        })
    end, opts(bufnr, "[E]rror [P]revious"))

    vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float, opts(bufnr, "Show line diagnostics"))
    vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, opts(bufnr, "Signature help"))
    vim.keymap.set("n", "[d", vim.diagnostic.goto_next, opts(bufnr, "Next diagnostic"))
    vim.keymap.set("n", "]d", vim.diagnostic.goto_prev, opts(bufnr, "Previous diagnostic"))
    vim.keymap.set("n", "]e", function()
        vim.diagnostic.goto_next({
            severity = vim.diagnostic.severity.ERROR,
        })
    end, opts(bufnr, "Next error"))
    vim.keymap.set("n", "[e", function()
        vim.diagnostic.goto_prev({
            severity = vim.diagnostic.severity.ERROR,
        })
    end, opts(bufnr, "Previous error"))
    vim.keymap.set("n", "]w", function()
        vim.diagnostic.goto_next({
            severity = { min = vim.diagnostic.severity.WARN },
        })
    end, opts(bufnr, "Next warning/error"))
    vim.keymap.set("n", "[w", function()
        vim.diagnostic.goto_prev({
            severity = { min = vim.diagnostic.severity.WARN },
        })
    end, opts(bufnr, "Previous warning/error"))
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
    end, opts(bufnr, "Toggle inline diagnostics (virtual text)"))
end

return M
