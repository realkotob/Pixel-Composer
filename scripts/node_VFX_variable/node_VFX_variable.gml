function Node_VFX_Variable(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "VFX Variable";
	color = COLORS.node_blend_vfx;
	icon  = THEME.vfx;
	node_draw_icon = s_node_vfx_variable;
	setDimension(96, 48);
	
	manual_ungroupable	 = false;
	
	
	newInput(0, nodeValue_Particle("Particles", self, -1 ))
		.setVisible(true, true);
	
	input_display_list = [ 0 ];
	
	newOutput(0, nodeValue_Output("Positions", self, VALUE_TYPE.float, [] ))
		.setDisplay(VALUE_DISPLAY.none)
		.setVisible(false);
	
	newOutput(1, nodeValue_Output("Scales", self, VALUE_TYPE.float, [] ))
		.setDisplay(VALUE_DISPLAY.none)
		.setVisible(false);
	
	newOutput(2, nodeValue_Output("Rotations", self, VALUE_TYPE.float, 0 ))
		.setDisplay(VALUE_DISPLAY.none)
		.setVisible(false);
	
	newOutput(3, nodeValue_Output("Blending", self, VALUE_TYPE.color, 0 ))
		.setDisplay(VALUE_DISPLAY.none)
		.setVisible(false);
	
	newOutput(4, nodeValue_Output("Alpha", self, VALUE_TYPE.float, 0 ))
		.setDisplay(VALUE_DISPLAY.none)
		.setVisible(false);
	
	newOutput(5, nodeValue_Output("Life", self, VALUE_TYPE.float, 0 ))
		.setDisplay(VALUE_DISPLAY.none)
		.setVisible(false);
	
	newOutput(6, nodeValue_Output("Max life", self, VALUE_TYPE.float, 0 ))
		.setDisplay(VALUE_DISPLAY.none)
		.setVisible(false);
	
	newOutput(7, nodeValue_Output("Surface", self, VALUE_TYPE.surface, noone ))
		.setDisplay(VALUE_DISPLAY.none)
		.setVisible(false);
	
	newOutput(8, nodeValue_Output("Velocity", self, VALUE_TYPE.float, [] ))
		.setDisplay(VALUE_DISPLAY.none)
		.setVisible(false);
	
	newOutput(9, nodeValue_Output("Seed", self, VALUE_TYPE.float, 0 ))
		.setDisplay(VALUE_DISPLAY.none)
		.setVisible(false);
		
	static update = function(frame = CURRENT_FRAME) {
		var parts = getInputData(0);
		if(!is_array(parts)) return;
		
		var _val = [];
		
		for( var i = 0; i < array_length(outputs); i++ )
			_val[i] = array_create(array_length(parts));
		
		for( var i = 0, n = array_length(parts); i < n; i++ ) {
			var part = parts[i];
			
			if(outputs[0].visible) _val[0][i] = [part.x,   part.y];
			if(outputs[1].visible) _val[1][i] = [part.scx, part.scy];
			if(outputs[2].visible) _val[2][i] = part.rot;
			if(outputs[3].visible) _val[3][i] = part.blend;
			if(outputs[4].visible) _val[4][i] = part.alp;
			if(outputs[5].visible) _val[5][i] = part.life;
			if(outputs[6].visible) _val[6][i] = part.life_total;
			if(outputs[7].visible) _val[7][i] = part.surf;
			if(outputs[8].visible) _val[8][i] = [part.speedx, part.speedy];
			if(outputs[9].visible) _val[9][i] = part.seed;
		}
		
		for( var i = 0; i < array_length(outputs); i++ )
			if(outputs[i].visible) outputs[i].setValue(_val[i]);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(node_draw_icon, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
	
	static getPreviewingNode = function() { return is(inline_context, Node_VFX_Group_Inline)? inline_context.getPreviewingNode() : self; }
	static getPreviewValues  = function() { return is(inline_context, Node_VFX_Group_Inline)? inline_context.getPreviewValues()  : self; }
}