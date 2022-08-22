
local S = sculpture.translator

local current_version = "16x16x16"

sculpture.current_version = current_version

local function update_textures(data, objs)
  --print("all: "..dump(objs))
  for _,obj in pairs(objs) do
    if not obj.object then
      obj = obj:get_luaentity()
    end
    if obj.axis then
      --print(obj.axis)
      obj.object:set_properties({textures = {sculpture.to_texturestring(data, obj.axis)}})
      --print("axis: "..obj.axis.." tex: "..sculpture.to_texturestring(data, obj.axis))
    end
  end
  --print(dump(textures))
end

local function sculpture_on_activate(self, pos)
  local node_meta = minetest.get_meta(pos)
  local data = {
    version = node_meta:get_string("version"),
    material = node_meta:get_string("material"),
    grid = node_meta:get_string("grid_3d"),
  }
  if (data.grid=="") then
    -- something bad happen, sculpture entity without node
    self.object:remove()
    return
  end
  data.grid = minetest.deserialize(sculpture.decompress(data.grid))
  if data.version ~= current_version then
    minetest.log("legacy", "[sculpture] updating placed picture data")
    data.version = current_version
    node_meta:set_string("version", data.version)
    node_meta:set_string("material", data.material)
    node_meta:set_string("grid_3d", sculpture.compress(minetest.serialize(data.grid)))
  end
  self.object:set_armor_groups({immortal=1})
  self.grid = data.grid
  self.material = data.material
  
  local objs = {self}
  for n=2,6 do
    objs[n] = minetest.add_entity(self.object:get_pos(), "sculpture:sculpture_axis")
    objs[n] = objs[n]:get_luaentity()
  end
  for n=1,6 do
    objs[n].axis = n
    objs[n].object:set_properties({mesh = "sculpture_sculpture_mesh_axis_"..n..".obj"})
  end
  update_textures(data, objs)
  
  return objs
end

-- sculpture by axis show
minetest.register_entity("sculpture:sculpture_axis", {
    initial_properties = {
      collisionbox = { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 },
      selectionbox = { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 },
      visual = "mesh",
      mesh = "sculpture_sculpture_mesh_axis_1.obj",
      visual_size = {x=10,y=10,z=10},
      pointable = false,
      static_save = false,
      textures = {"sculpture_tin.png"},
    },
    axis = 1,
    on_activate = function(self, staticdata)
      -- rotate entity by node
    end
  })

-- finished sculpture
minetest.register_entity("sculpture:sculpture_expo", {
    initial_properties = {
      collisionbox = { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 },
      selectionbox = { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 },
      visual = "mesh",
      mesh = "sculpture_sculpture_mesh_axis_1.obj",
      visual_size = {x=10,y=10,z=10},
      pointable = false,
      textures = {"sculpture_tin.png"},
    },
    on_activate = function(self, staticdata)
      local pos = self.object:get_pos()
      local objs = sculpture_on_activate(self, pos)
      
      local node = minetest.get_node(pos)
      local dir = minetest.facedir_to_dir(node.param2)
      local rot = vector.dir_to_rotation(dir)
      for _,obj in pairs(objs) do
        obj.object:set_rotation(rot)
      end
    end
  })

minetest.register_entity("sculpture:sculpture_unfinished", {
    initial_properties = {
      collisionbox = { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 },
      selectionbox = { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 },
      visual = "mesh",
      mesh = "sculpture_sculpture_mesh_axis_1.obj",
      visual_size = {x=10,y=10,z=10},
      textures = {"sculpture_tin.png"},
    },

    on_activate = function(self, staticdata)
      local pos = self.object:get_pos()
      pos.y = pos.y - 1
      sculpture_on_activate(self, pos)
    end,
    on_punch = function(self, puncher)
      --print("on_punch")
      local wield_item = puncher:get_wielded_item()
      local name = wield_item:get_name()
      local def = minetest.registered_items[name]
      if (not def) or (not def._sculpture_tool) then
        return
      end
      local from_pos = puncher:get_pos()
      from_pos.y = from_pos.y + puncher:get_properties().eye_height
      local pointed = sculpture.find_pointed_part(self.grid, from_pos, puncher:get_look_dir(), self.object:get_pos(), puncher)
      
      if pointed then
        --print(dump(pointed))
        local pos = self.object:get_pos()
        pos.y = pos.y - 1
        local node_meta = minetest.get_meta(pos)
        local data = {
          version = node_meta:get_string("version"),
          material = node_meta:get_string("material"),
          grid = node_meta:get_string("grid_3d")
        }
        data.grid = minetest.deserialize(sculpture.decompress(data.grid))
        data.grid[pointed.pos.z][pointed.pos.y][pointed.pos.x] = def._sculpture_tool.on_use(puncher, wield_item, sculpture.materials[data.material], data.grid[pointed.pos.z][pointed.pos.y][pointed.pos.x], pointed.axis)
        --print(dump(data.grid[pointed.pos.z][pointed.pos.y][pointed.pos.x]))
        local grid_string = sculpture.compress(minetest.serialize(data.grid)) 
        node_meta:set_string("grid_3d", grid_string)
        self.grid = data.grid
        update_textures(data, minetest.get_objects_inside_radius(self.object:get_pos(), 0.1))
        puncher:set_wielded_item(wield_item)
      end
    end,
  })

minetest.register_node("sculpture:sculpture",{
    description = S("Sculpture"),
    tiles = {"sculpture_node.png"},
    inventory_image = "sculpture_node_inv.png",
    drawtype = "glasslike",
    paramtype = "light",
    paramtype2 = "facedir",
    use_texture_alpha = "clip",
    stack_max = 1,
    groups = {oddly_breakable_by_hand = 1, not_in_creative_inventory = 1},
    after_place_node = function(pos, placer, itemstack, pointed_thing)
      local node_meta = minetest.get_meta(pos)
      local item_meta = itemstack:get_meta()
      
      node_meta:set_string("version", item_meta:get_string("version"))
      node_meta:set_string("material", item_meta:get_string("material"))
      node_meta:set_string("grid_3d", item_meta:get_string("grid_3d"))
      
      local obj = minetest.add_entity(pos, "sculpture:sculpture_expo")  
    end,
    on_rotate = function(pos, node, user, mode, new_param2)
      local dir = minetest.facedir_to_dir(new_param2)
      local rot = vector.dir_to_rotation(dir)
      --print("rot for "..new_param2.." :"..dump(rot))
      
      local objs = minetest.get_objects_inside_radius(pos, 0.1)
      for _,obj in pairs(objs) do
        local luaent = obj:get_luaentity()
        if luaent and 
            ((luaent.name=="sculpture:sculpture_expo")
            or (luaent.name=="sculpture:sculpture_axis")) then
          obj:set_rotation(rot)
        end
      end
      return new_param2
    end,
    preserve_metadata = function(pos, oldnode, oldmeta, drops)
      --print(dump(drops))
      local item_meta = drops[1]:get_meta()
      local node_meta = minetest.get_meta(pos)
          
      item_meta:set_string("version", node_meta:get_string("version"))
      item_meta:set_string("material", node_meta:get_string("material"))
      item_meta:set_string("grid_3d", node_meta:get_string("grid_3d"))
    end,
    after_destruct = function(pos, oldnode)
      local objs = minetest.get_objects_inside_radius(pos, 0.1)
      for _,obj in pairs(objs) do
        local luaent = obj:get_luaentity()
        if luaent and 
            ((luaent.name=="sculpture:sculpture_expo") 
          or (luaent.name=="sculpture:sculpture_axis")) then
          obj:remove()
        end
      end
    end,
  })

-- pedestal for making sculptures
minetest.register_node("sculpture:pedestal",{
    description = S("Sculpture Pedestal"),
    drawtype = "nodebox",
    node_box = {
      type = "fixed",
      fixed = {
        {0.25,-0.5,-0.5,0.5,-0.4375,-0.25},
        {-0.5,-0.5,-0.4375,-0.25,-0.4375,-0.1875},
        {0.3125,-0.4375,-0.4375,0.4375,0.5,-0.3125},
        {-0.4375,-0.4375,-0.375,-0.3125,0.5,-0.25},
        {-0.125,-0.5,-0.125,0.125,-0.4375,0.125},
        {-0.0625,-0.4375,-0.0625,0.0625,0.5,0.0625},
        {-0.5,-0.5,0.25,-0.25,-0.4375,0.5},
        {0.25,-0.5,0.25,0.5,-0.4375,0.5},
        {-0.4375,-0.4375,0.3125,-0.3125,0.5,0.4375},
        {0.3125,-0.4375,0.3125,0.4375,0.5,0.4375},
      },
    },
    --tiles = {"sculpture_pedestal.png"},
    tiles = {"default_wood.png"},
    paramtype = "light",
    
    groups = {choppy=2},
    
    on_destruct = function(pos, node)
        
      end,
    on_punch = function(pos, node, puncher, pointed_thing)
        --print("pedestal punched")
        -- convert punch item to sculpture base if possible
        if not puncher then
          minetest.node_punch(pos, node, puncher, pointed_thing)
          return
        end
        local node_meta = minetest.get_meta(pos)
        local has_sculpture = node_meta:get_int("has_sculpture")
        
        if has_sculpture~=0 then
          -- get sculpture
          pos.y = pos.y + 1
          local objs = minetest.get_objects_inside_radius(pos, 0.1)
          for _,obj in pairs(objs) do
            local luaent = obj:get_luaentity()
            if luaent and 
                ((luaent.name=="sculpture:sculpture_unfinished")
              or (luaent.name=="sculpture:sculpture_axis")) then
              obj:remove()
            end
          end
          
          local itemstack = ItemStack("sculpture:sculpture")
          local item_meta = itemstack:get_meta()
          
          item_meta:set_string("version", node_meta:get_string("version"))
          item_meta:set_string("material", node_meta:get_string("material"))
          item_meta:set_string("grid_3d", node_meta:get_string("grid_3d"))
          
          local stack = puncher:get_inventory()
          if stack:room_for_item(puncher:get_wield_list(), itemstack) then
            stack:add_item(puncher:get_wield_list(), itemstack)
          else
            minetest.add_item(pos, itemstack)
          end
          
          node_meta:set_int("has_sculpture", 0)
        else
          -- add sculpture to pedestal
          local wield_item = puncher:get_wielded_item()
          local wield_name = wield_item:get_name()
          local material_name,material = sculpture.find_material(wield_name)
          if material_name==nil then
            minetest.node_punch(pos, node, puncher, pointed_thing)
            return
          end
          node_meta:set_int("has_sculpture", 1)
          if not material.on_init then
            node_meta:set_string("version", current_version)
            node_meta:set_string("material", material_name)
            node_meta:set_string("grid_3d", sculpture.compress(minetest.serialize(sculpture.init_grid())))
          else
            material.on_init(material, node_meta, wield_item)
          end
          pos.y = pos.y + 1
          local obj = minetest.add_entity(pos, "sculpture:sculpture_unfinished")
          wield_item:take_item()
          puncher:set_wielded_item(wield_item)
        end
      end,
  })

