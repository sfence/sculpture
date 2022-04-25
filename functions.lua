
local S = sculpture.translator

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

-- optimise masks
local opts_mask = {}
for y = 0,15 do
  for x = 0,15 do
    key = y*16+x
    -- squares
    opts_mask[key] = {["sF"] = 256}
    if (y<8) and (x<8) then
      opts_mask[key]["s8"] = 64
    end
    if (y<4) and (x<4) then
      opts_mask[key]["s4"] = 16
    end
    if (y<2) and (x<2) then
      opts_mask[key]["s2"] = 4
    end
    -- horizontal lines
    if (y==0) then
      opts_mask[key]["hF"] = 16
    end
    if (y==0) and (x<8) then
      opts_mask[key]["h8"] = 8
    end
    if (y==0) and (x<4) then
      opts_mask[key]["h4"] = 4
    end
    if (y==0) and (x<2) then
      opts_mask[key]["h2"] = 2
    end
    -- vertical lines
    if (x==0) then
      opts_mask[key]["vF"] = 16
    end
    if (x==0) and (y<8) then
      opts_mask[key]["v8"] = 8
    end
    if (x==0) and (y<4) then
      opts_mask[key]["v4"] = 4
    end
    if (x==0) and (y<2) then
      opts_mask[key]["v2"] = 2
    end
  end
end
opts_mask[0][""] = 1

local function get_best_opt(tp, tx, ty, base)
  local opts = {
    ["sF"] = 256,
    ["s8"] = 64,
    ["s4"] = 16,
    ["s2"] = 4,
    
    ["hF"] = 16,
    ["h8"] = 8,
    ["h4"] = 4,
    ["h2"] = 2,
    
    ["vF"] = 16,
    ["v8"] = 8,
    ["v4"] = 4,
    ["v2"] = 2,
    
    [""] = 1,
  }
  -- look for usable optimises
  for y = 0,15 do
    for x = 0,15 do
      if (tp[ty+y]==nil) or (tp[ty+y][tx+x]~=base) then
        local mask = opts_mask[y*16+x]
        for key,_ in pairs(mask) do
          opts[key] = 0
        end
      end
    end
  end
  
  -- find best optimise from aviable
  local best_points = 0
  local best_opt = ""
  for opt,points in pairs(opts) do
    if points>best_points then
      best_points = points
      best_opt = opt
    end
  end
  
  -- remove opt from tp list
  if best_opt~="" then
    for y = 0,15 do
      for x = 0,15 do
        if opts_mask[y*16+x][best_opt] then
          tp[ty+y][tx+x] = 1 -- ignore it next time
        end
      end
    end
  end
  
  return best_opt
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
  local tp = {}
  local colors = {}
  for ty = 0,63 do
    tp[ty] = {}
    for tx = 0,63 do
      tp[ty][tx] = 1
    end
  end
	for z = 0, 15 do
	  for y = 0, 15 do
		  for x = 0, 15 do
        local point = data.grid[z][y][x]
        if point==0 then
          local tx, ty = point_3d_to_2d(x,y,z)
          tp[ty][tx] = 0
        elseif type(point) == "string" then
          -- all sides colored
          local tx, ty = point_3d_to_2d(x,y,z)
          tp[ty][tx] = point
          colors[point] = {}
        elseif type(point) == "table" then
          -- only some sides can be colored
          if type(point[axis])=="string" then
            local tx, ty = point_3d_to_2d(x,y,z)
            tp[ty][tx] = point[axis]
            colors[point[axis]] = {}
          end
        end
      end
		end
	end
  
  local cuts = {}
  for ty = 0,63 do
    for tx = 0,63 do
      local base = tp[ty][tx]
      if (base~=1) then
        local opt = get_best_opt(tp, tx, ty, base)
        if (base == 0) then
          table.insert(cuts, ":"..tx..","..ty.."=a"..opt..".png")
        elseif type(base)=="string" then
          table.insert(colors[base], ":"..tx..","..ty.."=w"..opt..".png")
        elseif type(base)=="table" then
          table.insert(colors[base[axis]], ":"..tx..","..ty.."=w"..opt..".png")
        end
      end
    end
  end
  --print(dump(cuts))
  --print(dump(colors))
  
  local texture = ""..material_data.textures[axis]
  if #cuts>0 then
	  texture = "("..texture.."^([combine:64x64"..table.concat(cuts)..")^[makealpha:1,1,1)"
  end
  for color, data in pairs(colors) do
    texture = texture .. "^(([combine:64x64"..table.concat(data)..")^[colorize:#"..color..")"
  end
  
  --print(string.len(texture))
  return texture
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
  --print(dump(from_dir))
  local pointed = nil
  --print(dump(points))
  for _, point in pairs(points) do
    x = math.floor((point.pos.x + 0.5) * 16)
    if point.axis==3 then
      x = x - 1
    end
    y = math.floor((point.pos.y + 0.5) * 16)
    if point.axis==1 then
      y = y - 1
    end
    z = math.floor((point.pos.z + 0.5) * 16)
    if point.axis==5 then
      z = z - 1
    end
    x = math.min(x, 15)
    y = math.min(y, 15)
    z = math.min(z, 15)
    if sculture_grid[z][y][x]~=0 then
      pointed = {
        pos = vector.new(x,y,z),
        axis = point.axis,
      }
      --print("point: "..dump(point.pos))
      --print("grid: "..dump(pointed))
      break
    end
  end
  
  return pointed
end

local inv_next_row_offset = 8
if minetest.get_modpath("hades_core") then
  inv_next_row_offset = 10
end

local function send_chat(puncher, msg)
  local player_name = puncher:get_player_name()
  if player_name~="" then
    minetest.chat_send_player(player_name, msg)
  end
end

function sculpture.tool_callback_point_core(puncher, itemstack, material, point)
  local def = itemstack:get_definition()
  if (not material) or (not def._sculpture_tool.category_name[material.category]) then
    send_chat(puncher, S("Looks like this tool is useless for this."))
    return point
  end
  if def._sculpture_tool.category_name[material.category] < material.strength then
    send_chat(puncher, S("Too weak tool for this material."))
    return point
  end
  -- check interval
  if def._sculpture_tool.interval then
    local meta = itemstack:get_meta()
    local last_time = meta:get_float("last_punch")
    local gametime = minetest.get_gametime()
    if (gametime-last_time)<def._sculpture_tool.interval then
      send_chat(puncher, S("Be patient. This work take some time."))
      return point
    end
    meta:set_float("last_punch", gametime)
  end
  if def._sculpture_tool.support_tool then
    -- look for support tool
    local inv = puncher:get_inventory()
    local support_item = inv:get_stack(puncher:get_wield_list(), puncher:get_wield_index()+inv_next_row_offset)
    local support_def = support_item:get_definition()
    
    if (not support_def._sculpture_support_tool) 
        or (support_def._sculpture_support_tool.category_name~=def._sculpture_tool.support_tool) then
      send_chat(puncher, S("You have to use some support tool. What about something like").." "..S(def._sculpture_tool.support_tool).."?")
      return point
    end
  end
  
  return point, def
end

function sculpture.tool_callback_point_wear(puncher, itemstack, material, point)
  local def = itemstack:get_definition()
  local wear = def._sculpture_tool.wear*(def._sculpture_tool.category_name[material.category]-material.strength+1)
  itemstack:add_wear(wear)
  
  if itemstack:get_count()==0 then
    if def._sculpture_tool.break_stack then
      itemstack:replace(ItemStack(def._sculpture_tool.break_stack))
    end
  end
  
  if def._sculpture_tool.support_tool then
    -- wear support tool
    local inv = puncher:get_inventory()
    local support_item = inv:get_stack(puncher:get_wield_list(), puncher:get_wield_index()+inv_next_row_offset)
    local support_def = support_item:get_definition()
    
    local wear = support_def._sculpture_support_tool.wear*(def._sculpture_tool.category_name[material.category]-material.strength+1)
    support_item:add_wear(wear)
    inv:set_stack(puncher:get_wield_list(), puncher:get_wield_index()+inv_next_row_offset, support_item)
    
    if support_item:get_count()==0 then
      if def._sculpture_support_tool.break_stack then
        support_item:replace(ItemStack(def._sculpture_support_tool.break_stack))
      end
    end
    inv:set_stack(puncher:get_wield_list(), puncher:get_wield_index()+inv_next_row_offset, support_item)
  end
end

function sculpture.tool_cut_point(puncher, itemstack, material, point, axis)
  local ret_point, def = sculpture.tool_callback_point_core(puncher, itemstack, material, point)
  if not def then
    return ret_point
  end
  
  sculpture.tool_callback_point_wear(puncher, itemstack, material, point)
  
  return 0
end

function sculpture.tool_paint_point(puncher, itemstack, material, point, axis)
  if point==0 then
    -- is cutted out, notning to do
    return point
  end
  
  local ret_point, def = sculpture.tool_callback_point_core(puncher, itemstack, material, point)
  if not def then
    return ret_point
  end
  
  -- do paint
  if type(point)~="table" then
    ret_point = {point, point, point, point, point, point}
  else
    ret_point = table.copy(point)
  end
  
  if def._sculpture_tool.brush_color then
    ret_point[axis] = def._sculpture_tool.brush_color
  else
    local meta = itemstack:get_meta()
    local color = meta:get("color")
    if color then
      ret_point[axis] = color
    end
  end
  
  sculpture.tool_callback_point_wear(puncher, itemstack, material, point)
  
  return ret_point
end

