local core = require('vfiler/libs/core')
local fs = require('vfiler/libs/filesystem')

local Item = {}
Item.__index = Item

function Item.new(stat)
  return setmetatable({
    gitstatus = nil,
    level = 0,
    name = stat.name,
    parent = nil,
    path = stat.path,
    selected = false,
    size = stat.size,
    time = stat.time,
    type = stat.type,
    mode = stat.mode,
    link = stat.link,
  }, Item)
end

function Item:delete()
  if not fs.delete(self.path) then
    core.message.error('"%s" Cannot delete.', self.name)
    return false
  end
  self:_become_orphan()
  return true
end

function Item:rename(name)
  local newpath = core.path.join(self.parent.path, name)
  if not fs.move(self.path, newpath) then
    core.message.error('Failed to rename.')
    return false
  end
  self.name = name
  self.path = newpath
  return true
end

--- Remove from parent tree
function Item:_become_orphan()
  if not self.parent then
    return
  end

  local children = self.parent.children
  for i, child in ipairs(children) do
    if child.path == self.path then
      table.remove(children, i)
      break
    end
  end
end

function Item:_move(destpath)
  if not fs.move(self.path, destpath) then
    return false
  end
  if not core.path.exists(destpath) and core.path.exists(self.path) then
    return false
  end
  self:_become_orphan()
  return true
end

return Item
