vim.api.nvim_create_autocmd(
    { 'BufRead', 'BufNewFile' },
    {
        pattern = { '*.pyst' },
        command = 'set filetype=python',
    }
)
