function Node_3D_Depth(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "3D Depth";
	
	newInput(0, nodeValue_Surface("Base Texture", self));
	
	newInput(1, nodeValue_Surface("Depth", self));
	
	newInput(2, nodeValue_Vec3("Rotation", self, [0, 0, 0] ));
	
	newOutput(0, nodeValue_Output("Surface Out", self, VALUE_TYPE.surface, noone));
	
	input_display_list = [
		["Texture",	false], 0, 1, 
		["Camera",	false], 2, 
	];
	
	attribute_surface_depth();
	attribute_interpolation();
		
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _tex = _data[0];
		var _dep = _data[1];
		var _rot = _data[2];
		
		if(!is_surface(_tex)) return _outSurf;
		if(!is_surface(_dep)) return _outSurf;
		
		var x_rad = degtorad(_rot[0]);
		var y_rad = degtorad(_rot[1]);
		var z_rad = degtorad(_rot[2]);
		
		var _cx =  cos(y_rad) * cos(z_rad);
		var _cy = (sin(x_rad) * sin(y_rad) * cos(z_rad) - cos(x_rad) * sin(z_rad));
		var _cz = (cos(x_rad) * sin(y_rad) * cos(z_rad) + sin(x_rad) * sin(z_rad));
		
		var up_x = -sin(x_rad);
		var up_y = cos(x_rad);
		var up_z = 0;
		
		var right_x = cos(y_rad) * cos(z_rad);
		var right_y = sin(x_rad) * sin(y_rad) * cos(z_rad) - cos(x_rad) * sin(z_rad);
		var right_z = cos(x_rad) * sin(y_rad) * cos(z_rad) + sin(x_rad) * sin(z_rad);
		
		//print($"POS:   {_cx}, {_cy}, {_cz}");
		//print($"UP:    {up_x}, {up_y}, {up_z}");
		//print($"RIGHT: {right_x}, {right_y}, {right_z}");
		//print("");
		
		surface_set_shader(_outSurf, sh_3d_depth);
			DRAW_CLEAR
			
			shader_set_surface("texMap", _tex);
			shader_set_f("dimension", surface_get_width_safe(_tex), surface_get_height_safe(_tex));
			
			shader_set_surface("depthMap", _dep);
			shader_set_f("depthDimension", surface_get_width_safe(_dep), surface_get_height_safe(_dep));
			
			shader_set_f("cameraPos",   _cx,	 _cy,	  _cz);
			shader_set_f("cameraUp",    up_x,	 up_y,	  up_z);
			shader_set_f("cameraRight", right_x, right_y, right_z);
			
			draw_sprite_stretched(s_fx_pixel, 0, 0, 0, surface_get_width_safe(_tex), surface_get_height_safe(_tex));
		surface_reset_shader();
		
		return _outSurf;
	}
}