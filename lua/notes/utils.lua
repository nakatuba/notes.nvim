local M = {}

function M.dir_exists(dir)
  if vim.fn.isdirectory(vim.fn.expand(dir)) == 0 then
    vim.notify('Directory "' .. dir .. '" does not exist', vim.log.levels.ERROR)
    return false
  end

  return true
end

function M.get_items(dir)
  local cmd = [[
fd -d 1 -e md --strip-cwd-prefix \
  -x sh -c 'yq --front-matter=extract -o json {} | jq --arg path {} ". + {path: \$path}"' | \
  jq -s 'sort_by(.path)'
]]
  local cwd = vim.fn.expand(dir)
  local obj = vim.system({ 'sh', '-c', cmd }, { cwd = cwd, text = true }):wait()
  local notes = vim.json.decode(obj.stdout, { luanil = { object = true, array = true } })

  local items = {}
  for _, note in ipairs(notes) do
    table.insert(items, {
      file = vim.fs.joinpath(cwd, note.path),
      text = note.title or note.path,
      value = note
    })
  end

  return items
end

return M
