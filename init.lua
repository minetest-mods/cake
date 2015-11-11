local throwable_cake = false

-- CAKE --

local sizes = {-0.4375, -0.3125, -0.1875, -0.0625, 0.0625, 0.1875, 0.3125}

for i, size in ipairs(sizes) do
	local slice = i - 1
	local name
	local description
	local drop
	local tiles
	
	if slice == 0 then
		name = "cake:cake"
		description = "Cake"
		drop = nil
		tiles = {"cake_top.png", "cake_bottom.png", "cake_side.png"}
	else
		name = "cake:cake_"..slice
		drop = ''
		tiles = {"cake_top.png", "cake_bottom.png", "cake_side.png", "cake_inner.png", "cake_side.png", "cake_side.png"}
	end
	
	minetest.register_node(name, {
		description = description,
		drop = drop,
		drawtype = "nodebox",
		tiles = tiles,
		paramtype = "light",
		is_ground_content = false,
		groups = {crumbly=3},
		--sounds = sounds,
		node_box = {
			type = "fixed",
			fixed = {
				{size, -0.5, -0.4375, 0.4375, 0, 0.4375},
			}
		},
		on_rightclick = function(pos, node, clicker)
			clicker:set_hp(clicker:get_hp() + 1)
			
			if i < #sizes then
				minetest.swap_node(pos, {name="cake:cake_"..i})
			else
				minetest.remove_node(pos)
			end
		end,
	})
end

if minetest.get_modpath("food") == nil then
	minetest.register_craftitem("cake:sugar", {
		description = "Sugar",
		inventory_image = "cake_sugar.png",
		groups = {food_sugar=1}
	})
	
	minetest.register_craft({
		type = "shapeless",
		output = "cake:sugar",
		recipe = {"default:papyrus"}
	})
else
	minetest.register_alias("cake:sugar", "food:sugar")
end

minetest.register_craft({
	type = "shapeless",
	output = "cake:cake",
	recipe = {"farming:flour", "group:water_bucket", "group:food_sugar", "group:food_sugar"}
})

-- THROWABLE CAKE --

minetest.register_entity("cake:cake_entity", {
	physical = false,
	timer = 0,
	textures = {"cake_entity.png"},
	lastpos = {},
	collisionbox = {0,0,0,0,0,0},
	on_step = function(self, dtime)
		self.timer=self.timer+dtime
		local pos = self.object:getpos()
		local node = minetest.env:get_node(pos)

		if self.timer>0.2 then
			local objs = minetest.env:get_objects_inside_radius({x=pos.x,y=pos.y,z=pos.z}, 2)
			for k, obj in pairs(objs) do
				if obj:get_luaentity() == nil or obj:get_luaentity().name ~= "cake:cake_entity" and obj:get_luaentity().name ~= "__builtin:item" then
					obj:set_hp(obj:get_hp() + 7)
					self.object:remove()
				end
			end
		end

		if self.lastpos.x~=nil then
			if node.name ~= "air" then
				minetest.env:add_item(self.lastpos, 'cake:cake')
				self.object:remove()
			end
		end
		self.lastpos={x=pos.x, y=pos.y, z=pos.z}
	end,
})

if throwable_cake then
	minetest.override_item("cake:cake", {
		on_use = function(itemstack, player, pointed_thing)
			if not minetest.setting_getbool("creative_mode") then
				itemstack:take_item()
			end
			local playerpos = player:getpos()
			local obj = minetest.env:add_entity({x=playerpos.x,y=playerpos.y+1.5,z=playerpos.z}, "cake:cake_entity")
			local dir = player:get_look_dir()
			obj:setvelocity({x=dir.x*19, y=dir.y*19, z=dir.z*19})
			obj:setacceleration({x=dir.x*-3, y=-10, z=dir.z*-3})
			obj:setyaw(player:get_look_yaw()+math.pi)
			return itemstack
		end,
	})
end

if minetest.get_modpath("i18n") then
	local separator = package.config:sub(1,1)
	dofile(minetest.get_modpath("i18n")..separator.."init.lua")
	i18n.localize_mod()
end
