local M = {}

---@class MacroMagicOptions
---@field keybind string The key to toggle macro recording (default: 'Q')
local default_opts = {
    -- TODO: Don't overwrite Q
    keybind = 'Q',
}

---@class MacroMagicState
---@field options MacroMagicOptions The configuration options for the plugin
---@field namespace integer The namespace ID for key recording
---@field key_sequence string[] The recorded key sequence
---@field register string? The register to store the macro in
---@field win integer? The window ID for the recording window
---@field buf integer? The buffer ID for the recording window
---@field initial_content string[]?
---@field initial_col integer?
---@field initial_row integer?
local state = {
    options = default_opts,
    namespace = vim.api.nvim_create_namespace("macro_magic"),
    key_sequence = {},
    register = nil,

    win = nil,
    buf = nil,
    history = {},
    initial_content = nil,
    initial_col = nil,
    initial_row = nil,
}

local function create_window()
    local buf = vim.api.nvim_create_buf(false, true)

    local width = math.floor(vim.o.columns * 0.3)
    local height = math.floor(1)
    local row = math.floor((vim.o.lines - height) - 1)
    local col = math.floor((vim.o.columns - width) / 2)

    state.win = vim.api.nvim_open_win(buf, false, {
        relative = 'editor',
        width = width,
        height = height,
        row = row,
        col = col,
        style = 'minimal',
        border = 'rounded',
    })

    -- TODO: Maybe don't make editable while recording
    -- vim.api.nvim_set_option_value('readonly', true, { buf = buf })

    state.buf = buf
end

local function setup_events()
    vim.api.nvim_create_autocmd('WinEnter', {
        buffer = state.buf,
        once = true,
        callback = function()
            vim.api.nvim_win_set_cursor(state.win, { 1, #state.key_sequence })
        end,
    })

    vim.api.nvim_create_autocmd('CursorMoved', {
        buffer = state.buf,
        callback = function()

        end,
    })
end

local function focus()
    vim.api.nvim_set_current_win(state.win)
    state.key_sequence = rtrim_keybind(state.key_sequence)
end

--- Trims `state.options.keybind` from the end of the recorded key sequence if it exists.
--- This should correctly handle '<leader>Q' and '<C-z>' style keybinds.
---@param key_sequence string[] The sequence of keys to trim
---@return string[] The trimmed key sequence
function rtrim_keybind(key_sequence)
    local keybind = state.options.keybind

    -- Expand special keys like <leader>, <C-z>, etc. into their actual key codes
    local expanded = vim.api.nvim_replace_termcodes(keybind, true, true, true)

    -- Split the expanded keybind into individual characters/keys
    local keybind_keys = {}
    for char in expanded:gmatch(".") do
        table.insert(keybind_keys, char)
    end

    local keybind_len = #keybind_keys
    local seq_len = #key_sequence

    -- If the sequence is shorter than the keybind, nothing to trim
    if seq_len < keybind_len then
        return key_sequence
    end

    -- Check if the end of key_sequence matches the keybind keys
    for i = 1, keybind_len do
        if key_sequence[seq_len - keybind_len + i] ~= keybind_keys[i] then
            return key_sequence
        end
    end

    -- Trim the keybind from the end
    local trimmed = {}
    for i = 1, seq_len - keybind_len do
        table.insert(trimmed, key_sequence[i])
    end

    return trimmed
end

---@param register string The register to store the macro in
function M.record(register)
    create_window()
    setup_events()

    local initial_buf = vim.api.nvim_get_current_buf()

    local initial_row, initial_col = unpack(vim.api.nvim_win_get_cursor(0))
    local initial_buf_content = vim.api.nvim_buf_get_lines(0, 0, -1, false)

    state.initial_row = initial_row
    state.initial_col = initial_col
    state.initial_content = initial_buf_content

    print('recording @' .. register)
    state.register = register
    ---@diagnostic disable-next-line: unused-local
    vim.on_key(function(_key, typed)
        if vim.api.nvim_get_current_buf() ~= initial_buf then
            return
        end

        table.insert(state.key_sequence, typed)
        state.key_sequence = rtrim_keybind(state.key_sequence)

        -- TODO: Maybe keytrans but gotta figure out indexing into the sequence
        local content = table.concat(state.key_sequence, '')
        vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, { content })
    end, state.namespace)
end

function M.stop_record()
    if not state.register then
        vim.notify("No macro recording in progress", vim.log.levels.WARN)
        return
    end

    state.key_sequence = rtrim_keybind(state.key_sequence)
    vim.fn.setreg(state.register, table)

    -- Cleanup
    state.register = nil
    state.key_sequence = {}
    vim.on_key(nil, state.namespace)
end

function M.setup(opts)
    local options = vim.tbl_deep_extend("force", default_opts, opts or {})
    state.options = options

    vim.keymap.set('n', options.keybind, function()
        if state.register then
            focus()
        else
            local char = vim.fn.getcharstr()
            M.record(char)
        end
    end)
end

return M
