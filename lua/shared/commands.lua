-- Typo resistance
vim.api.nvim_create_user_command('Wqa', 'wqa', {})

vim.api.nvim_create_user_command('W', 'SudaWrite', {})

local git_link = function(branch)
    require('snacks').gitbrowse({
        branch = branch,
        open = function(url)
            vim.fn.setreg('+', url)
        end,
    })
end
vim.api.nvim_create_user_command('GitLink', function() git_link() end, {})
vim.api.nvim_create_user_command('GitLinkDevelop', function() git_link('develop') end, {})

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

vim.api.nvim_create_user_command('CargoFeatures', function()
    require('shared.extensions').toggle_cargo_features()
end, {
    desc = 'Toggle cargo features for the attached rust-analyzer',
})

vim.api.nvim_create_user_command('EditRegister', function(opts)
    require('shared.extensions').edit_register(opts.args)
end, {
    desc = 'Open a floating window to edit a register',
    nargs = 1,
})
