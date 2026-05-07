-- Typo resistance
vim.api.nvim_create_user_command('Wqa', 'wqa', {})

vim.api.nvim_create_user_command('W', 'SudaWrite', {})

vim.api.nvim_create_user_command('GitLink', function()
    require('snacks').gitbrowse({
        open = function(url)
            vim.fn.setreg('+', url)
        end,
    })
end, {})

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

vim.api.nvim_create_user_command('EditRegister', function(opts)
    require('shared.extensions').edit_register(opts.args)
end, {
    desc = 'Open a floating window to edit a register',
    nargs = 1,
})
