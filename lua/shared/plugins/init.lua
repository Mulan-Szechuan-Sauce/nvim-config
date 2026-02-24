---@module 'lazy'
---@type LazySpec
return {

'nvim-lua/plenary.nvim',
'nvim-tree/nvim-web-devicons',

{
    'nvim-mini/mini.nvim',
    version = '*',
    config = function() require('shared.plugins.mini') end,
},

{
    'folke/which-key.nvim',
    event = 'VeryLazy',
    ---@type wk.Opts
    opts = {
        triggers = {},
    },
    keys = {
        {
            '<leader>?',
            function()
                require('which-key').show({ global = false })
            end,
            desc = 'Buffer Local Keymaps (which-key)',
        },
    },
},

{
    'https://codeberg.org/andyg/leap.nvim',
    config = function()
        vim.keymap.set({'n', 'x', 'o'}, 's', '<Plug>(leap)')
        vim.keymap.set('n',             'S', '<Plug>(leap-from-window)')
    end
},

{
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    build = ':TSUpdate',
    config = function()
        require('nvim-treesitter').setup();
        require('shared.plugins.treesitter');
    end
},

{
    'nvim-treesitter/nvim-treesitter-context',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
},

{
    'folke/todo-comments.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = {}
},

{
    'nvim-lualine/lualine.nvim',
    config = function() require('shared.plugins.lualine') end
},

{
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    config = function()
        require('snacks').setup({
            picker = { enabled = true, },
            input = { enabled = true },
            bufdelete = { enabled = true },
            git = { enabled = true },
            gitbrowse = { enabled = true },
        })

        -- vim.cmd [[highlight SnacksPickerDir guifg='#BCBCBC']]
        -- vim.cmd [[highlight SnacksDashboardDir guifg='#BCBCBC']]
    end,
},

{
    'saghen/blink.cmp',
    dependencies = 'rafamadriz/friendly-snippets',
    version = '*',
    event = { 'InsertEnter', 'CmdlineEnter' },
    opts = require('shared.plugins.blink'),
    opts_extend = { 'sources.default' }
},

{
    'folke/trouble.nvim',
    dependencies = 'nvim-tree/nvim-web-devicons',
    cmd = 'Trouble',
    opts = {
        focus = true
    },
},

{
    'williamboman/mason.nvim',
    cmd = 'Mason',
},

{
    'williamboman/mason-lspconfig.nvim',
    dependencies = {
        'williamboman/mason.nvim',
        'neovim/nvim-lspconfig',
        { 'folke/lazydev.nvim', ft = 'lua' },
        'b0o/schemastore.nvim',
    },
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
        require('shared.plugins.lsp-config')
        require('shared.plugins.lsp-ui-config')
    end
},

{
    'j-hui/fidget.nvim',
    dependencies = { 'neovim/nvim-lspconfig' },
    opts = {},
},

{
    'mfussenegger/nvim-dap',
    dependencies = {
        'nvim-neotest/nvim-nio',
        'rcarriga/nvim-dap-ui',
        'Weissle/persistent-breakpoints.nvim',
    },
    lazy = true,
    config = function() require('shared.plugins.dap') end,
},

{
    'lambdalisue/suda.vim',
    cmd = 'SudaWrite',
},

{
    'sbdchd/neoformat',
    cmd = 'Neoformat',
},

{
    'akinsho/toggleterm.nvim',
    version = '*',
    cmd = 'ToggleTerm',
    opts = {},
},

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
    cmd = 'Neogit',
    config = true,
},

{
    'ThePrimeagen/harpoon',
    branch = 'harpoon2',
    dependencies = { {'nvim-lua/plenary.nvim'} },
    opts = {
        settings = {
            save_on_toggle = true,
        }
    },
},

{
    'WolfeCub/harpeek.nvim',
    opts = {
        tabline = true,
    }
},

{
    'brenoprata10/nvim-highlight-colors',
    opts = {}
},

{
    'stevearc/quicker.nvim',
    ft = 'qf',
    ---@module 'quicker'
    ---@type quicker.SetupOptions
    opts = {},
}

}
