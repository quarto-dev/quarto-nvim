local M = {}
local api = vim.api
local cfg = require 'quarto.config'
local tools = require 'quarto.tools'
local util = require 'lspconfig.util'

function M.quartoPreview(opts)
  opts = opts or {}
  local args = opts.args or ''

  -- Find root directory / check if it is a project
  local buffer_path = api.nvim_buf_get_name(0)
  local root_dir = util.root_pattern '_quarto.yml'(buffer_path)
  local cmd
  local mode

  if root_dir then
    mode = 'project'
    cmd = 'quarto preview ' .. args
  else
    mode = 'file'
    cmd = 'quarto preview ' .. vim.fn.shellescape(buffer_path) .. ' ' .. args
  end

  -- Check file extensions
  local quarto_extensions = { '.qmd', '.Rmd', '.ipynb', '.md' }
  local file_extension = buffer_path:match '^.+(%..+)$'
  if mode == 'file' and not file_extension then
    vim.notify 'Not in a file. exiting.'
    return
  end
  if mode == 'file' and not tools.contains(quarto_extensions, file_extension) then
    vim.notify('Not a quarto file, ends in ' .. file_extension .. ' exiting.')
    return
  end

  -- Store current tabpage
  local current_tabpage = vim.api.nvim_get_current_tabpage()

  -- Open a new tab for the terminal
  vim.cmd('tabnew')
  local term_buf = vim.api.nvim_create_buf(true, false)
  vim.api.nvim_set_current_buf(term_buf)

  vim.fn.termopen(cmd, {
    on_exit = function(_, exit_code, _)
      if exit_code ~= 0 then
        vim.notify("Quarto preview exited with code " .. exit_code, vim.log.levels.ERROR)
      end
    end,
  })

  -- Store the terminal buffer and return to previous tab
  local quartoOutputBuf = vim.api.nvim_get_current_buf()
  vim.api.nvim_set_current_tabpage(current_tabpage)
  api.nvim_buf_set_var(0, 'quartoOutputBuf', quartoOutputBuf)

  -- Close preview terminal on exit of the Quarto buffer
  if cfg.config and cfg.config.closePreviewOnExit then
    api.nvim_create_autocmd({ 'QuitPre', 'WinClosed' }, {
      buffer = api.nvim_get_current_buf(),
      group = api.nvim_create_augroup('quartoPreview', {}),
      callback = function(_, _)
        if api.nvim_buf_is_loaded(quartoOutputBuf) then
          api.nvim_buf_delete(quartoOutputBuf, { force = true })
        end
      end,
    })
  end
end

function M.quartoClosePreview()
  local success, quartoOutputBuf = pcall(api.nvim_buf_get_var, 0, 'quartoOutputBuf')
  if not success then
    return
  end
  if api.nvim_buf_is_loaded(quartoOutputBuf) then
    api.nvim_buf_delete(quartoOutputBuf, { force = true })
  end
end

M.searchHelp = function(cmd_input)
  local topic = cmd_input.args
  local url = 'https://quarto.org/?q=' .. topic .. '&show-results=1'
  local sysname = vim.loop.os_uname().sysname
  local cmd
  if sysname == 'Linux' then
    cmd = 'xdg-open "' .. url .. '"'
  elseif sysname == 'Darwin' then
    cmd = 'open "' .. url .. '"'
  else
    print 'sorry, I do not know how to make Windows open a url with the default browser. This feature currently only works on linux and mac.'
    return
  end
  vim.fn.jobstart(cmd)
end

M.activate = function()
  local tsquery = nil
  if cfg.config.lspFeatures.chunks == 'curly' then
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
  require('otter').activate(cfg.config.lspFeatures.languages, cfg.config.lspFeatures.completion.enabled, cfg.config.lspFeatures.diagnostics.enabled, tsquery)
end

-- setup
M.setup = function(opt)
  cfg.config = vim.tbl_deep_extend('force', cfg.defaultConfig, opt or {})

  if cfg.config.codeRunner.enabled then
    -- setup top level run functions
    local runner = require 'quarto.runner'
    M.quartoSend = runner.run_cell
    M.quartoSendAbove = runner.run_above
    M.quartoSendBelow = runner.run_below
    M.quartoSendAll = runner.run_all
    M.quartoSendRange = runner.run_range
    M.quartoSendLine = runner.run_line

    -- setup run user commands
    api.nvim_create_user_command('QuartoSend', function(_)
      runner.run_cell()
    end, {})
    api.nvim_create_user_command('QuartoSendAbove', function(_)
      runner.run_above()
    end, {})
    api.nvim_create_user_command('QuartoSendBelow', function(_)
      runner.run_below()
    end, {})
    api.nvim_create_user_command('QuartoSendAll', function(_)
      runner.run_all()
    end, {})
    api.nvim_create_user_command('QuartoSendRange', function(_)
      runner.run_range()
    end, { range = 2 })
    api.nvim_create_user_command('QuartoSendLine', function(_)
      runner.run_line()
    end, {})
  end
end

return M
