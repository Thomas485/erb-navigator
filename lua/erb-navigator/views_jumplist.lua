local plenary = require("plenary")
local settings = require("erb-navigator.settings")

local utility = require("erb-navigator.utility")

local M = {}

settings.settings = vim.tbl_deep_extend("force", settings.settings, {
    views_jumplist = {
        line_numbers = true, -- show the line numbers in the list
        width = 100, -- width of the window
        height = 30, -- height of the window
        borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }, -- the borders, nil means no border
        filter_path = nil, -- a regex for files to be removed from the list. (e.g. '/?common/?')
        partial_regex = "<%%=%s*render[^\"']*[\"']([a-zA-Z_/]+)", -- regex to extract the partial-names
    }
})

local function is_controller(buffer)
    local name = nil
    if type(buffer) == "string" then
        name = buffer
    else
        name = vim.api.nvim_buf_get_name(buffer)
    end
    return utility.endswith(name, "_controller.rb")
end

local function is_erb(filename)
    return utility.endswith(filename, "html.erb")
end

local function to_partial_name(filepath)
    local base = vim.fs.basename(filepath)
    return "_" .. base .. ".html.erb"
end

local function set_keys(buffer)
    vim.api.nvim_buf_set_keymap(buffer, "n", "<Enter>", "<cmd>lua require('erb-navigator.views_jumplist').go(" .. buffer .. ")<CR>", {})
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
    local settings = settings.settings.views_jumplist
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

local function filter_out(table1, table2, str)
    local t1 = {}
    local t2 = {}
    for i, a in ipairs(table1) do
        if not string.find(a, str) and not string.find(table2[i], str) then
            table.insert(t1, a)
            table.insert(t2, table2[i])
        end
    end
    return t1, t2
end

local function append_path(partials, paths, prefix)
    local result = {}
    for i, partial in ipairs(partials) do
        local path = paths[i]
        path = (path:sub(0, #prefix) == prefix) and path:sub(#prefix+1) or path
        table.insert(result, partial .. " (" .. path ..  ")")
    end

    return result
end

function M.nav()
    local settings = settings.settings.views_jumplist
    local app_root = vim.fs.find("app", { upward = true })
    local filename = vim.api.nvim_buf_get_name(0)
    if is_controller(filename) then
        local buffer_content = table.concat(utility.get_buffer(0), "\n")
        local methods = {}
        for method in  string.gmatch(buffer_content, " *def ([^ (#]+)")  do
            table.insert(methods, method)
        end
        -- TODO: find all views
    elseif is_erb(filename) then
        local buffer_content = table.concat(utility.get_buffer(0), "\n")
        local partials = {}
        for partial in  string.gmatch(buffer_content, settings.partial_regex) do
            table.insert(partials, partial)
        end

        local paths = {}
        for _, partial in pairs(partials) do
            local path =  vim.fs.find(to_partial_name(partial), { path=app_root[1] .. "/views", type = "file" })
            if path then
                table.insert(paths, path)
            else
                table.insert(paths, nil)
            end
        end

        -- TODO: not assuming there is only one file found
        if settings.filter_path then
            paths, partials = filter_out(vim.tbl_flatten(paths), partials, settings.filter_path)
        else
            paths = vim.tbl_flatten(paths)
        end

        M.state = paths

        local buffer = create_buffer(append_path(partials, paths, app_root[1] .. "/"))

        create_window(buffer, settings.height, settings.width)
    end
end

-- go to the partial in the current line.
function M.go_partial()
    local settings = settings.settings.views_jumplist
    local app_root = vim.fs.find("app", { upward = true })

    local line_number, _ = unpack(vim.api.nvim_win_get_cursor(0))
    local current_line = vim.api.nvim_buf_get_lines(0, line_number-1, line_number, true)
    local name = string.match(current_line[1], settings.partial_regex)

    if name and name ~= "" then
        local path =  vim.fs.find(to_partial_name(name), { path=app_root[1] .. "/views", type = "file" })
        if #path == 0 then
            print("File not found")
        elseif #path == 1 then
            vim.cmd("e " .. path[1])
        else
            print("The partial name is ambiguous.")
        end
    else
        print("Could not find a partial in the current line")
    end
end

function M.go(buffer)
    local idx = vim.api.nvim__buf_stats(buffer).current_lnum
    vim.api.nvim_buf_delete(buffer, {})
    local path = M.state[idx]
    vim.cmd("e " .. path)
end

return M
