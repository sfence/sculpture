
local S = sculpture.translator

if true then
  minetest.register_tool("sculpture:hammer", {
      description = S("Hammer"),
      inventory_image = "sculpture_hammer.png",
      groups = {hammer=1},
      tool_capabilities = {
        full_punch_interval = 2,
        max_drop_level = 0,
        groupcaps = {},
        damage_groups = {cracky = 4},
        punch_attack_uses = 512,
      },
      _sculpture_support_tool = {
        category_name = "hammer",
        wear = 2
      },
    })
  minetest.register_tool("sculpture:chisel_stonemason", {
      description = S("Chisel"),
      inventory_image = "sculpture_chisel.png",
      groups = {chisel=1},
      tool_capabilities = {
        full_punch_interval = 2,
        max_drop_level = 0,
        groupcaps = {},
        damage_groups = {fleshy = 1},
        punch_attack_uses = 4096,
      },
      _sculpture_tool = {
        category_name = {metal=5},
        interval = 1,
        wear = 16,
        support_tool = "hammer",
        on_use = sculpture.tool_cut_point,
      },
    })
else
end
