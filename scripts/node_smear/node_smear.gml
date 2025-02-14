#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Smear", "Strength > Set",         KEY_GROUP.numeric, MOD_KEY.none, function(val) /*=>*/ { PANEL_GRAPH_FOCUS_STR _n.inputs[1].setValue(toNumber(chr(keyboard_key)) / 10); });
		addHotkey("Node_Smear", "Direction > Rotate CCW", "R", MOD_KEY.none, function(val) /*=>*/ { PANEL_GRAPH_FOCUS_STR _n.inputs[2].setValue((_n.inputs[2].getValue() + 90) % 360); });
		addHotkey("Node_Smear", "Mode > Toggle",          "M", MOD_KEY.none, function(val) /*=>*/ { PANEL_GRAPH_FOCUS_STR _n.inputs[11].setValue(!_n.inputs[11].getValue()); });
		addHotkey("Node_Smear", "Blend Mode > Toggle",    "B", MOD_KEY.none, function(val) /*=>*/ { PANEL_GRAPH_FOCUS_STR _n.inputs[15].setValue(!_n.inputs[15].getValue()); });
		addHotkey("Node_Smear", "Normalize > Toggle",     "N", MOD_KEY.none, function(val) /*=>*/ { PANEL_GRAPH_FOCUS_STR _n.inputs[16].setValue(!_n.inputs[16].getValue()); });
	});
#endregion

function Node_Smear(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Smear";
	
	newInput(0, nodeValue_Surface("Surface In", self));
	
	newInput(1, nodeValue_Float("Strength", self, 0.2))
		.setDisplay(VALUE_DISPLAY.slider, { range: [0, 0.5, 0.001] })
		.setMappable(9);
	
	newInput(2, nodeValue_Rotation("Direction", self, 0))
		.setMappable(10);
	
	newInput(3, nodeValue_Surface("Mask", self));
	
	newInput(4, nodeValue_Float("Mix", self, 1))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(5, nodeValue_Bool("Active", self, true));
		active_index = 5;
	
	newInput(6, nodeValue_Toggle("Channel", self, 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	__init_mask_modifier(3); // inputs 7, 8
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	newInput( 9, nodeValueMap("Strength map", self));
	
	newInput(10, nodeValueMap("Direction map", self));
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	newInput(11, nodeValue_Enum_Button("Mode", self,  0, [ "Greyscale", "Alpha" ]));
	
	newInput(12, nodeValue_Enum_Button("Modulate strength", self,  0, [ "Distance", "Color", "None" ]));
	
	newInput(13, nodeValue_Int("Spread", self, 0))
		.setDisplay(VALUE_DISPLAY.slider, { range : [ 0, 30, 1 ] });
	
	newInput(14, nodeValue_Bool("Invert", self, false));
	
	newInput(15, nodeValue_Enum_Scroll("Blend Mode", self,  0, [ "Maximum", "Additive" ]));
	
	newInput(16, nodeValue_Bool("Normalize", self, false));
	
	input_display_list = [ 5, 6, 
		["Surfaces", true], 0, 3, 4, 7, 8, 
		["Smear",	false], 11, 14, 1, 9, 2, 10, 13, 12, 
		["Render",  false], 16, 15, 
	]
	
	newOutput(0, nodeValue_Output("Surface Out", self, VALUE_TYPE.surface, noone));
	
	attribute_surface_depth();
	attribute_oversample();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _surf = outputs[0].getValue();
		if(is_array(_surf)) {
			if(array_length(_surf) == 0) return;
			_surf = _surf[preview_index];
		}
		
		var ww   = surface_get_width_safe(_surf);
		var hh   = surface_get_height_safe(_surf);
		var _hov = false;
		var  hv  = inputs[2].drawOverlay(hover, active, _x + ww / 2 * _s, _y + hh / 2 * _s, _s, _mx, _my, _snx, _sny); _hov |= hv;
		
		return _hov;
	}
	
	static step = function() {
		__step_mask_modifier();
		
		inputs[ 1].mappableStep();
		inputs[ 2].mappableStep();
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		
		var _dim = surface_get_dimension(_data[0]);
		
		surface_set_shader(_outSurf, sh_smear);
			shader_set_f("dimension",     _dim);
			shader_set_f("size",          max(_dim[0], _dim[1]));
			
			shader_set_f_map("strength",  _data[ 1], _data[ 9], inputs[ 1]);
			shader_set_f_map("direction", _data[ 2], _data[10], inputs[ 2]);
			shader_set_i("sampleMode",	  getAttribute("oversample"));
			shader_set_i("alpha",	      _data[11]);
			shader_set_i("inv",	    	  _data[14]);
			shader_set_i("blend",    	  _data[15]);
			shader_set_i("modulateStr",   _data[12]);
			shader_set_f("spread",        _data[13]);
			shader_set_i("normalized",    _data[16]);
			
			draw_surface_safe(_data[0]);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _data[3], _data[4]);
		_outSurf = channel_apply(_data[0], _outSurf, _data[6]);
		
		return _outSurf;
	}
}