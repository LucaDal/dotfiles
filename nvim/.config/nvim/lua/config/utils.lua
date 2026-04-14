local M = {}

local c_like_filetypes = {
    c = true,
    cpp = true,
    objc = true,
    objcpp = true,
    cuda = true,
    proto = true,
}

--Returns a dot repeatable version of a function to be used in keymaps
--that pressing `.` will repeat the action.
--Example: `vim.keymap.set('n', 'ct', dot_repeat(function() print(os.clock()) end), { expr = true })`
--Setting expr = true in the keymap is required for this function to make the keymap repeatable
--based on gist: https://gist.github.com/kylechui/a5c1258cd2d86755f97b10fc921315c3
function M.dot_repeat(
    callback --[[Function]]
)
    return function()
        _G.dot_repeat_callback = callback
        vim.go.operatorfunc = 'v:lua.dot_repeat_callback'
        return 'g@l'
    end
end

function M.format_buffer(bufnr)
    bufnr = bufnr or vim.api.nvim_get_current_buf()

    local opts = {
        async = true,
        bufnr = bufnr,
        lsp_format = "fallback",
    }

    if c_like_filetypes[vim.bo[bufnr].filetype] then
        opts.lsp_format = "never"
    end

    require("conform").format(opts)
end

return M
