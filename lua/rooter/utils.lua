local loop = vim.loop

local M = {}

function M.path_exists(p)
  local stat = loop.fs_stat(p)
  return stat and true or false
end

function M.dirname(path)
  local strip_dir_pat = '/([^/]+)$'
  local strip_sep_pat = '/$'
  if not path or #path == 0 then
    return
  end
  local result = path:gsub(strip_sep_pat, ''):gsub(strip_dir_pat, '')
  if #result == 0 then
    return '/'
  end
  return result
end

return M
