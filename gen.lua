local people = {
  Ork = {name = "Ork", inventory = {}, mood = 0, paralysed = false, health = 100},
  Fae = {name = "Fae", inventory = {}, mood = 0, paralysed = false, health = 100},
  Elf = {name = "Elf", inventory = {}, mood = 0, paralysed = false, health = 100},
  Goblin = {name = "Goblin", inventory = {}, mood = 0, paralysed = false, health = 100},
}

local rooms = {
  {'club', people.Ork},
  {'knife', people.Fae},
  {'rope', people.Elf},
  {'sword', people.Goblin},
}

math.randomseed(os.time())

for i=1, 7 do
for idx, room in ipairs(rooms) do
  print(string.format("We enter the room number %s.", idx))
  io.stdout:write("In the room, we find: ")
  if #room == 0 then
    io.stdout:write("nothing.\n")
  else
    for x, y in ipairs(room) do
      if type(y) == "table" then
        io.stdout:write(string.format("the %s, ", y.name))
        if #y.inventory > 0 then
          for _, val in ipairs(y.inventory) do
            io.stdout:write(string.format("(holding a %s), ", val))
          end
        end
      else
        io.stdout:write(string.format("the %s, ", y))
      end
    end
    io.stdout:write("\b\b.\n")
  end

  -- Chance of doing something
  for index, object in ipairs(room) do
    if type(object) == "table" then
      -- If paralysed, do nothing, and become unparalysed.
      if object.paralysed then
        print(string.format("The %s is paralysed, and cannot move.", object.name))
      else
        -- Chance of going to another room
        if math.random(2) == 1 then
          local nextroom = math.random(#rooms)
          -- Make sure we aren't moving to the room we are actually in.
          if nextroom == idx then
            -- By decrementing and looping, we can guarantee linear reassignment
            -- Instead of a possibly infinite while loop.
            nextroom = nextroom - 1
            if nextroom < 1 then
              nextroom = #rooms
            end
          end
          print(string.format("The %s walks to room %d", object.name, nextroom))
          rooms[nextroom][#rooms[nextroom] + 1] = object
          rooms[idx][index] = nil
        elseif math.random(2) == 1 then
          -- Chance of picking up an object (mood +1)
          for _, obj in ipairs(room) do
            if type(obj) ~= "table" then
              -- Add an object to a Character's inventory, and remove it from the room.
              print(string.format("The %s picks up the %s", object.name, obj))
              object.inventory[#object.inventory + 1] = obj
              table.remove(room, _)
              object.mood = object.mood + 1
              break
            end
          end
          -- TODO: If inventory and someone in the room, chance of attack (mood -2)
        elseif math.random(2) == 1 then
        	if #object.inventory > 0 then
        		-- TODO: check if someone else is in here.
        		for k, v in ipairs(room) do
        		  if type(v) == "table" and v ~= object then
        		  	print(string.format("%s attacks %s with their %s.", object.name, v.name, object.inventory[1]))
        		  end
        		end
        	end
          -- TODO: If inventory and someone in the room, chance of gift (mood +2)
          -- TODO: Also chance of paralyse magic (mood -1)
          local todo = true
        end
      end
    end
  end
end
end
