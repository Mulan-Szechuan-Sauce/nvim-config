local functions = require('shared.functions')
local git = require('snacks.git')

local M = {}

---@param path string
---@return string
local function make_title(path)
    local size = vim.api.nvim_list_uis()[1]
    local layout = require("snacks.picker.config.layouts").default.layout

    -- Lazy will show the preview window vertically below min_width otherwise it's 2 columns
    local multiplier = (vim.o.columns > layout.min_width) and 0.5 or 1
    local width = vim.fn.floor(size.width * layout.width * multiplier) - 4


    local relative = vim.fn.fnamemodify(path, ":.")
    local title = vim.fs.basename(vim.uv.cwd()) .. '/' .. relative

    -- If relative path is "above" us '..' or absolute fallback
    if vim.startswith(relative, '..') or vim.startswith(relative, '/') then
        local git_root = git.get_root(path)

        -- If we're in the git root let's show where we are
        if git_root and path ~= git_root then
            title = vim.fs.basename(git_root) .. '/' .. path:sub(#git_root + 2)
        else
            title = vim.fn.fnamemodify(path, ':~')
        end
    end

    -- Sorta dumb but makes sure there's exactly one trailing slash. Also handles '/'
    return functions.smart_shorten_path(title, width):gsub("/$", "") .. '/'
end


---Resolves input text to a filesystem path
---@param input string
---@param current_root string
---@return string
local function resolve_path(input, current_root)
    -- If input starts with / or ~, expand it directly (ignore cwd)
    if input:sub(1, 1) == "/" or input:sub(1, 1) == "~" then
        return vim.fn.expand(input)
    end
    -- Otherwise, append to the custom cwd
    return vim.fn.expand(current_root .. '/' .. input)
end

---@param path string
---@param picker snacks.Picker
local function edit_file(path, picker)
    picker:close()
    vim.cmd.edit(path)
end

---Imitates the ivy find file from emacs. Shows files from the current buffer directory.
---Can navigate with fuzzy matching or typing a known path.
function M.snacks_find_file()
    local sp = require('snacks.picker')
    local cwd = functions.get_buf_dir()

    ---@param dir string
    ---@param picker snacks.Picker
    local function goto_dir(dir, picker)
        cwd = dir
        picker:set_cwd(cwd)
        picker.title = make_title(dir)
        picker.input:set("", "")
        picker:find()
    end

    ---@param picker snacks.Picker
    local function goto_parent_dir(picker)
        local parent = vim.loop.fs_realpath(cwd .. '/..')
        goto_dir(parent, picker)
    end

    local function check_dir_change(picker)
        local input = picker:filter().pattern
        if input == "" then return end

        local path = resolve_path(input, cwd)
        -- Don't cd until the user types the final / but make
        -- sure to strip it like below so it will display correctly
        if vim.fn.isdirectory(path) == 1 and path:match('/$') then
            -- We can't strip '/' or we'll get ""
            if path ~= '/' then
                path = path:gsub("/$", "")
            end
            goto_dir(path, picker)
        end
    end

    sp.files({
        title = make_title(cwd),
        cwd = cwd,
        cmd = 'fd',
        args = { '--hidden', '--follow', '--max-depth', '1', '--type', 'd' },
        actions = {
            confirm = {
                action = function(picker, selected)
                    local input = picker:filter().pattern
                    -- If we've selected something use it. Otherwise let's go wherever we've typed.
                    local path = cwd .. '/' .. (selected and selected.file or input)

                    -- Strip trailing slash. This controls if the full path is displayed.
                    path = path:gsub("/$", "")

                    if vim.fn.isdirectory(path) == 1 then
                        goto_dir(path, picker)
                    else
                        edit_file(path, picker)
                    end
                end,
            },
            parent = {
                action = goto_parent_dir,
            },
            cd = {
                action = function(picker, selected)
                    cwd = vim.loop.fs_realpath(cwd .. '/' .. selected.file)
                    vim.cmd('tcd ' .. cwd)
                    picker:find()
                end
            },
            backspace = {
                action = function(picker)
                    local input = vim.api.nvim_get_current_line()

                    -- If there's text, behave like normal backspace
                    if input ~= nil and input ~= "" then
                        vim.api.nvim_feedkeys(
                            vim.api.nvim_replace_termcodes("<BS>", true, false, true),
                            "n",
                            false
                        )
                        return
                    end

                    goto_parent_dir(picker)
                end,
            },
        },
        win = {
            input = {
                keys = {
                    ['<c-w>'] = { 'parent', mode = { 'i', 'n' } },
                    ['<m-c>'] = { 'cd', mode = { 'i', 'n' } },
                    ['<bs>'] = { 'backspace', mode = { 'i' } },
                },
            },
        },
        on_show = function(picker)
            local buf = picker.input.win.buf
            vim.api.nvim_create_autocmd('TextChangedI', {
                buffer = buf,
                callback = function()
                    -- Schedule ensures the picker internal state is ready before we read it
                    vim.schedule(function()
                        check_dir_change(picker)
                    end)
                end,
            })
        end,
    })
end

return M
