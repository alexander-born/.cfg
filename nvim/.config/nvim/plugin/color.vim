let g:color_scheme = 'everforest'
let g:everforest_background = 'hard'
let g:everforest_disable_italic_comment = 1
let g:everforest_diagnostic_virtual_text = 'colored'
autocmd ColorScheme everforest call everforest#highlight('DiffText', ['NONE', 'NONE', 'NONE'], ['#546b76', '17', 'LightBlue'])
exe "colorscheme " . g:color_scheme

hi link LspDiagnosticsVirtualTextError Red
hi link LspDiagnosticsVirtualTextWarning Yellow
hi link LspDiagnosticsUnderlineError Red
hi link LspDiagnosticsUnderlineWarning Yellow
