function Node_Convolution(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Convolution";
	
	inputs[| 0] = nodeValue_Surface("Surface in", self);
	
	inputs[| 1] = nodeValue_Float("Kernel", self, array_create(9))
		.setDisplay(VALUE_DISPLAY.matrix, { size: 3 });
	
	inputs[| 2] = nodeValue_Enum_Scroll("Oversample mode", self, 0, [ "Empty", "Clamp", "Repeat" ])
		.setTooltip("How to deal with pixel outside the surface.\n    - Empty: Use empty pixel\n    - Clamp: Repeat edge pixel\n    - Repeat: Repeat texture.");
	
	inputs[| 3] = nodeValue_Surface("Mask", self);
	
	inputs[| 4] = nodeValue_Float("Mix", self, 1)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 5] = nodeValue_Bool("Active", self, true);
		active_index = 5;
	
	inputs[| 6] = nodeValue_Toggle("Channel", self, 0b1111, { data: array_create(4, THEME.inspector_channel) });
	
	__init_mask_modifier(3); // inputs 7, 8, 
	
	outputs[| 0] = nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone);
	
	input_display_list = [ 5, 6,
		["Surfaces", true],	0, 3, 4, 7, 8, 
		["Kernel",	false],	1, 
	];
	
	attribute_surface_depth();
	attribute_oversample();
	
	static step = function() { #region
		__step_mask_modifier();
	} #endregion
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _ker = _data[1];
		var _sam = struct_try_get(attributes, "oversample");
		
		surface_set_shader(_outSurf, sh_convolution);
			shader_set_f("dimension",  surface_get_width_safe(_outSurf), surface_get_height_safe(_outSurf));
			shader_set_f("kernel",     _ker);
			shader_set_i("sampleMode", _sam);
			
			draw_surface_safe(_data[0]);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _data[3], _data[4]);
		_outSurf = channel_apply(_data[0], _outSurf, _data[6]);
		
		return _outSurf;
	}
}