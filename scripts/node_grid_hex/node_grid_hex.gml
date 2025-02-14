#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Grid_Hex", "Render Type > Toggle", "R", MOD_KEY.none, function() /*=>*/ { PANEL_GRAPH_FOCUS_STR _n.inputs[7].setValue((_n.inputs[7].getValue() + 1) % 4); });
	});
#endregion

function Node_Grid_Hex(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Hexagonal Grid";
	
	newInput(0, nodeValue_Dimension(self));
	
	newInput(1, nodeValue_Vec2("Position", self, [ 0, 0 ]))
		.setUnitRef(function(index) { return getDimension(index); });
	
	newInput(2, nodeValue_Vec2("Scale", self, [ 2, 2 ]))
		.setMappable(11);
	
	newInput(3, nodeValue_Rotation("Angle", self, 0))
		.setMappable(12);
	
	newInput(4, nodeValue_Float("Gap", self, 0.1))
		.setDisplay(VALUE_DISPLAY.slider, { range: [0, 0.5, 0.001] })
		.setMappable(13);
	
	newInput(5, nodeValue_Gradient("Tile Color", self, new gradientObject(cola(c_white))))
		.setMappable(17);
	
	newInput(6, nodeValue_Color("Gap Color", self, cola(c_black)));
	
	newInput(7, nodeValue_Enum_Scroll("Render Type", self,  0, ["Colored tile", "Height map", "Texture grid", "Texture sample"]));
		
	newInput(8, nodeValueSeed(self));
		
	newInput(9, nodeValue_Surface("Texture", self));
	
	newInput(10, nodeValue_Bool("Anti-aliasing", self, false));
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	newInput(11, nodeValueMap("Scale Map", self));
	
	newInput(12, nodeValueMap("Angle Map", self));
	
	newInput(13, nodeValueMap("Gap Map", self));
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	newInput(14, nodeValue_Bool("Truchet", self, false));
	
	newInput(15, nodeValue_Int("Truchet Seed", self, seed_random()));
	
	newInput(16, nodeValue_Float("Truchet Threshold", self, 0.5))
		.setDisplay(VALUE_DISPLAY.slider)
		
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	newInput(17, nodeValueMap("Gradient Map", self));
	
	newInput(18, nodeValueGradientRange("Gradient Map Range", self, inputs[5]));
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	newInput(19, nodeValue_Rotation_Range("Texture Angle", self, [ 0, 0 ]));
		
	newInput(20, nodeValue_Slider_Range("Level", self, [ 0, 1 ]));
	
	newInput(21, nodeValue_Bool("Use Texture Dimension", self, false));
	
	input_display_list = [
		["Output",  false], 0,
		["Pattern",	false], 1, 3, 12, 2, 11, 4, 13,
		["Render",	false], 7, 8, 5, 17, 6, 9, 21, 10, 20, 
		["Truchet",  true, 14], 15, 16, 19, 
	];
	
	newOutput(0, nodeValue_Output("Surface Out", self, VALUE_TYPE.surface, noone));
	
	attribute_surface_depth();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _hov = false;
		var a = inputs[ 1].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);						active &= !a; _hov |= a;
		var a = inputs[18].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, getSingleValue(0));	active &= !a; _hov |= a;
		
		return _hov;
	}
	
	static step = function() {
		inputs[2].mappableStep();
		inputs[3].mappableStep();
		inputs[4].mappableStep();
		inputs[5].mappableStep();
	}
	
	static getDimension = function(_arr = 0) {
		var _dim = getSingleValue( 0, _arr);
		var _sam = getSingleValue( 9, _arr);
		var _mod = getSingleValue( 7, _arr);
		var _txd = getSingleValue(21, _arr);
		var _tex = _mod == 2 || _mod == 3;
		
		if(is_surface(_sam) && _tex && _txd) 
			return surface_get_dimension(_sam);
		return _dim;
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _dim  = surface_get_dimension(_outSurf);
		var _pos  = _data[1];
		var _sam  = _data[9];
		var _mode = _data[7];
		
		var _col_gap  = _data[6];
		var _tex_mode = _mode == 2 || _mode == 3;
		
		inputs[ 5].setVisible(_mode == 0);
		inputs[ 6].setVisible(_mode != 1);
		inputs[20].setVisible(_mode == 1);
		
		inputs[ 9].setVisible(_tex_mode, _tex_mode);
		inputs[21].setVisible(_tex_mode, _tex_mode);
		
		surface_set_shader(_outSurf, sh_grid_hex);
			shader_set_f("dimension", _dim[0], _dim[1]);
			shader_set_f("position",  _pos[0] / _dim[0], _pos[1] / _dim[1]);
			
			shader_set_f_map("scale", _data[ 2], _data[11], inputs[2]);
			shader_set_f_map("angle", _data[ 3], _data[12], inputs[3]);
			shader_set_f_map("thick", _data[ 4], _data[13], inputs[4]);
			
			shader_set_f("seed",  _data[ 8]);
			shader_set_i("mode",  _mode);
			shader_set_i("aa",    _data[10]);
			shader_set_color("gapCol",_col_gap);
			
			shader_set_i("textureTruchet", _data[14]);
			shader_set_f("truchetSeed",    _data[15]);
			shader_set_f("truchetThres",   _data[16]);
			shader_set_2("truchetAngle",   _data[19]);
			shader_set_2("level",          _data[20]);
			
			shader_set_gradient(_data[5], _data[17], _data[18], inputs[5]);
			
			if(is_surface(_sam)) draw_surface_stretched_safe(_sam, 0, 0, _dim[0], _dim[1]);
			else                 draw_sprite_ext(s_fx_pixel, 0, 0, 0, _dim[0], _dim[1], 0, c_white, 1);
		surface_reset_shader();
		
		return _outSurf;
	}
}