command! -nargs=0 Erbnavigator lua require("erb-navigator.comment_jumplist").nav()
command! -nargs=0 ErbnavigatorViews lua require("erb-navigator.views_jumplist").nav()
command! -nargs=0 ErbnavigatorGoPartial lua require("erb-navigator.views_jumplist").go_partial()
