
sculpture = {
  translator = minetest.get_translator("sculpture")
}

local modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(modpath.."/functions.lua")
dofile(modpath.."/materials.lua")
dofile(modpath.."/tools.lua")
dofile(modpath.."/sculpture.lua")