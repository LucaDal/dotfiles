local M = {}

local c_like = { c = true, cpp = true, objc = true, objcpp = true, cuda = true, proto = true }

function M.options(bufnr)
    bufnr = bufnr or vim.api.nvim_get_current_buf()
    return {
        bufnr = bufnr,
        lsp_format = c_like[vim.bo[bufnr].filetype] and "never" or "fallback",
    }
end

function M.enabled(bufnr)
    bufnr = bufnr or vim.api.nvim_get_current_buf()
    local enabled = vim.b[bufnr].autoformat
    if enabled ~= nil then
        return enabled
    end
    return not c_like[vim.bo[bufnr].filetype]
end

function M.toggle()
    vim.b.autoformat = not M.enabled()
    vim.notify("Format on save (this buffer): " .. (vim.b.autoformat and "ON" or "OFF"))
end

function M.on_save(bufnr)
    if not M.enabled(bufnr) then
        return nil
    end
    local opts = M.options(bufnr)
    opts.timeout_ms = 1000
    return opts
end

return M
