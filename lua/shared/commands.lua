require('legendary').commands({
    -- Use :W to sudo write file
    { ':W', ':SudaWrite' },

    -- Command to remove trailing whitespace
    { ':TrimWhitespace',
        function ()
            vim.cmd("%s/\\s\\+$//e")
            vim.cmd(
                vim.api.nvim_replace_termcodes("normal! <C-o>", true, false, true)
            )

        end,
        description = 'Trim trailing whitespace',
    },

    -- Copy the sourcegraph url for the current line to the clipboard
    { ':SgUrl', get_sourcegraph_url },
})

