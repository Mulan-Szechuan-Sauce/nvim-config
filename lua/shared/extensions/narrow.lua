local M = {}

local function restore_winopts(opts)
    for opt, value in pairs(opts) do
        vim.opt_local[opt] = value
    end
end

local function open_current_tsnode_in_scratch_buf()
    local node = vim.treesitter.get_node()

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

    local original_buf = vim.api.nvim_get_current_buf()
    local original_lines = vim.api.nvim_buf_get_lines(original_buf, 0, -1, false)
    local ft = vim.bo.filetype
    local cursor_row, cursor_col = unpack(vim.api.nvim_win_get_cursor(0))

    local tmp_buf = vim.api.nvim_create_buf(true, true)
    vim.api.nvim_buf_set_lines(tmp_buf, 0, -1, false, original_lines)
    vim.api.nvim_set_option_value('filetype', ft, { buf = tmp_buf })
    vim.api.nvim_set_option_value('bufhidden', 'delete', { buf = tmp_buf })
    vim.api.nvim_set_option_value('buftype', 'nofile', { buf = tmp_buf })
    vim.api.nvim_set_current_buf(tmp_buf)
    vim.api.nvim_win_set_cursor(0, { cursor_row, cursor_col })

    local original_name = vim.api.nvim_buf_get_name(original_buf)
    vim.api.nvim_buf_set_name(tmp_buf, original_name .. '.NARROW')

    -- Fold Top (Lines 1 to start_row)
    if start_row > 0 then
        -- Vim rows are 1-based, start_row is 0-based
        vim.cmd(string.format("1,%dfold", start_row))
    end
    -- Fold Bottom (Lines end_row+2 to EOF)
    local total_lines = vim.api.nvim_buf_line_count(tmp_buf)
    if end_row + 2 <= total_lines then
        vim.cmd(string.format("%d,$fold", end_row + 2))
    end

    local original_win_opts = {
        foldtext = vim.opt_local.foldtext,
        foldopen = vim.opt_local.foldopen,
        fillchars = vim.opt_local.fillchars,
        winhighlight = vim.opt_local.winhighlight,
    }

    -- Make fold text empty string
    vim.opt_local.foldtext = '""'
    -- Don't open folds
    vim.opt_local.foldopen = ''
    -- Make the fold column invisible/blend in
    vim.opt_local.fillchars:append('fold: ')
    -- Make the fold background invisible
    vim.opt_local.winhighlight:append("Folded:Normal")

    -- Copy over all our lsp clients
    local clients = vim.lsp.get_clients({ bufnr = original_buf })
    for _, client in ipairs(clients) do
        vim.lsp.buf_attach_client(tmp_buf, client.id)
    end

    vim.api.nvim_create_autocmd({ 'BufDelete' }, {
        pattern = { '<buffer>' },
        callback = function()
            -- TODO: Figure out how to set the cursor and viewport to be aligned

            -- Calculate new function size (incase we added/removed lines)
            local bottom_lines_count = #original_lines - (end_row + 1)
            local new_end_row = vim.api.nvim_buf_line_count(tmp_buf) - bottom_lines_count
            local narrowed_content = vim.api.nvim_buf_get_lines(tmp_buf, start_row, new_end_row, false)

            -- Copy over only the lines of our narrowed function
            vim.api.nvim_buf_set_lines(original_buf, start_row, end_row + 1, false, narrowed_content)

            restore_winopts(original_win_opts)
        end,
    })
end

function M.narrow_to_function()
    if string.find(vim.api.nvim_buf_get_name(0), '.NARROW', nil, true) then
        vim.api.nvim_buf_delete(0, {})
    else
        open_current_tsnode_in_scratch_buf()
    end
end

return M
