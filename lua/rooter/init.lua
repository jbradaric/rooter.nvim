local cmd = vim.api.nvim_command
local utils = require('rooter/utils')

local M = {}
local default_config = {
  patterns = {'.git', '_darcs', '.hg', '.bzr', '.svn', 'Makefile', 'CMakeLists.txt', 'package.json', 'Cargo.toml'},
  targets = {"/", "*"},
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

local function initialize_target_globs(config)
  local targets = config.targets
  if not targets then
    return
  end
  local new_targets = {}
  for _, target in ipairs(targets) do
    if target == '/' then
      new_targets[#new_targets + 1] = vim.regex(vim.fn.glob2regpat('*/'))
    else
      new_targets[#new_targets + 1] = vim.regex(vim.fn.glob2regpat(target))
    end
  end

  config.targets = new_targets
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

function is_target(path, config)
  if not path or path == '' then
    return false
  end

  for _, target_re in ipairs(config.targets) do
    if target_re:match_str(path) then
      return true
    end
  end
  return false
end

function M.setup(opts)
  config = merge_config(default_config, opts)
  initialize_target_globs(config)
  initialize(config)
end

local function find_root(path, config)
  if utils.startswith(path, 'term:') then
    return nil
  end
  if not is_target(path, config) then
    return nil
  end

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
