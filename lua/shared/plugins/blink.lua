---@module 'blink.cmp'
---@type blink.cmp.Config
return {
    keymap = {
        preset = 'enter',
        ['<TAB>'] = { 'select_next', 'fallback' },
        ['<S-TAB>'] = { 'select_prev', 'fallback' },
    },

    appearance = {
        use_nvim_cmp_as_default = true,
        nerd_font_variant = 'normal'
    },

    sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
    },

    signature = { enabled = true },

    completion = {
        menu = {
            draw = {
                padding = { 0, 1 },

                columns = { { 'kind_icon' }, { 'label' }, { 'source_name' } },

                components = {
                    kind_icon = {
                        text = function(ctx) return ' ' .. ctx.kind_icon .. ' ' .. ctx.icon_gap end,
                    },
                },
            },
        },
        list = {
            selection = {
                preselect = false,
            },
        },
        documentation = {
            auto_show = true,
        },
    },

    cmdline = {
        keymap = {
            preset = 'inherit',
            -- Since we suppress auto show on the first word if we want manual completion
            -- we can trigger as per usual
            ['<C-n>'] = { 'select_next', 'show', 'fallback' },
            ['<C-p>'] = { 'select_prev', 'show', 'fallback' },
            ['<TAB>'] = { 'select_next', 'show', 'fallback' },
            ['<S-TAB>'] = { 'select_prev', 'show', 'fallback' },
            ['<C-c>'] = { 'cancel', 'fallback' },
        },
        completion = {
            menu = {
                -- Don't auto show on the first word since pressing enter will trigger
                -- completion rather than submit. After the first word though we can
                -- trigger completions more naturally.
                auto_show = function(ctx)
                    local split = vim.split(ctx.line, ' ')
                    return #split > 1
                end,
            },
        },
    },
}
