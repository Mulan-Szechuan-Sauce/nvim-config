local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local lazy = require('lazy')
local user_plugins = vim.g.user_config.install_plugins()

-- When wrapped with nix (nix-wrapper-modules), the config lives at an
-- out-of-tree store path that lazy.setup() drops when it resets the rtp.
-- Keep it on the rtp so `require('shared.*')` still resolves (and stays
-- bytecode-cached by vim.loader). No-op in the normal ~/.config/nvim setup.
local rtp_paths = vim.g.nix_info_plugin_name
    and { require(vim.g.nix_info_plugin_name).settings.config_directory }
    or {}

lazy.setup({
    spec = {
        { import = 'shared.plugins' },
        user_plugins,
    },
    -- No point having the lockfile in the shared repo
    -- Let's put it next to the user's config
    lockfile = vim.g.user_config_path .. '/lazy-lock.json',
    performance = {
        rtp = {
            paths = rtp_paths,
        },
    },
})
