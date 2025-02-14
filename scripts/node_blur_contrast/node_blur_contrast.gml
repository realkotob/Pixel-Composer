#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Blur_Contrast", "Size > Set",  KEY_GROUP.numeric, MOD_KEY.none, function(val) /*=>*/ { PANEL_GRAPH_FOCUS_STR _n.inputs[1].setValue(toNumber(chr(keyboard_key))); });
	});
#endregion

function Node_Blur_Contrast(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Contrast Blur";
	
	newInput(0, nodeValue_Surface("Surface In", self));
	
	newInput(1, nodeValue_Float("Size", self, 3))
		.setValidator(VV_min(0))
		.setUnitRef(function(index) /*=>*/ {return getDimension(index)});
	
	newInput(2, nodeValue_Float("Threshold", self, 0.2, "Brightness different to be blur together."))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(3, nodeValue_Surface("Mask", self));
	
	newInput(4, nodeValue_Float("Mix", self, 1))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(5, nodeValue_Bool("Active", self, true));
		active_index = 5;
	
	newInput(6, nodeValue_Toggle("Channel", self, 0b1111, { data: array_create(4, THEME.inspector_channel) }));
		
	__init_mask_modifier(3); // inputs 7, 8
	
	newInput(9, nodeValue_Bool("Gamma Correction", self, false));
	
	input_display_list = [ 5, 6, 
		["Surfaces", true], 0, 3, 4, 7, 8, 
		["Blur",	false], 1, 2, 9, 
	]
	
	newOutput(0, nodeValue_Output("Surface Out", self, VALUE_TYPE.surface, noone));
	
	temp_surface = [ surface_create(1, 1) ];
	
	attribute_surface_depth();
	
	static step = function() {
		__step_mask_modifier();
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _surf = _data[0];
		var _size = _data[1];
		var _tres = _data[2];
		var _mask = _data[3];
		var _mix  = _data[4];
		var _gam  = _data[9];
		
		var ww = surface_get_width_safe(_surf);
		var hh = surface_get_height_safe(_surf);
		
		surface_set_shader(_outSurf, sh_blur_box_contrast);
			shader_set_f("dimension", [ ww, hh ]);
			shader_set_f("size",      _size);
			shader_set_f("treshold",  _tres);
			shader_set_i("gamma",     _gam);
			
			draw_surface_safe(_surf);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _mask, _mix);
		_outSurf = channel_apply(_data[0], _outSurf, _data[6]);
		
		return _outSurf;
	}
}