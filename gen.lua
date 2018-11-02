local world = {
  {
    'club',
    {name = 'Ork', inventory = {}, health = 100}
  },
  {
    'knife',
    {name = 'Fae', inventory = {}, health = 100},
  },
  {
    'rope',
    {name = 'Elf', inventory = {}, health = 100},
  },
  {
    'sword',
    {name = 'Goblin', inventory = {}, health = 100},
  },
}

local has_object = function(room)
  local things = {}
  for ix, v in ipairs(room) do
    if type(v) ~= "table" then
      things[#things + 1] = v
    end
  end
  if #things == 0 then
    return false
  else
    return things
  end
end

local has_character = function(room)
  local chars = {}
  for ix, v in ipairs(room) do
    if type(v) == "table" then
      chars[#chars + 1] = v
    end
  end
  if #chars == 0 then
    return false
  else
    return chars
  end
end

local remove_weapon = function(place, thing)
  local index = 0
  for ix, obj in ipairs(place) do
    if obj == thing then
      index = ix
    end
  end
  table.remove(place, index)
end

local remove_character = function(place, person)
  local index = 0
  for ix, obj in ipairs(place) do
    if obj == person then
      index = ix
    end
  end
  table.remove(place, index)
end

local tick = function()
  for room_index, room in ipairs(world) do

    print(string.format("We enter room %d.", room_index))

    -- Are there people in the room?
    local chars = has_character(room)
    if chars ~= false then
      for character_index, character in ipairs(chars) do
        -- Only announce if alive.
        if character.health > 0 then
          print(string.format("The %s is in the room.", character.name))
          if #character.inventory > 0 then
            for inv_index, inv in ipairs(character.inventory) do
              print(string.format("The %s is holding the %s.", character.name, inv))
            end
           end
        end
      end
    else
      print("There is no one in the room.")
    end

    -- Is there a weapon on the ground?
    local weap = has_object(room)
    if weap ~= false then
      for weapon_index, weapon in ipairs(weap) do
        print(string.format("The %s is in the room.", weapon))
      end
    else
      print("There are no weapons on the ground.")
    end

    -- Maybe pick up a weapon
    if weap ~= false and chars ~= false and math.random(2) == 1 then
      local character = chars[1]
      local weapon = weap[1]
      print(string.format("The %s picks up the %s.", character.name, weapon))
      remove_weapon(room, weapon)
      character.inventory[#character.inventory + 1] = weapon
    end

    -- Maybe attack.
    if chars ~= false and #chars > 1 and math.random(2) == 1 then
      local a = chars[1]
      local b = chars[2]
      -- TODO: Chance of retaliation if both have weapons.
      if #a.inventory > 0 then
        print(string.format("The %s attacks the %s with the %s!", a.name, b.name, a.inventory[1]))
        -- Drop weapon into room.
        print(string.format("%s dropped the %s.", a.name, a.inventory[1]))
        room[#room + 1] = a.inventory[1]
        table.remove(a.inventory, 1)
        -- Hurt the person
        b.health = b.health - 1
      elseif #b.inventory > 0 then
        print(string.format("The %s attacks the %s with the %s!", b.name, a.name, b.inventory[1]))
        -- Drop weapon into room.
        print(string.format("%s dropped the %s.", b.name, b.inventory[1]))
        room[#room + 1] = b.inventory[1]
        table.remove(b.inventory, 1)
        -- Hurt the person
        a.health = a.health - 1
      end
    end

    -- Check if anyone is dead.
    if chars ~= false then
      for character_index, character in ipairs(chars) do
        if character.health < 1 then
          -- Announce if they're dead.
          print(string.format("%s's body is in the room.", character.name))
          -- TODO: Chance of dropping body part as weapon, can't have duplicates.
          -- If they have inventory, drop it into the room.
          if #character.inventory > 0 then
            local x = false
            while x ~= nil do
              x = table.remove(character.inventory)
              if x ~= nil then
                room[#room + 1] = x
              end
            end
          end
        end
      end
    end

    -- TODO: Chance of 'Overseer's Blessing'
    -- All people in a room healed, maybe resurrected

    -- Maybe move room
    if chars ~= false and math.random(2) == 1 then
      for char_index, character in ipairs(chars) do
        -- Only move if *alive*
        if character.health > 0 then
          -- Move forwards *or* backwards
          if math.random(2) == 1 then
            print(string.format("The %s moves to the next room.", character.name))
            local nextroom = room_index + 1
            if nextroom > #world then nextroom = 1 end
            world[nextroom][#world[nextroom] + 1] = character
            remove_character(room, character)
          else
            print(string.format("The %s moves to the previous room.", character.name))
            local nextroom = room_index - 1
            if nextroom < 1 then nextroom = #world end
            world[nextroom][#world[nextroom] + 1] = character
            remove_character(room, character)
          end
        end
      end
    end

  end
end

math.randomseed(os.time())
-- TODO: work out exact number of ticks needed.
for i=1, 100 do
  tick()
end
