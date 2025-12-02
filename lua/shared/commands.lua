vim.api.nvim_create_user_command('W', 'SudaWrite', {})

vim.api.nvim_create_user_command('GitLink', 'lua Snacks.gitbrowse()', {})

vim.api.nvim_create_user_command(
    'TrimWhitespace',
    function ()
        vim.cmd("%s/\\s\\+$//e")
        vim.cmd(
            vim.api.nvim_replace_termcodes("normal! <C-o>", true, false, true)
        )
    end,
    { desc = 'Trim trailing whitespace'}
)
