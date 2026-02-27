-- Text Editing
require('mini.ai').setup()
require('mini.align').setup()
require('mini.comment').setup()

require('mini.move').setup({
    mappings = {
        down       = '<down>',
        up         = '<up>',
        line_down  = '<down>',
        line_up    = '<up>',
        left       = '',
        right      = '',
        line_left  = '',
        line_right = '',
    }
})

require('mini.operators').setup({
    exchange = {
        prefix = 'gX',
    },
    replace = {
        prefix = 'gl',
    },
})

require('mini.splitjoin').setup()

-- https://github.com/nvim-mini/mini.surround/blob/main/doc/mini-surround.txt#L677
require('mini.surround').setup({
    mappings = {
        add = 'ys',
        delete = 'ds',
        find = '',
        find_left = '',
        highlight = '',
        replace = 'cs',
    },
    search_method = 'cover_or_next',
})
-- Remap adding surrounding to Visual mode selection
vim.keymap.del('x', 'ys')
vim.keymap.set('x', 'S', [[:<C-u>lua MiniSurround.add('visual')<CR>]], { silent = true })
-- Make special mapping for "add surrounding for line"
vim.keymap.set('n', 'yss', 'ys_', { remap = true })
