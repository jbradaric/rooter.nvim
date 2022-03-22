local cmd = vim.api.nvim_command
local utils = require('rooter/utils')

local M = {}

local default_patterns = {'.git', '.hg'}

local function initialize()
  cmd('augroup rooter')
  cmd('autocmd!')
  cmd('autocmd BufReadPost,BufEnter *.py call Rooter()')
  cmd('augroup END')

  cmd([[
    function! Rooter()
      execute "cd " . v:lua.require'rooter'.find_root(expand('%:p'))
    endfunction
  ]])

  cmd([[
    function! FindRootDirectory()
      return v:lua.require'rooter'.find_root(expand('%:p'))
    endfunction
  ]])

  cmd('command Rooter call Rooter()')
end

function M.setup(opts)
  initialize()

  local patterns = opts and opts['patterns']
  if not patterns then
    patterns = default_patterns
  end
  M.patterns = patterns
end

local function find_root(path, patterns)
  local parent = utils.dirname(path)
  local result = false
  while true do
    if not parent or parent == '' or parent == '/' then
      break
    end
    for _, pat in ipairs(patterns) do
      if utils.path_exists(parent .. '/' .. pat) then
        return parent
      end
    end
    parent = utils.dirname(parent)
  end

  if not path or path == '' then
    return os.getenv('HOME')
  else
    return utils.dirname(path)
  end
end

function M.find_root(path)
  if path == nil then
    local current = vim.api.nvim_get_current_buf()
    path = vim.api.nvim_buf_get_name(tonumber(current))
  end
  local root = find_root(path, M.patterns)
  return root
end

return M
