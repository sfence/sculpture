
local S = sculpture.translator

local items = {
  steel_ingot = "default:steel_ingot",
  stick = "default:stick",
}

if minetest.get_modpath("hades_core") then
  items.steel_ingot = "hades_core:steel_ingot"
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
        {items.steel_ingot},
        {items.steel_ingot},
      },
    })
end

