function Node_Blur_Contrast(_x, _y, _group = -1) : Node_Processor(_x, _y, _group) constructor {
	name = "Blur contrast";
	
	uniform_dim = shader_get_uniform(sh_blur_box_contrast, "dimension");
	uniform_siz = shader_get_uniform(sh_blur_box_contrast, "size");
	uniform_tes = shader_get_uniform(sh_blur_box_contrast, "treshold");
	uniform_dir = shader_get_uniform(sh_blur_box_contrast, "direction");
	
	inputs[| 0] = nodeValue(0, "Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	inputs[| 1] = nodeValue(1, "Size", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 3)
		.setDisplay(VALUE_DISPLAY.slider, [1, 32, 1]);
	
	inputs[| 2] = nodeValue(2, "Treshold", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.2)
		.setDisplay(VALUE_DISPLAY.slider, [0, 1, 0.01]);
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	
	pass = PIXEL_SURFACE;
	
	static process_data = function(_outSurf, _data, _output_index) {
		var _surf = _data[0];
		var _size = _data[1];
		var _tres = _data[2];
		
		var ww = surface_get_width(_surf);
		var hh = surface_get_height(_surf);
		
		if(is_surface(pass)) surface_size_to(pass, ww, hh);
		else pass = surface_create_valid(ww, hh);
		
		surface_set_target(pass);
		draw_clear_alpha(0, 0);
		BLEND_ADD
			shader_set(sh_blur_box_contrast);
			shader_set_uniform_f_array(uniform_dim, [ ww, hh ]);
			shader_set_uniform_f(uniform_siz, _size);
			shader_set_uniform_f(uniform_tes, _tres);
			shader_set_uniform_i(uniform_dir, 0);
			draw_surface_safe(_surf, 0, 0);
			shader_reset();
		BLEND_NORMAL
		surface_reset_target();
		
		surface_set_target(_outSurf);
		draw_clear_alpha(0, 0);
		BLEND_ADD
			shader_set(sh_blur_box_contrast);
			shader_set_uniform_i(uniform_dir, 1);
			draw_surface_safe(pass, 0, 0);
			shader_reset();
		BLEND_NORMAL
		surface_reset_target();
		
		return _outSurf;
	}
}