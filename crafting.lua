
local S = sculpture.translator

local items = {
  steel_ingot = "default:steel_ingot",
  stick = "default:stick",
  iron_stick = "default:steel_ingot", 
  diamond = "default:diamond",
  
  steel_strip = "default:steel_ingot",
}

if minetest.get_modpath("basic_materials") then
  items.iron_stick = "basic_materials:steel_bar"
end

if minetest.get_modpath("darkage") then
  items.iron_stick = "darkage:iron_stick"
end

if minetest.get_modpath("hades_core") then
  items.steel_ingot = "hades_core:steel_ingot"
  items.stick = "hades_core:stick"
  items.iron_stick = "hades_core:steel_rod"
  items.diamond = "hades_core:diamond"
  
  items.steel_strip = "hades_core:steel_strip"
end

if minetest.get_modpath("basic_materials") then
  items.steel_strip = "basic_materials:steel_strip"
end
  
minetest.register_craft({
    output = "sculpture:pedestal",
    recipe = {
      {items.stick, "", items.stick},
      {"", items.stick, ""},
      {items.stick, "", items.stick},
    },
  })

if true then
  minetest.register_craft({
      output = "sculpture:hammer",
      recipe = {
        {items.steel_ingot, items.steel_ingot, items.steel_ingot},
        {items.steel_ingot, items.steel_ingot, items.steel_ingot},
        {"",items.stick,""},
      },
    })
  minetest.register_craft({
      output = "sculpture:chisel_stonemason",
      recipe = {
        {items.iron_stick},
        {items.iron_stick},
      },
    })
  minetest.register_craft({
      output = "sculpture:chisel_stonemason_diamond",
      recipe = {
        {items.iron_stick},
        {items.iron_stick},
        {items.diamond},
      },
    })
  minetest.register_craft({
      output = "sculpture:spatula",
      recipe = {
        {items.steel_strip, items.steel_strip, items.steel_strip},
        {"", items.steel_strip, ""},
        {"", items.stick, ""},
      },
    })
end

