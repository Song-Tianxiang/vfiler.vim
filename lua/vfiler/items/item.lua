local core = require('vfiler/libs/core')
local fs = require('vfiler/libs/filesystem')

local Item = {}
Item.__index = Item

function Item.new(stat)
  local self = setmetatable({
    gitstatus = nil,
    level = 0,
    parent = nil,
    selected = false,
  }, Item)
  return self:_set_stat(stat)
end

function Item:delete()
  if not fs.delete(self:_get_path()) then
    core.message.error('"%s" Cannot delete.', self.name)
    return false
  end
  self:_become_orphan()
  return true
end

function Item:rename(name)
  local newpath = core.path.join(self.parent.path, name)
  if not fs.move(self:_get_path(), newpath) then
    core.message.error('Failed to rename.')
    return false
  end
  self.name = name
  self.path = newpath
  return true
end

function Item:update()
  local stat = fs.stat(self:_get_path())
  if not stat then
    return
  end
  self:_set_stat(stat)
end

--- Remove from parent tree
function Item:_become_orphan()
  if not self.parent then
    return
  end

  self.parent:remove(self)
end

function Item:_get_path()
  local path = self.path
  if self.link and self.type == 'directory' and path:match('/$') then
    return path:sub(1, #path - 1)
  end
  return path
end

function Item:_move(destpath)
  local path = self:_get_path()
  if not fs.move(path, destpath) then
    return false
  end
  if not core.path.exists(destpath) and core.path.exists(path) then
    return false
  end
  self:_become_orphan()
  return true
end

function Item:_set_stat(stat)
  self.name = stat.name
  self.path = stat.path
  self.size = stat.size
  self.time = stat.time
  self.type = stat.type
  self.mode = stat.mode
  self.link = stat.link
  return self
end

return Item
