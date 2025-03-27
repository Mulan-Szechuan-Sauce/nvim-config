return {

'nvim-lua/plenary.nvim',
'nvim-tree/nvim-web-devicons',

{
    'mrjones2014/legendary.nvim',
    config = function()
        require('legendary').setup()
        require('shared.commands')
        require('shared.autocommands')
    end,
},

'tpope/vim-surround',
'tpope/vim-repeat',
'nelstrom/vim-visual-star-search',
'tommcdo/vim-lion',
'lambdalisue/suda.vim',
'sbdchd/neoformat',

{
    'ggandor/leap.nvim',
    config = function() require('leap').set_default_keymaps() end
},

{
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
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
},

{
    'nvim-treesitter/nvim-treesitter-context',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
},

{
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
    }
},

{
    'nvim-lualine/lualine.nvim',
    config = function() require('shared.plugins.lualine') end
},

{
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    config = function()
        require('snacks').setup({
            picker = {
                formatters = {
                    file = {
                        truncate = 100,
                    },
                },
            },
            bufdelete = { enabled = true },
            git = { enabled = true },
            gitbrowse = { enabled = true },
            dashboard = require('shared.plugins.dashboard'),
        })

        -- vim.cmd [[highlight SnacksPickerDir guifg='#BCBCBC']]
        -- vim.cmd [[highlight SnacksDashboardDir guifg='#BCBCBC']]
    end,
},

{
    'saghen/blink.cmp',
    dependencies = 'rafamadriz/friendly-snippets',
    version = '*',
    opts = require('shared.plugins.blink'),
    opts_extend = { "sources.default" }
},

{
    'folke/trouble.nvim',
    dependencies = 'nvim-tree/nvim-web-devicons',
    config = function()
        require('trouble').setup();
    end
},

'folke/lazydev.nvim',

{
    'williamboman/mason.nvim',
    dependencies = {
        'mrjones2014/legendary.nvim',
        'williamboman/mason-lspconfig.nvim',
        'neovim/nvim-lspconfig',
    },
    config = function()
        require('shared.plugins.lsp-config')
        require('shared.plugins.lsp-ui-config')
    end
},

{
    'j-hui/fidget.nvim',
    dependencies = { 'neovim/nvim-lspconfig' },
    config = function()
        require('fidget').setup({})
    end
},

{
    'mfussenegger/nvim-dap',
    dependencies = {
        'mrjones2014/legendary.nvim',
        'nvim-neotest/nvim-nio',
        'rcarriga/nvim-dap-ui',
        'Weissle/persistent-breakpoints.nvim',
    },
    config = function() require('shared.plugins.dap') end,
},

{
    'akinsho/toggleterm.nvim',
    version = '*',
    config = function()
        require('toggleterm').setup()
    end
},

{
    'numToStr/Comment.nvim',
    config = function()
        require('Comment').setup()
    end
},

'gpanders/editorconfig.nvim',
'github/copilot.vim',
'sindrets/diffview.nvim',

{
    'stevearc/oil.nvim',
    opts = {},
},

{
    'NeogitOrg/neogit',
    dependencies = {
        'nvim-lua/plenary.nvim',
        'sindrets/diffview.nvim',
    },
    config = true,
},

{
    "cbochs/grapple.nvim",
    opts = {
        scope = "git",
    },
},


{
    'WolfeCub/harpeek.nvim',
    config = function()
        require('harpeek').setup({
            tabline = true,
        })
    end
},

}
