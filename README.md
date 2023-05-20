# erb-navigator
A simple nvim plugin to jump around in eruby files.

At the moment there are three (probably buggy) features:

1. List all ruby comments (`<%# … %>`) in the current buffer and jump to them by pressing enter.
3. List all partials/views rendered in the current buffer (This is a jumplist, too)
4. Go to the partial/view mentioned in the current line.

## How to use

| No. | command | lua |
|---|---|---|
| 1 | :Erbnavigator | require("erb-navigator.comment_jumplist").nav() |
| 2 | :ErbnavigatorViews | require("erb-navigator.views_jumplist").nav() |
| 3 | :ErbnavigatorGoPartial | require("erb-navigator.views_jumplist").go_partial() |

