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
local user_plugins = user_install_plugins()

-- Updated this to be list_extends instead of tbl_extends because lists in lua are tables with key = array index and when
-- performing an extend using tbl.extend we don't actually get all values from both tables. Given length of user_plugins
-- is N we get the following: 
--   1) All plugins from user_plugins
--   2) plugins with index > N from the shared plugins
-- This function actually gives us all from both
vim.list_extend(plugins, user_plugins)
lazy.setup(plugins)


