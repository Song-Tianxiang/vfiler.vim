local a = require('vfiler/actions/directory')
local u = require('tests/utilities')

local configs = {
  options = u.vfiler.generate_options(),
}

describe('directory actions', function()
  local vfiler = u.vfiler.start(configs)
  it(u.vfiler.desc('open tree recursive', vfiler), function()
    local view = vfiler._view
    local init_lnum = configs.options.header and 2 or 1

    local item
    for lnum = init_lnum, view:num_lines() do
      item = view:get_item(lnum)
      if item.type == 'directory' then
        view:move_cursor(item.path)
        break
      end
    end
    vfiler:do_action(a.open_tree_recursive)
    assert.is_true(item.opened)
  end)
  vfiler:quit(true)
end)
