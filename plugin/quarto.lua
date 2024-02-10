if vim.fn.has("nvim-0.9.0") ~= 1 then
  local msg = [[
  quarto-dev/quarto-nvim and jmbuhr/otter.nvim require Neovim version >= 0.9.0 (https://github.com/neovim/neovim/releases/tag/stable).
  If you are unable to update Neovim, you can specify a specific version of the plugins involved instead of the latest stable version.
  How you do this will vary depending on your plugin manager, but you can see one example using `lazy.nvim` here:
  <https://github.com/jmbuhr/quarto-nvim-kickstarter/blob/nvim-0.8.3/lua/plugins/quarto.lua>
  ]]
  local displayed = vim.notify_once(msg, vim.log.levels.WARN)
  if displayed then
    return msg
  end
  return
end

local quarto = require("quarto")
local api = vim.api

api.nvim_create_user_command("QuartoPreview", quarto.quartoPreview, { nargs = "*" })
api.nvim_create_user_command("QuartoClosePreview", quarto.quartoClosePreview, {})
api.nvim_create_user_command("QuartoActivate", quarto.activate, {})
api.nvim_create_user_command("QuartoHelp", quarto.searchHelp, { nargs = 1 })
api.nvim_create_user_command("QuartoHover", ':lua require"otter".ask_hover()<cr>', {})
