
minetest.register_privilege("sculpture_export", {
    description = "Right for export sculpture into files in world directory.",
    give_to_singleplayer = false,
    give_to_admin = false,
  })

minetest.register_privilege("sculpture_import", {
    description = "Right for import sculpture from files in world directory.",
    give_to_singleplayer = false,
    give_to_admin = false,
  })

minetest.register_chatcommand("sculpture_export", {
    params = "<filename> [position]",
    description = "Export sculpture data to lua file in world directory. If not position is set, wielded item is used.",
    privs = {sculpture_export=true},
    func = function(name, param)
        local params = string.split(param or "", " ")
        if (param==nil) or (param=="") then
          return false, "Use /sculpture_export file_name [position]"
        end
        
        local data = nil
        if #params>1 then
          -- node
          local pos = minetest.string_to_pos(params[2])
          if (not pos) then
            return false, "Bad position format."
          end
          local node_meta = minetest.get_meta(pos)
          data = {
              version = node_meta:get_string("version"),
              material = node_meta:get_string("material"),
              grid = node_meta:get_string("grid_3d"),
            }
        else
          -- wielded item
          local player = minetest.get_player_by_name(name)
          local stack = player:get_wielded_item()
          local meta = stack:get_meta()
          data = {
              version = meta:get_string("version"),
              material = meta:get_string("material"),
              grid = meta:get_string("grid_3d"),
            }
        end
        if (data.grid=="") then
          return false, "Wielded item or node is not valid sculpture."
        else
          data.grid = minetest.deserialize(sculpture.decompress(data.grid))
        end
        if (not data) or (not data.grid) or (data.grid=="") then
          return false, "Wielded item or node is not valid sculpture."
        end
        if data.version ~= sculpture.current_version then
          return false, "Wielded item or node is old version sculpture."
        end
        if sculpture.file_exists(params[1]) then
          return false, "File \""..pstsmd[1].."\" already exists."
        end
        if sculpture.string_to_file(params[1], minetest.serialize(data)) then
          return true, "Sculpture has been exported to file \""..params[1].."\"."
        end
        return false, "Exporting sculpture to file failed."
      end,
  })

minetest.register_chatcommand("sculpture_import", {
    params = "<filename> [position]",
    description = "Import sculpture data from lua file in world directory. If not position is set, wielded item is used.",
    privs = {sculpture_import=true},
    func = function(name, param)
        local params = string.split(param or "", " ")
        if (param==nil) or (param=="") then
          return false, "Use /sculpture_export file_name [position]"
        end
        
        local data = sculpture.file_to_string(params[1])
        if (not data) then
          return false, "File reading failed."
        end
        data = minetest.deserialize(data)
        
        if (not data.version) or (not data.material) or (not data.grid) then
          return false, "Bad imported data format."
        end
        
        if #params>1 then
          -- node
          local pos = minetest.string_to_pos(params[2])
          if (not pos) then
            return false, "Bad position format."
          end
          local node_meta = minetest.get_meta(pos)
          node_meta:set_string("version", data.version)
          node_meta:set_string("material", data.material)
          node_meta:set_string("grid", sculpture.compress(minetest.serialize(data.grid)))
        else
          -- wielded item
          local player = minetest.get_player_by_name(name)
          local stack = player:get_wielded_item()
          local meta = stack:get_meta()
          meta:set_string("version", data.version)
          meta:set_string("material", data.material)
          meta:set_string("grid", sculpture.compress(minetest.serialize(data.grid)))
          player:set_wielded_item(stack)
        end
        return true, "Sculpture has been imported."
    end,
  })

