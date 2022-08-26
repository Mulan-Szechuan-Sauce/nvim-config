local use = require('packer').use

use 'wbthomason/packer.nvim'
use 'nvim-lua/plenary.nvim'

use {
    'mrjones2014/legendary.nvim',
    config = function()
        require('legendary').setup()
        require('shared.commands')
        require('shared.autocommands')
    end,
}

use 'tpope/vim-surround'
use 'tpope/vim-repeat'
use 'tpope/vim-rsi'
use 'nelstrom/vim-visual-star-search'
use 'tommcdo/vim-lion'
use 'lambdalisue/suda.vim'
use 'sbdchd/neoformat'
use 'famiu/bufdelete.nvim'

use {
    'ggandor/leap.nvim',
    config = function() require('leap').set_default_keymaps() end
}

use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate',
    config = function()
        require('nvim-treesitter.configs').setup({
            sync_install = false,
            highlight = {
                enable = true,
                additional_vim_regex_highlighting = false,
            },
        });
        require('shared.plugins.treesitter');
    end
}

use {
    'nvim-lualine/lualine.nvim',
    requires = { 'kyazdani42/nvim-web-devicons', opt = true },
    config = function() require('shared.plugins.lualine') end
}

use {
    'nvim-telescope/telescope.nvim',
    requires = {
        'kyazdani42/nvim-web-devicons',
        { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' },
        'nvim-telescope/telescope-file-browser.nvim',
    },
    config = function()
        require('telescope').setup({
            defaults = {
                sorting_strategy = 'ascending',
                layout_config = {
                    horizontal = {
                        prompt_position = "top",
                    },
                },
            },
            pickers = {
                git_files = {
                    show_untracked = true,
                },
            },
        });
        require('telescope').load_extension('fzf');
        require('telescope').load_extension('file_browser');
    end
}

use {
    'stevearc/dressing.nvim',
    setup = function()
        require('legendary').bind_autocmds({
            { 'ColorScheme', function()
                vim.api.nvim_set_hl(0, 'FloatBorder', { fg = "fg" })
            end },
        })
    end,
    config = function()
        require('dressing').setup({
            input = {
                winblend = 0,
            },
        })
    end
}

use {
    'hrsh7th/nvim-cmp',
    requires = {
        'neovim/nvim-lspconfig',
        'hrsh7th/cmp-nvim-lsp',
        'L3MON4D3/LuaSnip',
        'saadparwaiz1/cmp_luasnip',
        'onsails/lspkind.nvim',
        'hrsh7th/cmp-path',
        'hrsh7th/cmp-cmdline',
    },
    config = function() require('shared.plugins.cmp') end
}

use {
    'folke/trouble.nvim',
    requires = 'kyazdani42/nvim-web-devicons',
    config = function()
        require('trouble').setup();
    end
}

use {
    'williamboman/mason.nvim',
    requires = {
        'williamboman/mason-lspconfig.nvim',
        'neovim/nvim-lspconfig',
    },
    config = function()
        require('shared.plugins.lsp-config')
        require('shared.plugins.lsp-ui-config')
    end
}

use {
    'j-hui/fidget.nvim',
    requires = { 'neovim/nvim-lspconfig' },
    config = function()
        require('fidget').setup({})
    end
}

use 'folke/lua-dev.nvim'

use {
    'mfussenegger/nvim-dap',
    requires = {
        'rcarriga/nvim-dap-ui',
        'Weissle/persistent-breakpoints.nvim',
    },
    config = function() require('shared.plugins.dap') end,
}

use {
    'akinsho/toggleterm.nvim',
    tag = 'v1.*',
    config = function()
        require('toggleterm').setup()
    end
}

use {
    'TimUntersberger/neogit',
    config = function()
        require('neogit').setup {}
    end
}

use {
    'numToStr/Comment.nvim',
    config = function()
        require('Comment').setup()
    end
}
