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
            ensure_installed = { "comment" },
            sync_install = false,
            highlight = {
                enable = true,
                additional_vim_regex_highlighting = false,
            },
            rainbow = {
                enable = true,
                extended_mode = true,
                max_file_lines = 10000,
            },
        });
        require('shared.plugins.treesitter');
    end
}

use {
    'nvim-treesitter/nvim-treesitter-context',
    requires = { 'nvim-treesitter/nvim-treesitter' },
}

use {
    'nvim-lualine/lualine.nvim',
    requires = { 'kyazdani42/nvim-web-devicons', opt = true },
    config = function() require('shared.plugins.lualine') end
}

use {
    'ibhagwan/fzf-lua',
    requires = { 'kyazdani42/nvim-web-devicons' },
    config = function()
        require('fzf-lua').setup({
            global_resume = true,
            global_resume_query = true,
            git = {
                files = {
                    cmd = 'git ls-files --exclude-standard --cached --others',
                },
            },
        })
    end
}

use {
    'stevearc/dressing.nvim',
    setup = function()
        require('legendary').autocmds({
            { 'ColorScheme', function()
                vim.api.nvim_set_hl(0, 'FloatBorder', { fg = "fg" })
            end },
        })
    end,
    config = function()
        require('dressing').setup({
            input = {
                win_options = {
                    winblend = 0,
                },
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

use 'folke/neodev.nvim'

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

use {
    'ray-x/lsp_signature.nvim',
    requires = { 'neovim/nvim-lspconfig' },
    config = function()
        require('lsp_signature').setup({
            bind = true,
            hint_enable = true,
            floating_window = false,
            always_trigger = true,
            auto_close_after = 4,
        })
    end
}

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
    tag = '*',
    config = function()
        require('toggleterm').setup()
    end
}

--use {
--    'TimUntersberger/neogit',
--    config = function()
--        require('neogit').setup {}
--    end
--}

use {
    'numToStr/Comment.nvim',
    config = function()
        require('Comment').setup()
    end
}

use 'mrjones2014/nvim-ts-rainbow'
use 'gpanders/editorconfig.nvim'

use {
    'is0n/jaq-nvim',
    config = function()
        require('jaq-nvim').setup {
            cmds = {
                -- Uses vim commands
                internal = {
                    lua = "luafile %",
                    vim = "source %"
                },
                -- Uses shell commands
                external = {
                    markdown = "glow %",
                    python   = "python3 %",
                    go       = "go run %",
                    sh       = "sh %"
                }
            },
        }
    end
}
