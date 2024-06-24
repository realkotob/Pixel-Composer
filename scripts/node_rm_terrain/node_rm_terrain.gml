function Node_RM_Terrain(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "RM Terrain";
	
	inputs[| 0] = nodeValue("Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, DEF_SURF)
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 1] = nodeValue("Surface", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone );
	
	inputs[| 2] = nodeValue("Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 3] = nodeValue("Rotation", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 30, 45, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 4] = nodeValue("Scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 0, 4, 0.01 ] });
	
	inputs[| 5] = nodeValue("FOV", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 30)
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 0, 90, 1 ] });
	
	inputs[| 6] = nodeValue("View Range", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 6 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 7] = nodeValue("BG Bleed", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 8] = nodeValue("Ambient", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white);
	
	inputs[| 9] = nodeValue("Height", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 0, 4, 0.01 ] });
	
	inputs[| 10] = nodeValue("Tile", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true)
	
	inputs[| 11] = nodeValue("Texture", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone );
	
	inputs[| 12] = nodeValue("Background", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_black);
	
	inputs[| 13] = nodeValue("Reflection", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone );
	
	inputs[| 14] = nodeValue("Sun Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ .5, 1, .5 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 15] = nodeValue("Shadow", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.2)
		.setDisplay(VALUE_DISPLAY.slider);
	
	outputs[| 0] = nodeValue("Surface Out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [ 0,
		["Extrusion", false], 1, 9, 10,
		["Textures",  false], 11, 13, 
		["Transform", false], 2, 3, 4, 
		["Camera",    false], 5, 6, 
		["Render",    false], 12, 7, 8,
		["Light",     false], 14, 15, 
	];
	
	temp_surface = [ 0, 0, 0, 0 ];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {}
	
	static step = function() {
		
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index = 0) {
		var _dim  = _data[0];
		var _surf = _data[1];
		
		var _pos  = _data[2];
		var _rot  = _data[3];
		var _sca  = _data[4];
		
		var _fov  = _data[5];
		var _rng  = _data[6];
		
		var _dpi  = _data[7];
		var _amb  = _data[8];
		var _thk  = _data[9];
		var _tile = _data[10];
		var _text = _data[11];
		var _bgc  = _data[12];
		var _refl = _data[13];
		var _sun  = _data[14];
		var _sha  = _data[15];
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1]);
		
		for (var i = 0, n = array_length(temp_surface); i < n; i++)
			temp_surface[i] = surface_verify(temp_surface[i], 8192, 8192);
		
		var tx = 1024;
		surface_set_shader(temp_surface[0]);
			draw_surface_stretched_safe(_surf, tx * 0, tx * 0, tx, tx);
			draw_surface_stretched_safe(_text, tx * 1, tx * 0, tx, tx);
			draw_surface_stretched_safe(_refl, tx * 2, tx * 0, tx, tx);
		surface_reset_shader();
		
		gpu_set_texfilter(true);
		
		surface_set_shader(_outSurf, sh_rm_terrain);
		
			for (var i = 0, n = array_length(temp_surface); i < n; i++)
				shader_set_surface($"texture{i}", temp_surface[i]);
			
			shader_set_i("shape",       1);
			shader_set_i("tile",        _tile);
			shader_set_i("useTexture",  is_surface(_text));
			shader_set_3("position",    _pos);
			shader_set_3("rotation",    _rot);
			shader_set_f("objectScale", _sca);
			shader_set_f("thickness",   _thk);
			
			shader_set_f("fov",         _fov);
			shader_set_2("viewRange",   _rng);
			shader_set_f("depthInt",    _dpi);
			
			shader_set_3("sunPosition", _sun);
			shader_set_f("shadow",      _sha);
			
			shader_set_color("background", _bgc);
			shader_set_color("ambient",    _amb);
			
			draw_sprite_stretched(s_fx_pixel, 0, 0, 0, _dim[0], _dim[1]);
		surface_reset_shader();
		
		return _outSurf; 
	}
} 
