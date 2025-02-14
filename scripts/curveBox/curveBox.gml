function curveBox(_onModify) : widget() constructor {
	onModify   = _onModify;
	curr_data  = [];
	anc_mirror = [];
	h = 200;
	
	curve_surface = surface_create(1, 1);
	node_dragging = -1;
	node_drag_typ = -1;
	node_drag_break = false;
	
	height_drag   = false;
	height_my     = 0;
	height_ss     = 0;
	show_coord    = false;
	
	minx = 0; maxx = 1;
	miny = 0; maxy = 1;
	
	dragging = 0;
	drag_m   = 0;
	drag_s   = 0;
	drag_h   = 0;
	progress_draw = -1;
	
	display_pos_x = 0;
	display_pos_y = 0;
	display_sel   = 0;
	
	grid_snap = false;
	grid_step = 0.10;
	grid_show = true;
	
	scale_control = true;
	control_zoom  = 64;
	
	selecting   = noone;
	select_type = 0;
	
	cw = 0;
	ch = 0;
	
	tb_shift = new textBox(TEXTBOX_INPUT.number, function(val) { var _data = array_clone(curr_data); _data[0] = val; onModify(_data); });
	tb_scale = new textBox(TEXTBOX_INPUT.number, function(val) { var _data = array_clone(curr_data); _data[1] = val; onModify(_data); });
	
	tb_shift.label = "Shift";
	tb_scale.label = "Scale";
	
	static get_x = function(val) { return cw *      (val - minx) / (maxx - minx) ; }
	static get_y = function(val) { return ch * (1 - (val - miny) / (maxy - miny)); }
	
	static setInteract = function(interactable = noone) {
		self.interactable = interactable;
		
		tb_shift.setInteract(interactable);
		tb_scale.setInteract(interactable);
	}
	
	static register = function(parent = noone) {
		self.parent = parent;
		tb_shift.register(parent);
		tb_scale.register(parent);
	}
	
	static isHovering = function() { 
		if(tb_shift.isHovering()) return true;
		if(tb_scale.isHovering()) return true;
		
		return hovering;
	}
	
	static drawParam = function(params) {
		rx = params.rx;
		ry = params.ry;
		tb_shift.setParam(params);
		tb_scale.setParam(params);
		
		return draw(params.x, params.y, params.w, params.data, params.m);
	}
	
	static draw = function(_x, _y, _w, _data, _m) {
		x = _x; 
		y = _y;
		w = _w; 
		
		if(!is_array(_data) || array_length(_data) == 0) return 0;
		if(is_array(_data[0])) return 0;
		
		var _h = h - ui(4);
		
		var _amo = array_length(_data);
		    _shf = _amo % 6;
		var points = (_amo - _shf) / 6;
		
		var _shift = 0;
		var _scale = 1;
		
		var zoom_size = ui(12);
		var zoom_padd = zoom_size + ui(8);
		
		var tbh = line_get_height(font) + ui(4);
		
		cw = _w - zoom_padd;
		ch = _h - zoom_padd - (tbh + ui(4)) * bool(_shf);
		
		hovering  = false;
		curr_data = _data;
			 if(_shf == 1) { _shift = _data[0]; } 
		else if(_shf == 2) { _shift = _data[0]; _scale = _data[1]; }
		
		display_pos_x = lerp(minx, maxx,     (_m[0] - _x) / cw);
		display_pos_y = lerp(miny, maxy, 1 - (_m[1] - _y) / ch);
		display_sel   = false;
		
		curve_surface = surface_verify(curve_surface, cw, ch);
		
		if(node_dragging != -1) { // editing
			show_coord = true;
			_data = array_clone(_data);
			
			if(node_drag_typ == 0) { //anchor
				
				var _mx = (_m[0] - _x) / cw;
					_mx = clamp(_mx * (maxx - minx) + minx, 0, 1);
						
				var _my = 1 - (_m[1] - _y) / ch;
					_my = clamp(_my * (maxy - miny) + miny, 0, 1);
					
				var node_point = (node_dragging - _shf - 2) / 6;
				if(node_point > 0 && node_point < points - 1) {
					
					if(key_mod_press(CTRL) || grid_snap)
						_mx = value_snap(_mx, grid_step);
					
					var bfx = _data[node_dragging - 6];
					var afx = _data[node_dragging + 6];
					
					if(_mx > bfx && _mx < afx) _data[node_dragging + 0] = _mx;
				}
				
				if(key_mod_press(CTRL) || grid_snap) 
					_my = value_snap(_my, grid_step);
				_data[node_dragging + 1] = _my;
				
				display_pos_x = _data[node_dragging + 0];
				display_pos_y = _data[node_dragging + 1];
				display_sel   = 1;
				
				if(onModify(_data))
					UNDO_HOLDING = true;
					
			} else { //control
			
				var _px = _data[node_dragging + 0];
				var _py = _data[node_dragging + 1];
				
				var _mx = (_m[0] - _x) / cw;
					_mx = clamp(lerp(minx, maxx, _mx), 0, 1);
					
				var _my = 1 - (_m[1] - _y) / ch;
					_my = lerp(miny, maxy, _my);
				
				var _scax = scale_control? (node_drag_typ > 0? _data[node_dragging + 6] - _px : _px - _data[node_dragging - 6]) : control_zoom / cw;
				var _scay = scale_control? _scax : control_zoom / ch;
				
				if(key_mod_press(CTRL) || grid_snap) _mx = value_snap(_mx, grid_step);
				if(key_mod_press(CTRL) || grid_snap) _my = value_snap(_my, grid_step);
					
				if(node_drag_break) {
					if(node_drag_typ == 1) {
						_data[node_dragging + 2] = (_mx - _px) * node_drag_typ / _scax;
						_data[node_dragging + 3] = clamp(_my - _py, -1, 1) * node_drag_typ / _scay;	
						
					} else {
						_data[node_dragging - 2] = (_px - _mx) * node_drag_typ / _scax;
						_data[node_dragging - 1] = clamp(_py - _my, -1, 1) * node_drag_typ / _scay;
						
					}
					
				} else {
					_data[node_dragging - 2] = (_px - _mx) * node_drag_typ / _scax;
					_data[node_dragging + 2] = (_mx - _px) * node_drag_typ / _scax;
					
					_data[node_dragging - 1] = clamp(_py - _my, -1, 1) * node_drag_typ / _scay;
					_data[node_dragging + 3] = clamp(_my - _py, -1, 1) * node_drag_typ / _scay;
				}
				
				display_pos_x = node_drag_typ? _data[node_dragging - 2] : _data[node_dragging + 2];
				display_pos_y = node_drag_typ? _data[node_dragging - 1] : _data[node_dragging + 3];
				display_sel   = 2;
				
				if(onModify(_data))
					UNDO_HOLDING = true;
			} 
			
			if(mouse_release(mb_left)) {
				node_dragging = -1;
				node_drag_typ = -1;
				
				UNDO_HOLDING = false;
			}
		}
		
		var node_hovering  = -1;
		var node_hover_typ = -1;
		var point_insert   = 1;
		var _x1 = 0;
		
		var msx = _m[0] - _x;
		var msy = _m[1] - _y;
		
		#region ==== draw curve ====
			surface_set_target(curve_surface);
				DRAW_CLEAR
				
				draw_set_color(COLORS.widget_curve_line);
				draw_set_alpha(0.5);
				
				if(grid_show) {
					var st = max(grid_step, 0.02);
					
					for( var i = st; i < 1; i += st ) {
						var y0 = ch * (1 - (i - miny) / (maxy - miny));
						draw_line(0, y0, cw, y0);
						
						var x0 = cw * (i - minx) / (maxx - minx);
						draw_line(x0, get_y(0), x0, get_y(1));
					}
				}
				
				var y0 = ch - ch * (0 - miny) / (maxy - miny);
				var y1 = ch - ch * (1 - miny) / (maxy - miny);
				
				draw_set_alpha(0.9);
				draw_line(0, y0, cw, y0);
				draw_line(0, y1, cw, y1);
				draw_set_alpha(1);
				
				if(progress_draw > -1) {
					var _prg = clamp(progress_draw, 0, 1);
					var _px  = get_x(cw * _prg);
					
					draw_set_color(COLORS.widget_curve_line);
					draw_line(_px, 0, _px, ch);
				}
				
				if(_shf) {
					draw_set_color(merge_color(COLORS._main_icon, COLORS._main_icon_dark, 0.5));
					draw_curve(0, 0, cw, ch, _data, minx, maxx, miny, maxy, _shift, _scale);
				}
				
				for( var i = 0; i < points; i++ ) {
					var ind = _shf + i * 6;
					var _x0 = _data[ind + 2];
					var _y0 = _data[ind + 3];
					
					var _sca_bx = scale_control? (i > 0?          _x0 - _data[ind - 6 + 2] : 1) : control_zoom / cw;
					var _sca_by = scale_control? _sca_bx : control_zoom / ch;
					
					var _sca_ax = scale_control? (i < points - 1? _data[ind + 6 + 2] - _x0 : 1) : control_zoom / cw;
					var _sca_ay = scale_control? _sca_ax : control_zoom / ch;
					
					var bx0 = _x0 + _data[ind + 0] * _sca_bx;
					var by0 = _y0 + _data[ind + 1] * _sca_by;
					var ax0 = _x0 + _data[ind + 4] * _sca_ax;
					var ay0 = _y0 + _data[ind + 5] * _sca_ay;
					
					// print($"{_x0}, {_y0} | {_data[ind + 0]}, {_data[ind + 1]} | {_data[ind + 4]}, {_data[ind + 5]}");
					
					bx0 = get_x(bx0);
					by0 = get_y(by0);
					_x0 = get_x(_x0);
					_y0 = get_y(_y0);
					ax0 = get_x(ax0);
					ay0 = get_y(ay0);
				
					draw_set_color(COLORS.widget_curve_line);
					if(i > 0) { //draw pre line
						draw_line(bx0, by0, _x0, _y0);
					
						draw_circle_prec(bx0, by0, 3, false);
						if(hover && point_in_circle(msx, msy, bx0, by0, 10)) {
							draw_circle_prec(bx0, by0, 5, false);
							node_hovering = ind + 2;
							node_hover_typ = -1;
							
							display_pos_x = _data[ind + 0];
							display_pos_y = _data[ind + 1];
							display_sel   = 2;
						}
					}
			
					if(i < points - 1) { //draw post line
						draw_line(ax0, ay0, _x0, _y0);
				
						draw_circle_prec(ax0, ay0, 3, false);
						if(hover && point_in_circle(msx, msy, ax0, ay0, 10)) {
							draw_circle_prec(ax0, ay0, 5, false);
							node_hovering = ind + 2;
							node_hover_typ = 1;
							
							display_pos_x = _data[ind + 4];
							display_pos_y = _data[ind + 5];
							display_sel   = 2;
						}
					}
			
					draw_set_color(COLORS._main_accent);
					draw_circle_prec(_x0, _y0, 3, false);
					if(hover && point_in_circle(msx, msy, _x0, _y0, 10)) {
						draw_circle_prec(_x0, _y0, 5, false);
						node_hovering = ind + 2;
						node_hover_typ = 0;
							
						display_pos_x = _data[ind + 2];
						display_pos_y = _data[ind + 3];
						display_sel   = 1;
					}
			
					if(msx >= _x1 && msy <= _x0)
						point_insert = i;
					_x1 = _x0;
				}
		
				draw_set_color(COLORS._main_accent);
				draw_curve(0, 0, cw, ch, _data, minx, maxx, miny, maxy);
			
			surface_reset_target();
		#endregion
		
		#region ==== view controls ====
			
			var hov = 0;
			var bs  = zoom_size;
			
			var zminy = 0 - 1;
			var zmaxy = 1 + 1;
			
			var byH = ch;
			
			var bx  = _x + w - bs;
			var by  = _y;
			var zy0 = by + bs / 2 + (byH - bs) * (1 - (miny - zminy) / (zmaxy - zminy));
			var zy1 = by + bs / 2 + (byH - bs) * (1 - (maxy - zminy) / (zmaxy - zminy));
			
			if(dragging) {
				var _mdy = (drag_m[1] - _m[1]) / (byH - bs) * 2;
				
				if(dragging == 1 || dragging == 3) miny = clamp(drag_s[0] + _mdy, zminy, min(maxy - 0.1, zmaxy));
				if(dragging == 2 || dragging == 3) maxy = clamp(drag_s[1] + _mdy, max(miny + 0.1, zminy), zmaxy);
				
				if(mouse_release(mb_left))
					dragging = false;
			} 
			
				 if(point_in_rectangle(_m[0], _m[1], bx, zy0 - bs / 2, bx + bs, zy0 + bs / 2))
				hov = 1;
			else if(point_in_rectangle(_m[0], _m[1], bx, zy1 - bs / 2, bx + bs, zy1 + bs / 2))
				hov = 2;
			else if(point_in_rectangle(_m[0], _m[1], bx, zy1 - bs / 2, bx + bs, zy0 + bs / 2))
				hov = 3;
				
			draw_sprite_stretched_ext(THEME.box_r2, 0, bx, by, bs, byH, CDEF.main_black, 1);
			draw_sprite_stretched_ext(THEME.box_r2, 0, bx, zy1, bs, zy0 - zy1, drag_h == 3? merge_color(CDEF.main_dkgrey, CDEF.main_grey, 0.4) : CDEF.main_dkgrey, 1);
			
			draw_sprite_stretched_ext(THEME.box_r2, 0, bx, zy0 - bs / 2, bs, bs, drag_h == 1? COLORS._main_icon_light : COLORS._main_icon, 1);
			draw_sprite_stretched_ext(THEME.box_r2, 0, bx, zy1 - bs / 2, bs, bs, drag_h == 2? COLORS._main_icon_light : COLORS._main_icon, 1);
			
			var zminx = 0;
			var zmaxx = 1;
			
			var bxW = _w - zoom_padd;
			var bx  = _x;
			var by  = _y + _h - bs - (tbh + ui(4)) * bool(_shf);
			
			var zx0 = bx + bs / 2 + (bxW - bs) * (minx - zminx) / (zmaxx - zminx);
			var zx1 = bx + bs / 2 + (bxW - bs) * (maxx - zminx) / (zmaxx - zminx);
			
			if(dragging) {
				var _mdx = (_m[0] - drag_m[0]) / (bxW - bs);
				
				if(dragging == 4 || dragging == 6) minx = clamp(drag_s[2] + _mdx, zminx, min(maxx - 0.1, zmaxx));
				if(dragging == 5 || dragging == 6) maxx = clamp(drag_s[3] + _mdx, max(minx + 0.1, zminx), zmaxx);
				
				if(mouse_release(mb_left))
					dragging = false;
			} 
			
				 if(point_in_rectangle(_m[0], _m[1], zx0 - bs / 2, by, zx0 + bs / 2, by + bs))
				hov = 4;
			else if(point_in_rectangle(_m[0], _m[1], zx1 - bs / 2, by, zx1 + bs / 2, by + bs))
				hov = 5;
			else if(point_in_rectangle(_m[0], _m[1], zx0 - bs / 2, by, zx1 + bs / 2, by + bs))
				hov = 6;
				
			draw_sprite_stretched_ext(THEME.box_r2, 0, bx, by, bxW, bs, CDEF.main_black, 1);
			draw_sprite_stretched_ext(THEME.box_r2, 0, zx0, by, zx1 - zx0, bs, drag_h == 6? merge_color(CDEF.main_dkgrey, CDEF.main_grey, 0.4) : CDEF.main_dkgrey, 1);
			
			draw_sprite_stretched_ext(THEME.box_r2, 0, zx0 - bs / 2, by, bs, bs, drag_h == 4? COLORS._main_icon_light : COLORS._main_icon, 1);
			draw_sprite_stretched_ext(THEME.box_r2, 0, zx1 - bs / 2, by, bs, bs, drag_h == 5? COLORS._main_icon_light : COLORS._main_icon, 1);
			
			drag_h = hov;
			if(mouse_press(mb_left, hov && active)) {
				dragging = hov;
				drag_m   = [ _m[0], _m[1] ];
				drag_s   = [ miny, maxy, minx, maxx ];
			}
			
			if(dragging == 10) {
				var _mdx = (_m[0] - drag_m[0]) / (bxW - bs);
				var _mdy = (drag_m[1] - _m[1]) / (byH - bs) * 2;
				
				var zw = drag_s[3] - drag_s[2];
				var zh = drag_s[1] - drag_s[0];
				
				var cx = clamp((drag_s[3] + drag_s[2]) / 2 - _mdx, zminx + zw / 2, zmaxx - zw / 2);
				var cy = clamp((drag_s[1] + drag_s[0]) / 2 - _mdy, zminy + zh / 2, zmaxy - zh / 2);
				
				minx = cx - zw / 2;
				maxx = cx + zw / 2;
				
				miny = cy - zh / 2;
				maxy = cy + zh / 2;
				
				if(mouse_release(mb_middle))
					dragging = false;
			}
					
			if(point_in_rectangle(_m[0], _m[1], _x, _y, _x + cw, _y + ch) && mouse_press(mb_middle, active)) {
				dragging = 10;
				drag_m   = [ _m[0], _m[1] ];
				drag_s   = [ miny, maxy, minx, maxx ];
			}
			
			var _bhx = _x + _w - bs;
			var _bhy = _y + _h - bs - (tbh + ui(4)) * bool(_shf);
			var _hov = false;
			
			if(point_in_rectangle(_m[0], _m[1], _bhx, _bhy, _bhx + bs, _bhy + bs)) {
				_hov = true;
				if(mouse_press(mb_left, active)) {
					dragging = hov;
					
					height_drag = true;
					height_my   = _m[1];
					height_ss   = h;
				}
				
			}
			draw_sprite_stretched_ext(THEME.box_r2, 0, _bhx, _bhy, bs, bs, _hov? COLORS._main_icon : CDEF.main_dkgrey, 1);
			
			if(height_drag) {
				h = height_ss + _m[1] - height_my;
				h = max(100, h);
				
				if(mouse_release(mb_left))
					height_drag = false;
			}
		#endregion
		
		if(hover && point_in_rectangle(_m[0], _m[1], _x, _y, _x + cw, _y + ch)) {
			show_coord = true;
			hovering   = true;
			
			if(mouse_press(mb_left, active)) {
				if(node_hovering == -1) {
					var _ind = _shf + point_insert * 6;
					var _px =     (_m[0] - _x) / cw;
					var _py = 1 - (_m[1] - _y) / ch;
					
					array_insert(_data, _ind + 0, -1 / 3);
					array_insert(_data, _ind + 1, 0);
					array_insert(_data, _ind + 2, _px);
					array_insert(_data, _ind + 3, _py);
					array_insert(_data, _ind + 4, 1 / 3);
					array_insert(_data, _ind + 5, 0);
					
					if(onModify(_data))
						UNDO_HOLDING = true;
					
					node_dragging = _ind + 2;
					node_drag_typ = 0;
					
				} else {
					node_dragging = node_hovering;
					node_drag_typ = node_hover_typ;
					
					if(node_hover_typ != 0) {
						var _cax = _data[node_dragging - 2];
						var _cay = _data[node_dragging - 1];
						var _cbx = _data[node_dragging + 2];
						var _cby = _data[node_dragging + 3];
						
						node_drag_break = key_mod_press(SHIFT);
						
						if(_cax != -_cbx || _cay != -_cby)
							node_drag_break = true;
					}
				}
				
			} else if(mouse_press(mb_right, active)) {
				// var node_point = (node_hovering - _shf - 2) / 6;
				// if(node_hover_typ == 0 && node_point > 0 && node_point < points - 1) {
				// 	array_delete(_data, _shf + node_point * 6, 6);
				// 	if(onModify(_data)) UNDO_HOLDING = true;
				// }
			}
			
			if(mouse_press(mb_right, active)) {
				var rmx = rx + _m[0];
				var rmy = ry + _m[1];
				
				if(node_hovering == -1 || node_hover_typ != 0) {
					menuCall("widget_curve", [
						menuItemGroup(__txt("Presets"), [ 
							[ [THEME.curve_presets, 0], function() /*=>*/ { onModify(CURVE_DEF_00); } ],
							[ [THEME.curve_presets, 1], function() /*=>*/ { onModify(CURVE_DEF_11); } ],
							[ [THEME.curve_presets, 2], function() /*=>*/ { onModify(CURVE_DEF_01); } ],
							[ [THEME.curve_presets, 3], function() /*=>*/ { onModify(CURVE_DEF_10); } ],
						]),
						-1,
						menuItem(__txt("Reset View"), function() /*=>*/ { 
							minx = 0; maxx = 1;
							miny = 0; maxy = 1;
						}),
						menuItem(__txt("Grid"),         function() /*=>*/ { grid_show = !grid_show; }, noone, noone, function() /*=>*/ {return grid_show}),
						menuItem(__txt("Snap to grid"), function() /*=>*/ { grid_snap = !grid_snap; }, noone, noone, function() /*=>*/ {return grid_snap}),
						menuItemGroup(__txt("Grid size"), [
							[ "1%",  function() /*=>*/ { grid_step = 0.01; } ],
							[ "5%",  function() /*=>*/ { grid_step = 0.05; } ],
							[ "10%", function() /*=>*/ { grid_step = 0.10; } ],
							[ "25%", function() /*=>*/ { grid_step = 0.25; } ],
						]),
						menuItem(__txt("Scale Controls"), function() /*=>*/ { scale_control = !scale_control; }, noone, noone, function() /*=>*/ {return scale_control} ),
					], rmx, rmy);
					
				} else {
					selecting   = node_hovering;
					select_type = node_hover_typ;
					select_data = _data;
					
					var node_point = (selecting - _shf - 2) / 6;
					var _menu = [];
					
					array_push(_menu, menuItem(__txt("Reset Controls"), function() /*=>*/ { 
						var node_point = (selecting - _shf - 2) / 6;
						var _ind  = _shf + node_point * 6;
						
						select_data[@ _ind + 0] = -1 / 3;
						select_data[@ _ind + 1] = 0;
						select_data[@ _ind + 4] = 1 / 3;
						select_data[@ _ind + 5] = 0;
						onModify(select_data);
					}));
					
					if(node_point > 0 && node_point < points - 1) {
						array_push(_menu, menuItem(__txt("Delete Anchor"), function() /*=>*/ { 
							var node_point = (selecting - _shf - 2) / 6;
							array_delete(select_data, _shf + node_point * 6, 6);
							onModify(select_data);
						}, THEME.cross));
					}
					
					menuCall("widget_curve", _menu, rmx, rmy);
				}
			}
		}
			
		draw_surface(curve_surface, _x, _y);
		
		draw_set_color(COLORS.widget_curve_outline);
		draw_rectangle(_x, _y, _x + cw, _y + ch, true);
		
		if(show_coord) {
			var tx = _x + cw - ui(6);
			var ty = _y + ch - ui(6);
			
			draw_set_text(f_p2, fa_right, fa_bottom, display_sel? COLORS._main_text: COLORS._main_text_sub);
			draw_text_add(tx, ty, $"{display_sel == 2? "dy" : "y"}: {string_format(display_pos_y * 100, -1, 2)}%");
			
			ty -= line_get_height();
			draw_text_add(tx, ty, $"{display_sel == 2? "dx" : "x"}: {string_format(display_pos_x * 100, -1, 2)}%");
		}
		
		show_coord = false;
		
		if(_shf) {
			var tby = _y + h - tbh;
			var tbw = _w / 2;
			
			tb_shift.setFocusHover(active, hover);
			tb_scale.setFocusHover(active, hover);
			
			tb_shift.hide = true;
			tb_scale.hide = true;
				
			draw_sprite_stretched_ext(THEME.textbox, 3, _x, tby, _w, tbh, c_white, 1);
			draw_sprite_stretched_ext(THEME.textbox, 0, _x, tby, _w, tbh, c_white, 0.5 + 0.5 * interactable);	
			
			tb_shift.draw(_x,       tby, tbw, tbh, _data[0], _m);
			tb_scale.draw(_x + tbw, tby, tbw, tbh, _data[1], _m);
		}
		
		resetFocus();
		
		return h;
	}
	
	static clone = function() {
		var cln = new curveBox(onModify);
		return cln;
	}

	static free = function() {
		surface_free_safe(curve_surface);
	}
}