function Node_Color_adjust(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Color Adjust";
	batch_output = false;
	
	newInput(0, nodeValue_Surface("Surface In", self));
	
	newInput(1, nodeValue_Float("Brightness", self, 0))
		.setDisplay(VALUE_DISPLAY.slider, { range: [ -1, 1, 0.01 ] })
		.setMappable(18);
	
	newInput(2, nodeValue_Float("Contrast",   self, 0.5))
		.setDisplay(VALUE_DISPLAY.slider)
		.setMappable(19);
	
	newInput(3, nodeValue_Float("Hue",        self, 0))
		.setDisplay(VALUE_DISPLAY.slider, { range: [ -1, 1, 0.01 ] })
		.setMappable(20);
	
	newInput(4, nodeValue_Float("Saturation", self, 0))
		.setDisplay(VALUE_DISPLAY.slider, { range: [ -1, 1, 0.01 ] })
		.setMappable(21);
	
	newInput(5, nodeValue_Float("Value",      self, 0))
		.setDisplay(VALUE_DISPLAY.slider, { range: [ -1, 1, 0.01 ] })
		.setMappable(22);
	
	newInput(6, nodeValue_Color("Blend",   self, cola(c_white)));
	
	newInput(7, nodeValue_Float("Blend amount",  self, 0))
		.setDisplay(VALUE_DISPLAY.slider)
		.setMappable(23);
	
	newInput(8, nodeValue_Surface("Mask", self));
	
	newInput(9, nodeValue_Float("Alpha", self, 1))
		.setDisplay(VALUE_DISPLAY.slider)
		.setMappable(24);
	
	newInput(10, nodeValue_Float("Exposure", self, 1))
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 0, 4, 0.01 ] })
		.setMappable(25);
	
	newInput(11, nodeValue_Bool("Active", self, true));
		active_index = 11;
		
	newInput(12, nodeValue_Enum_Button("Input Type", self,  0, [ "Surface", "Color" ]));
	
	newInput(13, nodeValue_Palette("Color", self, array_clone(DEF_PALETTE)))
		.setVisible(true, true);
	
	newInput(14, nodeValue_Enum_Scroll("Blend mode", self,  0, BLEND_TYPES));
		
	newInput(15, nodeValue_Toggle("Channel", self, 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	newInput(16, nodeValue_Bool("Invert mask", self, false));
	
	newInput(17, nodeValue_Float("Mask feather", self, 1))
		.setDisplay(VALUE_DISPLAY.slider, { range: [1, 16, 0.1] });
	
	////////////////////////////////////////////////////////////////////////////////////////
	
	newInput(18, nodeValue_Surface("Brightness map", self))
		.setVisible(false, false);
	
	newInput(19, nodeValue_Surface("Contrast map", self))
		.setVisible(false, false);
	
	newInput(20, nodeValue_Surface("Hue map", self))
		.setVisible(false, false);
	
	newInput(21, nodeValue_Surface("Saturation map", self))
		.setVisible(false, false);
	
	newInput(22, nodeValue_Surface("Value map", self))
		.setVisible(false, false);
	
	newInput(23, nodeValue_Surface("Blend map", self))
		.setVisible(false, false);
	
	newInput(24, nodeValue_Surface("Alpha map", self))
		.setVisible(false, false);
	
	newInput(25, nodeValue_Surface("Exposure map", self))
		.setVisible(false, false);
		
	////////////////////////////////////////////////////////////////////////////////////////
	
	newOutput(0, nodeValue_Output("Surface Out", self, VALUE_TYPE.surface, noone));
	
	newOutput(1, nodeValue_Output("Color out", self, VALUE_TYPE.color, []))
		.setDisplay(VALUE_DISPLAY.palette);
	
	input_display_list = [11, 12, 15, 9, 24, 
		["Input",		false], 0, 8, 16, 17, 13, 
		["Brightness",	false], 1, 18, 10, 25, 2, 19, 
		["HSV",			false], 3, 20, 4, 21, 5, 22, 
		["Color blend", false], 6, 14, 7, 23, 
	];
	
	temp_surface = [ surface_create(1, 1), surface_create(1, 1) ];
	
	attribute_surface_depth();
	
	static step = function() {
		inputs[ 1].mappableStep();
		inputs[ 2].mappableStep();
		inputs[ 3].mappableStep();
		inputs[ 4].mappableStep();
		inputs[ 5].mappableStep();
		inputs[ 7].mappableStep();
		inputs[ 9].mappableStep();
		inputs[10].mappableStep();
	}
	
	static processData_prebatch = function() {
		var _type = getSingleValue(12);
		
		inputs[ 0].setVisible(_type == 0, _type == 0);
		inputs[ 8].setVisible(_type == 0, _type == 0);
		inputs[ 9].setVisible(_type == 0);
		inputs[13].setVisible(_type == 1, _type == 1);
		inputs[14].setVisible(_type == 0);
		
		outputs[0].setVisible(_type == 0, _type == 0);
		outputs[1].setVisible(_type == 1, _type == 1);
		
		inputs[16].setVisible(_type == 0);
		inputs[17].setVisible(_type == 0);
		
		preview_draw = _type == 0;
			 if(_type == 0) setDimension(128, 128);
		else if(_type == 1) setDimension(96, process_length[13] * 32);
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _bri = _data[1];
		var _con = _data[2];
		var _hue = _data[3];
		var _sat = _data[4];
		var _val = _data[5];
		
		var _bl  = _data[6];
		var _bla = _data[7];
		var _m   = _data[8];
		var _alp = _data[9];
		var _exp = _data[10];
		
		var _type = _data[12];
		var _col  = _data[13];
		var _blm  = _data[14];
		
		var _mskInv = _data[16];
		var _mskFea = _data[17];
		
		if(_type == 0 && _output_index != 0) return [];
		if(_type == 1 && _output_index != 1) return noone;
		
		var _surf     = _data[0];
		var _baseSurf = _outSurf;
		
		_col = array_clone(_col);
		
		if(_type == 1) { // single color adjust
			if(is_array(_bri)) _bri = array_safe_get_fast(_bri, 0);
			if(is_array(_con)) _con = array_safe_get_fast(_con, 0);
			if(is_array(_hue)) _hue = array_safe_get_fast(_hue, 0);
			if(is_array(_sat)) _sat = array_safe_get_fast(_sat, 0);
			if(is_array(_val)) _val = array_safe_get_fast(_val, 0);
			if(is_array(_bla)) _bla = array_safe_get_fast(_bla, 0);
			if(is_array(_alp)) _alp = array_safe_get_fast(_alp, 0);
			if(is_array(_exp)) _exp = array_safe_get_fast(_exp, 0);
			
			if(!is_array(_col)) _col = [ _col ];
			
			for( var i = 0, n = array_length(_col); i < n; i++ ) {
				var _c = _col[i];
				
				var r = _color_get_red(_c);
				var g = _color_get_green(_c);
				var b = _color_get_blue(_c);
				var a =  color_get_alpha(_c);
				
				_c = make_color_rgba(
					clamp((.5 + _con * 2 * (r - .5) + _bri) * _exp, 0, 1) * 255,
					clamp((.5 + _con * 2 * (g - .5) + _bri) * _exp, 0, 1) * 255,
					clamp((.5 + _con * 2 * (b - .5) + _bri) * _exp, 0, 1) * 255,
					a
				);
				
				var h = _color_get_hue(_c);
				var s = _color_get_saturation(_c);
				var v = _color_get_value(_c);
				
				h = clamp(frac(h + _hue), -1, 1);
				if(h < 0) h = 1 + h;
				v = clamp((v + _val) * (1 + _sat * s * 0.5), 0, 1);
				s = clamp(s * (_sat + 1), 0, 1);
				
				_c = make_color_hsva(h * 255, s * 255, v * 255, a);
				_c = merge_color(_c, _bl, _bla);
				_col[i] = _c;
			}
			
			return _col;
		}
		
		#region param
			var sw = surface_get_width_safe(_baseSurf);
			var sh = surface_get_height_safe(_baseSurf);
		
			temp_surface[0] = surface_verify(temp_surface[0], sw * 2, sh * 2);
			temp_surface[1] = surface_verify(temp_surface[1], sw * 2, sh * 2);
		
			surface_set_target(temp_surface[0]);
				DRAW_CLEAR
				
				draw_surface_stretched_safe(_data[18], sw * 0, sh * 0, sw, sh); //Brightness
				draw_surface_stretched_safe(_data[25], sw * 1, sh * 0, sw, sh); //Exposure
				draw_surface_stretched_safe(_data[19], sw * 0, sh * 1, sw, sh); //Contrast
				draw_surface_stretched_safe(_data[20], sw * 1, sh * 1, sw, sh); //Hue
			surface_reset_target();
		
			surface_set_target(temp_surface[1]);
				DRAW_CLEAR
				
				draw_surface_stretched_safe(_data[21], sw * 0, sh * 0, sw, sh); //Sat
				draw_surface_stretched_safe(_data[22], sw * 1, sh * 0, sw, sh); //Val
				draw_surface_stretched_safe(_data[23], sw * 0, sh * 1, sw, sh); //Blend
				draw_surface_stretched_safe(_data[24], sw * 1, sh * 1, sw, sh); //Alpha
			surface_reset_target();
		#endregion
		
		#region surface adjust
			_m = mask_modify(_m, _mskInv, _mskFea);
			
			surface_set_shader(_baseSurf, sh_color_adjust, true, BLEND.over);
				shader_set_surface("param0", temp_surface[0]);
				shader_set_surface("param1", temp_surface[1]);
				
				shader_set_f_map_s("brightness", _bri, _data[18], inputs[ 1]);
				shader_set_f_map_s("exposure",   _exp, _data[25], inputs[10]);
				shader_set_f_map_s("contrast",   _con, _data[19], inputs[ 2]);
				shader_set_f_map_s("hue",        _hue, _data[20], inputs[ 3]);
				shader_set_f_map_s("sat",        _sat, _data[21], inputs[ 4]);
				shader_set_f_map_s("val",        _val, _data[22], inputs[ 5]);
				
				shader_set_color("blend",   _bl);
				shader_set_f_map_s("blendAmount", _bla * _color_get_alpha(_bl), _data[23], inputs[7]);
				shader_set_i("blendMode",   _blm);
				
				shader_set_f_map_s("alpha", _alp, _data[24], inputs[9]);
				shader_set_i("use_mask", is_surface(_m));
				shader_set_surface("mask", _m);
			
				draw_surface_ext_safe(_surf, 0, 0, 1, 1, 0, c_white, 1);
			surface_reset_shader();
		#endregion
		
		return _outSurf;
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var type = getInputData(12);
		if(type == 0) return;
		
		var bbox = drawGetBbox(xx, yy, _s);
		if(bbox.h < 1) return;
		
		var pal = outputs[1].getValue();
		if(array_empty(pal)) return;
		if(!is_array(pal[0])) pal = [ pal ];
		
		var _y = bbox.y0;
		var gh = bbox.h / array_length(pal);
			
		for( var i = 0, n = array_length(pal); i < n; i++ ) {
			drawPalette(pal[i], bbox.x0, _y, bbox.w, gh);
			_y += gh;
		}
	}
}