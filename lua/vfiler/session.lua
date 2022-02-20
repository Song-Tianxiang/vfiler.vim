local core = require('vfiler/libs/core')

------------------------------------------------------------------------------
-- ItemAttribute class
------------------------------------------------------------------------------
local ItemAttribute = {}
ItemAttribute.__index = ItemAttribute

function ItemAttribute.copy(attribute)
  local root_attr = ItemAttribute.new(attribute.name)
  for name, attr in pairs(attribute.opened_attributes) do
    root_attr.opened_attributes[name] = ItemAttribute.copy(attr)
  end
  for name, selected in pairs(attribute.selected_names) do
    root_attr.selected_names[name] = selected
  end
  return root_attr
end

function ItemAttribute.parse(root)
  local root_attr = ItemAttribute.new(root.name)
  if not root.children then
    return root_attr
  end
  for _, child in ipairs(root.children) do
    if child.opened then
      root_attr.opened_attributes[child.name] = ItemAttribute.parse(child)
    end
    if child.selected then
      root_attr.selected_names[child.name] = true
    end
  end
  return root_attr
end

function ItemAttribute.new(name)
  return setmetatable({
    name = name,
    opened_attributes = {},
    selected_names = {},
  }, ItemAttribute)
end

------------------------------------------------------------------------------
-- Session class
------------------------------------------------------------------------------
local Session = {}
Session.__index = Session

local shared_attributes = {}
local shared_drives = {}

local function expand(root, attribute)
  for _, child in ipairs(root.children) do
    local opened = attribute.opened_attributes[child.name]
    if opened then
      child:open()
      expand(child, opened)
    end

    local selected = attribute.selected_names[child.name]
    if selected then
      child.selected = true
    end
  end
  return root
end

function Session.new(type)
  local attributes
  if type == 'buffer' then
    attributes = {}
  elseif type == 'share' then
    attributes = shared_attributes
  end

  local drives
  if type == 'share' then
    drives = shared_drives
  else
    drives = {}
  end

  return setmetatable({
    _type = type,
    _attributes = attributes,
    _drives = drives,
  }, Session)
end

function Session:copy()
  local new = Session.new(self._type)
  if new._type ~= 'share' then
    new._drives = core.table.copy(self._drives)
  end

  if new._type == 'buffer' then
    for path, attribute in pairs(self._attributes) do
      new._attributes[path] = {
        previus_path = attribute.previus_path,
        object = ItemAttribute.copy(attribute.object),
      }
    end
  end
  return new
end

function Session:save(root, path)
  local drive = core.path.root(root.path)
  self._drives[drive] = root.path
  if self._attributes then
    self._attributes[root.path] = {
      previus_path = path,
      object = ItemAttribute.parse(root),
    }
  end
end

function Session:load(root)
  if not self._attributes then
    return nil
  end
  local attribute = self._attributes[root.path]
  if not attribute then
    return nil
  end
  expand(root, attribute.object)
  return attribute.previus_path
end

function Session:get_path_in_drive(drive)
  local dirpath = self._drives[drive]
  if not dirpath then
    return nil
  end
  return dirpath
end

return Session
