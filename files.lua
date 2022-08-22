
local sculpturedir = minetest.get_worldpath().."/sculpture/"

minetest.mkdir(sculpturedir)

function sculpture.complete_path(filename)
  return sculpturedir..filename
end

function sculpture.file_exists(filename)
  local file = io.open(sculpture.complete_path(filename),"r")
  if (file==nil) then
    return false
  end
  file:close()
  return true
end

function sculpture.file_to_string(filename)
  local file = io.open(sculptured.complete_path(filename),"r")
  if not file then
    return nil
  end
  local text = file:read("a")
  file:close()
  return text
end

function sculpture.string_to_file(filename, text)
  local file = io.open(sculpture.complete_path(filename),"w")
  if not file then
    return false
  end
  file:write(text)
  file:close()
  return true
end

