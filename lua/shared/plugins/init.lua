---@module 'lazy'
---@type LazySpec
return {

'nvim-lua/plenary.nvim',
'nvim-tree/nvim-web-devicons',

{
    'nvim-mini/mini.nvim',
    version = '*',
    config = function() require('shared.configs.mini') end,
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
        require('shared.configs.treesitter');
    end
},

{
    'nvim-treesitter/nvim-treesitter-textobjects',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    branch = 'main',
    init = function()
        vim.g.no_plugin_maps = true
    end,
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
    'folke/trouble.nvim',
    dependencies = 'nvim-tree/nvim-web-devicons',
    cmd = 'Trouble',
    opts = {
        focus = true
    },
},


{
    'mason-org/mason.nvim',
    lazy = true,
},

{
    'mason-org/mason-lspconfig.nvim',
    dependencies = {
        'mason-org/mason.nvim',
        'neovim/nvim-lspconfig',
        'b0o/schemastore.nvim',
    },
    cmd = { 'Mason', 'LspInstall' },
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
        require('shared.configs.lsp-config')
        require('shared.configs.lsp-ui-config')
    end
},

{
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
        library = {
            -- Load luvit types when the `vim.uv` word is found
            { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
            { path = 'nvim-lspconfig', words = { 'lspconfig' } },
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
    config = function() require('shared.configs.dap') end,
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
