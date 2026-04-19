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

local function is_blank(line)
    return line:match("^%s*$") ~= nil
end

local function capture_block(start_line, end_line)
    local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
    local indents = {}
    local base_indent

    for i, line in ipairs(lines) do
        if is_blank(line) then
            indents[i] = nil
        else
            local indent = vim.fn.indent(start_line + i - 1)
            indents[i] = indent
            if base_indent == nil or indent < base_indent then
                base_indent = indent
            end
        end
    end

    return lines, indents, base_indent or 0
end

local function starts_block(line)
    return line:match("{%s*$")
        or line:match("%b()%s*{$")
        or line:match("%f[%a](then|do|else|elseif|repeat|function|try|catch|finally)%f[%A]%s*$")
        or line:match(":%s*$")
end

local function closes_block(line)
    return line:match("^%s*[}%])]")
        or line:match("^%s*%f[%a](end|else|elseif|until|catch|finally)%f[%A]")
end

local function target_indent_for_line(line_number)
    local previous = vim.fn.prevnonblank(line_number - 1)
    local shiftwidth = vim.fn.shiftwidth()
    local current_line = vim.api.nvim_buf_get_lines(0, line_number - 1, line_number, false)[1] or ""

    if previous == 0 then
        return 0
    end

    local previous_line = vim.api.nvim_buf_get_lines(0, previous - 1, previous, false)[1] or ""
    local previous_indent = vim.fn.indent(previous)

    if closes_block(current_line) then
        return math.max(previous_indent - shiftwidth, 0)
    end

    if starts_block(previous_line) then
        return previous_indent + shiftwidth
    end

    return previous_indent
end

local function apply_block_indent(start_line, end_line, lines, indents, base_indent, cursor_line, cursor_col)
    local target_indent = target_indent_for_line(start_line)
    local view = vim.fn.winsaveview()

    for offset, line in ipairs(lines) do
        local line_number = start_line + offset - 1

        if is_blank(line) then
            vim.api.nvim_buf_set_lines(0, line_number - 1, line_number, false, { "" })
        else
            local relative_indent = (indents[offset] or base_indent) - base_indent
            local indent = math.max(target_indent + relative_indent, 0)
            local content = line:gsub("^%s*", "")
            vim.api.nvim_buf_set_lines(0, line_number - 1, line_number, false, {
                string.rep(" ", indent) .. content,
            })
        end
    end

    if cursor_line and cursor_col then
        vim.api.nvim_win_set_cursor(0, { cursor_line, cursor_col })
    else
        vim.fn.winrestview(view)
    end
end

local function move_current_line(delta)
    local cursor = vim.api.nvim_win_get_cursor(0)
    local line = cursor[1]
    local line_count = vim.api.nvim_buf_line_count(0)
    local destination
    local lines, indents, base_indent = capture_block(line, line)

    if delta > 0 then
        destination = math.min(line + delta, line_count)
    else
        destination = math.max(line + delta - 1, 0)
    end

    if destination == line or destination == line - 1 then
        return
    end

    vim.cmd(string.format("%dmove %d", line, destination))
    local new_line = math.max(1, math.min(line + delta, line_count))
    apply_block_indent(new_line, new_line, lines, indents, base_indent, new_line, cursor[2])
end

local function block_base_indent(start_line, end_line)
    local base_indent

    for line_number = start_line, end_line do
        local line = vim.api.nvim_buf_get_lines(0, line_number - 1, line_number, false)[1] or ""
        if not is_blank(line) then
            local indent = vim.fn.indent(line_number)
            if base_indent == nil or indent < base_indent then
                base_indent = indent
            end
        end
    end

    return base_indent or 0
end

local function shift_block_indent(start_line, end_line, indent_delta)
    if indent_delta == 0 then
        return
    end

    local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
    local updated = {}

    for offset, line in ipairs(lines) do
        if is_blank(line) then
            updated[offset] = line
        else
            local line_number = start_line + offset - 1
            local content = line:gsub("^%s*", "")
            local indent = math.max(vim.fn.indent(line_number) + indent_delta, 0)
            updated[offset] = string.rep(" ", indent) .. content
        end
    end

    vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, updated)
end

local function move_visual_selection(delta)
    local start_pos = vim.fn.getpos("v")
    local end_pos = vim.fn.getcurpos()
    local start_line = math.min(start_pos[2], end_pos[2])
    local end_line = math.max(start_pos[2], end_pos[2])
    local line_count = vim.api.nvim_buf_line_count(0)
    local block_size = end_line - start_line + 1
    local destination
    local new_start

    if delta > 0 then
        destination = math.min(end_line + delta, line_count)
        new_start = math.min(start_line + delta, line_count - block_size + 1)
    else
        destination = math.max(start_line + delta - 1, 0)
        new_start = math.max(start_line + delta, 1)
    end

    if new_start == start_line then
        return
    end

    vim.cmd(string.format("%d,%dmove %d", start_line, end_line, destination))

    local new_end = new_start + block_size - 1
    local desired_indent = target_indent_for_line(new_start)
    local current_indent = block_base_indent(new_start, new_end)
    shift_block_indent(new_start, new_end, desired_indent - current_indent)

    vim.fn.setpos("'<", { 0, new_start, 1, 0 })
    vim.fn.setpos("'>", { 0, new_end, 1, 0 })
    vim.cmd("normal! gv")
end

function M.move_line_down()
    move_current_line(vim.v.count1)
end

function M.move_line_up()
    move_current_line(-vim.v.count1)
end

function M.move_selection_down()
    move_visual_selection(vim.v.count1)
end

function M.move_selection_up()
    move_visual_selection(-vim.v.count1)
end

return M
