
local S = sculpture.translator

sculpture.materials = {}

function sculpture.register_material(material_name, material_def)
  sculpture.materials[material_name] = material_def
end

function sculpture.find_material(item_name)
  for material_name,material in pairs(sculpture.materials) do
    if (material.item_name==item_name)  then
      return material_name,material
    end
  end
  return nil,nil
end
  
function sculpture.nub_on_use(itemstack)
  if (itemstack:get_count()==itemstack:get_stack_max()) then
    local def = itemstack:get_definition()
    return ItemStack(def._sculpture_nubs_material)
  end
end

function sculpture.register_nub(material_name, nub_def)
  local material = sculpture.materials[material_name]
  
  minetest.register_craftitem("sculpture:nub_"..material_name, {
      description = S("@1 Nub", material.desc),
      inventory_image = "sculpture_nub_"..material_name..".png",
      stack_max = nub_def.stack_max,
      _sculpture_nubs_material = nub_def.nubs_material,
      
      on_use = sculpture.nub_on_use,
    })
  
  minetest.override_item(nub_def.nubs_material, {
      _sculpture_material = {
          name = material_name,
          change = "sculpture:nub_"..material_name.." "..nub_def.stack_max,
        },
    })
end

sculpture.register_material("sculpture", {
    item_name = "sculpture:sculpture",
    on_init = function(material_def, node_meta, item)
      local item_meta = item:get_meta()
      node_meta:set_string("version", item_meta:get_string("version"))
      node_meta:set_string("material", item_meta:get_string("material"))
      node_meta:set_string("grid_3d", item_meta:get_string("grid_3d"))
    end,
  })

if minetest.get_modpath("default") then
  sculpture.register_material("tin", {
      desc = S("Tin"),
      item_name = "default:tinblock",
      textures = { -- 64x64, y-,y+, x-,x+, z-,z+
          "sculpture_tin.png","sculpture_tin.png",
          "sculpture_tin.png","sculpture_tin.png",
          "sculpture_tin.png","sculpture_tin.png",
        },
      category = "metal",
      strength = 1,
    })
  sculpture.register_material("gold", {
      desc = S("Gold"),
      item_name = "default:goldblock",
      textures = { -- 64x64, y-,y+, x-,x+, z-,z+
          "sculpture_gold.png","sculpture_gold.png",
          "sculpture_gold.png","sculpture_gold.png",
          "sculpture_gold.png","sculpture_gold.png",
        },
      category = "metal",
      strength = 2,
    })
  sculpture.register_material("clay", {
      desc = S("Clay"),
      item_name = "default:clay",
      textures = { -- 64x64, y-,y+, x-,x+, z-,z+
          "sculpture_clay.png","sculpture_clay.png",
          "sculpture_clay.png","sculpture_clay.png",
          "sculpture_clay.png","sculpture_clay.png",
        },
      category = "clay",
      strength = 1,
      nub_material = "sculpture:nub_clay",
    })
  sculpture.register_nub("clay", {
      stack_max = 1024,
      nubs_material = "default:clay_lump",
    })
  sculpture.register_material("clay_lump", {
      desc = S("Clay"),
      item_name = "default:clay_lump",
      textures = { -- 64x64, y-,y+, x-,x+, z-,z+
          "sculpture_clay.png","sculpture_clay.png",
          "sculpture_clay.png","sculpture_clay.png",
          "sculpture_clay.png","sculpture_clay.png",
        },
      category = "clay",
      strength = 1,
      nub_material = "sculpture:nub_clay",
      on_init = function(material_def, node_meta, item)
        local item_meta = item:get_meta()
        node_meta:set_string("version", sculpture.current_version)
        node_meta:set_string("material", "clay")
        local grid = {}
        for z = 0, 15 do
          grid[z] = {}
          for y = 0, 15 do
            grid[z][y] = {}
            if y<4 then
              for x = 0, 15 do
                grid[z][y][x] = 1
              end
            else
              for x = 0, 15 do
                grid[z][y][x] = 0
              end
            end
          end
        end
        node_meta:set_string("grid_3d", sculpture.compress(minetest.serialize(grid)))
      end,
    })
elseif minetest.get_modpath("hades_core") then
  sculpture.register_material("tin", {
      desc = S("Tin"),
      item_name = "hades_core:tinblock",
      textures = { -- 64x64, y-,y+, x-,x+, z-,z+
          "sculpture_tin_hades.png","sculpture_tin_hades.png",
          "sculpture_tin_hades.png","sculpture_tin_hades.png",
          "sculpture_tin_hades.png","sculpture_tin_hades.png",
        },
      category = "metal",
      strength = 1,
    })
  sculpture.register_material("gold", {
      desc = S("Gold"),
      item_name = "hades_core:goldblock",
      textures = { -- 64x64, y-,y+, x-,x+, z-,z+
          "sculpture_gold.png","sculpture_gold.png",
          "sculpture_gold.png","sculpture_gold.png",
          "sculpture_gold.png","sculpture_gold.png",
        },
      category = "metal",
      strength = 2,
    })
  sculpture.register_material("clay", {
      desc = S("Clay"),
      item_name = "hades_core:clay",
      textures = { -- 64x64, y-,y+, x-,x+, z-,z+
          "sculpture_clay.png","sculpture_clay.png",
          "sculpture_clay.png","sculpture_clay.png",
          ",culpture_clay.png","sculpture_clay.png",
        },
      category = "clay",
      strength = 1,
      nub_material = "sculpture:nub_clay",
    })
  sculpture.register_nub("clay", {
      stack_max = 1024,
      nubs_material = "hades_core:clay_lump",
    })
end

--[[
sculpture.register_nub("tin", {
    stack_max = 512,
  })

sculpture.register_nub("gold", {
    stack_max = 512,
  })
--]]


