local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
local notes = require('notes')

function actions.new_note(prompt_bufnr)
  actions.close(prompt_bufnr)
  notes.new_note()
end

function actions.new_daily_note(prompt_bufnr)
  actions.close(prompt_bufnr)
  notes.new_daily_note()
end

function actions.insert_link(prompt_bufnr)
  actions.close(prompt_bufnr)
  local selection = action_state.get_selected_entry()
  local note = selection.value
  vim.schedule(function()
    vim.cmd.startinsert()
    vim.api.nvim_put({ '[' .. note.title .. '](' .. note.filename .. ')' }, '', true, true)
  end)
end

return actions
