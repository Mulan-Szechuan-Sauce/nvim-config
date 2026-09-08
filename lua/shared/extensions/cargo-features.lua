local M = {}

---@param client vim.lsp.Client
---@param on_done fun(all: string[])
local function all_features(client, on_done)
    vim.system(
        { 'cargo', 'metadata', '--no-deps', '--format-version', '1' },
        { cwd = client.root_dir, text = true },
        vim.schedule_wrap(function(out)
            if out.code ~= 0 then
                return vim.notify('cargo metadata failed\n' .. out.stderr, vim.log.levels.ERROR)
            end

            local all = {}
            for _, pkg in ipairs(vim.json.decode(out.stdout).packages) do
                for feature in pairs(pkg.features) do
                    if feature ~= 'default' then
                        table.insert(all, pkg.name .. '/' .. feature)
                    end
                end
            end
            table.sort(all)
            on_done(all)
        end)
    )
end

---@param client vim.lsp.Client
---@param all string[]
---@return table<string, true>
local function enabled_features(client, all)
    local current = vim.tbl_get(client.settings, 'rust-analyzer', 'cargo', 'features') or {}
    if current == 'all' then
        current = all
    end

    local enabled = {}
    for _, feature in ipairs(current) do
        enabled[feature] = true
    end
    return enabled
end

---@param client vim.lsp.Client
---@param all string[]
---@param enabled table<string, true>
local function apply(client, all, enabled)
    local on, off = {}, {}
    for _, feature in ipairs(all) do
        table.insert(enabled[feature] and on or off, feature)
    end

    local settings = vim.deepcopy(client.settings)
    -- rust-analyzer has no "all except" option, so one feature off means sending
    -- the whole explicit list
    settings['rust-analyzer'].cargo.features = #off == 0 and 'all' or on

    client.settings = settings
    client:notify('workspace/didChangeConfiguration', { settings = settings })

    vim.notify(#off == 0
        and 'rust-analyzer: all features'
        or 'rust-analyzer without: ' .. table.concat(off, ', '))
end

---@param client vim.lsp.Client
---@param all string[]
local function pick(client, all)
    local enabled = enabled_features(client, all)
    local dirty = false

    require('snacks.picker').pick({
        source = 'cargo_features',
        title = 'Cargo Features',
        items = vim.tbl_map(function(feature) return { text = feature } end, all),
        layout = { preset = 'select' },
        format = function(item)
            local is_on = enabled[item.text]
            return {
                { is_on and '● ' or '○ ', is_on and 'DiagnosticOk' or 'Comment' },
                { item.text },
            }
        end,
        ---@param picker snacks.Picker
        confirm = function(picker)
            for _, item in ipairs(picker:selected({ fallback = true })) do
                enabled[item.text] = not enabled[item.text] or nil
            end
            dirty = true
            picker.list:set_selected()
        end,
        on_close = function()
            if dirty then
                apply(client, all, enabled)
            end
        end,
    })
end

---Toggle cargo features for the attached rust-analyzer. Applied on close; no
---restart needed, rust-analyzer reloads the workspace on the config change.
function M.toggle_cargo_features()
    local client = vim.lsp.get_clients({ bufnr = 0, name = 'rust_analyzer' })[1]
    if not client then
        return vim.notify('No rust_analyzer client attached', vim.log.levels.WARN)
    end

    all_features(client, function(all)
        pick(client, all)
    end)
end

return M
