function Node_Skew(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Skew";
	
	newInput(0, nodeValue_Surface("Surface In", self));
	newInput(1, nodeValue_Enum_Button("Axis", self,  0, ["x", "y"]));
	
	newInput(2, nodeValue_Float("Strength", self, 0))
		.setDisplay(VALUE_DISPLAY.slider, { range: [-1, 1, 0.01] })
		.setMappable(12);
		
	newInput(3, nodeValue_Bool("Wrap", self, false));
	
	newInput(4, nodeValue_Vec2("Center", self, [0, 0] , { side_button : button(function() { centerAnchor(); }).setIcon(THEME.anchor).setTooltip(__txt("Set to center")) }));
	
	newInput(5, nodeValue_Enum_Scroll("Oversample mode", self,  0, [ "Empty", "Clamp", "Repeat" ]))
		.setTooltip("How to deal with pixel outside the surface.\n    - Empty: Use empty pixel\n    - Clamp: Repeat edge pixel\n    - Repeat: Repeat texture.");
	
	newInput(6, nodeValue_Surface("Mask", self));
	
	newInput(7, nodeValue_Float("Mix", self, 1))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(8, nodeValue_Bool("Active", self, true));
		active_index = 8;
	
	newInput(9, nodeValue_Toggle("Channel", self, 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	__init_mask_modifier(6); // inputs 10, 11
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	newInput(12, nodeValueMap("Strength map", self));
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	input_display_list = [ 8, 9, 
		["Surfaces", true],	0, 6, 7, 10, 11, 
		["Skew",	false],	1, 2, 12, 4,
	]
	
	newOutput(0, nodeValue_Output("Surface Out", self, VALUE_TYPE.surface, noone));
	
	attribute_surface_depth();
	attribute_oversample();
	attribute_interpolation();
	
	static centerAnchor = function() {
		if(!is_surface(current_data[0])) return;
		var ww = surface_get_width_safe(current_data[0]);
		var hh = surface_get_height_safe(current_data[0]);
		
		inputs[4].setValue([ww / 2, hh / 2]);
	}
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		PROCESSOR_OVERLAY_CHECK
		
		var _hov = false;
		var  hv  = inputs[4].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny); _hov |= hv;
		
		return _hov;
	}
	
	static step = function() {
		__step_mask_modifier();
		
		inputs[2].mappableStep();
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _samp = getAttribute("oversample");
		
		surface_set_shader(_outSurf, sh_skew);
		shader_set_interpolation(_data[0]);
			shader_set_dim("dimension",	_data[0]);
			shader_set_2("center",		_data[4]);
			shader_set_i("axis",		_data[1]);
			shader_set_f_map("amount",  _data[2], _data[12], inputs[2]);
			shader_set_i("sampleMode",	_samp);
			draw_surface_safe(_data[0]);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _data[6], _data[7]);
		_outSurf = channel_apply(_data[0], _outSurf, _data[9]);
		
		return _outSurf;
	}
}