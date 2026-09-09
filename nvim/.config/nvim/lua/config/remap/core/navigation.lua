local map = vim.keymap.set

map("n", "<C-h>", "<cmd>TmuxNavigateLeft<CR>", { desc = "Go to Left Window" })
map("n", "<C-j>", "<cmd>TmuxNavigateDown<CR>", { desc = "Go to Lower Window" })
map("n", "<C-k>", "<cmd>TmuxNavigateUp<CR>", { desc = "Go to Upper Window" })
map("n", "<C-l>", "<cmd>TmuxNavigateRight<CR>", { desc = "Go to Right Window" })

map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })

local function swap_tmux_pane(direction)
    local pane = vim.env.TMUX_PANE
    if not vim.env.TMUX or not pane or not pane:match("^%%%d+$") then
        return
    end

    local edge = ({ up = "top", down = "bottom", left = "left", right = "right" })[direction]
    -- Scope both the edge check and the source to this Neovim's pane.
    local result = vim.system({
        "tmux", "if-shell", "-t", pane, "-F", "#{pane_at_" .. edge .. "}", "",
        "swap-pane -d -s " .. pane .. " -t '{" .. direction .. "-of}'",
    }, { text = true }):wait()
    if result.code ~= 0 then
        vim.notify(result.stderr, vim.log.levels.ERROR, { title = "Move tmux pane" })
    end
end

local function swap_window(direction, tmux_direction)
    return function()
        local current = vim.api.nvim_get_current_win()
        local target_number = vim.fn.winnr(direction)
        local target = vim.fn.win_getid(target_number)

        if target == current then
            swap_tmux_pane(tmux_direction)
            return
        end

        vim.cmd("WinShift " .. tmux_direction)
    end
end

-- Clean up older mappings when this file is sourced in an existing editor.
for _, arrow in ipairs({ "Up", "Down", "Left", "Right" }) do
    pcall(vim.keymap.del, "n", "<C-S-" .. arrow .. ">")
    pcall(vim.keymap.del, "n", "<M-S-" .. arrow .. ">")
end

map("n", "<C-g><Up>", swap_window("k", "up"), { desc = "Move Window Up" })
map("n", "<C-g><Down>", swap_window("j", "down"), { desc = "Move Window Down" })
map("n", "<C-g><Left>", swap_window("h", "left"), { desc = "Move Window Left" })
map("n", "<C-g><Right>", swap_window("l", "right"), { desc = "Move Window Right" })
