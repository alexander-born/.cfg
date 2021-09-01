local install_path = vim.fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  vim.fn.system({'git', 'clone', 'https://github.com/wbthomason/packer.nvim', install_path})
  vim.cmd('packadd packer.nvim')
end

vim.cmd([[autocmd BufWritePost plugins.lua source <afile> | PackerCompile]])

return require('packer').startup(function(use)
    -- Packer can manage itself
    use 'wbthomason/packer.nvim'

    -- general
    use 'inkarkat/vim-ReplaceWithRegister'
    use 'machakann/vim-sandwich'
    use 'tpope/vim-abolish'
    use 'tpope/vim-commentary'
    use 'tpope/vim-dispatch'
    use 'tpope/vim-unimpaired'
    use 'wsdjeg/vim-fetch'
    -- use 'ggandor/lightspeed.nvim'

    -- undotree
    use 'mbbill/undotree'

    -- appearance
    use 'lukas-reineke/indent-blankline.nvim'
    use 'hoob3rt/lualine.nvim'
    use {'kyazdani42/nvim-web-devicons', config= function() require('nvim-web-devicons').setup() end }
    use 'akinsho/nvim-bufferline.lua'
    use {'norcalli/nvim-colorizer.lua', config = function() require'colorizer'.setup() end }
    use {'folke/todo-comments.nvim', config = function() require'todo-comments'.setup() end }

    -- filetree
    use 'kyazdani42/nvim-tree.lua'

    -- colorschemes
    use 'sainnhe/everforest'
    use 'sainnhe/gruvbox-material'
    use 'ChristianChiarulli/nvcode-color-schemes.vim'

    -- grep
    use 'mileszs/ack.vim'

    -- wiki
    use 'vimwiki/vimwiki'

    -- markdown
    use {'iamcco/markdown-preview.nvim', ft = {'markdown'}, run = 'vim.cmd("mkdp#util#install()")'}

    -- git
    use 'tpope/vim-fugitive'
    use 'tpope/vim-rhubarb'
    use 'lewis6991/gitsigns.nvim'
    use 'rhysd/conflict-marker.vim'

    -- tmux jump windows
    use 'christoomey/vim-tmux-navigator'

    -- python
    use 'alfredodeza/pytest.vim'

    -- autoformat
    use 'google/vim-codefmt'
    use 'google/vim-glaive'
    use 'google/vim-maktaba'

    -- bazel
    use 'bazelbuild/vim-bazel'
    use 'alexander-born/bazel-vim'

    -- debugging
    use 'szw/vim-maximizer'
    use 'puremourning/vimspector'

    -- telescope
    use 'nvim-lua/popup.nvim'
    use 'nvim-lua/plenary.nvim'
    use 'nvim-telescope/telescope.nvim'
    use 'nvim-telescope/telescope-fzy-native.nvim'

    -- treesitter
    use {'nvim-treesitter/nvim-treesitter', run = ':TSUpdate'}
    use 'nvim-treesitter/nvim-treesitter-textobjects'
    use 'nvim-treesitter/playground'

    -- trouble
    use {'folke/trouble.nvim', config = function() require'trouble'.setup() end }

    -- lsp
    use 'neovim/nvim-lspconfig'
    use 'kabouzeid/nvim-lspinstall'
    use 'hrsh7th/nvim-compe'
    use 'ray-x/lsp_signature.nvim'
    use 'onsails/lspkind-nvim'
    use 'aymericbeaumet/vim-symlink'

    -- snippets
    use 'hrsh7th/vim-vsnip'
    use 'hrsh7th/vim-vsnip-integ'
    use 'rafamadriz/friendly-snippets'

end)
