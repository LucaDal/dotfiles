local M = {}

local function opts(bufnr, desc)
    return { buffer = bufnr, desc = desc }
end

function M.on_attach(bufnr)
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts(bufnr, "Go to definition"))
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts(bufnr, "Hover documentation"))
    vim.keymap.set("n", "<leader>vws", vim.lsp.buf.workspace_symbol, opts(bufnr, "Search workspace symbols"))
    vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float, opts(bufnr, "Show line diagnostics"))
    vim.keymap.set("n", "<leader>vde", function()
        vim.diagnostic.setloclist({
            severity = vim.diagnostic.severity.ERROR,
        })
        vim.cmd("lopen")
    end, opts(bufnr, "Open buffer errors (loclist)"))
    vim.keymap.set("n", "<leader>vdw", function()
        vim.diagnostic.setloclist({
            severity = { min = vim.diagnostic.severity.WARN },
        })
        vim.cmd("lopen")
    end, opts(bufnr, "Open buffer warnings (loclist)"))
    vim.keymap.set("n", "<leader>vdqe", function()
        vim.diagnostic.setqflist({
            severity = vim.diagnostic.severity.ERROR,
        })
        vim.cmd("copen")
    end, opts(bufnr, "Open workspace errors (quickfix)"))
    vim.keymap.set("n", "<leader>vdl", function()
        vim.diagnostic.setloclist()
        vim.cmd("lopen")
    end, opts(bufnr, "Open buffer diagnostics list (loclist)"))

    vim.keymap.set("n", "<leader>vca", vim.lsp.buf.code_action, opts(bufnr, "Code actions"))
    vim.keymap.set("n", "<leader>vrr", vim.lsp.buf.references, opts(bufnr, "List references"))
    vim.keymap.set("n", "<leader>vrn", vim.lsp.buf.rename, opts(bufnr, "Rename symbol"))
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
    vim.keymap.set("n", "<leader>vdq", function()
        vim.diagnostic.setqflist()
        vim.cmd("copen")
    end, opts(bufnr, "Open workspace diagnostics (quickfix)"))
    vim.keymap.set("n", "<leader>vf", function()
        require("config.utils").format_buffer(bufnr)
    end, opts(bufnr, "Format buffer"))
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
