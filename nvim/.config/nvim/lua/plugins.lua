local install_path = vim.fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  vim.fn.system({'git', 'clone', 'https://github.com/wbthomason/packer.nvim', install_path})
  vim.cmd('packadd packer.nvim')
end

vim.cmd([[autocmd BufWritePost plugins.lua source <afile> | PackerCompile]])

return require('packer').startup(function(use)
    -- Packer can manage itself
    use {'wbthomason/packer.nvim'}

    -- general
    use {'inkarkat/vim-ReplaceWithRegister'}
    use {'machakann/vim-sandwich'}
    use {'tpope/vim-abolish'}
    use {'tpope/vim-commentary'}
    use {'tpope/vim-dispatch'}
    use {'tpope/vim-unimpaired'}
    use {'wsdjeg/vim-fetch'}
    -- use {'ggandor/lightspeed.nvim', config = function() require'lightspeed'.setup({}) end }

    -- undotree
    use {'mbbill/undotree'}

    -- appearance
    use {'lukas-reineke/indent-blankline.nvim', config = function() require'indent_blankline'.setup {filetype = {'python', 'json', 'bzl'} } end }
    use {'nvim-lualine/lualine.nvim', config = function() require'config.lualine'.setup() end }
    use {'kyazdani42/nvim-web-devicons', config = function() require'nvim-web-devicons'.setup() end }
    use {'norcalli/nvim-colorizer.lua', config = function() require'colorizer'.setup() end }
    use {'folke/todo-comments.nvim', config = function() require'todo-comments'.setup() end }
    use {'akinsho/nvim-bufferline.lua', config = function() require'config.bufferline'.setup() end }
    use {'luukvbaal/stabilize.nvim', config = function() require("stabilize").setup() end }

    -- filetree
    use {'kyazdani42/nvim-tree.lua', config = function() require'config.nvimtree'.setup() end }

    -- colorschemes
    use {'sainnhe/everforest'}
    use {'sainnhe/gruvbox-material'}
    use {'ChristianChiarulli/nvcode-color-schemes.vim'}

    -- grep
    use {'mileszs/ack.vim'}

    -- wiki
    use {'vimwiki/vimwiki'}

    -- markdown
    use {'iamcco/markdown-preview.nvim', ft = {'markdown'}, run = 'vim.cmd("mkdp#util#install()")'}

    -- git
    use {'tpope/vim-fugitive'}
    use {'tpope/vim-rhubarb'}
    use {'lewis6991/gitsigns.nvim', config = function() require'gitsigns'.setup() end }
    use {'rhysd/conflict-marker.vim'}

    -- tmux jump windows
    use {'christoomey/vim-tmux-navigator'}

    -- python
    use {'alfredodeza/pytest.vim'}

    -- autoformat
    use {'google/vim-codefmt'}
    use {'google/vim-glaive'}
    use {'google/vim-maktaba'}

    -- bazel
    use {'bazelbuild/vim-bazel'}
    use {'alexander-born/bazel-vim', config = function() require'config.bazel'.setup() end }

    -- debugging
    use {'szw/vim-maximizer'}
    use {'puremourning/vimspector'}

    -- telescope
    use {'nvim-lua/popup.nvim'}
    use {'nvim-lua/plenary.nvim'}
    use {'nvim-telescope/telescope-fzy-native.nvim'}
    use {'nvim-telescope/telescope.nvim', config = function() require'config.telescope'.setup() end }
    use {'AckslD/nvim-neoclip.lua', config = function() require('neoclip').setup() end }

    -- treesitter
    use {'nvim-treesitter/nvim-treesitter', run = ':TSUpdate', config = function() require'config.treesitter'.setup() end }
    use {'nvim-treesitter/nvim-treesitter-textobjects'}
    use {'nvim-treesitter/playground'}

    -- trouble
    use {'folke/trouble.nvim', config = function() require'trouble'.setup() end }

    -- lsp
    use {'kabouzeid/nvim-lspinstall', config = function() require'lspinstall'.setup() end }
    use {'neovim/nvim-lspconfig', config = function() require'config.lsp'.setup() end }
    use {'ray-x/lsp_signature.nvim', config = function() require'lsp_signature'.setup({hint_enable = false}) end }
    use {'aymericbeaumet/vim-symlink'}

    -- completion
    use {'onsails/lspkind-nvim', config = function() require'lspkind'.init() end }

    -- cmp
    use {'hrsh7th/nvim-cmp', config = function() require'config.cmp'.setup() end }
    use {'hrsh7th/cmp-nvim-lsp'}
    use {'hrsh7th/cmp-path'}
    use {'hrsh7th/cmp-buffer'}
    use {'hrsh7th/cmp-vsnip'}
    use {'alexander-born/cmp-bazel'}

    -- snippets
    use {'hrsh7th/vim-vsnip'}
    use {'rafamadriz/friendly-snippets'}


end)
