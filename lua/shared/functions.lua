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
            package.path = (expanded .. "?.lua;") .. (expanded .. "?/init.lua") .. ";" .. package.path
            require('init')

            vim.g.user_config_path = expanded
            break
        end
    end
end

function require_viml(vimlConfigPath)
    vim.cmd(string.format('source %s/viml/%s', vim.g.user_config_path, vimlConfigPath))
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

function get_sourcegraph_url()
    local repo_root = vim.fn.finddir('.git/..', vim.fn.expand('%:p:h') .. ';'):gsub('.git/', '')
    local file_path = vim.fn.expand('%:p')
    local url = 'https://sourcegraph.pp.dropbox.com/' ..
        vim.fn.fnamemodify(repo_root, ':t') .. -- repo name
        '/-/blob' ..
        file_path:gsub(repo_root, '') .. -- relative file path
        '?L' ..
        vim.fn.line('.')

    vim.fn.setreg('+', url)
end
