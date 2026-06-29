local M = {}

local c_like_filetypes = {
    c = true,
    cpp = true,
    objc = true,
    objcpp = true,
    cuda = true,
    proto = true,
}

local function is_blank(line)
    return line:match("^%s*$") ~= nil
end

local function get_format_opts(bufnr)
    local opts = {
        async = true,
        bufnr = bufnr,
        lsp_format = "fallback",
    }

    if c_like_filetypes[vim.bo[bufnr].filetype] then
        opts.lsp_format = "never"
    end

    return opts
end

local function normalize_text(text)
    return vim.trim((text or ""):gsub("\n", " "):gsub("%s+", " "))
end

local function ordered_positions(pos_a, pos_b)
    local start_line, start_col = pos_a[2], pos_a[3]
    local end_line, end_col = pos_b[2], pos_b[3]

    if start_line > end_line or (start_line == end_line and start_col > end_col) then
        start_line, end_line = end_line, start_line
        start_col, end_col = end_col, start_col
    end

    return start_line, start_col, end_line, end_col
end

local function get_comment_parts(bufnr, ref_position)
    local commentstring = vim.bo[bufnr].commentstring
    local ok, mini_comment = pcall(require, "mini.comment")

    if ok and type(mini_comment.get_commentstring) == "function" then
        local computed = mini_comment.get_commentstring(ref_position)
        if type(computed) == "string" and computed ~= "" then
            commentstring = computed
        end
    end

    if type(commentstring) ~= "string" or commentstring == "" or not commentstring:find("%%s") then
        return nil
    end

    local left, right = commentstring:match("^(.-)%%s(.-)$")
    left = vim.trim(left or "")
    right = vim.trim(right or "")

    return {
        left = left == "" and "" or (left .. " "),
        right = right == "" and "" or (" " .. right),
    }
end

local function comment_line(line, parts)
    if is_blank(line) then
        return line
    end

    local indent, content = line:match("^(%s*)(.*)$")
    if parts.right == "" then
        return indent .. parts.left .. content
    end

    return indent .. parts.left .. content .. parts.right
end

local function uncomment_line(line, parts)
    if is_blank(line) then
        return line
    end

    local indent, content = line:match("^(%s*)(.*)$")
    local left = vim.trim(parts.left)
    local right = vim.trim(parts.right)

    if left == "" then
        return line
    end

    if right == "" then
        local updated, count = content:gsub("^" .. vim.pesc(left) .. "%s?", "", 1)
        return count == 0 and line or (indent .. updated)
    end

    local updated, count = content:gsub("^" .. vim.pesc(left) .. "%s?(.-)%s*" .. vim.pesc(right) .. "$", "%1", 1)
    return count == 0 and line or (indent .. updated)
end

local function replace_lines(line_start, line_end, transform)
    local lines = vim.api.nvim_buf_get_lines(0, line_start - 1, line_end, false)
    local updated = vim.tbl_map(transform, lines)
    vim.api.nvim_buf_set_lines(0, line_start - 1, line_end, false, updated)
end

local function open_cmdline(cmd)
    local keys = vim.api.nvim_replace_termcodes(":" .. cmd .. "<Left><Left><Left>", true, false, true)
    vim.schedule(function()
        vim.api.nvim_feedkeys(keys, "n", false)
    end)
end

local function escape_search_pattern(text)
    return vim.fn.escape((text or ""):gsub("\n", [[\n]]), [[/\]])
end

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
    require("conform").format(get_format_opts(bufnr))
end

function M.get_visual_range()
    local mode = vim.fn.mode()
    if not vim.tbl_contains({ "v", "V", "\22" }, mode) then
        return nil
    end

    local start_line, start_col, end_line, end_col = ordered_positions(vim.fn.getpos("v"), vim.fn.getcurpos())
    local end_line_text = vim.api.nvim_buf_get_lines(0, end_line - 1, end_line, false)[1] or ""

    if mode == "V" or mode == "\22" then
        start_col = 1
        end_col = #end_line_text
    end

    return {
        mode = mode,
        start = { line = start_line, col = math.max(start_col - 1, 0) },
        finish = { line = end_line, col = math.max(end_col, 0) },
    }
end

function M.get_visual_selection()
    local range = M.get_visual_range()
    if not range then
        return ""
    end

    local lines
    if range.mode == "V" or range.mode == "\22" then
        lines = vim.api.nvim_buf_get_lines(0, range.start.line - 1, range.finish.line, false)
    else
        lines = vim.api.nvim_buf_get_text(
            0,
            range.start.line - 1,
            range.start.col,
            range.finish.line - 1,
            range.finish.col,
            {}
        )
    end

    return table.concat(lines, "\n")
end

function M.comment_range(line_start, line_end)
    local parts = get_comment_parts(0, { line_start, 1 })
    if not parts then
        vim.notify("commentstring is not configured for this buffer", vim.log.levels.WARN)
        return
    end

    replace_lines(line_start, line_end, function(line)
        return comment_line(line, parts)
    end)
end

function M.uncomment_range(line_start, line_end)
    local parts = get_comment_parts(0, { line_start, 1 })
    if not parts then
        vim.notify("commentstring is not configured for this buffer", vim.log.levels.WARN)
        return
    end

    replace_lines(line_start, line_end, function(line)
        return uncomment_line(line, parts)
    end)
end

function M.comment_current_line()
    local line = vim.api.nvim_win_get_cursor(0)[1]
    M.comment_range(line, line)
end

function M.uncomment_current_line()
    local line = vim.api.nvim_win_get_cursor(0)[1]
    M.uncomment_range(line, line)
end

function M.comment_visual_selection()
    local range = M.get_visual_range()
    if not range then
        return
    end

    M.comment_range(range.start.line, range.finish.line)
end

function M.uncomment_visual_selection()
    local range = M.get_visual_range()
    if not range then
        return
    end

    M.uncomment_range(range.start.line, range.finish.line)
end

function M.substitute_current_word()
    local word = vim.fn.expand("<cword>")
    if word == "" then
        return
    end

    open_cmdline(string.format("%%s/\\V\\<%s\\>//gc", escape_search_pattern(word)))
end

function M.substitute_visual_selection()
    local text = M.get_visual_selection()
    if text == "" then
        return
    end

    open_cmdline(string.format("%%s/\\V%s//gc", escape_search_pattern(text)))
end

function M.organize_imports()
    vim.lsp.buf.code_action({
        apply = true,
        context = {
            only = { "source.organizeImports" },
            diagnostics = {},
        },
    })
end

function M.replace_in_files(search)
    search = normalize_text(search or vim.fn.expand("<cword>"))
    if search == "" then
        return
    end

    local ok, grug_far = pcall(require, "grug-far")
    if not ok then
        vim.notify("grug-far is not available. Run :Lazy sync to install it.", vim.log.levels.WARN)
        return
    end

    grug_far.open({
        prefills = {
            search = search,
        },
    })
end

function M.replace_visual_in_files()
    M.replace_in_files(M.get_visual_selection())
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
