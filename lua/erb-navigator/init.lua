local plenary = require("plenary")

local M = {}

M.settings = {
    regex = "<%%# *(.*) *%%>",
    line_numbers = true,
    width = 100,
    height = 30,
    borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
}

function M.setup(options)
    vim.tbl_deep_extend("force", M.settings, options)
end

local function get_buffer()
    return vim.api.nvim_buf_get_lines(0, 0, vim.api.nvim_buf_line_count(0), false)
end

local function set_keys(buffer)
    vim.api.nvim_buf_set_keymap(buffer, "n", "<Enter>", "<cmd>lua require('erb-navigator').go(" .. buffer .. ")<CR>", {})
    vim.api.nvim_buf_set_keymap(buffer, "n", "<Esc>",
        "<cmd>lua vim.api.nvim_buf_delete(" .. buffer .. ", {})<CR>", {})
end

function M.go(buffer)
    local idx = vim.api.nvim__buf_stats(buffer).current_lnum
    vim.api.nvim_buf_delete(buffer, {})

    local line = M.state[idx]
    vim.api.nvim_win_set_cursor(0,{line,0})
end

local function filter_comments(content)
    local numbers, values = {}, {}
    for i, v in ipairs(content) do
        local line = string.match(v, M.settings.regex)
        if line then
            numbers[#numbers+1] = i
            values[#values+1] = line
        end
    end
    return numbers, values
end

local function create_buffer(content)
    local buffer = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buffer, -2, -1, true, content)
    set_keys(buffer)
    return buffer
end

local function create_window(buffer, height, width)
    local title = vim.api.nvim_buf_get_name(0)
    if title == "" then
        title = "erb-navigator"
    end

    local win, _ = plenary.popup.create(buffer, {
        title = title,
        line = math.floor(((vim.o.lines - height) / 2) - 1),
        col = math.floor((vim.o.columns - width) / 2),
        minwidth = width,
        minheight = height,
        borderchars = M.settings.borderchars,
    })

    if M.settings.line_numbers then
        vim.api.nvim_win_set_option(win, "number", true)
    end

    return win
end

function M.nav()
    local line_numbers, comments = filter_comments(get_buffer())
    if comments[#comments] == "" then
        table.remove(comments, #comments)
    end

    M.state = line_numbers

    local buffer = create_buffer(comments)

    create_window(buffer, M.settings.height, M.settings.width)
end

return M
