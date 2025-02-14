function Node_VFX_Wind(_x, _y, _group = noone) : Node_VFX_effector(_x, _y, _group) constructor {
	name = "Wind";
	node_draw_icon = s_node_vfx_wind;
	
	function onAffect(part, str) {
		var _rot = random_range(rotateX, rotateY);
		var _scX = random_range(scaleX0, scaleX1);
		var _scY = random_range(scaleY0, scaleY1);
		
		part.x = part.x + effectVx * strength * str;
		part.y = part.y + effectVy * strength * str;
					
		part.rot += _rot * str;
		
		var scx_s = _scX * str;
		var scy_s = _scY * str;
		
		if(scx_s < 0)	part.scx = lerp_linear(part.scx, 0, abs(scx_s));
		else			part.scx += sign(part.scx) * scx_s;
		
		if(scy_s < 0)	part.scy = lerp_linear(part.scy, 0, abs(scy_s));
		else			part.scy += sign(part.scy) * scy_s;
	}
}