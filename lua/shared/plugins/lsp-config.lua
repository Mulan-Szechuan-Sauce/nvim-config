local lspconfig = require('lspconfig')

-- Make sure neodev runs before any lspconfig
require('lazydev').setup({
    library = {
        -- Load luvit types when the `vim.uv` word is found
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        vim.fn.stdpath('config'),
    },
    enabled = function(root_dir)
        -- If the repo/project root is dotfiles assume we're in a user.nvim config and enable
        if root_dir:match('dotfiles$') or root_dir:find('.config/nvim') or root_dir:find('%.nvim') then
            return true
        end
        return false
    end,
})

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
    local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

    -- Enable completion triggered by <c-x><c-o>
    buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

    vim.api.nvim_create_autocmd("CursorHold", {
        buffer = bufnr,
        callback = function()
            local opts = {
                focusable = false,
                close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
                source = 'always',
                prefix = ' ',
                scope = 'cursor',
                border = 'none',
            }
            vim.diagnostic.open_float(nil, opts)
        end
    })

    vim.g.user_config.on_lsp_attach(client, bufnr)
end

vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if not client then
            return
        end
        on_attach(client, args.buf)
    end,
})

-- Default LSP settings
vim.lsp.config('*', {
    capabilities = require('blink.cmp').get_lsp_capabilities(),
})

vim.lsp.config('svelte', {
    on_attach = function(client, bufnr)
        -- First call our standard on_attach
        on_attach(client, bufnr)

        -- Then this workaround https://github.com/sveltejs/language-tools/issues/2008#issuecomment-2351976230
        vim.api.nvim_create_autocmd('BufWritePost', {
            pattern = { '*.js', '*.ts' },
            group = vim.api.nvim_create_augroup('svelte_ondidchangetsorjsfile', { clear = true }),
            callback = function(ctx)
                client.notify('$/onDidChangeTsOrJsFile', { uri = ctx.match })
            end,
        })
    end,
})

require('mason').setup({
    registries = {
        'github:mason-org/mason-registry',
        'github:Crashdummyy/mason-registry',
    },
})
require('mason-lspconfig').setup()


-- TODO: https://github.com/neovim/neovim/issues/30985 remove this workaround when possible
for _, method in ipairs({ 'textDocument/diagnostic', 'workspace/diagnostic' }) do
    local default_diagnostic_handler = vim.lsp.handlers[method]
    vim.lsp.handlers[method] = function(err, result, context, config)
        if err ~= nil and err.code == -32802 then
            return
        end
        return default_diagnostic_handler(err, result, context, config)
    end
end

-- vim.cmd [[autocmd! ColorScheme * highlight NormalFloat guibg=#1f2335]]
-- vim.cmd [[autocmd! ColorScheme * highlight FloatBorder guifg=white guibg=#1f2335]]
--
-- local border = {
--     { "┏", "FloatBorder" },
--     { "━", "FloatBorder" },
--     { "┓", "FloatBorder" },
--     { "┃", "FloatBorder" },
--     { "┛", "FloatBorder" },
--     { "━", "FloatBorder" },
--     { "┗", "FloatBorder" },
--     { "┃", "FloatBorder" },
-- }
--
-- local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
-- function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
--     opts = opts or {}
--     opts.border = opts.border or border
--     return orig_util_open_floating_preview(contents, syntax, opts, ...)
-- end
