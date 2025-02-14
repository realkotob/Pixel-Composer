#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Outline", "Width > Set", KEY_GROUP.numeric, MOD_KEY.none, function() /*=>*/ { PANEL_GRAPH_FOCUS_STR _n.inputs[1].setValue(toNumber(chr(keyboard_key))); });
		addHotkey("Node_Outline", "Position > Toggle",         "S", MOD_KEY.none, function() /*=>*/ { PANEL_GRAPH_FOCUS_STR _n.inputs[ 5].setValue((_n.inputs[ 5].getValue() + 1) % 2); });
		addHotkey("Node_Outline", "Blend > Toggle",            "B", MOD_KEY.none, function() /*=>*/ { PANEL_GRAPH_FOCUS_STR _n.inputs[ 3].setValue((_n.inputs[ 3].getValue() + 1) % 2); });
		addHotkey("Node_Outline", "Profile > Toggle",          "P", MOD_KEY.none, function() /*=>*/ { PANEL_GRAPH_FOCUS_STR _n.inputs[18].setValue((_n.inputs[18].getValue() + 1) % 3); });
		addHotkey("Node_Outline", "Anti-aliasing > Toggle",    "A", MOD_KEY.none, function() /*=>*/ { PANEL_GRAPH_FOCUS_STR _n.inputs[ 6].setValue((_n.inputs[ 6].getValue() + 1) % 2); });
	});
#endregion

function Node_Outline(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Outline";
	batch_output = false;
	
	attributes.filter = array_create(9, 1);
	filtering_vl = false;
	
	filter_button = new buttonAnchor(noone, function(ind) {
		if(mouse_press(mb_left))
			filtering_vl = !attributes.filter[ind];
		attributes.filter[ind] = filtering_vl;
		triggerRender();
	});
	
	newInput(0, nodeValue_Surface("Surface In", self));
	
	newInput(1, nodeValue_Int("Width",   self, 0))
		.setDisplay(VALUE_DISPLAY._default, { front_button : filter_button })
		.setValidator(VV_min(0))
		.setMappable(15);
	
	newInput(2, nodeValue_Color("Color",   self, cola(c_white)));
	
	newInput(3, nodeValue_Bool("Blend",   self, false, "Blend outline color with the original color."));
	
	newInput(4, nodeValue_Float("Blend alpha",   self, 1))
		.setDisplay(VALUE_DISPLAY.slider)
		.setMappable(16);
	
	newInput(5, nodeValue_Enum_Button("Position",   self,  1, ["Inside", "Outside"]));
	
	newInput(6, nodeValue_Bool("Anti-aliasing",   self, 0));
	
	newInput(7, nodeValue_Enum_Scroll("Oversample mode", self,  0, [ "Empty", "Clamp", "Repeat" ]))
		.setTooltip("How to deal with pixel outside the surface.\n    - Empty: Use empty pixel\n    - Clamp: Repeat edge pixel\n    - Repeat: Repeat texture.");
		
	newInput(8, nodeValue_Int("Start", self, 0, "Shift outline inside, outside the shape."))
		.setMappable(17);
	
	newInput(9, nodeValue_Surface("Mask", self));
	
	newInput(10, nodeValue_Float("Mix", self, 1))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(11, nodeValue_Bool("Active", self, true));
		active_index = 11;
	
	newInput(12, nodeValue_Bool("Crop border", self, false));
	
	__init_mask_modifier(9); // inputs 13, 14
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	newInput(15, nodeValueMap("Width map", self));
	
	newInput(16, nodeValueMap("Blend alpha map", self));
	
	newInput(17, nodeValueMap("Start map", self));
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	newInput(18, nodeValue_Enum_Scroll("Profile", self,  0, [ "Circle", "Square", "Diamond" ]));
	
	newOutput(0, nodeValue_Output("Surface Out", self, VALUE_TYPE.surface, noone));
	
	newOutput(1, nodeValue_Output("Outline", self, VALUE_TYPE.surface, noone));
	
	input_display_list = [ 11, 
		["Surfaces", true], 0, 9, 10, 13, 14, 
		["Outline",	false], 18, 1, 15, 5, 8, 17, 12, 
		["Render",	false], 2, 6,
		["Blend",	 true, 3], 4, 16,
	];
	
	attribute_surface_depth();
	attribute_oversample();
	
	static step = function() {
		var _wid  = getInputData(1);
		var _side = getInputData(5);
		
		inputs[12].setVisible(_side == 0);
		
		__step_mask_modifier();
		
		inputs[1].mappableStep();
		inputs[4].mappableStep();
		inputs[8].mappableStep();
		
		filter_button.index = attributes.filter;
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var ww = surface_get_width_safe(_data[0]);
		var hh = surface_get_height_safe(_data[0]);
		var cl = _data[2];
		
		var blend = _data[3];
		var side  = _data[5];
		var aa    = _data[6];
		var sam   = getAttribute("oversample");
		var _crop = _data[12];
		
		surface_set_shader(_outSurf, sh_outline);
			shader_set_f("dimension",       ww, hh);
			shader_set_f_map("borderSize",  _data[1], _data[15], inputs[1]);
			shader_set_f_map("borderStart", _data[8], _data[17], inputs[8]);
			shader_set_color("borderColor", cl);
			
			shader_set_i("profile",         _data[18]);
			shader_set_i("side",            side);
			shader_set_i("highRes",         0);
			shader_set_i("is_aa",           aa);
			shader_set_i("outline_only",    _output_index);
			shader_set_i("is_blend",        blend);
			shader_set_f_map("blend_alpha", _data[4], _data[16], inputs[4]);
			shader_set_i("sampleMode",      sam);
			shader_set_i("crop_border",     _crop);
			shader_set_i("filter",          attributes.filter);
			
			draw_surface_safe(_data[0]);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _data[9], _data[10]);
		
		return _outSurf;  
	}
}