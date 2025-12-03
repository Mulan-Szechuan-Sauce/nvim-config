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

-- Using list_extend instead of tbl_extend to ensure all plugins are included. tbl_extend merges the two and because
-- lists in Lua are tables with keys 1 -> N we end up losing values in the lists from key conflicts.
vim.list_extend(plugins, user_plugins)
lazy.setup(plugins)
