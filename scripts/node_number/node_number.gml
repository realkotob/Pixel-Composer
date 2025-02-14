function Node_Number(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Number";
	color = COLORS.node_blend_number;
	
	setDimension(96, 48);
	
	// wd_slider = slider(0, 1, 0.01, function(val) { inputs[0].setValue(val); } );
	
	slider_value    = -1;
	slider_surface  = -1;
	slider_dragging = false;
	slider_mx = 0;
	slider_sx = 0;
	slider_m  = 0;
	
	rotator_surface  = -1;
	rotator_dragging = false;
	rotator_s = 0;
	rotator_p = 0;
	rotator_m = 0;
	rotate_dx = 0;
	
	newInput(0, nodeValue_Float("Value", self, 0))
		.setVisible(true, true);
	
	newInput(1, nodeValue_Bool("Integer", self, false));
	
	newInput(2, nodeValue_Enum_Scroll("Display", self, 0, { data: [ "Number", "Slider", "Rotator", "Increment" ], update_hover: false }));
	
	newInput(3, nodeValue_Range("Range", self, [ 0, 1 ]));
	
	newInput(4, nodeValue_Float("Step", self, 0.01));
	
	newInput(5, nodeValue_Bool("Clamp to range", self, false));
	
	newInput(6, nodeValue_Enum_Button("Style", self, 0, { data: [ "Blob", "Flat" ] }));
	
	newInput(7, nodeValue_Float("Rotate speed", self, 1));
	
	newInput(8, nodeValue_Bool("Show on global", self, false, "Whether to show overlay gizmo when not selecting any nodes."));
	
	newInput(9, nodeValue_Vec2("Gizmo offset", self, [ 0, 0 ]));
	
	newInput(10, nodeValue_Float("Gizmo scale", self, 1));
	
	newInput(11, nodeValue_Enum_Scroll("Gizmo style", self, 0, [ "Default", "Shapes", "Sprite" ]));
	
	newInput(12, nodeValue_Enum_Scroll("Gizmo shape", self, 0, [ "Rectangle", "Ellipse", "Arrow" ]));
	
	newInput(13, nodeValue_Surface("Gizmo sprite", self, noone));
	
	newInput(14, nodeValue_Vec2("Gizmo size", self, [ 32, 32 ]));
	
	newOutput(0, nodeValue_Output("Number", self, VALUE_TYPE.float, 0));
	
	input_display_list = [ 0, 1, 
		["Editor",  false], 2, 6, 3, 5, 4, 7,
		["Gizmo",   false], 8, 11, 12, 13, 14, 9, 10,
	];
	
	gz_style  = 0;
	gz_shape  = 0;
	gz_sprite = 0;
	gz_pos    = [ 0, 0 ];
	gz_size   = [ 0, 0 ];
	gz_scale  = 1;
	
	gz_dragging = false;
	gz_drag_sx  = 0;
	gz_drag_mx  = 0;
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _val = getInputData(0);
		var _dsp = getInputData(2);
		if(is_array(_val)) return false;
		
		if(_dsp == 0 || _dsp == 1) inputs[0].display_type = VALUE_DISPLAY._default;
		else if(_dsp == 2)	       inputs[0].display_type = VALUE_DISPLAY.rotation;
		
		var _gx = _x + gz_pos[0] * _s;
		var _gy = _y + gz_pos[1] * _s;
		var _h = false;
		
		if(gz_style == 0) _h = inputs[0].drawOverlay(hover, active, _gx, _gy, _s, _mx, _my, _snx, _sny, 0, gz_scale);
		else {
			var val = inputs[0].getValue();
			
			if(gz_dragging) {
				var _nv = gz_drag_sx + (_mx - gz_drag_mx) / (_s * gz_scale);
				
				if(inputs[0].setValue(_nv)) 
					UNDO_HOLDING = true;
				
				if(mouse_release(mb_left)) {
					gz_dragging = false;
					UNDO_HOLDING = false;
				}
			}
			
			var _rx  = _gx + val * (_s * gz_scale);
			var _ry  = _gy;
			var _rw  = gz_size[0] * _s;
			var _rh  = gz_size[1] * _s;
			var _rx0 = _rx - _rw / 2;
			var _ry0 = _ry - _rh / 2;
			var _rx1 = _rx + _rw / 2;
			var _ry1 = _ry + _rh / 2;
			
			_h = hover && point_in_rectangle(_mx, _my, _rx0, _ry0, _rx1, _ry1);
			
			if(gz_style == 1) {
				draw_set_color(_h || gz_dragging? COLORS._main_accent : COLORS._main_icon);
				draw_set_circle_precision(32);
				
				switch(gz_shape) {
					case 0 : draw_rectangle(_rx0, _ry0, _rx1, _ry1, true); break;
					case 1 : draw_ellipse(_rx0, _ry0, _rx1, _ry1, true);   break;
					case 2 : 
						var _ah = min(_rw, _rh) / 4;
						var _lt = min(_rw, _rh) / 3;
						
						draw_primitive_begin(pr_linestrip); // arrow shape
							draw_vertex(_rx0,       _ry);
							draw_vertex(_rx0 + _ah, _ry0);
							draw_vertex(_rx0 + _ah, _ry0 + _lt);
							draw_vertex(_rx1 - _ah, _ry0 + _lt);
							draw_vertex(_rx1 - _ah, _ry0);
							draw_vertex(_rx1,       _ry);
							draw_vertex(_rx1 - _ah, _ry1);
							draw_vertex(_rx1 - _ah, _ry1 - _lt);
							draw_vertex(_rx0 + _ah, _ry1 - _lt);
							draw_vertex(_rx0 + _ah, _ry1);
							draw_vertex(_rx0,       _ry);
						draw_primitive_end();
						break;
				}
				
			} else if(gz_style == 2) {
				if(is_surface(gz_sprite)) draw_surface_stretched_ext(gz_sprite, _rx0, _ry0, _rw, _rh, c_white, 0.5 + 0.5 * _h);
			}
			
			if(_h && mouse_press(mb_left, active)) {
				gz_dragging = true;
				
				gz_drag_sx = val;
				gz_drag_mx = _mx;
			}
		}
		
		inputs[0].display_type = VALUE_DISPLAY._default;
		
		return _h;
	}
	
	static setType = function() {
		var int  = getInputData(1);
		var disp = getInputData(2);
		var styl = getInputData(6);
		
		var _ww = 96, _hh = 48;
		
		inputs[3].setVisible(disp > 0);
		inputs[4].setVisible(disp > 0);
		inputs[5].setVisible(disp > 0);
		inputs[6].setVisible(disp > 0);
		inputs[7].setVisible(disp == 2);
		
		switch(disp) {
			case 1 : 
				_ww = 160; 
					 if(styl == 0) _hh = 96;
				else if(styl == 1) _hh = 64;
				break;
				
			case 2 : _ww = 128; _hh = 128; break;
			case 3 : _ww = 160; _hh =  64; break;
		}
		
		setDimension(_ww, _hh);
		inputs[0].setType( int? VALUE_TYPE.integer : VALUE_TYPE.float);
		outputs[0].setType(int? VALUE_TYPE.integer : VALUE_TYPE.float);
	}
	
	static processNumber = function(_val, _int) { 
		if(is_numeric(_val)) return _int? round(_val) : _val;
		
		if(is_array(_val)) {
			for (var i = 0, n = array_length(_val); i < n; i++)
				_val[i] = processNumber(_val[i], _int);
		}
		
		return _val;
	}
	
	doUpdate = doUpdateLite;
	static update = function() {
		setType();
		isGizmoGlobal = getInputData( 8);
		gz_pos        = getInputData( 9);
		gz_scale      = getInputData(10);
		gz_style      = getInputData(11);
		gz_shape      = getInputData(12);
		gz_sprite     = getInputData(13);
		gz_size       = getInputData(14);
		
		inputs[12].setVisible(gz_style == 1);
		inputs[13].setVisible(gz_style == 2, gz_style == 2);
		inputs[14].setVisible(gz_style != 0);
		
		var _dat = getInputData(0);
		var _int = getInputData(1);
		
		var _res = processNumber(_dat, _int);
		
		outputs[0].setValue(_res);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var raw  = getInputData(0);
		var _int = getInputData(1);
		var disp = getInputData(2);
		var rang = getInputData(3);
		var stp  = getInputData(4);
		var cmp  = getInputData(5);
		var sty  = getInputData(6);
		var spd  = getInputData(7);
		var _col = getColor();
		
		var val  = outputs[0].getValue();
		
		var bbox = drawGetBbox(xx, yy, _s);
		if(disp == 0 || inputs[0].value_from != noone) {
			draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
			draw_text_bbox(bbox, string_real(val));
			return;
		}
		
		var _minn = rang[0];
		var _maxx = rang[1];
				
		switch(disp) {
			case 1 :
				var _hov  = _hover;
				
				if(sty == 0) {
					slider_value = slider_value == -1? raw : lerp_float(slider_value, raw, 2.5);
					var _prog = clamp((slider_value - _minn) / (_maxx - _minn), 0., 1.);
					
					bbox = drawGetBbox(xx, yy, _s, 2);
					draw_set_text(f_sdf, fa_center, fa_center, _col);
					draw_text_transformed(bbox.xc, bbox.y0 + 16 * _s, string_real(val), _s * 0.5, _s * 0.5, 0);
				
					var sl_w = bbox.w - 8 * _s;
					var sl_h = _s * 40;
					
					var sl_x0 = bbox.x0 + 4 * _s;
					var sl_x1 = sl_x0 + sl_w;
					var sl_y0 = (bbox.y0 + (24 * _s) + bbox.y1) / 2 - sl_h / 2;
					var sl_y1 = sl_y0 + sl_h;
					var _hov  = _hover && point_in_rectangle(_mx, _my, sl_x0, sl_y0, sl_x1, sl_y1);
					
					var c0   = (_hov || slider_dragging)? colorMultiply(CDEF.main_white, _col) : colorMultiply(CDEF.main_grey, _col);
					var c1   = colorMultiply(CDEF.main_dkgrey, _col);
					
					slider_surface = surface_verify(slider_surface, sl_w, sl_h);
					
					surface_set_shader(slider_surface, sh_ui_slider);
						shader_set_color("c0", c0);
						shader_set_color("c1", c1);
						shader_set_dim("dimension", slider_surface);
						shader_set_f("mouseProg", animation_curve_eval(ac_ripple, slider_m));
						shader_set_f("prog", clamp(_prog, 0.1, 0.9));
						
						draw_sprite_stretched(s_fx_pixel, 0, 0, 0, sl_w, sl_h);
					surface_reset_shader();
					
					draw_surface(slider_surface, sl_x0, sl_y0);
					
				} else if(sty == 1) {
					slider_value = raw;
					var _prog = clamp((slider_value - _minn) / (_maxx - _minn), 0., 1.);
					
					var sl_w = bbox.w - 8 * _s;
					var sl_h = bbox.h - 8 * _s;
					
					var sl_x0 = bbox.x0 + 4 * _s;
					var sl_x1 = bbox.x1 - 4 * _s;
					var sl_y0 = bbox.y0 + 4 * _s;
					var sl_y1 = bbox.y1 - 4 * _s;
					var _hov  = _hover && point_in_rectangle(_mx, _my, sl_x0, sl_y0, sl_x1, sl_y1);
					
					draw_sprite_stretched_ext(THEME.textbox, 3,    sl_x0, sl_y0, sl_w,         sl_h + 1, _col, 1);
					draw_sprite_stretched_ext(THEME.textbox, 4,    sl_x0, sl_y0, sl_w * _prog, sl_h + 1, _col, 1);
					draw_sprite_stretched_ext(THEME.textbox, _hov || slider_dragging, sl_x0, sl_y0, sl_w, sl_h + 1, _col, 1);
					
					draw_set_text(f_sdf, fa_center, fa_center, _col);
					draw_text_transformed(bbox.xc, bbox.yc + 2, string_real(val), _s * 0.5, _s * 0.5, 0);
					
				}
				
				if(slider_dragging) {
					slider_m = lerp_float(slider_m, 1, 4);
					
					var _valM = (_mx - sl_x0) / (sl_x1 - sl_x0);
					var _valL = lerp(_minn, _maxx, _valM);
					    _valL = value_snap(_valL, stp);
					if(cmp) _valL = clamp(_valL, _minn, _maxx);
					
					if(inputs[0].setValue(_valL))
						UNDO_HOLDING = true;
					
					if(mouse_release(mb_left)) {
						slider_dragging = false;
						UNDO_HOLDING    = false;
					}
				} else 
					slider_m = lerp_float(slider_m, 0, 5);
				
				if(_hov) {
					if(mouse_press(mb_left, _focus) && is_real(raw)) {
						slider_dragging = true;
						slider_mx = _mx;
						slider_sx = raw;
					}
					
					draggable = false;
				}
				
				break;
				
			case 2 :
				var _ss  = min(bbox.w, bbox.h);
				var _dst = point_distance(_mx, _my, bbox.xc, bbox.yc);
				var _x0  = bbox.xc - _ss / 2;
				var _y0  = bbox.yc - _ss / 2;
				
				if(sty == 0) {
					var c0   = (draggable && !rotator_dragging)? colorMultiply(CDEF.main_grey, _col) : colorMultiply(CDEF.main_white, _col);
					var c1   = colorMultiply(CDEF.main_dkgrey, _col);
				
					rotator_surface = surface_verify(rotator_surface, _ss, _ss);
					
					surface_set_shader(rotator_surface, sh_ui_rotator);
						shader_set_color("c0", c0);
						shader_set_color("c1", c1);
						shader_set_f("angle", degtorad(raw));
						shader_set_f("mouse", (_mx - _x0) / _ss, (_my - _y0) / _ss);
						shader_set_f("mouseProg", animation_curve_eval(ac_ripple, rotator_m));
						
						draw_sprite_stretched(s_fx_pixel, 0, 0, 0, _ss, _ss);
					surface_reset_shader();
					
					draw_surface(rotator_surface, _x0, _y0);
					
				} else if(sty == 1) {
					var c0   = (draggable && !rotator_dragging)? colorMultiply(CDEF.main_grey, _col) : colorMultiply(CDEF.main_white, _col);
					var c1   = colorMultiply(merge_color(CDEF.main_grey, CDEF.main_dkgrey, .5), _col);
				
					var _r = _ss / 2 - 10 * _s;
					draw_circle_ui(bbox.xc, bbox.yc, _r, .04, cola(c1));
					
					var _knx =  bbox.xc + lengthdir_x(_r - 12 * _s, raw);
					var _kny =  bbox.yc + lengthdir_y(_r - 12 * _s, raw);
					
					draw_circle_ui(_knx, _kny, 6 * _s, 0, cola(c0));
				}
				
				if(rotator_dragging) {
					rotator_m = lerp_float(rotator_m, 1, 4);
					var dir = point_direction(bbox.xc, bbox.yc, _mx, _my);
					var dx  = angle_difference(dir, rotator_p);
					rotate_dx += dx;
					rotator_p = dir;
					
					var _val = rotator_s + rotate_dx * spd;
					    _val = value_snap(_val, stp);
					if(cmp) _val = clamp(_val, _minn, _maxx);
					
					if(inputs[0].setValue(_val))
						UNDO_HOLDING = true;
					
					if(mouse_release(mb_left)) {
						rotator_dragging = false;
						UNDO_HOLDING     = false;
					}
				} else 
					rotator_m = lerp_float(rotator_m, 0, 5);
				
				if(_hover && point_in_circle(_mx, _my, bbox.xc, bbox.yc, _ss / 2)) {
					if(mouse_press(mb_left, _focus) && is_real(raw)) {
						rotator_dragging = true;
						rotator_s = raw;
						rotator_p = point_direction(bbox.xc, bbox.yc, _mx, _my);
						rotate_dx = 0;
					}
					
					draggable = false;
				}
				
				draw_set_text(f_sdf, fa_center, fa_center, _col);
				draw_text_transformed(bbox.xc, bbox.yc, string_real(val, 999, 3), _s * .5, _s * .5, 0);
				break;
				
			case 3 :
				var bw = 32 * _s;
				var bh = bbox.h  - 8 * _s;
				var bx = bbox.x0 + 4 * _s;
				var by = bbox.y0 + 4 * _s;
				var cc = colorMultiply(CDEF.main_white, _col);
				
				var b = buttonInstant(THEME.button_def, bx, by, bw, bh, [ _mx, _my ], _hover, _focus, "", THEME.minus, 0, COLORS._main_value_negative, 1, .75 * _s, cc);
				if(b) draggable = false;
				if(b == 2) {
					val -= stp;
					if(cmp) val = clamp(val, _minn, _maxx);
					inputs[0].setValue(val);
				}
				
				var bx = bbox.x1 - 4 * _s - bw;
				var b = buttonInstant(THEME.button_def, bx, by, bw, bh, [ _mx, _my ], _hover, _focus, "", THEME.add, 0, COLORS._main_value_positive, 1, .75 * _s, cc);
				if(b) draggable = false;
				if(b == 2) {
					val += stp;
					if(cmp) val = clamp(val, _minn, _maxx);
					inputs[0].setValue(val);
				}
				
				draw_set_text(f_sdf, fa_center, fa_center, _col);
				draw_text_transformed(bbox.xc, bbox.yc + 2, string_real(val), _s * 0.5, _s * 0.5, 0);
				break;
				
		}
	}
	
}