require('legendary').autocmds({
    { 'TermOpen', function()
        -- Disable line numbers and signcolumn in terminal buffers
        vim.cmd('setlocal nonumber norelativenumber')
        vim.cmd('setlocal signcolumn=no')
    end },
    {
        { 'BufRead', 'BufNewFile' },
        ':set filetype=python',
        opts = {
            pattern = { '*.pyst' },
        },
    },
})
