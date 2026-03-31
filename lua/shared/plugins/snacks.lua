return {
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

        local snacks_select = Snacks.picker.select
        Snacks.picker.select = function(items, opts, on_choice)
            if opts and opts.kind == 'codeaction' then
                table.sort(items, function(a, b)
                    local a_null = a.action and a.action.command == 'NULL_LS_CODE_ACTION'
                    local b_null = b.action and b.action.command == 'NULL_LS_CODE_ACTION'
                    return not a_null and b_null
                end)
            end
            return snacks_select(items, opts, on_choice)
        end
    end,
}
