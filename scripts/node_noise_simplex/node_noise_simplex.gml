#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Noise_Simplex", "Color Mode > Toggle", "C", MOD_KEY.none, function() /*=>*/ { PANEL_GRAPH_FOCUS_STR _n.inputs[4].setValue((_n.inputs[4].getValue() + 1) % 3); });
	});
#endregion

function Node_Noise_Simplex(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Simplex Noise";
	
	newInput(0, nodeValue_Dimension(self));
	
	newInput(1, nodeValue_Vec3("Position", self, [ 0, 0, 0 ] ));
	
	newInput(2, nodeValue_Vec2("Scale", self, [ 1, 1 ] ))
		.setMappable(8);
	
	newInput(3, nodeValue_Int("Iteration", self, 1 ))
		.setDisplay(VALUE_DISPLAY.slider, { range: [1, 16, 0.1] })
		.setMappable(9);
	
	newInput(4, nodeValue_Enum_Button("Color Mode", self, 0, [ "Greyscale", "RGB", "HSV" ]));
	
	newInput(5, nodeValue_Slider_Range("Color R Range", self, [ 0, 1 ]));
	
	newInput(6, nodeValue_Slider_Range("Color G Range", self, [ 0, 1 ]));
	
	newInput(7, nodeValue_Slider_Range("Color B Range", self, [ 0, 1 ]));
	
	//////////////////////////////////////////////////////////////////////////////////
	
	newInput(8, nodeValueMap("Scale map", self));
	
	newInput(9, nodeValueMap("Iteration map", self));
	
	//////////////////////////////////////////////////////////////////////////////////
		
	newInput(10, nodeValue_Rotation("Rotation", self, 0));
		
	input_display_list = [
		["Output",	false], 0, 
		["Noise",	false], 1, 10, 2, 8, 3, 9, 
		["Render",	false], 4, 5, 6, 7, 
	];
	
	newOutput(0, nodeValue_Output("Surface Out", self, VALUE_TYPE.surface, noone));
	
	attribute_surface_depth();
	
	static step = function() {
		var _col = getInputData(4);
		
		inputs[5].setVisible(_col != 0);
		inputs[6].setVisible(_col != 0);
		inputs[7].setVisible(_col != 0);
		
		inputs[5].name = _col == 1? "Color R Range" : "Color H Range";
		inputs[6].name = _col == 1? "Color G Range" : "Color S Range";
		inputs[7].name = _col == 1? "Color B Range" : "Color V Range";
		
		inputs[2].mappableStep();
		inputs[3].mappableStep();
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _dim = _data[0];
		var _pos = _data[1];
		
		var _col = _data[4];
		var _clr = _data[5];
		var _clg = _data[6];
		var _clb = _data[7];
		var _ang = _data[10];
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1], attrDepth());
		
		surface_set_shader(_outSurf, sh_simplex);
			shader_set_f("dimension", _dim);
			shader_set_3("position",  _pos);
			shader_set_f("rotation",  degtorad(_ang));
			shader_set_f_map("scale",     _data[2], _data[8], inputs[2]);
			shader_set_f_map("iteration", _data[3], _data[9], inputs[3]);
			
			shader_set_i("colored",   _col);
			shader_set_2("colorRanR", _clr);
			shader_set_2("colorRanG", _clg);
			shader_set_2("colorRanB", _clb);
		
			draw_sprite_ext(s_fx_pixel, 0, 0, 0, _dim[0], _dim[1], 0, c_white, 1);
		surface_reset_shader();
		
		return _outSurf;
	}
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _hov = false;
		var  hv  = inputs[1].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny); _hov |= hv;
		
		return _hov;
	}
}