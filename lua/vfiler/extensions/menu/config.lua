local action = require('vfiler/extensions/menu/action')
local core = require('vfiler/libs/core')

local M = {}

M.configs = {
  options = {
    floating = {
      width = 'auto',
      height = 'auto',
      minwidth = 4,
      minheight = 1,
      relative = true,
    },
  },

  mappings = {
    ['k'] = action.loop_cursor_up,
    ['j'] = action.loop_cursor_down,
    ['q'] = action.quit,
    ['<CR>'] = action.select,
    ['<ESC>'] = action.quit,
  },

  events = {
    vfiler_menu = {
      {
        event = 'WinLeave',
        action = action.quit,
      },
    },
  },
}

function M.setup(configs)
  return core.table.merge(M.configs, configs)
end

return M
