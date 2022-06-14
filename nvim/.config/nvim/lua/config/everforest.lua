local M = {}

function M.setup()
    vim.cmd[[
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
    ]]
end
return M
