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
    'folke/flash.nvim',
    event = 'VeryLazy',
    keys = {
        { 's', mode = { 'n', 'x' }, function() require('flash').jump() end, desc = 'Flash' },
        { 'S', mode = { 'n', 'x', 'o' }, function() require('flash').treesitter() end, desc = 'Flash Treesitter' },
        { '<c-s>', mode = { 'c' }, function() require('flash').toggle() end, desc = 'Toggle Flash Search' },
    },
    ---@module 'flash'
    ---@type Flash.Config
    opts = {
        modes = {
            char = {
                enabled = false,
            },
        },
    },
    config = function(_, opts)
        require('flash').setup(opts)

        local hl = vim.api.nvim_get_hl(0, { name = 'Substitute', link = false })
        vim.api.nvim_set_hl(0, 'FlashLabel', { fg = hl.fg, bg = hl.bg, bold = true, standout = true })
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
        'b0o/schemastore.nvim',
    },
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
        require('shared.plugins.lsp-config')
        require('shared.plugins.lsp-ui-config')
    end
},

{
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
        library = {
            -- Load luvit types when the `vim.uv` word is found
            { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
            vim.fn.stdpath('config'),
        },
        enabled = function(root_dir)
            -- If the repo/project root is dotfiles assume we're in a user.nvim config and enable
            if root_dir:match('dotfiles$') or root_dir:find('.config/nvim') or root_dir:find('%.nvim') then
                return true
            end
            return false
        end,
    },
},

{
    'j-hui/fidget.nvim',
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
