function require_user_config()
    local config_paths = {
        os.getenv("MSS_NEOVIM_USER_DIR") or "GARBAGE",
        "~/local/src/user.nvim/",
        "~/.config/user.nvim/",
        "~/.user.nvim/",
    }

    for _, path in ipairs(config_paths) do
        local expanded = vim.fn.expand(path)
        if vim.fn.filereadable(expanded .. "init.lua") == 1 then
            package.path = package.path .. ";" .. (expanded .. "?.lua;") .. (expanded .. "?/init.lua")
            dofile(expanded .. "init.lua")
            break
        end
    end
end

function telescope_find_files_dwim()
    local builtin = require('telescope.builtin')
    local ok = pcall(builtin.git_files, { cwd = get_buf_dir() })
    if not ok then
        buildin.find_files({})
    end
end

function open_toggle_term()
    vim.cmd(
        string.format("ToggleTerm ToggleTerm direction=vertical size=%d", vim.api.nvim_list_uis()[1].width * 0.4)
    )
end

function alt_buf_with_fallback()
    if vim.fn.bufnr('#') == -1 then
        vim.cmd('bnext')
    else
        vim.cmd('b#')
    end
end

function get_buf_dir()
    return vim.fn.expand("%:p:h")
end
