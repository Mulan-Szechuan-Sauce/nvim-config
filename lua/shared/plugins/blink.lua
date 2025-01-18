return {
    keymap = { preset = 'enter' },

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
}
