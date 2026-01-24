-- Oriented Bounding Box Raycast System --
--         Made by SoundsDotZip         --
-- modified a bit 

return {
	new = function(self, _position, _corners, _rotation)
		return {
			position = _position,
			corners  = _corners,
			rotation = _rotation
		}
	end,
	raycast = function(self, obb_table, ray_start, ray_end)
		local hits = {}
		for ID, _ in pairs(obb_table) do
			local j = obb_table[ID]
			local ray_start_ls = (ray_start - j.position):transform(j.rotation:inverted())
			local ray_end_ls = (ray_end - j.position):transform(j.rotation:inverted())
			local _, hitpos, side, _ = raycast:aabb(ray_start_ls, ray_end_ls, { j.corners })
			if hitpos then
				hits[ID] = {
					distance = (hitpos - ray_start):length(),
					orientedHitPos = hitpos:copy(),
					hitPos = hitpos:transform(j.rotation):add(j.position),
					side = side
				}
			end
		end
		return hits
	end
}
