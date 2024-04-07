local entry_display = require('telescope.pickers.entry_display')

local make_entry = {}

function make_entry.gen_from_note(opts)
  local displayer = entry_display.create {
    separator = ' │ ',
    items = {
      { width = 0.5 },
      { remaining = true }
    }
  }

  local make_display = function(entry)
    local note = entry.value

    return displayer {
      note.title,
      table.concat(note.tags, ' ')
    }
  end

  return function(entry)
    local note = {}
    note.filename = entry
    note.path = vim.fn.expand(opts.dir .. '/' .. entry)

    local lines = {}
    local in_frontmatter = false
    for line in io.lines(note.path) do
      if not in_frontmatter and line:match('^---+$') then
        in_frontmatter = true
      elseif in_frontmatter and line:match('^---+$') then
        break
      end

      table.insert(lines, line)
    end

    local frontmatter = table.concat(lines, '\n')
    local metadata = require('yaml').load(frontmatter)

    if metadata == nil then
      return
    end

    for k, v in pairs(metadata) do
      note[k] = v
    end

    for i, tag in ipairs(note.tags) do
      note.tags[i] = '#' .. tag
    end

    return {
      value = note,
      ordinal = note.title .. ' ' .. table.concat(note.tags, ' '),
      display = make_display,
      path = note.path
    }
  end
end

return make_entry
