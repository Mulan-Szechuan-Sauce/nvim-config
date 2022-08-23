local lspconfig = require('lspconfig')

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
    });

    user_on_lsp_attach(client, bufnr)
end

local setup_lsp = function (server_name, overrides)
    local opts = {
        on_attach = on_attach,
        capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities()),
    }
    lspconfig[server_name].setup(
        vim.tbl_extend('force', opts, overrides)
    )
end

local make_setup_handlers = function ()
    local default_lsp_overrides = {
        function (server_name)
            setup_lsp(server_name, {})
        end,

        -- Neovim lua lsp
        sumneko_lua = function()
            setup_lsp('sumneko_lua', require('lua-dev').setup())
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
