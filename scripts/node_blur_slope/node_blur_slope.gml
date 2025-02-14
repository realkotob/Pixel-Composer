#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Blur_Slope", "Strength > Set",  KEY_GROUP.numeric, MOD_KEY.none, function(val) /*=>*/ { PANEL_GRAPH_FOCUS_STR _n.inputs[1].setValue(toNumber(chr(keyboard_key))); });
	});
#endregion

function Node_Blur_Slope(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Slope Blur";
	
	newInput(0, nodeValue_Surface("Surface In", self));
	
	newInput(1, nodeValue_Float("Strength", self, 4))
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 1, 32, 0.1 ] })
		.setMappable(9);
	
	newInput(2, nodeValue_Surface("Slope Map",   self));
	
	newInput(3, nodeValue_Surface("Mask", self));
	
	newInput(4, nodeValue_Float("Mix", self, 1))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(5, nodeValue_Bool("Active", self, true));
		active_index = 5;
	
	newInput(6, nodeValue_Toggle("Channel", self, 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	__init_mask_modifier(3); // inputs 7, 8
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	newInput( 9, nodeValueMap("Strength map", self));
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	newInput(10, nodeValue_Float("Step", self, 0.1))
		.setDisplay(VALUE_DISPLAY.slider, { range: [0, 1, 0.01] });
		
	newInput(11, nodeValue_Bool("Gamma Correction", self, false));
	
	input_display_list = [ 5, 6, 
		["Surfaces", true], 0, 3, 4, 7, 8, 
		["Blur",	false], 2, 1, 9, 10, 11, 
	]
	
	newOutput(0, nodeValue_Output("Surface Out", self, VALUE_TYPE.surface, noone));
	
	attribute_surface_depth();
	attribute_oversample();
	attribute_interpolation();
	
	static step = function() {
		__step_mask_modifier();
		
		inputs[1].mappableStep();
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		surface_set_shader(_outSurf, sh_blur_slope);
			shader_set_interpolation(_data[0]);
			shader_set_f("dimension",      surface_get_dimension(_data[0]));
			shader_set_f_map("strength",   _data[1], _data[ 9], inputs[1]);
			shader_set_f("stepSize",       _data[10]);
			shader_set_surface("slopeMap", _data[2]);
			shader_set_f("slopeMapDim",    surface_get_dimension(_data[2]));
			shader_set_i("sampleMode",	  getAttribute("oversample"));
			shader_set_i("gamma",          _data[11]);
			
			draw_surface_safe(_data[0]);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _data[3], _data[4]);
		_outSurf = channel_apply(_data[0], _outSurf, _data[6]);
		
		return _outSurf;
	}
}