local functions = {};

function functions.require_user_config()
    local config_paths = {
        "~/local/src/user.nvim/",
        "~/.config/user.nvim/",
        "~/.user.nvim/",
    }

    local env_dir = os.getenv("MSS_NEOVIM_USER_DIR")
    if env_dir then
        table.insert(config_paths, 1, env_dir)
    end

    for _, path in ipairs(config_paths) do
        local expanded = vim.fn.expand(path)
        if vim.fn.filereadable(expanded .. "init.lua") == 1 then
            package.path = (expanded .. "?.lua;") .. (expanded .. "?/init.lua") .. ";" .. package.path
            require('init')

            --- Path to the user.nvim folder that has been loaded
            vim.g.user_config_path = expanded
            break
        end
    end
end

function functions.require_viml(vimlConfigPath)
    vim.cmd(string.format('source %s/viml/%s', vim.g.user_config_path, vimlConfigPath))
end

function functions.open_toggle_term()
    vim.cmd(
        string.format("ToggleTerm ToggleTerm direction=vertical size=%d", vim.api.nvim_list_uis()[1].width * 0.4)
    )
end

function functions.alt_buf_with_fallback()
    if vim.fn.bufnr('#') == -1 then
        vim.cmd('bnext')
    else
        vim.cmd('b#')
    end
end

function functions.get_buf_dir()
    return vim.fn.expand("%:p:h")
end

---@param path string
---@param width number
---@return string
function functions.smart_shorten_path(path, width)
    local shortened = path

    -- Iteratively shorten the first long directory found (e.g. "utils/" -> "u/")
    -- We stop as soon as the path fits the width.
    while #shortened > width do
        local new_path, count = shortened:gsub('([^/])[^/]+/', '%1/', 1)

        if count == 0 then break end

        shortened = new_path
    end

    if #shortened > width then
        shortened = '…' .. shortened:sub(-width + 1)
    end

    return shortened
end

---Copies the diagnostic under the cursor to the clipboard.
function functions.copy_diagnostic()
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    local diagnostics = vim.diagnostic.get(0, { lnum = line - 1 })

    ---@type vim.Diagnostic[]
    local matches = {}
    -- Find diagnostics that overlap with the column of our cursor
    for _, d in pairs(diagnostics) do
        if col >= d.col and col < d.end_col then
            table.insert(matches, d)
        end
    end

    if #matches == 0 then return end

    -- Sort to find the most relevant diagnostic if there are multiple
    table.sort(matches, function(a, b) return a.severity < b.severity end)

    local message = diagnostics[1].message
    -- Copy to system clipboard
    vim.fn.setreg('+', message)
end

-- TODO: Control characters aren't handled. Fancy progress bars (and similar won't work)
function functions.run_cmd_in_floating_window(cmd, cwd)
    local tmp_buf = vim.api.nvim_create_buf(true, true)
    vim.api.nvim_buf_set_keymap(tmp_buf, 'n', 'q', '<cmd>q<cr>', { noremap = true })

    local size = vim.api.nvim_list_uis()[1]
    local width = vim.fn.floor(size.width * 0.8)
    local height = vim.fn.floor(size.height * 0.8)

    vim.api.nvim_open_win(tmp_buf, true, {
        relative = 'win',
        row = (size.height - height) * 0.5,
        col = (size.width - width) * 0.5,
        width = width,
        height = height,
        border = 'single',
        style = 'minimal'
    })

    local output = {}
    local function print_stdout(chan_id, data, name)
        local d = data
        if d ~= { "" } then
            d = table.remove(d)
        end
        for _, v in ipairs(data) do
            table.insert(output, v)
        end
        vim.api.nvim_buf_set_lines(tmp_buf, 0, -1, true, output)
        -- Scroll to bottom and redraw so it's visible
        vim.cmd('normal G')
        vim.cmd('redraw')
    end

    local exit_code = 0
    local j = vim.fn.jobstart(cmd,
        { cwd = cwd, on_stdout = print_stdout, on_exit = function(_, code) exit_code = code end })

    -- This blocks
    vim.fn.jobwait({ j })

    -- Don't exit on error
    if exit_code == 0 then
        vim.api.nvim_buf_delete(tmp_buf, { force = true })
    end

    return output
end

---@deprecated Export moved. Use `require('shared.extensions').snacks_find_file()` instead
function functions.snacks_find_file()
    require('shared.extensions').snacks_find_file()
end

return functions
