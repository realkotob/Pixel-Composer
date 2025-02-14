function Node_Smoke_Vortex(_x, _y, _group = noone) : Node_Smoke(_x, _y, _group) constructor {
	name  = "Vortex";
	setDimension(96, 96);
	
	manual_ungroupable	 = false;
	
	newInput(0, nodeValue("Domain", self, CONNECT_TYPE.input, VALUE_TYPE.sdomain, noone))
		.setVisible(true, true);
	
	newInput(1, nodeValue_Vec2("Position", self, [0, 0]));
	
	newInput(2, nodeValue_Float("Radius", self, 8));
	
	newInput(3, nodeValue_Float("Strength", self, 0.10))
		.setDisplay(VALUE_DISPLAY.slider, { range: [-1, 1, 0.01] });
	
	newInput(4, nodeValue_Float("Attraction", self, 0))
		.setDisplay(VALUE_DISPLAY.slider, { range: [-1, 1, 0.01] });
	
	input_display_list = [ 
		["Domain",	false], 0, 
		["Vortex",	false], 1, 2, 3, 4
	];
	
	newOutput(0, nodeValue_Output("Domain", self, VALUE_TYPE.sdomain, noone));
	newOutput(1, nodeValue_Output("Domain", self, VALUE_TYPE.surface, noone));
	
	temp_surface = [ 0 ];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _pos = getInputData(1);
		var _rad = getInputData(2);
		var px = _x + _pos[0] * _s;
		var py = _y + _pos[1] * _s;
		
		draw_set_color(COLORS._main_accent);
		draw_circle_prec(px, py, _rad * _s, true);
		
		inputs[1].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
		inputs[2].drawOverlay(hover, active, px, py, _s, _mx, _my, _snx, _sny);
	}
	
	static update = function(frame = CURRENT_FRAME) {
		var _dom = getInputData(0);
		var _pos = getInputData(1);
		var _rad = getInputData(2);
		var _str = getInputData(3);
		var _aio = getInputData(4);
		
		SMOKE_DOMAIN_CHECK
		outputs[0].setValue(_dom);
		
		_rad = max(_rad, 1);
		temp_surface[0] = surface_verify(temp_surface[0], _dom.width, _dom.height, surface_rgba32float);
		
		surface_set_target(temp_surface[0])
			draw_clear_alpha(0., 0.);
			shader_set(sh_fd_vortex);
			BLEND_OVERRIDE
		
			shader_set_f("vortex",  _str);
			shader_set_f("angleIO", _aio);
			draw_sprite_stretched(s_fx_pixel, 0, _pos[0] - _rad, _pos[1] - _rad, _rad * 2, _rad * 2);
			BLEND_NORMAL
			shader_reset();
		surface_reset_target();
		
		_dom.addVelocity(temp_surface[0]);
		
		outputs[1].setValue(temp_surface[0]);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		
		draw_sprite_fit(s_node_smoke_vortex, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}