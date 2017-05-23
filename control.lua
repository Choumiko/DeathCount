function string.trim(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end

local function set_filename(s)
  if type(s) == 'table' then
    s = s.parameter
  end
  global.filename = string.trim(tostring(s))
  game.print(string.format("Deaths for this save will be written to: 'script-output/stream_data/%s", global.filename))
end

local function set_death_count(i)
  global.deathCount = tonumber(i)
  game.print(string.format("Death count set to %d", global.deathCount))
end

local function create_gui(player)
  local frame = player.gui.center.add{type="frame", name="frame"}
  frame.add{type="label", caption="DeathCount filename:"}
  frame.add{type="textfield", name="filename"}.text = "dc.txt"
  frame.add{type="button", name="death_count_ok", caption="Save"}
end

local function on_init()
  global.deathCount = global.deathCount or 0
  global.filename = global.filename or false
end

script.on_init(on_init)
script.on_configuration_changed(function(data)
  on_init()
  if data and data.mod_changes and data.mod_changes["DeathCount"] then
    if not global.filename then
      for _, player in pairs(game.players) do
        create_gui(player) --just create it for all, first one to set a name wins
      end
    end
  end
end)

script.on_event(defines.events.on_player_created, function(e)
  if not global.filename then
    create_gui(game.players[e.player_index])
  end
end)

script.on_event(defines.events.on_gui_click, function(e)
  if e.element.name == "death_count_ok" then
    local filename = string.trim(e.element.parent["filename"].text)
    if filename ~= "" then
      set_filename(filename)
      e.element.parent.destroy()
      script.on_event(defines.events.on_gui_click, nil)
      game.write_file('stream_data/' .. global.filename, global.deathCount)
    else
      game.players[e.player_index].print("Empty filename, try again")
    end
  end
end)
script.on_event(defines.events.on_player_died, function()
  global.deathCount = global.deathCount + 1
  game.write_file('stream_data/' .. global.filename, global.deathCount..'')
end)

commands.add_command("deathCount_set_filename", "usage: /deathCount_set_file name-of-file-txt", set_filename)
commands.add_command("deathCount_set_counter", "usage: /deathCount_set_counter 0", set_death_count)
