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
  -- TODO: Chapter titles
  print("\n\n# Tick\n\n")

  for room_index, room in ipairs(world) do

    print(string.format("\n\n## We enter room %d.\n\n", room_index))

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
           io.stdout:write("\n\n")
        end
      end
    else
      print("There is no one in the room.")
    end

    -- Is there a weapon on the ground?
    local weap = has_object(room)
    if weap ~= false then
      for weapon_index, weapon in ipairs(weap) do
        print(string.format("The %s is in the room.\n\n", weapon))
      end
    else
      print("There are no weapons on the ground.")
    end

    -- Maybe pick up a weapon
    if weap ~= false and chars ~= false and math.random(2) == 1 then
      local character = chars[1]
      -- Only if alive.
      if character.health > 0 then
        local weapon = weap[1]
        print(string.format("The %s picks up the %s.\n\n", character.name, weapon))
        remove_weapon(room, weapon)
        character.inventory[#character.inventory + 1] = weapon
      end
    end

    -- Maybe attack.
    if chars ~= false and #chars > 1 and math.random(2) == 1 then
      local a = chars[1]
      local b = chars[2]
      -- TODO: Chance of retaliation if both have weapons.
      if #a.inventory > 0 and a.health > 0 then
        print(string.format("The %s attacks the %s with the %s!", a.name, b.name, a.inventory[1]))
        -- Drop weapon into room.
        print(string.format("%s dropped the %s.\n\n", a.name, a.inventory[1]))
        room[#room + 1] = a.inventory[1]
        table.remove(a.inventory, 1)
        -- Hurt the person
        b.health = b.health - math.random(10)
        -- Chance to retaliate!
        if #b.inventory > 0 and math.random(10) == 1 then
          print(string.format("The %s retaliates against the %s with the %s!", b.name, a.name, b.inventory[1]))
          -- Drop weapon into room.
          print(string.format("%s dropped the %s.\n\n", b.name, b.inventory[1]))
          room[#room + 1] = b.inventory[1]
          table.remove(b.inventory, 1)
          -- Hurt the person
          a.health = a.health - math.random(20)
        end
      elseif #b.inventory > 0 and b.health > 0 then
        print(string.format("The %s attacks the %s with the %s!", b.name, a.name, b.inventory[1]))
        -- Drop weapon into room.
        print(string.format("%s dropped the %s.\n\n", b.name, b.inventory[1]))
        room[#room + 1] = b.inventory[1]
        table.remove(b.inventory, 1)
        -- Hurt the person
        a.health = a.health - math.random(10)
        -- Chance to retaliate!
        if #a.inventory > 0 and math.random(10) == 1 then
          print(string.format("The %s retaliates against the %s with the %s!", a.name, b.name, a.inventory[1]))
          -- Drop weapon into room.
          print(string.format("%s dropped the %s.\n\n", a.name, a.inventory[1]))
          room[#room + 1] = a.inventory[1]
          table.remove(a.inventory, 1)
          -- Hurt the person
          b.health = b.health - math.random(10)
        end
      end
    end

    -- Check if anyone is dead.
    if chars ~= false then
      for character_index, character in ipairs(chars) do
        if character.health < 1 then
          -- Announce if they're dead.
          print(string.format("%s's body is in the room.\n\n", character.name))
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

    -- Health check.
    if chars ~= false then
      for character_index, character in ipairs(chars) do
        if character.health > 0 and character.health < 10 then
          print(string.format("The %s is dying.", character.name))
        elseif character.health > 0 and character.health < 50 then
          print(string.format("The %s is badly hurt.", character.name))
        elseif character.health > 0 and character.health < 80 then
          print(string.format("The %s is hurt.", character.name))
        end
      end
      io.stdout:write("\n\n")
    end

    -- Chance of 'Overseer's Blessing'
    -- All people in a room healed, maybe resurrected
    if math.random(20) == 1 then
      print(string.format("The Overseer casts their blessing on room %d!\n\n", room_index))
      if chars ~= false then
        for character_index, character in ipairs(chars) do
          if character.health > 0 and character.health < 100 then
            print(string.format("The %s was healed by the Overseer.\n\n", character.name))
          elseif character.health < 1 then
            print(string.format("*The %s was resurrected by the Overseer!*\n\n", character.name))
          end
          character.health = 100
        end
      end
    end

    -- Maybe move room
    if chars ~= false and math.random(2) == 1 then
      for char_index, character in ipairs(chars) do
        -- Only move if *alive*
        if character.health > 0 then
          -- Move forwards *or* backwards
          if math.random(2) == 1 then
            print(string.format("The %s moves to the next room.\n", character.name))
            local nextroom = room_index + 1
            if nextroom > #world then nextroom = 1 end
            world[nextroom][#world[nextroom] + 1] = character
            remove_character(room, character)
          else
            print(string.format("The %s moves to the previous room.\n", character.name))
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
-- 500 ticks produces just over 50,000 words.
for i=1, 500 do
  tick()
end
