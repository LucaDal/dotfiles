local M = {}

local function check_visible_files()
    local mode = vim.api.nvim_get_mode().mode:sub(1, 1)
    if (mode ~= "n" and mode ~= "t") or vim.fn.getcmdwintype() ~= "" then
        return
    end

    local checked = {}
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        if not checked[buf] then
            checked[buf] = true
            local options = vim.bo[buf]
            local autoread = options.autoread
            if autoread == nil then
                autoread = vim.go.autoread
            end
            if options.buftype == "" and not options.modified and autoread
                and vim.api.nvim_buf_get_name(buf) ~= "" then
                vim.cmd("silent checktime " .. buf)
            end
        end
    end
end

function M.setup()
    vim.opt.autoread = true

    if M.timer then
        vim.fn.timer_stop(M.timer)
    end

    local group = vim.api.nvim_create_augroup("AutoReloadFiles", { clear = true })
    vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "TermLeave", "InsertLeave" }, {
        group = group,
        callback = check_visible_files,
    })

    -- Poll even when the terminal does not report focus changes or stays idle.
    M.timer = vim.fn.timer_start(1000, check_visible_files, { ["repeat"] = -1 })
    vim.api.nvim_create_autocmd("VimLeavePre", {
        group = group,
        callback = function()
            vim.fn.timer_stop(M.timer)
            M.timer = nil
        end,
    })
end

return M
