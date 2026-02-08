local functions = {};

function functions.require_user_config()
    local config_paths = {
        os.getenv("MSS_NEOVIM_USER_DIR") or "GARBAGE",
        "~/local/src/user.nvim/",
        "~/.config/user.nvim/",
        "~/.user.nvim/",
    }

    for _, path in ipairs(config_paths) do
        local expanded = vim.fn.expand(path)
        if vim.fn.filereadable(expanded .. "init.lua") == 1 then
            package.path = (expanded .. "?.lua;") .. (expanded .. "?/init.lua") .. ";" .. package.path
            require('init')

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

function functions.fzf_path_aliases(path_aliases, root)
    local fzf = require('fzf-lua')

    local dirs = ""
    for k, _ in pairs(path_aliases) do
        dirs = dirs .. " " .. k
    end

    local reverse_map = {}

    local UnshortenerPreviewer = require("fzf-lua.previewer.builtin").buffer_or_file:extend()
    function UnshortenerPreviewer:new(o, opts, fzf_win)
        UnshortenerPreviewer.super.new(self, o, opts, fzf_win)
        setmetatable(self, UnshortenerPreviewer)
        return self
    end

    function UnshortenerPreviewer:parse_entry(entry_str)
        local path = fzf.path.entry_to_file(entry_str).path
        local full_path = root .. '/' .. reverse_map[path]
        return {
            path = full_path,
        }
    end

    fzf.fzf_exec('fd . --type file' .. dirs, {
        cwd = root,
        previewer = UnshortenerPreviewer,
        fn_transform = function(item)
            for k, v in pairs(path_aliases) do
                local prefix = item:sub(0, k:len())
                if k == prefix then
                    local shortened = item:gsub(prefix, v)
                    reverse_map[shortened] = item
                    return fzf.make_entry.file(shortened, { file_icons = true, color_icons = true })
                end
            end
        end,
        actions = {
            ['default'] = function(selected, opts)
                local path = fzf.path.entry_to_file(selected[1]).path
                fzf.actions.file_edit({ reverse_map[path] }, opts)
            end
        },
    })
end

local function open_current_tsnode_in_scratch_buf()
    local ts_utils = require('nvim-treesitter.ts_utils')
    local node = ts_utils.get_node_at_cursor()

    while node do
        local type = node:type()
        if type == 'function_declaration' or
            type == 'function_definition' or
            type == 'function_item' or
            type == 'method_declaration' then
            break
        else
            node = node:parent()
        end
    end

    if not node then return end

    local start_row, start_col, end_row, end_col = vim.treesitter.get_node_range(node)
    -- Take entire first row to grab indentation
    local text = vim.api.nvim_buf_get_text(0, start_row, 0, end_row, end_col, {})
    -- local text = vim.treesitter.query.get_node_text(node, 0, { concat = false })

    -- Strip leading indent
    local indent = text[1]:match("^%s*")
    for k, v in pairs(text) do
        text[k] = v:sub(indent:len() + 1, -1)
    end

    local original_buf = vim.api.nvim_get_current_buf()
    local ft = vim.bo.filetype
    local cursor_row, cursor_col = unpack(vim.api.nvim_win_get_cursor(0))

    local tmp_buf = vim.api.nvim_create_buf(true, true)
    vim.api.nvim_buf_set_lines(tmp_buf, 0, -1, true, text)
    vim.api.nvim_buf_set_option(tmp_buf, 'filetype', ft)
    vim.api.nvim_set_current_buf(tmp_buf)
    vim.api.nvim_win_set_cursor(0, { cursor_row - start_row, cursor_col })
    vim.api.nvim_buf_set_name(tmp_buf, '*narrow-tmp*')

    vim.api.nvim_create_autocmd({ 'BufDelete' }, {
        pattern = { '<buffer>' },
        callback = function()
            -- TODO: Figure out how to set the cursor in another buffer
            -- local tmp_cursor_row, tmp_cursor_col = unpack(vim.api.nvim_win_get_cursor(0))
            local buffer_content = vim.api.nvim_buf_get_lines(tmp_buf, 0, -1, false)
            -- Reindent
            for k, v in pairs(buffer_content) do
                if v ~= "" then
                    buffer_content[k] = indent .. v
                end
            end

            vim.api.nvim_buf_set_text(original_buf, start_row, 0, end_row, end_col, buffer_content)
        end,
    })
end

function functions.narrow_to_function()
    if string.find(vim.api.nvim_buf_get_name(0), '*narrow-tmp*', nil, true) then
        vim.api.nvim_buf_delete(0, {})
    else
        open_current_tsnode_in_scratch_buf()
    end
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
