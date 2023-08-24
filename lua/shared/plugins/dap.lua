local dap = require('dap');
local dapui = require('dapui');

function get_dll_paths()
    local cwd = vim.fn.getcwd();
    local sln_file = vim.fn.globpath(cwd, '*.sln');

    local matcher = "";
    if sln_file == "" then
        local dir_name = vim.fn.fnamemodify(cwd, ':t');
        matcher = string.format('**/bin/Debug/*/%s.dll', dir_name);
    else
        local base_name = vim.fn.fnamemodify(sln_file, ':t:r');
        matcher = string.format('**/bin/Debug/*/%s*.dll', base_name);
    end

    local globs = vim.fn.globpath(cwd, matcher);
    local files = vim.split(globs, "\n");

    return require('dap.ui').pick_one_sync(files, 'Path to dll:', function(item) return item end);
end

dap.adapters.coreclr = {
    type = 'executable',
    command = 'netcoredbg',
    args = { '--interpreter=vscode' }
}
dap.configurations.cs = {
    {
        type = "coreclr",
        name = "launch - netcoredbg",
        request = "launch",
        program = get_dll_paths,
    },
}
dap.adapters.lldb = {
    type = 'executable',
    command = '/usr/sbin/lldb-vscode',
    name = 'lldb'
}
dap.adapters.codelldb = {
    type = 'server',
    port = "${port}",
    executable = {
        command = vim.fn.stdpath('data') .. '/mason/bin/codelldb',
        args = {"--port", "${port}"},
    }
}

dap.configurations.rust = {
    {
        name = 'Run',
        type = 'codelldb',
        request = 'launch',
        program = function()
            local path = vim.fn.getcwd() .. '/target/debug/*'
            for i, p in ipairs(vim.split(vim.fn.glob(path), '\n')) do
                if vim.fn.filereadable(p) == 1 and vim.fn.getfperm(p):sub(3,3) == 'x' then
                    path = p
                    break
                end
            end
            -- return vim.fn.input('Path to executable: ', path, 'file')
            return path
        end,
        cwd = '${workspaceFolder}',
        stopOnEntry = false,
        args = function()
            local args = vim.fn.input('Args: ')
            return { '--', args }
        end,
    },
    {
        name = 'Test',
        type = 'codelldb',
        request = 'launch',
        program = function()
            local cwd = vim.fn.expand('%:p:h')
            local output = run_cmd_in_floating_window('bash -c "RUSTFLAGS=-g cargo test --no-run 2>&1"', cwd)
            local candidates = {}
            for _, line in ipairs(output) do
                local path = line:match('Executable.*')
                if path then
                    table.insert(candidates, path)
                end
            end

            local selection = nil

            if #candidates == 1 then
                selection = candidates[1]
            else
                selection = require('dap.ui').pick_one_sync(candidates, 'Select test: ', function(candidate)
                    return candidate
                end)
            end

            if selection == nil then
                print('Invalid selection')
                return nil
            end

            local path = vim.split(selection, '[\\(\\)]')[2]
            return path
        end,
        cwd = '${workspaceFolder}',
        stopOnEntry = false,
    },
};

local user = os.getenv("USER")

dap.adapters.delve = {
    type = "server",
    host = ("%s-dbx.dev.corp.dropbox.com"):format(user),
    port = 56134,
}
dap.configurations.go = {
    {
        type = "delve",
        name = "Debug",
        request = "attach",
        mode = "remote",
        substitutePath = {
            {
                from = ("/Users/%s/src/server/"):format(user),
                to = ""
            }
        },
    },
}

vim.fn.sign_define('DapBreakpoint', { text = '🛑', texthl = '', linehl = '', numhl = '' })

dapui.setup({
    icons = { expanded = "▾", collapsed = "▸" },
    mappings = {
        -- Use a table to apply multiple mappings
        expand = { "<CR>", "<2-LeftMouse>" },
        open = "o",
        remove = "d",
        edit = "e",
        repl = "r",
        toggle = "t",
    },
    -- Expand lines larger than the window
    -- Requires >= 0.7
    expand_lines = vim.fn.has("nvim-0.7"),
    -- Layouts define sections of the screen to place windows.
    -- The position can be "left", "right", "top" or "bottom".
    -- The size specifies the height/width depending on position. It can be an Int
    -- or a Float. Integer specifies height/width directly (i.e. 20 lines/columns) while
    -- Float value specifies percentage (i.e. 0.3 - 30% of available lines/columns)
    -- Elements are the elements shown in the layout (in order).
    -- Layouts are opened in order so that earlier layouts take priority in window sizing.
    layouts = {
        {
            elements = {
                "watches",
            },
            size = 0.25, -- 25% of total lines
            position = "bottom",
        },
        {
            elements = {
                -- Elements can be strings or table with id and size keys.
                { id = "scopes", size = 0.25 },
                "breakpoints",
                "stacks",
                "repl",
            },
            size = .2,
            position = "left",
        },
    },
    floating = {
        max_height = nil, -- These can be integers or a float between 0 and 1.
        max_width = nil, -- Floats will be treated as percentage of your screen.
        border = "single", -- Border style. Can be "single", "double" or "rounded"
        mappings = {
            close = { "q", "<Esc>" },
        },
    },
    windows = { indent = 1 },
    render = {
        max_type_length = nil, -- Can be integer or nil.
    }
});

-- Auto open dapui on debug
dap.listeners.after.event_initialized["dapui_config"] = function()
    dapui.open();
end
dap.listeners.before.event_terminated["dapui_config"] = function()
    dapui.close();
end
dap.listeners.before.event_exited["dapui_config"] = function()
    dapui.close();
end


require('persistent-breakpoints').setup({});
-- automatically load breakpoints when a file is loaded into the buffer.
vim.api.nvim_create_autocmd({"BufReadPost"},{ callback = require('persistent-breakpoints.api').load_breakpoints });
