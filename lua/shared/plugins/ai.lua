return {
    'olimorris/codecompanion.nvim',
    version = '^18.0.0',
    dependencies = {
        'nvim-lua/plenary.nvim',
        'nvim-treesitter/nvim-treesitter',
        'lalitmee/codecompanion-spinners.nvim',
        'j-hui/fidget.nvim',
    },
    cmd = { 'CodeCompanion', 'CodeCompanionChat', 'CodeCompanionActions', 'CodeCompanionCmd' },
    opts = {
        opts = {
            log_level = 'DEBUG',
        },
        display = {
            action_palette = {
                provider = 'default',
            },
        },
        adapters = {
            http = {
                copilot = function()
                    return require('codecompanion.adapters').extend('copilot', {
                        schema = {
                            model = {
                                default = 'claude-sonnet-4.6',
                            },
                        },
                    })
                end,
            },
        },
        extensions = {
            spinner = {
                opts = {
                    style = 'fidget',
                },
            },
        },
    },
}
