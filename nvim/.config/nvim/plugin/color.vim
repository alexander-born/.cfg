let g:color_scheme = 'everforest'
let g:everforest_background = 'hard'
let g:everforest_disable_italic_comment = 1
let g:everforest_diagnostic_virtual_text = 'colored'
let g:everforest_palette = everforest#get_palette(everforest#get_configuration().background, everforest#get_configuration().colors_override)
autocmd ColorScheme everforest call everforest#highlight('DiffText', ['NONE', 'NONE', 'NONE'], ['#546b76', '17', 'LightBlue'])
" autocmd ColorScheme everforest call everforest#highlight('ErrorText', g:everforest_palette.none, g:everforest_palette.none, 'NONE', g:everforest_palette.red)
autocmd ColorScheme everforest call everforest#highlight('WarningText', g:everforest_palette.none, g:everforest_palette.none, 'NONE', g:everforest_palette.yellow)
autocmd ColorScheme everforest call everforest#highlight('InfoText', g:everforest_palette.none, g:everforest_palette.none, 'NONE', g:everforest_palette.blue)
autocmd ColorScheme everforest call everforest#highlight('HintText', g:everforest_palette.none, g:everforest_palette.none, 'NONE', g:everforest_palette.green)
exe "colorscheme " . g:color_scheme
call everforest#highlight('MultiMonoHl', g:everforest_palette.fg, g:everforest_palette.red)
call everforest#highlight('MultiCursorHl', g:everforest_palette.fg, g:everforest_palette.orange)
let g:VM_Mono_hl = 'MultiMonoHl'
let g:VM_Extend_hl = 'Visual'
let g:VM_Cursor_hl = 'MultiCursorHl'
let g:VM_Insert_hl = 'DiffChange'
