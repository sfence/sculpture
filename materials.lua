

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
      item_name = "default:goldblock",
      textures = { -- 64x64, y-,y+, x-,x+, z-,z+
          "sculpture_gold.png","sculpture_gold.png",
          "sculpture_gold.png","sculpture_gold.png",
          "sculpture_gold.png","sculpture_gold.png",
        },
      category = "metal",
      strength = 2,
    })
elseif minetest.get_modpath("hades_core") then
  sculpture.register_material("tin", {
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
      item_name = "hades_core:goldblock",
      textures = { -- 64x64, y-,y+, x-,x+, z-,z+
          "sculpture_gold.png","sculpture_gold.png",
          "sculpture_gold.png","sculpture_gold.png",
          "sculpture_gold.png","sculpture_gold.png",
        },
      category = "metal",
      strength = 2,
    })
end

