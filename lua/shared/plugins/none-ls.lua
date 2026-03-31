local ai_diagnostics = require('shared.extensions.ai-diagnostics')

return {
    'nvimtools/none-ls.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
        local null_ls = require('null-ls')
        null_ls.setup({
            sources = {
                {
                    name = 'codecompanion',
                    method = null_ls.methods.CODE_ACTION,
                    filetypes = {}, -- empty = all filetypes
                    generator = {
                        fn = function()
                            local diagnostic = ai_diagnostics.get_most_relevant_diagnostic_at_cursor()

                            if not diagnostic then return end

                            return {
                                {
                                    title = '🤖 Fix with CodeCompanion',
                                    action = function()
                                        ai_diagnostics.codecompanion_fix_diagnostic(diagnostic)
                                    end,
                                },
                            }
                        end
                    }
                },
            },
        })
    end
}
