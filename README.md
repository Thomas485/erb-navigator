# erb-navigator
A simple nvim plugin to jump around in eruby files.

At the moment there are three (probably buggy) features:

1. List all ruby comments (`<%# … %>`) in the current buffer and jump to them by pressing enter.
3. List all partials/views rendered in the current buffer (This is a jumplist, too)
4. Go to the partial/view mentioned in the current line.

## How to use

| No. | command | lua |
|---|---|---|
| 1 | :Erbnavigator | require("erb-navigator.comment\_jumplist").nav() |
| 2 | :ErbnavigatorViews | require("erb-navigator.views\_jumplist").nav() |
| 3 | :ErbnavigatorGoPartial | require("erb-navigator.views\_jumplist").go\_partial() |

## default settings

```lua
require('erb-navigator').setup({
    comment_jumplist = {
        regex = "<%%# *(.*) *%%>", -- the regex used to extract the comments
        line_numbers = true, -- show the line numbers in the list
        width = 100, -- width of the window
        height = 30, -- height of the window
        borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }, -- the borders, nil means no border
        keep_indent = true, -- preserve the indentation of the file (shows the values in a hierarchical manner)
    },
    views_jumplist = {
        line_numbers = true, -- show the line numbers in the list
        width = 100, -- width of the window
        height = 30, -- height of the window
        borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }, -- the borders, nil means no border
        filter_path = nil, -- a regex for files to be removed from the list. (e.g. '/?common/?')
        partial_regex = "<%%=%s*render[^\"']*[\"']([a-zA-Z_/]+)", -- regex to extract the partial-names
    },
})  

```

## screenshots

![erbnavigator4](https://github.com/Thomas485/erb-navigator/assets/1681511/39009081-2b2e-4e8f-b774-1293f2d79dd7)

