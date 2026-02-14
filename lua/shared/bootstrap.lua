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
local plugins = require('shared.plugins')
local user_plugins = vim.g.user_config.install_plugins()

lazy.setup({
    spec = {
        plugins,
        user_plugins,
    },
    -- No point having the lockfile in the shared repo
    -- Let's put it next to the user's config
    lockfile = vim.g.user_config_path .. '/lazy-lock.json'
})
