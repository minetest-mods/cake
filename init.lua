local sizes = {-0.4375, -0.3125, -0.1875, -0.0625, 0.0625, 0.1875, 0.3125}

for i, size in ipairs(sizes) do
	local slice = i - 1
	local name
	local description
	local drop
	local tiles
	local not_in_creative_inventory
	
	if slice == 0 then
		name = "cake:cake"
		description = "Cake"
		drop = nil
		tiles = {"cake_top.png", "cake_bottom.png", "cake_side.png"}
		not_in_creative_inventory = 0
	else
		name = "cake:cake_"..slice
		description = "Cake (Slice "..slice..")"
		drop = ''
		tiles = {"cake_top.png", "cake_bottom.png", "cake_side.png", "cake_inner.png", "cake_side.png", "cake_side.png"}
		not_in_creative_inventory = 1
	end
	
	minetest.register_node(name, {
		description = description,
		drop = drop,
		drawtype = "nodebox",
		tiles = tiles,
		paramtype = "light",
		is_ground_content = false,
		groups = {crumbly=3,not_in_creative_inventory=not_in_creative_inventory},
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

minetest.register_craft({
	type = "shapeless",
	output = "cake:cake",
	recipe = {"farming:flour", "farming:flour", "group:water_bucket"}
})
