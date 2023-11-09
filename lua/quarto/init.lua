local M = {}
local api = vim.api
local cfg = require("quarto.config")
local otter = require("otter")
local tools = require("quarto.tools")
local util = require("lspconfig.util")

function M.quartoPreview(opts)
  opts = opts or {}
  local args = opts.args or ""

  -- find root directory / check if it is a project
  local buffer_path = api.nvim_buf_get_name(0)
  local root_dir = util.root_pattern("_quarto.yml")(buffer_path)
  local cmd
  local mode
  if root_dir then
    mode = "project"
    cmd = "quarto preview" .. " " .. args
  else
    mode = "file"
    if vim.loop.os_uname().sysname == "Windows_NT" then
      cmd = 'quarto preview \\"' .. buffer_path .. '\\"' .. " " .. args
    else
      cmd = "quarto preview '" .. buffer_path .. "'" .. " " .. args
    end
  end

  local quarto_extensions = { ".qmd", ".Rmd", ".ipynb", ".md" }
  local file_extension = buffer_path:match("^.+(%..+)$")
  if mode == "file" and not file_extension then
    vim.notify("Not in a file. exiting.")
    return
  end
  if mode == "file" and not tools.contains(quarto_extensions, file_extension) then
    vim.notify("Not a quarto file, ends in " .. file_extension .. " exiting.")
    return
  end

  -- run command in embedded terminal
  -- in a new tab and go back to the buffer
  vim.cmd("tabedit term://" .. cmd)
  local quartoOutputBuf = vim.api.nvim_get_current_buf()
  vim.cmd("tabprevious")
  api.nvim_buf_set_var(0, "quartoOutputBuf", quartoOutputBuf)

  if not cfg.config then
    return
  end

  -- close preview terminal on exit of the quarto buffer
  if cfg.config.closePreviewOnExit then
    api.nvim_create_autocmd({ "QuitPre", "WinClosed" }, {
      buffer = api.nvim_get_current_buf(),
      group = api.nvim_create_augroup("quartoPreview", {}),
      callback = function(_, _)
        if api.nvim_buf_is_loaded(quartoOutputBuf) then
          api.nvim_buf_delete(quartoOutputBuf, { force = true })
        end
      end,
    })
  end
end

function M.quartoClosePreview()
  local success, quartoOutputBuf = pcall(api.nvim_buf_get_var, 0, "quartoOutputBuf")
  if not success then
    return
  end
  if api.nvim_buf_is_loaded(quartoOutputBuf) then
    api.nvim_buf_delete(quartoOutputBuf, { force = true })
  end
end

M.searchHelp = function(cmd_input)
  local topic = cmd_input.args
  local url = "https://quarto.org/?q=" .. topic .. "&show-results=1"
  local sysname = vim.loop.os_uname().sysname
  local cmd
  if sysname == "Linux" then
    cmd = 'xdg-open "' .. url .. '"'
  elseif sysname == "Darwin" then
    cmd = 'open "' .. url .. '"'
  else
    print(
      "sorry, I do not know how to make Windows open a url with the default browser. This feature currently only works on linux and mac."
    )
    return
  end
  vim.fn.jobstart(cmd)
end

M.activate = function()
  local tsquery = nil
  if cfg.config.lspFeatures.chunks == "curly" then
    tsquery = [[
      (fenced_code_block
      (info_string
        (language) @_lang
      ) @info
        (#match? @info "{")
      (code_fence_content) @content (#offset! @content)
      )
      ((html_block) @html @combined)

      ((minus_metadata) @yaml (#offset! @yaml 1 0 -1 0))
      ((plus_metadata) @toml (#offset! @toml 1 0 -1 0))

      ]]
  end
  otter.activate(
    cfg.config.lspFeatures.languages,
    cfg.config.lspFeatures.completion.enabled,
    cfg.config.lspFeatures.diagnostics.enabled,
    tsquery
  )
end

-- setup
M.setup = function(opt)
  cfg.config = vim.tbl_deep_extend("force", cfg.defaultConfig, opt or {})

  if cfg.config.codeRunner.enabled then
    -- setup top level run functions
    local runner = require("quarto.runner")
    M.quartoSend = runner.run_cell
    M.quartoSendAbove = runner.run_above
    M.quartoSendBelow = runner.run_below
    M.quartoSendAll = runner.run_all
    M.quartoSendRange = runner.run_range
    M.quartoSendLine = runner.run_line

    -- setup run user commands
    api.nvim_create_user_command("QuartoSend", runner.run_cell, {})
    api.nvim_create_user_command("QuartoSendAbove", runner.run_above, {})
    api.nvim_create_user_command("QuartoSendBelow", runner.run_below, {})
    api.nvim_create_user_command("QuartoSendAll", runner.run_all, {})
    api.nvim_create_user_command("QuartoSendRange", runner.run_range, { range = 2 })
    api.nvim_create_user_command("QuartoSendLine", runner.run_line, {})
  end
end


return M
