local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local result = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
  -- vim.pretty_print(result)
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({ { import = "ig.plugins" }, {import = "ig.plugins.lsp"} }, {
  checker = {
    enabled = true,
    notify = false,
  },
  change_detection = {
    notify = false
  }
})
