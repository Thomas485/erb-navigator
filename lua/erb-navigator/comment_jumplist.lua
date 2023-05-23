local plenary = require("plenary")
local settings = require("erb-navigator.settings")

local M = {}

local utility = require("erb-navigator.utility")

settings.settings = vim.tbl_deep_extend("force", settings.settings, {
    comment_jumplist = {
        regex = "(%s*)<%%# *(.*) *%%>", -- the regex used to extract the comments
        line_numbers = true, -- show the line numbers in the list
        width = 100, -- width of the window
        height = 30, -- height of the window
        borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }, -- the borders, nil means no border
        keep_indent = true, -- preserve the indentation of the file (shows the values in a hierarchical manner)
    }
})

local function filter_comments(content)
    local settings = settings.settings.comment_jumplist
    local numbers, values = {}, {}
    local indentations = {}
    for i, v in ipairs(content) do
        local indent, line = string.match(v, settings.regex)
        if line then
            if settings.keep_indent then
                numbers[#numbers+1] = i
                values[#values+1] = indent .. line
                table.insert(indentations, #indent)
            else
                numbers[#numbers+1] = i
                values[#values+1] = line
            end
        end
    end

    -- strip down indentation
    if settings.keep_indent then
        local min_indentation = math.huge
        for _, indent in ipairs(indentations) do
            min_indentation = min_indentation < indent and min_indentation or  indent
        end
        for i = 1, #values, 1 do
            values[i] = string.sub(values[i], min_indentation+1)
        end
    end
    return numbers, values
end

local function set_keys(buffer)
    vim.api.nvim_buf_set_keymap(buffer, "n", "<Enter>", "<cmd>lua require('erb-navigator.comment_jumplist').go(" .. buffer .. ")<CR>", {})
    vim.api.nvim_buf_set_keymap(buffer, "n", "<Esc>",
        "<cmd>lua vim.api.nvim_buf_delete(" .. buffer .. ", {})<CR>", {})
end

local function create_buffer(content)
    local buffer = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buffer, -2, -1, true, content)
    vim.api.nvim_buf_set_option(buffer, 'readonly', true)
    set_keys(buffer)
    return buffer
end

local function create_window(buffer, height, width)
    local settings = settings.settings.comment_jumplist
    local title = utility.get_title(0)

    local win, _ = plenary.popup.create(buffer, {
        title = title,
        line = math.floor(((vim.o.lines - height) / 2) - 1),
        col = math.floor((vim.o.columns - width) / 2),
        minwidth = width,
        minheight = height,
        borderchars = settings.borderchars,
    })

    if settings.line_numbers then
        vim.api.nvim_win_set_option(win, "number", true)
    end

    return win
end

function M.nav()
    local settings = settings.settings.comment_jumplist
    local line_numbers, comments = filter_comments(utility.get_buffer())
    if comments[#comments] == "" then
        table.remove(comments, #comments)
    end

    M.state = line_numbers

    local buffer = create_buffer(comments)

    create_window(buffer, settings.height, settings.width)
end

function M.go(buffer)
    local idx = vim.api.nvim__buf_stats(buffer).current_lnum
    vim.api.nvim_buf_delete(buffer, {})

    local line = M.state[idx]
    vim.api.nvim_win_set_cursor(0,{line,0})
end

return M
