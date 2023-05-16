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
'famiu/bufdelete.nvim',

{
    'ggandor/leap.nvim',
    config = function() require('leap').set_default_keymaps() end
},

{
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
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
},

{
    'nvim-treesitter/nvim-treesitter-context',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
},

{
    'nvim-lualine/lualine.nvim',
    config = function() require('shared.plugins.lualine') end
},

{
    'ibhagwan/fzf-lua',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
        require('fzf-lua').setup({
            global_resume = true,
            global_resume_query = true,
            winopts = {
                -- TODO: Not sure why this is being mapped but it's causing issues exiting
                --       so for now just unmap it (buffer locally) when you get into a fzf term
                window_on_create = function()
                    vim.cmd('tmap <buffer> <Esc> <Esc>')
                end
            },
            files = {
                git_icons = false,
            },
            git = {
                files = {
                    cmd = 'git ls-files --exclude-standard --cached --others',
                },
            },
        })
    end
},

{
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
},

{
    'hrsh7th/nvim-cmp',
    event = "InsertEnter",
    dependencies = {
        'neovim/nvim-lspconfig',
        'hrsh7th/cmp-nvim-lsp',
        'L3MON4D3/LuaSnip',
        'saadparwaiz1/cmp_luasnip',
        'onsails/lspkind.nvim',
        'hrsh7th/cmp-path',
        'hrsh7th/cmp-cmdline',
    },
    config = function() require('shared.plugins.cmp') end
},

{
    'folke/trouble.nvim',
    dependencies = 'nvim-tree/nvim-web-devicons',
    config = function()
        require('trouble').setup();
    end
},

'folke/neodev.nvim',

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
    'ray-x/lsp_signature.nvim',
    dependencies = { 'neovim/nvim-lspconfig' },
    config = function()
        require('lsp_signature').setup({
            bind = true,
            hint_enable = true,
            floating_window = false,
            always_trigger = true,
            auto_close_after = 4,
        })
    end
},

{
    'mfussenegger/nvim-dap',
    dependencies = {
        'mrjones2014/legendary.nvim',
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

'mrjones2014/nvim-ts-rainbow',
'gpanders/editorconfig.nvim',

{
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
},

'github/copilot.vim',

}
