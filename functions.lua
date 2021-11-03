
function sculpture.compress(string)
  return minetest.encode_base64(minetest.compress(string, "deflate"))
end

function sculpture.decompress(string)
  return minetest.decompress(minetest.decode_base64(string), "deflate")
end

function sculpture.init_grid()
  local grid = {}
	for z = 0, 15 do
    grid[z] = {}
	  for y = 0, 15 do
      grid[z][y] = {}
		  for x = 0, 15 do
        grid[z][y][x] = 1
      end
    end
  end
  return grid;
end

local function point_3d_to_2d_z(x, y, z)
  local tx = x + math.fmod(z,4)*16
  local ty = y + math.floor(z/4)*16
  --print("tx: "..tx.." ty: "..ty)
  return tx, ty
end
local function point_3d_to_2d_x(x, y, z)
  local tx = z + math.fmod((15-x),4)*16
  local ty = y + math.floor((15-x)/4)*16
  --print("tx: "..tx.." ty: "..ty)
  return tx, ty
end
local function point_3d_to_2d_y(x, y, z)
  local tx = (15-x) + math.fmod((15-y),4)*16
  local ty = z + math.floor((15-y)/4)*16
  --print("tx: "..tx.." ty: "..ty)
  return tx, ty
end

function sculpture.to_texturestring(data, axis)
	if not data then
		minetest.log("error", "[sculpture] missing data")
		return
	end
  local material_data = sculpture.materials[data.material]
	if not material_data then
		minetest.log("error", "[sculpture] missing material data for material "..data.material)
		return
	end
  local point_3d_to_2d = point_3d_to_2d_y
  if (axis == 3) or (axis == 4) then
    point_3d_to_2d = point_3d_to_2d_x
    --print("use x axis "..axis)
  elseif (axis == 5) or (axis == 6) then
    point_3d_to_2d = point_3d_to_2d_z
    --print("use z axis "..axis)
  end
  local colorize = {}
	local texture = {"[combine:64x64"}
	for z = 0, 15 do
	  for y = 0, 15 do
		  for x = 0, 15 do
        local point = data.grid[z][y][x]
        if point==0 then
          local tx, ty = point_3d_to_2d(x,y,z)
          --table.insert(texture, ":"..tx..","..ty.."=sculpture_makealpha.png")
          table.insert(texture, ":"..tx..","..ty.."=a.png")
        elseif type(point) == "string" then
          -- all sides colored
          local tx, ty = point_3d_to_2d(x,y,z)
          --table.insert(colorize, "^(([combine:64x64:"..tx..","..ty.."=sculpture_white.png)^[colorize:#"..point..")")
          table.insert(colorize, "^(([combine:64x64:"..tx..","..ty.."=w.png)^[colorize:#"..point..")")
        elseif type(point) == "table" then
          -- only some sides can be colored
          if type(point[axis]=="string") then
            local tx, ty = point_3d_to_2d(x,y,z)
            --table.insert(colorize, "^(([combine:64x64:"..tx..","..ty.."=sculpture_white.png)^[colorize:#"..point[axis]..")")
            table.insert(colorize, "^(([combine:64x64:"..tx..","..ty.."=w.png)^[colorize:#"..point[axis]..")")
          end
        end
      end
		end
	end
	table.insert(texture, ")^[makealpha:1,1,1)")
	--print(table.concat(t))
	return "("..material_data.textures[axis].."^("..table.concat(texture)..table.concat(colorize)
end

local function add_point(points, from_pos, x, y, z, axis)
  if      (x>=-0.5) and (x<=0.5) 
      and (y>=-0.5) and (y<=0.5)
      and (z>=-0.5) and (z<=0.5) then
    local pos = vector.new(x, y, z)
    --print("good point "..dump(pos))
    local diff = vector.length(vector.subtract(pos, from_pos))
    local index = 1
    if (#points>0) and (diff>points[1].diff) then
      index = #points+1
      for n=2,#points do
        if (points[n-1].diff<=diff) and (points[n].diff>=diff) then
          index = n
          break;
        end
      end
    end
    table.insert(points, index, {
        pos = pos,
        diff = diff,
        axis = axis,
      })
  end
end

function sculpture.find_pointed_part(sculture_grid, from_pos, from_dir, to_pos)
  -- x = from.x + t*u.x
  -- y = from.y + t*u.y
  -- z = from.y + t*u.z
  --print("from_pos: "..dump(from_pos))
  --print("from_dir: "..dump(from_dir))
  --print("to_pos: "..dump(to_pos))
  from_pos = vector.subtract(from_pos, to_pos)
  --print("from_pos: "..dump(from_pos))
  
  local points = {}
  local t, x, y, z = 0
  -- fixed to 16x16x16 grid
  if from_dir.x~=0 then
    local axis = 3
    if from_dir.x>=0 then
      axis = 4
    end
    for x=-8,8 do
      t = (x/16 - from_pos.x)/from_dir.x
      y = from_pos.y + t*from_dir.y
      z = from_pos.z + t*from_dir.z
      --print("y: "..y.." z: "..z)
      add_point(points, from_pos, x/16, y, z, axis)
    end
  end
  if from_dir.y~=0 then
    local axis = 1
    if from_dir.y>=0 then
      axis = 2
    end
    for y=-8,8 do
      t = (y/16 - from_pos.y)/from_dir.y
      x = from_pos.x + t*from_dir.x
      z = from_pos.z + t*from_dir.z
      --print("x: "..x.." z: "..z)
      add_point(points, from_pos, x, y/16, z, axis)
    end
  end
  if from_dir.z~=0 then
    local axis = 5
    if from_dir.z>=0 then
      axis = 6
    end
    for z=-8,8 do
      t = (z/16 - from_pos.z)/from_dir.z
      x = from_pos.x + t*from_dir.x
      y = from_pos.y + t*from_dir.y
      --print("x: "..x.." y: "..y)
      add_point(points, from_pos, x, y, z/16, axis)
    end
  end
  
  -- check colisions and grid
  local pointed = nil
  --print(dump(points))
  for _, point in pairs(points) do
    x = math.floor((point.pos.x + 0.5) * 16)
    y = math.floor((point.pos.y + 0.5) * 16)
    z = math.floor((point.pos.z + 0.5) * 16)
    x = math.min(x, 15)
    y = math.min(y, 15)
    z = math.min(z, 15)
    if sculture_grid[z][y][x]~=0 then
      pointed = vector.new(x,y,z)
      --print("point: "..dump(point.pos))
      --print("grid: "..dump(pointed))
      break
    end
  end
  
  return pointed
end

function sculpture.tool_cut_point(itemstack, material, point)
  local def = itemstack:get_definition()
  if (not material) or (not def._sculpture_tool.category_name[material.category]) then
    print("Missing material or category.")
    return point
  end
  if def._sculpture_tool.category_name[material.category] < material.strength then
    print("Too weak tool for this material.")
    return point
  end
  local wear = def._sculpture_tool.wear*(def._sculpture_tool.category_name[material.category]-material.strength+1)
  itemstack:add_wear(wear)
  return 0
end

