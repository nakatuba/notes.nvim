local M = {}

function M.dir_exists(dir)
  if vim.fn.isdirectory(vim.fn.expand(dir)) == 0 then
    vim.notify('Directory does not exist: ' .. dir, vim.log.levels.ERROR)
    return false
  end

  return true
end

function M.get_items(dir)
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
    table.insert(items, {
      file = vim.fs.joinpath(cwd, note.path),
      text = note.type .. ' ' .. note.title .. ' ' .. table.concat(note.tags, ' '),
      value = note
    })
  end

  return items
end

function M.format(item)
  local a = require('snacks').picker.util.align
  local note = item.value
  local type_hl = { literature = 'Green', permanent = 'Blue' }
  local tags = {}
  for _, tag in ipairs(note.tags) do
    table.insert(tags, '#' .. tag)
  end

  return {
    { a(note.type, 12), type_hl[note.type] },
    { note.title },
    { ' ' },
    { table.concat(tags, ' '), 'Purple' }
  }
end

return M
