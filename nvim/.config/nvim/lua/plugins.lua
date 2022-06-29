local fn = vim.fn
local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  packer_bootstrap = fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
  vim.cmd[[packadd packer.nvim]]
end

return require('packer').startup(function(use)
    use {'wbthomason/packer.nvim'}

    -- general
    use {'inkarkat/vim-ReplaceWithRegister'}
    use {'machakann/vim-sandwich'}
    use {'tpope/vim-abolish'}
    use {'tpope/vim-dispatch'}
    use {'tpope/vim-unimpaired'}
    use {'wsdjeg/vim-fetch'}
    use {'numToStr/Comment.nvim', config = function() require'Comment'.setup() end }
    use {'mg979/vim-visual-multi'}

    -- undotree
    use {'mbbill/undotree'}

    -- appearance
    use {'lukas-reineke/indent-blankline.nvim', config = function() require'indent_blankline'.setup {filetype = {'python', 'json', 'bzl'} } end }
    use {'nvim-lualine/lualine.nvim', config = function() require'config.lualine'.setup() end }
    use {'kyazdani42/nvim-web-devicons', config = function() require'nvim-web-devicons'.setup() end }
    use {'norcalli/nvim-colorizer.lua', config = function() require'colorizer'.setup() end }
    use {'akinsho/nvim-bufferline.lua', config = function() require'config.bufferline'.setup() end }
    use {'luukvbaal/stabilize.nvim', config = function() require("stabilize").setup() end }

    -- filetree
    use {'kyazdani42/nvim-tree.lua', config = function() require'config.nvimtree'.setup() end }

    -- colorschemes
    use {'sainnhe/everforest', config = function() require'config.everforest'.setup() end }

    -- wiki
    use {'vimwiki/vimwiki', config = function() require'config.vimwiki'.setup() end }

    -- markdown
    use {'davidgranstrom/nvim-markdown-preview'}

    -- git
    use {'TimUntersberger/neogit'}
    use {'tpope/vim-fugitive'}
    use {'tpope/vim-rhubarb'}
    use {'sindrets/diffview.nvim', config = function() require'diffview'.setup() end }
    use {'lewis6991/gitsigns.nvim', config = function() require'gitsigns'.setup() end }
    use {'rhysd/conflict-marker.vim', config = function() require'config.conflict_marker'.setup() end }

    -- tmux jump windows
    use {'christoomey/vim-tmux-navigator'}

    -- null-ls for autoformat
    use {'jose-elias-alvarez/null-ls.nvim', config = function() require'config.null-ls'.setup() end }

    -- bazel
    use {'google/vim-maktaba'}
    use {'bazelbuild/vim-bazel'}
    use {'alexander-born/bazel-vim', config = function() require'config.bazel'.setup() end }

    -- telescope
    use {'nvim-lua/popup.nvim'}
    use {'nvim-lua/plenary.nvim'}
    use {'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }
    use {'nvim-telescope/telescope.nvim', config = function() require'config.telescope'.setup() end }
    use {'AckslD/nvim-neoclip.lua', config = function() require('neoclip').setup() end }

    -- debugging
    use {'szw/vim-maximizer'}
    use {'rcarriga/nvim-dap-ui'}
    use {'mfussenegger/nvim-dap', config = function() require'config.dap'.setup() end }
    use {'nvim-telescope/telescope-dap.nvim'}
    -- use {'Pocco81/DAPInstall.nvim', config = function() require("dap-install").setup() end }

    -- treesitter
    use {'nvim-treesitter/nvim-treesitter', run = ':TSUpdate', config = function() require'config.treesitter'.setup() end }
    use {'nvim-treesitter/nvim-treesitter-textobjects'}
    use {'nvim-treesitter/playground'}

    -- trouble
    use {'folke/trouble.nvim', config = function() require'trouble'.setup() end }

    -- lsp
    use {'williamboman/nvim-lsp-installer'}
    use {'neovim/nvim-lspconfig', config = function() require'config.lsp'.setup() end }
    use {'ray-x/lsp_signature.nvim', config = function() require'lsp_signature'.setup({hint_enable = false}) end }
    use {'j-hui/fidget.nvim', config = function() require'fidget'.setup() end }

    -- completion
    use {'onsails/lspkind-nvim', config = function() require'lspkind'.init() end }

    -- cmp
    use {'hrsh7th/nvim-cmp', config = function() require'config.cmp'.setup() end }
    use {'hrsh7th/cmp-nvim-lsp'}
    use {'hrsh7th/cmp-path'}
    use {'hrsh7th/cmp-buffer'}
    use {'hrsh7th/cmp-vsnip', config = function() require'config.vsnip'.setup() end }
    use {'alexander-born/cmp-bazel'}

    -- snippets
    use {'hrsh7th/vim-vsnip'}
    use {'rafamadriz/friendly-snippets'}

    -- mappings
    use {'folke/which-key.nvim', config = function() require'config.mappings'.setup() end }

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if packer_bootstrap then
    require('packer').sync()
  end
end)

