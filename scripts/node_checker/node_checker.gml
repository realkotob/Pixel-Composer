#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Checker", "Amount > Set", KEY_GROUP.numeric, MOD_KEY.none, function() /*=>*/ { PANEL_GRAPH_FOCUS_STR _n.inputs[1].setValue(toNumber(chr(keyboard_key))); });
		addHotkey("Node_Checker", "Type > Toggle", "T", MOD_KEY.none, function() /*=>*/ { PANEL_GRAPH_FOCUS_STR _n.inputs[8].setValue((_n.inputs[8].getValue() + 1) % 3); });
	});
#endregion

function Node_Checker(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Checker";
	
	newInput(0, nodeValue_Dimension(self));
	
	newInput(1, nodeValue_Float("Amount", self, 2))
		.setDisplay(VALUE_DISPLAY.slider, { range: [1, 16, 0.1] })
		.setMappable(6);
	
	newInput(2, nodeValue_Rotation("Angle", self, 0))
		.setMappable(7);
	
	newInput(3, nodeValue_Vec2("Position", self, [0, 0] ))
		.setUnitRef(function(index) { return getDimension(index); });
	
	newInput(4, nodeValue_Color("Color 1", self, cola(c_white)));
	
	newInput(5, nodeValue_Color("Color 2", self, cola(c_black)));
	
	//////////////////////////////////////////////////////////////////////////////////
	
	newInput(6, nodeValueMap("Amount map", self));
	
	newInput(7, nodeValueMap("Angle map", self));
	
	//////////////////////////////////////////////////////////////////////////////////
	
	newInput(8, nodeValue_Enum_Button("Type", self,  0, [ "Solid", "Smooth", "AA" ]));
	
	newOutput(0, nodeValue_Output("Surface Out", self, VALUE_TYPE.surface, noone));
	
	input_display_list = [
		["Output",	true],	0,  
		["Pattern",	false], 1, 6, 2, 7, 3,
		["Render",	false], 8, 4, 5,
	];
	
	attribute_surface_depth();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var pos  = getInputData(3);
		var px   = _x + pos[0] * _s;
		var py   = _y + pos[1] * _s;
		var _hov = false;
		
		var hv = inputs[3].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny); _hov |= hv;
		var hv = inputs[2].drawOverlay(hover, active, px, py, _s, _mx, _my, _snx, _sny); _hov |= hv;
		
		return _hov;
	}
	
	static step = function() {
		inputs[1].mappableStep();
		inputs[2].mappableStep();
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _dim = _data[0];
		var _pos = _data[3];
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1], attrDepth());
			
		surface_set_shader(_outSurf, sh_checkerboard);
			shader_set_f("dimension",   surface_get_width_safe(_outSurf), surface_get_height_safe(_outSurf));
			shader_set_f("position",   _pos[0] / _dim[0], _pos[1] / _dim[1]);
			shader_set_f_map("amount", _data[1], _data[6], inputs[1]);
			shader_set_f_map("angle",  _data[2], _data[7], inputs[2]);
			shader_set_color("col1",   _data[4]);
			shader_set_color("col2",   _data[5]);
			shader_set_i("blend",	   _data[8]);
			
			draw_sprite_ext(s_fx_pixel, 0, 0, 0, _dim[0], _dim[1], 0, c_white, 1);
		surface_reset_shader();
		
		return _outSurf;
	}
}