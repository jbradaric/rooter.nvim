local cmd = vim.api.nvim_command
local utils = require('rooter/utils')

local M = {}
local default_config = {
  patterns = {'.git', '_darcs', '.hg', '.bzr', '.svn', 'Makefile', 'CMakeLists.txt', 'package.json', 'Cargo.toml'},
  cd_command = 'cd',
  change_dir_for_non_project_files = '',
  chdir_on_buf_enter = true,
  vim_rooter_compat = true,
}
local config = {}

local function merge_config(default, user_conf)
  if user_conf == nil then
    user_conf = {}
  end
  config = vim.tbl_deep_extend('error', {}, default)
  config = vim.tbl_extend('force', config, user_conf)
  return config
end

local function initialize(config)
  if config.chdir_on_buf_enter then
    cmd('augroup rooter')
    cmd('autocmd!')
    cmd('autocmd BufReadPost,BufEnter * lua require("rooter").update_cwd()')
    cmd('augroup END')
  end

  if config.vim_rooter_compat then
    cmd([[
      function! FindRootDirectory()
        return v:lua.require'rooter'.find_root(expand('%:p'))
      endfunction
    ]])

    cmd('command! Rooter lua require("rooter").update_cwd()')
  end
end

function M.setup(opts)
  config = merge_config(default_config, opts)
  initialize(config)
end

local function find_root(path, config)
  local parent = utils.dirname(path)
  while true do
    if not parent or parent == '' or parent == '/' then
      break
    end
    for _, pat in ipairs(config.patterns) do
      if utils.path_exists(parent .. '/' .. pat) then
        return parent
      end
    end
    parent = utils.dirname(parent)
  end

  if not path or path == '' then
    return nil
  end

  local behavior = config['change_dir_for_non_project_files'] or ''
  if behavior == '' then
    return nil
  elseif behavior == 'current' then
    return utils.dirname(path)
  elseif behavior == 'home' then
    return os.getenv('HOME')
  end
end

function M.find_root(path)
  if path == nil then
    local current = vim.api.nvim_get_current_buf()
    path = vim.api.nvim_buf_get_name(tonumber(current))
  end
  return find_root(path, config)
end

function M.update_cwd()
  local path = vim.fn.expand('%:p')
  local root_dir = M.find_root(path)
  if root_dir then
    cmd('execute "' .. config.cd_command .. ' ' .. root_dir .. '"')
  end
end

return M
