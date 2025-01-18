local lspconfig = require('lspconfig')

-- Make sure neodev runs before any lspconfig
require('neodev').setup({
    override = function(root_dir, library)
        -- If the repo/project root is dotfiles assume we're in a user.nvim config and enable
        if root_dir:match('dotfiles$') or root_dir:find('.config/nvim') or root_dir:find('%.nvim') then
            library.enabled = true
            library.runtime = true
            library.types = true
            library.plugins = true
        end
    end,
})
require('mason').setup()
require('mason-lspconfig').setup()

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
                border = 'rounded',
            }
            vim.diagnostic.open_float(nil, opts)
        end
    })

    user_on_lsp_attach(client, bufnr)
end

local setup_lsp = function(server_name, overrides)
    local opts = {
        on_attach = on_attach,
        capabilities = require('blink.cmp').get_lsp_capabilities(),
    }
    lspconfig[server_name].setup(
        vim.tbl_extend('force', opts, overrides)
    )
end

local make_setup_handlers = function()
    local default_lsp_overrides = {
        function(server_name)
            setup_lsp(server_name, {})
        end,
        svelte = function()
            setup_lsp('svelte', {
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
        end,
    }

    for server_name, value in pairs(user_lsp_overrides) do
        default_lsp_overrides[server_name] = function()
            setup_lsp(server_name, value)
        end
    end
    return default_lsp_overrides
end

require("mason-lspconfig").setup_handlers(make_setup_handlers())

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

vim.cmd [[autocmd! ColorScheme * highlight NormalFloat guibg=#1f2335]]
vim.cmd [[autocmd! ColorScheme * highlight FloatBorder guifg=white guibg=#1f2335]]

local border = {
    { "┏", "FloatBorder" },
    { "━", "FloatBorder" },
    { "┓", "FloatBorder" },
    { "┃", "FloatBorder" },
    { "┛", "FloatBorder" },
    { "━", "FloatBorder" },
    { "┗", "FloatBorder" },
    { "┃", "FloatBorder" },
}

local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
    opts = opts or {}
    opts.border = opts.border or border
    return orig_util_open_floating_preview(contents, syntax, opts, ...)
end
