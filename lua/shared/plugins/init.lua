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
'sindrets/diffview.nvim',

{
    'linrongbin16/gitlinker.nvim',
    config = function()
        require('gitlinker').setup()
    end,
},

{
    "cbochs/grapple.nvim",
    -- opts = {
    --     scope = "cwd",
    -- },
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
