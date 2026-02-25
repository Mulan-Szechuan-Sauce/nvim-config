require('lspconfig')

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
    -- Enable completion triggered by <c-x><c-o>
    vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'

    -- Show floating diagnostic window after idle cursor
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

vim.lsp.config('jsonls', {
  settings = {
    json = {
      schemas = require('schemastore').json.schemas(),
      validate = { enable = true },
    },
  },
})

vim.lsp.config('yamlls', {
  settings = {
    yaml = {
      schemaStore = {
        enable = false,
        url = "",
      },
      schemas = require('schemastore').yaml.schemas(),
    },
  },
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
