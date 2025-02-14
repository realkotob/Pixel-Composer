function Node_Sprite_Stack(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Sprite Stack";
	dimension_index = 1;
	
	newInput(0, nodeValue_Surface("Base shape", self));
	
	newInput(1, nodeValue_Dimension(self));
	
	newInput(2, nodeValue_Int("Stack amount", self, 4));
	
	newInput(3, nodeValue_Vec2("Stack shift", self, [ 0, 1 ] ));
	
	newInput(4, nodeValue_Vec2("Position", self, [ 0, 0 ] ))
		.setUnitRef(function(index) { return getDimension(index); });
		
	newInput(5, nodeValue_Rotation("Rotation", self, 0));
	
	newInput(6, nodeValue_Color("Stack blend", self, cola(c_white) ));
	
	newInput(7, nodeValue_Float("Alpha end", self, 1, "Alpha value for the last copy." ))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(8, nodeValue_Bool("Move base", self, false, "Make each copy move the original image." ));
	
	newInput(9, nodeValue_Enum_Scroll("Highlight", self,  0, [ "None", "Color", "Inner pixel" ]));
	
	newInput(10, nodeValue_Color("Highlight color", self, cola(c_white)));
	
	newInput(11, nodeValue_Float("Highlight alpha", self, 1))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(12, nodeValue_Enum_Scroll("Array process", self, 1, [ "Individual", "Combined" ]));
	
	newInput(13, nodeValue_Enum_Scroll("Output dimension type", self, OUTPUT_SCALING.constant, [
																			new scrollItem("Same as input"),
																			new scrollItem("Constant"),
																			new scrollItem("Relative to input").setTooltip("Set dimension as a multiple of input surface."),
																			new scrollItem("Fit content").setTooltip("Automatically set dimension to fit content."),
																		]));
	
	newInput(14, nodeValue_Vec2("Relative dimension", self, [ 1, 1 ]));
	
	newOutput(0, nodeValue_Output("Surface Out", self, VALUE_TYPE.surface, noone));
	
	input_display_list = [
		["Surface",	false],	0, 13, 1, 14, 12, 
		["Stack",	false], 2, 3, 8, 4, 5, 
		["Render",  false], 6, 7, 9, 10, 
	];
	
	attribute_surface_depth();
	
	preview_custom         = false;
	preview_custom_surface = -1;
	preview_custom_index   = noone;
	
	preview_custom_x     = 0;
	preview_custom_x_to  = 0;
	preview_custom_x_max = 0;
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		PROCESSOR_OVERLAY_CHECK
		
		var pos = current_data[4];
		var sck = current_data[3];
		
		var px = _x + pos[0] * _s;
		var py = _y + pos[1] * _s;
		var sx = px + sck[0] * _s * 4;
		var sy = py + sck[1] * _s * 4;
		
		draw_set_color(COLORS._main_accent);
		draw_line(px, py, sx, sy);
		var _hov = false;
		var  hv  = inputs[3].drawOverlay(hover, active, px, py, _s * 4, _mx, _my, _snx, _sny, 1); active &= hv; _hov |= hv;
		var  hv  = inputs[4].drawOverlay(hover, active, _x, _y, _s,     _mx, _my, _snx, _sny);	active &= hv; _hov |= hv;
		var  hv  = inputs[5].drawOverlay(hover, active, px, py, _s,     _mx, _my, _snx, _sny);	active &= hv; _hov |= hv;
		
		return _hov;
	}
	
	static drawPreviewToolOverlay = function(hover, active, _mx, _my, _panel) {
		var _surf = getInputData(0);
		if(!is_array(_surf)) return false;
		
		var _arry = getInputData(12);
		if(_arry == 0) return false;
		
		var prev_size = ui(48);
		var sx  = preview_custom_x + ui(8);
		var sy  = _panel.y1 - ui(8) - prev_size;
		var hov = false;
		
		preview_custom_index = noone;
		preview_custom_x_max = 0;
		
		for( var i = 0, n = array_length(_surf); i < n; i++ ) {
			var _s = _surf[i];
			
			var _sw = surface_get_width_safe(_s);
			var _sh = surface_get_height_safe(_s);
			var _ss = prev_size / max(_sw, _sh);
			var _sx = sx + (prev_size / 2 - _sw * _ss / 2);
			var _sy = sy + (prev_size / 2 - _sh * _ss / 2);
			
			draw_surface_ext_safe(_s, _sx, _sy, _ss, _ss);
			
			if(hover && point_in_rectangle(_mx, _my, _sx - ui(4), _sy, _sx + _sw * _ss + ui(4), _sy + _sh * _ss)) {
				preview_custom_index = i;
				
				draw_set_color(COLORS._main_accent);
			} else 
				draw_set_color(COLORS.panel_preview_surface_outline);
			
			draw_rectangle(_sx, _sy, _sx + _sw * _ss, _sy + _sh * _ss, true);
			
			sx += _sw * _ss + ui(8);
			preview_custom_x_max += _sw * _ss + ui(8);
		}
		
		preview_custom_x_max = max(preview_custom_x_max - _panel.w + ui(64), 0);
		
		var hov = hover && point_in_rectangle(_mx, _my, 0, sy, _panel.x1, _panel.y1);
		
		if(hov) {
			if(mouse_wheel_down()) preview_custom_x_to -= ui(128);
			if(mouse_wheel_up())   preview_custom_x_to += ui(128);
		}
		
		preview_custom_x_to = clamp(preview_custom_x_to, -preview_custom_x_max, 0);
		preview_custom_x    = lerp_float(preview_custom_x, preview_custom_x_to, 5);
		
		return hov;
	}
	
	static preGetInputs = function() {
		var _surf = inputs[ 0].getValue();
		var _arry = inputs[12].getValue();
		
		inputs[0].setArrayDepth(is_array(_surf) && _arry);
	}
	
	static step = function() {
		var _high = getInputData(9);
		var _surf = getInputData(0);
		var _arry = getInputData(12);
		
		inputs[ 2].setVisible(_arry == 0 || !is_array(_surf));
		
		inputs[10].setVisible(_high);
		inputs[11].setVisible(_high);
		
		inputs[12].setVisible(is_array(_surf));
		
		// custom preview
		preview_custom = preview_custom_index != noone && is_array(_surf) && _arry;
		if(preview_custom) drawPreviewCustom();
	}
	
	static drawPreviewCustom = function() {
		var _in  = getSingleValue(0);
		var _dim = getSingleValue(1);
		var _shf = getSingleValue(3);
		
		var _pos = getSingleValue(4);
		var _rot = getSingleValue(5);
		var _col = getSingleValue(6);
		var _alp = getSingleValue(7);
		var _mov = getSingleValue(8);
		
		_pos     = [ _pos[0], _pos[1] ];
		
		if(_mov) {
			_pos[0] -= _shf[0] * _amo;
			_pos[1] -= _shf[1] * _amo;
		}
		
		var _prev_s = noone;
		var _prev_x = noone;
		var _prev_y = noone;
		
		preview_custom_surface = surface_verify(preview_custom_surface, _dim[0], _dim[1]);
		surface_set_target(preview_custom_surface);
			DRAW_CLEAR
			
			for(var i = 0; i < array_length(_in); i++) {
				var index = clamp(i, 0, array_length(_in) - 1);
				var _surf = _in[index];
				if(!is_surface(_surf)) continue;
					
				var _ww = surface_get_width_safe(_surf);
				var _hh = surface_get_height_safe(_surf);
				var _po = point_rotate(0, 0, _ww / 2, _hh / 2, _rot);
				var _aa = i == preview_custom_index? 1 : 0.2;
				
				if(i == preview_custom_index) {
					_prev_s = _surf;
					_prev_x = _po[0] + _pos[0];
					_prev_y = _po[1] + _pos[1];
				}
				
				draw_surface_ext_safe(_surf, _po[0] + _pos[0], _po[1] + _pos[1], 1, 1, _rot, _col, 0.2);
				_pos[0] += _shf[0];
				_pos[1] += _shf[1];
			}
			
			if(is_surface(_prev_s))
				draw_surface_ext_safe(_prev_s, _prev_x, _prev_y, 1, 1, _rot, _col, 1);
		surface_reset_target();
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _surf = _data[0];
		var _dimc = _data[1];
		var _amo  = _data[2];
		var _shf  = _data[3];
		
		var _pos = _data[4];
		var _rot = _data[5];
		var _col = _data[6];
		var _alp = _data[7];
		var _mov = _data[8];
		
		var _hig = _data[ 9];
		var _hiC = _data[10];
		var _hiA = _data[11];
		var _arr = _data[12];
		
		var _dimt = _data[13];
		var _dims = _data[14];
		
		/////////////////////////////////////// ===== DIMENSION
		
		var _sdim = surface_get_dimension(is_array(_surf)? _surf[0] : _surf);
		var _dim = _sdim;
		
		inputs[ 1].setVisible(false);
		inputs[14].setVisible(false);
		
		switch(_dimt) {
			case OUTPUT_SCALING.same_as_input :
				_dim = _sdim;
				break;
				
			case OUTPUT_SCALING.constant :
				inputs[ 1].setVisible(true);
				
				_dim = _dimc;
				break;
				
			case OUTPUT_SCALING.relative :
				inputs[14].setVisible(true);
				
				_dim = [ _sdim[0] * _dims[0], _sdim[1] * _dims[1] ];
				break;
				
		}
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1]);
		var _x, _y;
		
		///////////////////////////////////////
		
		_pos     = [ _pos[0], _pos[1] ];
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1], attrDepth());
		
		if(is_array(_surf) && _arr) _amo = array_length(_surf);
		
		if(_mov) {
			_pos[0] -= _shf[0] * _amo;
			_pos[1] -= _shf[1] * _amo;
		}
		
		surface_set_target(_outSurf);
		DRAW_CLEAR
			if(is_surface(_surf)) {
				var _ww = surface_get_width_safe(_surf);
				var _hh = surface_get_height_safe(_surf);
				var _po = point_rotate(0, 0, _ww / 2, _hh / 2, _rot);
				var aa  = _alp;
				var aa_delta = (1 - aa) / _amo;
				
				_pos[0] += _shf[0] * _amo;
				_pos[1] += _shf[1] * _amo;
					
				for( var i = 0; i < _amo; i++ ) {
					if(_hig && i == _amo - 1) {
						shader_set(sh_replace_color);
						shader_set_i("type",      _hig);
						shader_set_f("dimension", _ww, _hh);
						shader_set_f("shift",     _shf[0] / _ww, _shf[1] / _hh);
						shader_set_f("angle",     degtorad(_rot));
						draw_surface_ext_safe(_surf, _po[0] + _pos[0], _po[1] + _pos[1], 1, 1, _rot, _hiC, _color_get_alpha(_hiC));
						shader_reset();
					} else
						draw_surface_ext_safe(_surf, _po[0] + _pos[0], _po[1] + _pos[1], 1, 1, _rot, _col, _color_get_alpha(_col) * aa);
					_pos[0] -= _shf[0];
					_pos[1] -= _shf[1];
						
					aa += aa_delta;
				}
				
				draw_surface_ext_safe(_surf, _po[0] + _pos[0], _po[1] + _pos[1], 1, 1, _rot, c_white, aa);
				
			} else if(is_array(_surf)) {
				for(var i = 0; i < _amo; i++) {
					var index = clamp(i, 0, array_length(_surf) - 1);
					var _surf = _surf[index];
					if(!is_surface(_surf)) continue;
					
					var _ww = surface_get_width_safe(_surf);
					var _hh = surface_get_height_safe(_surf);
					var _po = point_rotate(0, 0, _ww / 2, _hh / 2, _rot);
					
					draw_surface_ext_safe(_surf, _po[0] + _pos[0], _po[1] + _pos[1], 1, 1, _rot, _col, _color_get_alpha(_col));
					_pos[0] += _shf[0];
					_pos[1] += _shf[1];
				}
			}
		surface_reset_target();
		
		return _outSurf;
	}
	
	static getPreviewValues = function() {
		if(preview_custom && is_surface(preview_custom_surface)) return preview_custom_surface;
		if(preview_channel >= array_length(outputs)) return noone;
		
		switch(outputs[preview_channel].type) {
			case VALUE_TYPE.surface :
			case VALUE_TYPE.dynaSurface :
				break;
			default :
				return;
		}
		
		return outputs[preview_channel].getValue();
	}
}