local ts = require('nvim-treesitter')
local parsers = require("nvim-treesitter.parsers")

---@param event vim.api.keyset.create_autocmd.callback_args
local install_parser_and_enable_features = function(event)
    local buf = event.buf
    local lang = event.match

    -- If it's not a valid lang no need to prompt
    if not parsers[lang] then
        return
    end

    -- Don’t ask again for this buffer
    if vim.b[buf].ts_install_declined then
        return
    end

    if vim.tbl_contains(ts.get_installed(), lang) then
        pcall(vim.treesitter.start, buf, lang)
        return
    end


    local on_select = function(choice)
        if choice ~= "yes" then
            vim.b[buf].ts_install_declined = true
            return
        end

        local ok, task = pcall(ts.install, { lang }, { summary = true })
        if not ok or not task then
            return
        end

        task:wait(10000)

        ok, _ = pcall(vim.treesitter.start, buf, lang)
        if not ok then return end

        -- Enable other features as needed.

        -- Enable indentation based on treesitter for the buffer.
        -- vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"

        -- Enable folding based on treesitter for the buffer.
        -- vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
    end

    vim.schedule(function()
        vim.ui.select(
            { "yes", "no" },
            { prompt = "Install tree-sitter parser for " .. lang .. "?" },
            on_select
        )
    end)
end

-- Install missing parsers on file open.
vim.api.nvim_create_autocmd('FileType', {
    group = vim.api.nvim_create_augroup('ui.treesitter', { clear = true }),
    pattern = { '*' },
    callback = install_parser_and_enable_features
})

local function install_treesitter_cli()
    local data_dir = vim.fn.stdpath("data")
    local cli_dir = data_dir .. "/tree-sitter-cli"
    local cli_path = cli_dir .. "/tree-sitter"

    vim.env.PATH = cli_dir .. ":" .. vim.env.PATH

    if vim.fn.filereadable(cli_path) ~= 0 then
        return
    end

    ---@diagnostic disable-next-line: redefined-local
    local work = vim.uv.new_work(function(cli_dir, cli_path)
        print('Installing tree-sitter cli...')

        vim.uv.fs_mkdir(cli_dir, 448, function() end) -- 0o700

        local sysname = vim.uv.os_uname().sysname
        local arch = vim.uv.os_uname().machine

        if arch == "x86_64" then
            arch = "x64"
        elseif arch == "aarch64" then
            arch = "arm64"
        end

        local platform
        if sysname == "Linux" then
            platform = "linux"
        elseif sysname == "Darwin" then
            platform = "macos"
        else
            error("Unsupported OS: " .. sysname)
        end

        local url = string.format(
            "https://github.com/tree-sitter/tree-sitter/releases/latest/download/tree-sitter-%s-%s.gz",
            platform, arch
        )
        local archive = cli_dir .. "/tree-sitter.gz"

        local handle = io.popen(string.format('curl -f -L -s -o "%s" -w "%%{http_code}" "%s"', archive, url))
        if not handle then
            error("Unable to open curl process to download tree-sitter cli binary")
        end
        local result = handle:read("*a")
        handle:close()

        if result:match("^404") or not vim.uv.fs_stat(archive) then
            error("Tree-sitter binary not found for " .. platform .. "-" .. arch)
        end

        local ok = os.execute(string.format('gunzip -f "%s"', archive))
        if ok ~= 0 then
            error("Failed to extract tree-sitter binary")
        end

        vim.uv.fs_chmod(cli_path, 448) -- 0o700
    end, function()
        print('Successfully installed tree-sitter cli')
    end)

    work:queue(cli_dir, cli_path)
end

install_treesitter_cli()
