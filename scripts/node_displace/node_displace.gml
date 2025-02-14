#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Displace", "Mode > Toggle",            "M", MOD_KEY.none, function() /*=>*/ { PANEL_GRAPH_FOCUS_STR _n.inputs[ 5].setValue((_n.inputs[ 5].getValue() + 1) % 4); });
		addHotkey("Node_Displace", "Oversample Mode > Toggle", "O", MOD_KEY.none, function() /*=>*/ { PANEL_GRAPH_FOCUS_STR _n.inputs[ 7].setValue((_n.inputs[ 7].getValue() + 1) % 3); });
		addHotkey("Node_Displace", "Blend Mode > Toggle",      "B", MOD_KEY.none, function() /*=>*/ { PANEL_GRAPH_FOCUS_STR _n.inputs[11].setValue((_n.inputs[11].getValue() + 1) % 3); });
		
		addHotkey("Node_Displace", "Iterate > Toggle",         "I", MOD_KEY.none, function() /*=>*/ { PANEL_GRAPH_FOCUS_STR _n.inputs[ 6].setValue((_n.inputs[ 6].getValue() + 1) % 2); });
		addHotkey("Node_Displace", "Fade Distance > Toggle",   "F", MOD_KEY.none, function() /*=>*/ { PANEL_GRAPH_FOCUS_STR _n.inputs[19].setValue((_n.inputs[19].getValue() + 1) % 2); });
	});
#endregion

function Node_Displace(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Displace";
	
	newInput(0, nodeValue_Surface("Surface In", self))
		.setVisible(true, true);
	
	newInput(1, nodeValue_Surface("Displace map", self))
		.setVisible(true, true);
	
	newInput(2, nodeValue_Vec2("Position", self, [ 1, 0 ] ))
		.setTooltip("Vector to displace pixel by.")
		.setUnitRef(function(index) { return getDimension(index); });
	
	newInput(3, nodeValue_Float("Strength",   self, 1))
		.setMappable(15);
	
	newInput(4, nodeValue_Float("Mid value",  self, 0., "Brightness value to be use as a basis for 'no displacement'."))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(5, nodeValue_Enum_Button("Mode", self, 0, [ "Linear", "Vector", "Angle", "Gradient" ]))
		.setTooltip(@"Use color data for extra information.
    - Linear: Displace along a single line (defined by the position value).
    - Vector: Use red as X displacement, green as Y displacement.
    - Angle: Use red as angle, green as distance.
    - Gradient: Displace down the brightness value defined by the Displace map.");
	
	newInput(6, nodeValue_Bool("Iterate",  self, false, @"If not set, then strength value is multiplied directly to the displacement.
If set, then strength value control how many times the effect applies on itself."));
	
	newInput(7, nodeValue_Enum_Scroll("Oversample Mode", self,  0, [ "Empty", "Clamp", "Repeat" ]))
		.setTooltip("How to deal with pixel outside the surface.\n    - Empty: Use empty pixel\n    - Clamp: Repeat edge pixel\n    - Repeat: Repeat texture.");
	
	newInput(8, nodeValue_Surface("Mask", self));
	
	newInput(9, nodeValue_Float("Mix", self, 1))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(10, nodeValue_Bool("Active", self, true));
		active_index = 10;
	
	newInput(11, nodeValue_Enum_Scroll("Blend Mode", self,  0, [ "Overwrite", "Min", "Max" ]));
		
	newInput(12, nodeValue_Toggle("Channel", self, 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	__init_mask_modifier(8); // inputs 13, 14
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	newInput(15, nodeValue_Surface("Strength map",   self))
		.setVisible(false, false);
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	newInput(16, nodeValue_Bool("Separate axis", self, false));
	
	newInput(17, nodeValue_Surface("Displace map 2", self));
	
	newInput(18, nodeValue_Int("Iteration", self, 32));
	
	newInput(19, nodeValue_Bool("Fade Distance", self, true));
	
	newInput(20, nodeValue_Bool("Reposition", self, false));
	
	input_display_list = [ 10, 12, 
		["Surfaces",	  true], 0, 8, 9, 13, 14, 
		["Strength",	 false], 1, 17, 3, 15, 4,
		["Displacement", false], 5, 16, 2, 
		["Algorithm",	  true], 6, 11, 18, 19, 20, 
	];
	
	newOutput(0, nodeValue_Output("Surface Out", self, VALUE_TYPE.surface, noone));
	
	attribute_surface_depth();
	attribute_oversample();
	attribute_interpolation();
	
	static step = function() {
		__step_mask_modifier();
		inputs[3].mappableStep();
		
		var _mode = getInputData(5);
		var _sep  = getInputData(16);
		
		var _dsp2 = (_mode == 1 || _mode == 2) && _sep;
		
		inputs[ 2].setVisible(_mode == 0);
		inputs[16].setVisible(_mode == 1 || _mode == 2);
		inputs[17].setVisible(_dsp2, _dsp2);
		
		if(_mode == 1 && _sep) {
			inputs[ 1].setName("Displace X");
			inputs[17].setName("Displace Y");
			
		} else if(_mode == 2 && _sep) {
			inputs[ 1].setName("Displace angle");
			inputs[17].setName("Displace amount");
			
		} else {
			inputs[ 1].setName("Displace map");
		}
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _map  = _data[1];
		var _sep  = _data[16];
		var _map2 = _data[17];
		
		var _mode = _data[5];
		if(!is_surface(_map) || (_sep && !is_surface(_map2))) {
			surface_set_shader(_outSurf); 
				draw_surface_safe(_data[0]);
			surface_reset_shader()
			return _outSurf;
		}
		
		var ww = surface_get_width_safe(_data[0]);
		var hh = surface_get_height_safe(_data[0]);
		var mw = surface_get_width_safe(_data[1]);
		var mh = surface_get_height_safe(_data[1]);
		
		surface_set_shader(_outSurf, sh_displace);
		shader_set_interpolation(_data[0]);
			shader_set_surface("map",  _data[1]);
			shader_set_surface("map2", _data[17]);
			
			shader_set_f("dimension",     [ww, hh]);
			shader_set_f("map_dimension", [mw, mh]);
			shader_set_f("displace",      _data[ 2]);
			shader_set_f_map("strength",  _data[ 3], _data[15], inputs[3]);
			shader_set_f("middle",        _data[ 4]);
			shader_set_i("mode",          _data[ 5]);
			shader_set_i("sepAxis",       _data[16]);
			
			shader_set_i("iterate",       _data[ 6]);
			shader_set_f("iteration",     _data[18]);
			shader_set_i("blendMode",     _data[11]);
			shader_set_i("fadeDist",      _data[19]);
			shader_set_i("reposition",    _data[20]);
			draw_surface_safe(_data[0]);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _data[8], _data[9]);
		_outSurf = channel_apply(_data[0], _outSurf, _data[12]);
		
		return _outSurf;
	}
}