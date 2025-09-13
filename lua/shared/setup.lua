---@class mss.config
---@field install_plugins fun()
---@field on_lsp_attach fun(client: vim.lsp.Client, bufnr: integer)
---@field config fun()
---@field dapui_config dapui.Config | nil

local setup = {}

---@param config mss.config
function setup.setup(config)
    vim.g.user_config = config
end

return setup
