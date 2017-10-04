--[[
Name: sponge mod
Vers: 1.0
Desc: adds minecraft style sponges to minetest
Auth: emjds
Date: 10/04/2017
Ghub: emjds
]]

--defines the search radius for the sponge
RANGE = 2

minetest.register_node("wetsponge:sponge",{
	description = "Sponge",
	tiles = {"wetsponge_sponge.png"},
	groups = {crumbly=1,flamable=1,dig_immediate=2,oddly_breakable_by_hand=1},
	
	--When rightclicked, turns a block of size RANGE into air blocks
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		local bolUsed = false
		for a=-RANGE,RANGE,1
		do
			for b=-RANGE,RANGE,1
			do
				for c=-RANGE,RANGE,1
				do
					local vec = {x=pos.x+a,y=pos.y+b,z=pos.z+c}
					if(minetest.get_node(vec).name=="default:water_source" or minetest.get_node(vec).name=="default:river_water_source" or minetest.get_node(vec).name=="default:water_flowing" or minetest.get_node(vec).name=="default:river_water_flowing")
					then
						minetest.set_node(vec, {name="wetsponge:false_air"})
						bolUsed = true
					end
				end
			end
		end
		--If at least one block of water was replaced, turns into "wet_sponge"
		if bolUsed
		then
			minetest.set_node(pos, {name="wetsponge:wet_sponge"})
		end
	end,
	
	--After placement, does a search in radius RANGE for water blocks and replaces them with "false_air" to prevent water from returning
	after_place_node = function(pos, placer, itemstack, pointed_thing)
		local bolUsed = false
		for a=-RANGE,RANGE,1
		do
			for b=-RANGE,RANGE,1
			do
				for c=-RANGE,RANGE,1
				do
					local vec = {x=pos.x+a,y=pos.y+b,z=pos.z+c}
					if(minetest.get_node(vec).name=="default:water_source" or minetest.get_node(vec).name=="default:river_water_source" or minetest.get_node(vec).name=="default:water_flowing" or minetest.get_node(vec).name=="default:river_water_flowing")
					then
						minetest.set_node(vec, {name="wetsponge:false_air"})
						bolUsed = true
					end
				end
			end
		end
		--If at least one block of water was replaced, turns into "wet_sponge" which can be dried in a furnace and used again
		if bolUsed
		then
			minetest.set_node(pos, {name="wetsponge:wet_sponge"})
		end
	end,
})

minetest.register_node("wetsponge:wet_sponge", {
	description = "Wet Sponge",
	tiles = {"wetsponge_wet_sponge.png"},
	groups = {crumbly=1,dig_immediate=2,oddly_breakable_by_hand=1},
	
	--When rightclicked, turns a block of size RANGE into water source blocks
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		local bolUsed = false
		if(itemstack:is_empty())
		then
			for a=-RANGE,RANGE,1
			do
				for b=-RANGE,RANGE,1
				do
					for c=-RANGE,RANGE,1
					do
						local vec = {x=pos.x+a,y=pos.y+b,z=pos.z+c}
						--minetest.log("testing "..vec.x..", "..vec.y..", "..vec.z)
						if(minetest.get_node(vec).name=="wetsponge:false_air" or minetest.get_node(vec).name=="air")
						then
							minetest.set_node(vec, {name="default:water_source"})
							bolUsed = true
						end
					end
				end
			end
			if (bolUsed)
			then
				minetest.set_node(pos, {name="wetsponge:sponge"})
			end
		end
	end,
	
	--After destruction, does a search for all the "false_air" that do not have a sponge withing a two block radius and replaces them with real "air"
	after_destruct = function(pos, oldnode)
		--First search loop searches for "false_air"
		for a=-RANGE,RANGE,1
		do
			for b=-RANGE,RANGE,1
			do
				for c=-RANGE,RANGE,1
				do
					local vec = {x=pos.x+a,y=pos.y+b,z=pos.z+c}
					if(minetest.get_node(vec).name=="wetsponge:false_air")
					then	
						--Second search loop searches for a sponge block within radius RANGE
						local bolHasSponge=false
						local bolHasDrySpg=false
						local dryVec = nil
						for d=-RANGE,RANGE,1
						do
							for e=-RANGE,RANGE,1
							do
								for f=-RANGE,RANGE,1
								do
									local newVec = {x=vec.x+d,y=vec.y+e,z=vec.z+f}
									if(minetest.get_node(newVec).name=="wetsponge:wet_sponge")
									then
										bolHasSponge=true
									elseif(minetest.get_node(newVec).name=="wetsponge:sponge")
									then
										bolHasDrySpg=true
										dryVec = newVec
									end
								end
							end
						end
						--If there is no dry or wet sponge in the search radius, replace with "air"
						if((not bolHasSponge) and (not bolHasDrySpg))
						then
							minetest.set_node(vec, {name="air"})
						--If there is a dry sponge but no wet sponge, replace the dry sponge with a wet sponge, but otherwise do nothing
						elseif(bolHasDrySpg and not bolHasSponge)
						then
							minetest.set_node(dryVec, {name="wetsponge:wet_sponge"})
						end
						--If neither of these conditions are true (ie there is a wet sponge or there is a wet sponge and a dry sponge) do nothing
					end
				end
			end
		end	
	end,
})

--"false_air" prevents the water from flowing back into the cleared area
minetest.register_node("wetsponge:false_air", {
	drawtype = "airlike",
	walkable = false,
	pointable = false,
	diggable = false,
	climable = false,
	buildable_to = true,
	sunlight_propogates = true,
	paramtype = "light",
	groups = {not_in_creative_inventory=1}
})

--Placing "wool" of any colour in a furnace will create sponge
minetest.register_craft({
	type = "cooking",
	output = "wetsponge:sponge",
	recipe = "wool:white",
})

minetest.register_craft({
	type = "cooking",
	output = "wetsponge:sponge",
	recipe = "wool:grey",
})

minetest.register_craft({
	type = "cooking",
	output = "wetsponge:sponge",
	recipe = "wool:dark_grey",
})

minetest.register_craft({
	type = "cooking",
	output = "wetsponge:sponge",
	recipe = "wool:black",
})

minetest.register_craft({
	type = "cooking",
	output = "wetsponge:sponge",
	recipe = "wool:blue",
})

minetest.register_craft({
	type = "cooking",
	output = "wetsponge:sponge",
	recipe = "wool:cyan",
})

minetest.register_craft({
	type = "cooking",
	output = "wetsponge:sponge",
	recipe = "wool:green",
})

minetest.register_craft({
	type = "cooking",
	output = "wetsponge:sponge",
	recipe = "wool:dark_green",
})

minetest.register_craft({
	type = "cooking",
	output = "wetsponge:sponge",
	recipe = "wool:yellow",
})

minetest.register_craft({
	type = "cooking",
	output = "wetsponge:sponge",
	recipe = "wool:orange",
})

minetest.register_craft({
	type = "cooking",
	output = "wetsponge:sponge",
	recipe = "wool:brown",
})

minetest.register_craft({
	type = "cooking",
	output = "wetsponge:sponge",
	recipe = "wool:red",
})

minetest.register_craft({
	type = "cooking",
	output = "wetsponge:sponge",
	recipe = "wool:pink",
})

minetest.register_craft({
	type = "cooking",
	output = "wetsponge:sponge",
	recipe = "wool:magenta",
})

minetest.register_craft({
	type = "cooking",
	output = "wetsponge:sponge",
	recipe = "wool:violet",
})

--Placing "wet_sponge" in a furnace will create sponge
minetest.register_craft({
	type = "cooking",
	output = "wetsponge:sponge",
	recipe = "wetsponge:wet_sponge",
})