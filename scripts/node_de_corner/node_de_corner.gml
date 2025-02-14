function Node_De_Corner(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "De-Corner";
	
	newInput(0, nodeValue_Surface("Surface In", self));
	
	newInput(1, nodeValue_Bool("Active", self, true));
		active_index = 1;
	
	newInput(2, nodeValue_Float("Tolerance", self, 0))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(3, nodeValue_Int("Iteration", self, 2))
	
	newInput(4, nodeValue_Enum_Button("Type", self,  0, [ "Double", "Diagonal" ]));
	
	newInput(5, nodeValue_Surface("Mask", self));
	
	newInput(6, nodeValue_Float("Mix", self, 1))
		.setDisplay(VALUE_DISPLAY.slider);
	
	__init_mask_modifier(5); // inputs 7, 8, 
	
	newInput(9, nodeValue_Toggle("Include", self, 0b11, { data: [ "Inner", "Side" ] }));
	
	newOutput(0, nodeValue_Output("Surface Out", self, VALUE_TYPE.surface, noone));
	
	input_display_list = [ 1, 
		["Surfaces",  true], 0, 5, 6, 7, 8, 
		["Effect",	 false], 4, 9, 2, 3, 
	]
	
	attribute_surface_depth();
	
	temp_surface = [ noone, noone ];
	
	static step = function() {
		__step_mask_modifier();
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var surf = _data[0];
		var _tol = _data[2];
		var _itr = _data[3];
		var _str = _data[4];
		var _inn = _data[9];
		
		var _sw  = surface_get_width_safe(surf);
		var _sh  = surface_get_height_safe(surf);
		
		for( var i = 0; i < 2; i++ ) temp_surface[i] = surface_verify(temp_surface[i], _sw, _sh);
		
		var _bg = 0;
		surface_set_shader(temp_surface[1]);
			draw_surface_safe(surf);
		surface_reset_shader();
		
		repeat(_itr) {
			surface_set_shader(temp_surface[_bg], sh_de_corner);
				shader_set_f("dimension", _sw, _sh);
				shader_set_f("tolerance", _tol);
				shader_set_i("strict",    _str);
				shader_set_i("inner",     bool(_inn & 0b01));
				shader_set_i("side",      bool(_inn & 0b10));
			
				draw_surface_safe(temp_surface[!_bg]);
			surface_reset_shader();
		
			_bg = !_bg;
		}
		
		surface_set_shader(_outSurf);
			draw_surface_safe(temp_surface[!_bg]);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _data[5], _data[6]);
		
		return _outSurf;
	}
	
}