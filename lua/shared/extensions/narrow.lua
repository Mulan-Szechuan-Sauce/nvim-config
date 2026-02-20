local M = {}

local function restore_winopts(opts)
    for opt, value in pairs(opts) do
        vim.opt_local[opt] = value
    end
end

---@return TSNode?
local function get_current_function_node()
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

    return node
end

---@param fn_node TSNode
local function get_leading_comment_start_row(fn_node)
    local node = fn_node:prev_named_sibling()

    -- walk up over contiguous comment siblings
    local top_row = nil
    while node and node:type() == 'comment' do
        top_row = node:start()
        node = node:prev_named_sibling()
    end

    return top_row
end


local function fold_lines(buf, start_row, end_row)
    -- Fold Top (Lines 1 to start_row)
    if start_row > 0 then
        -- Vim rows are 1-based, start_row is 0-based
        vim.cmd(string.format("1,%dfold", start_row))
    end
    -- Fold Bottom (Lines end_row+2 to EOF)
    local total_lines = vim.api.nvim_buf_line_count(buf)
    if end_row + 2 <= total_lines then
        vim.cmd(string.format("%d,$fold", end_row + 2))
    end
end

local function setup_narrow_win()
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

    return original_win_opts
end

local function copy_lsp_clients(src_buf, target_buf)
    for _, client in ipairs(vim.lsp.get_clients({ bufnr = src_buf })) do
        vim.lsp.buf_attach_client(target_buf, client.id)
    end
end

local function open_current_tsnode_in_scratch_buf()
    local node = get_current_function_node()
    if not node then return end

    local start_row = get_leading_comment_start_row(node) or node:start()
    local end_row = node:end_()

    local original_buf = vim.api.nvim_get_current_buf()
    local original_lines = vim.api.nvim_buf_get_lines(original_buf, 0, -1, false)
    local ft = vim.bo.filetype
    local cursor_row, cursor_col = unpack(vim.api.nvim_win_get_cursor(0))

    local tmp_buf = vim.api.nvim_create_buf(true, true)
    vim.api.nvim_buf_set_lines(tmp_buf, 0, -1, false, original_lines)
    vim.api.nvim_set_option_value('filetype', ft, { buf = tmp_buf })
    vim.api.nvim_set_option_value('bufhidden', 'wipe', { buf = tmp_buf })
    vim.api.nvim_set_option_value('buftype', 'nofile', { buf = tmp_buf })
    vim.api.nvim_set_current_buf(tmp_buf)
    vim.api.nvim_win_set_cursor(0, { cursor_row, cursor_col })

    local original_name = vim.api.nvim_buf_get_name(original_buf)
    vim.api.nvim_buf_set_name(tmp_buf, original_name .. '.NARROW')

    local original_win_opts = setup_narrow_win()
    fold_lines(tmp_buf, start_row, end_row)
    copy_lsp_clients(original_buf, tmp_buf)

    vim.api.nvim_create_autocmd({ 'BufDelete' }, {
        pattern = { '<buffer>' },
        callback = function()
            local cur_cursor = vim.api.nvim_win_get_cursor(0)
            local visual_line = vim.fn.winline()

            -- Calculate new function size (incase we added/removed lines)
            local bottom_lines_count = #original_lines - (end_row + 1)
            local new_end_row = vim.api.nvim_buf_line_count(tmp_buf) - bottom_lines_count
            local narrowed_content = vim.api.nvim_buf_get_lines(tmp_buf, start_row, new_end_row, false)

            -- Copy over only the lines of our narrowed function
            vim.api.nvim_buf_set_lines(original_buf, start_row, end_row + 1, false, narrowed_content)

            -- Focusing our original buffer with bufhidden still set would try and delete it causing an error
            vim.api.nvim_set_option_value('bufhidden', '', { buf = tmp_buf })
            vim.api.nvim_set_current_buf(original_buf)

            -- Adjust the view to match what it was in the temp buffer
            vim.api.nvim_win_set_cursor(0, cur_cursor)
            local topline = cur_cursor[1] - visual_line + 1
            vim.fn.winrestview({ topline = topline })

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
