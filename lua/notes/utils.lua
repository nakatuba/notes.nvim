local M = {}

function M.dir_exists(dir)
  if vim.fn.isdirectory(vim.fn.expand(dir)) == 0 then
    vim.notify('Directory does not exist: ' .. dir, vim.log.levels.ERROR)
    return false
  end

  return true
end

function M.get_items(dir, types)
  local cmd = [[
fd -e md --strip-cwd-prefix -x sh -c '
  head -n 1 "$1" | grep -q "^---" &&
  yq --front-matter=extract -o json "$1" | jq --arg path $1 "{path: \$path} + ."
' _ {} | jq -s 'sort_by(.path)'
]]
  local cwd = vim.fn.expand(dir)
  local obj = vim.system({ 'sh', '-c', cmd }, { cwd = cwd, text = true }):wait()
  local notes = vim.json.decode(obj.stdout, { luanil = { object = true, array = true } })

  local items = {}
  for _, note in ipairs(notes) do
    note.type = vim.fs.dirname(note.path)
    note.title = note.title or vim.fs.basename(note.path)
    note.tags = note.tags or {}
    if vim.tbl_contains(types, note.type) then
      table.insert(items, {
        file = vim.fs.joinpath(cwd, note.path),
        text = note.type .. ' ' .. note.title .. ' ' .. table.concat(note.tags, ' '),
        value = note
      })
    end
  end

  return items
end

function M.get_format(highlights)
  return function(item)
    local a = require('snacks').picker.util.align
    local note = item.value
    local tags = {}
    for _, tag in ipairs(note.tags) do
      table.insert(tags, '#' .. tag)
    end

    return {
      { a(note.type, 12), highlights[note.type] },
      { note.title },
      { ' ' },
      { table.concat(tags, ' '), highlights.tags }
    }
  end
end

function M.get_relative_path(from_dir, to_path)
  local from_parts = vim.split(from_dir, '/', { plain = true })
  local to_parts = vim.split(to_path, '/', { plain = true })

  local common_length = 0
  for i = 1, math.min(#from_parts, #to_parts) do
    if from_parts[i] == to_parts[i] then
      common_length = i
    else
      break
    end
  end

  local result = {}
  for _ = common_length + 1, #from_parts do
    table.insert(result, '..')
  end
  for i = common_length + 1, #to_parts do
    table.insert(result, to_parts[i])
  end

  return table.concat(result, '/')
end

return M
