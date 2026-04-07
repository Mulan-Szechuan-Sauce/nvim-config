local M = {}

local function is_valid_writable_reg(reg)
    -- Must be exactly one character
    if #reg ~= 1 then return false end

    -- List of read-only registers that Neovim will reject on write:
    -- . (last inserted text)
    -- : (last command)
    -- % (current file name)
    -- # (alternate file name)
    -- = (expression register - though you can set it, you can't "edit" it like a buffer)
    local readonly = { ['.'] = true, [':'] = true, ['%'] = true, ['#'] = true, ['='] = true }

    if readonly[reg] then return false end

    -- Check if it's a standard writable character:
    -- %w: Alphanumeric (a-z, A-Z, 0-9)
    -- Special: " (unnamed), * + (clipboards), - (small delete), _ (black hole), / (search)
    return reg:match('^[%w"%*%+%-/_%?]$') ~= nil
end

--- Opens a floating window to edit the contents of a register.
function M.edit_register(reg_name)
    if not is_valid_writable_reg(reg_name) then
        vim.notify("Invalid register: " .. reg_name, vim.log.levels.ERROR)
        return
    end

    local reg_type = vim.fn.getregtype(reg_name)
    local content = vim.fn.getreg(reg_name, 1, true)

    local tmp_buf = vim.api.nvim_create_buf(false, true)

    -- We give it a unique name so Neovim doesn't throw a "No file name" error.
    vim.api.nvim_buf_set_name(tmp_buf, string.format("Register_[%s]_%d", reg_name, tmp_buf))
    vim.api.nvim_set_option_value('buftype', 'acwrite', { buf = tmp_buf })
    vim.api.nvim_set_option_value('bufhidden', 'wipe', { buf = tmp_buf })

    require('snacks').win({
        buf = tmp_buf,
        width = 0.6,
        height = 0.1,
        title = ' Edit Register: ' .. reg_name .. ' ',
        title_pos = 'center',
        border = 'solid',
        keys = {
            q = "close",
        },
        wo = {
            winhighlight = 'NormalFloat:Normal,FloatBorder:Normal',
        },
    })

    vim.api.nvim_buf_set_lines(tmp_buf, 0, -1, false, content)
    -- Reset the modified flag after populating so :q works
    vim.api.nvim_set_option_value('modified', false, { buf = tmp_buf })

    local function save_register()
        local new_content = vim.api.nvim_buf_get_lines(tmp_buf, 0, -1, false)
        vim.fn.setreg(reg_name, new_content, reg_type)

        -- Tell Neovim the buffer is "saved" so the 'q' part of ':wq' executes without warning
        vim.api.nvim_set_option_value('modified', false, { buf = tmp_buf })
    end

    -- Intercept the write command to trigger our save logic
    vim.api.nvim_create_autocmd('BufWriteCmd', {
        buffer = tmp_buf,
        callback = save_register,
    })
end

return M
