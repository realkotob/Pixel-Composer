function canvas_tool_brush(brush, eraser = false) : canvas_tool() constructor {
	self.brush = brush;
	isEraser   = eraser;
	
	brush_resizable = true;
	
	mouse_cur_x  = 0;
	mouse_cur_y  = 0;
	mouse_cur_tx = 0;
	mouse_cur_ty = 0;
	mouse_pre_x  = 0;
	mouse_pre_y  = 0;
	mouse_pre_draw_x = undefined;
	mouse_pre_draw_y = undefined;
	
	mouse_line_drawing = false;
	mouse_line_x0 = 0;
	mouse_line_y0 = 0;
	mouse_line_x1 = 0;
	mouse_line_y1 = 0;
	
	brush_warp   = false;
	warp_block_x  = 0;
	warp_block_y  = 0;
	warp_block_px = 0;
	warp_block_py = 0;
	
	draw_w = 1;
	draw_h = 1;
	
	function draw_point_wrap(_draw = true) {
		var _oxn = mouse_cur_tx - brush.brush_range < 0;
		var _oxp = mouse_cur_tx + brush.brush_range > draw_w;
		var _oyn = mouse_cur_ty - brush.brush_range < 0;
		var _oyp = mouse_cur_ty + brush.brush_range > draw_h;
		
		if(brush.tileMode & 0b01) {
			     if(_oxn) canvas_draw_point_brush(brush, draw_w + mouse_cur_tx, mouse_cur_ty, _draw);
			else if(_oxp) canvas_draw_point_brush(brush, mouse_cur_tx - draw_w, mouse_cur_ty, _draw);
		}
		
		if(brush.tileMode & 0b10) {
			     if(_oyn) canvas_draw_point_brush(brush, mouse_cur_tx, draw_h + mouse_cur_ty, _draw);
			else if(_oyp) canvas_draw_point_brush(brush, mouse_cur_tx, mouse_cur_ty - draw_h, _draw);
		}
		
		if(brush.tileMode == 0b11) {
			     if(_oxn && _oyn) canvas_draw_point_brush(brush, draw_w + mouse_cur_tx, draw_h + mouse_cur_ty, _draw);
			else if(_oxn && _oyp) canvas_draw_point_brush(brush, draw_w + mouse_cur_tx, mouse_cur_ty - draw_h, _draw);
			
			else if(_oxp && _oyn) canvas_draw_point_brush(brush, mouse_cur_tx - draw_w, draw_h + mouse_cur_ty, _draw);
			else if(_oxp && _oyp) canvas_draw_point_brush(brush, mouse_cur_tx - draw_w, mouse_cur_ty - draw_h, _draw);
		}
		
		canvas_draw_point_brush(brush, mouse_cur_tx, mouse_cur_ty, _draw);
	}
	
	function draw_line_wrap(_draw = true) {
		if(!brush_warp) canvas_draw_line_brush(brush, mouse_pre_draw_x, mouse_pre_draw_y, mouse_cur_tx, mouse_cur_ty, _draw);
		else {
			if(warp_block_x > warp_block_px) {
				canvas_draw_line_brush(brush, mouse_pre_draw_x, mouse_pre_draw_y, draw_w + mouse_cur_tx, mouse_cur_ty, _draw);
				canvas_draw_line_brush(brush, mouse_pre_draw_x - draw_w, mouse_pre_draw_y, mouse_cur_tx, mouse_cur_ty, _draw);
			} else if(warp_block_x < warp_block_px) {
				canvas_draw_line_brush(brush, mouse_pre_draw_x, mouse_pre_draw_y, mouse_cur_tx - draw_w, mouse_cur_ty, _draw);
				canvas_draw_line_brush(brush, draw_w + mouse_pre_draw_x, mouse_pre_draw_y, mouse_cur_tx, mouse_cur_ty, _draw);
			}
			
			if(warp_block_y > warp_block_py) {
				canvas_draw_line_brush(brush, mouse_pre_draw_x, mouse_pre_draw_y, mouse_cur_tx, draw_h + mouse_cur_ty, _draw);
				canvas_draw_line_brush(brush, mouse_pre_draw_x, mouse_pre_draw_y - draw_h, mouse_cur_tx, mouse_cur_ty, _draw);
			} else if(warp_block_y < warp_block_py) {
				canvas_draw_line_brush(brush, mouse_pre_draw_x, mouse_pre_draw_y, mouse_cur_tx, mouse_cur_ty - draw_h, _draw);
				canvas_draw_line_brush(brush, mouse_pre_draw_x, draw_h + mouse_pre_draw_y, mouse_cur_tx, mouse_cur_ty, _draw);
			}
			
		}
	}
	
	function step(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		
		mouse_cur_x = round((_mx - _x) / _s - 0.5);
		mouse_cur_y = round((_my - _y) / _s - 0.5);
		
		if(mouse_pre_draw_x != undefined && mouse_pre_draw_y != undefined && key_mod_presses(SHIFT, CTRL)) {
			
			var _dx = mouse_cur_x - mouse_pre_draw_x;
			var _dy = mouse_cur_y - mouse_pre_draw_y;
			
			if(_dx != _dy) {
				var _ddx = _dx;
				var _ddy = _dy;
				
				if(abs(_dx) > abs(_dy)) {
					var _rat = round(_ddx / _ddy);
					_ddx = _ddy * _rat;
					
				} else if(abs(_dx) < abs(_dy)) {
					var _rat = round(_ddy / _ddx);
					_ddy = _ddx * _rat;
					
				}
				
				mouse_cur_x = mouse_pre_draw_x + _ddx - sign(_ddx);
				mouse_cur_y = mouse_pre_draw_y + _ddy - sign(_ddy);
			}
		}
			
		mouse_cur_tx = mouse_cur_x;
		mouse_cur_ty = mouse_cur_y;
		draw_w = surface_get_width(drawing_surface);
		draw_h = surface_get_height(drawing_surface);
		
		if(brush.tileMode & 0b01) {
			warp_block_x = floor(mouse_cur_x / draw_w);
			mouse_cur_tx = safe_mod(mouse_cur_tx, draw_w, MOD_NEG.wrap); 
		}
		
		if(brush.tileMode & 0b10) {
			warp_block_y = floor(mouse_cur_y / draw_h);
			mouse_cur_ty = safe_mod(mouse_cur_ty, draw_h, MOD_NEG.wrap); 
		}
		
		brush_warp = warp_block_x != warp_block_px || warp_block_y != warp_block_py;
		
		if(mouse_press(mb_left, active)) {
			
			surface_set_shader(drawing_surface, noone);
				draw_point_wrap(true);
			surface_reset_shader();
				
			mouse_holding = true;
			if(mouse_pre_draw_x != undefined && mouse_pre_draw_y != undefined && key_mod_press(SHIFT)) { ///////////////// shift line
				surface_set_shader(drawing_surface, noone, true, BLEND.alpha);
					draw_line_wrap(true);
				surface_reset_shader();
				mouse_holding = false;
					
				apply_draw_surface();
			}
			
			node.tool_pick_color(mouse_cur_tx, mouse_cur_ty);
				
			mouse_pre_draw_x = mouse_cur_tx;
			mouse_pre_draw_y = mouse_cur_ty;
			
			warp_block_px = warp_block_x;
			warp_block_py = warp_block_y;
			
		}
			
		if(mouse_holding) {
			var _move = mouse_pre_draw_x != mouse_cur_tx || mouse_pre_draw_y != mouse_cur_ty;
			var _1stp = brush.brush_dist_min == brush.brush_dist_max && brush.brush_dist_min == 1;
				
			if(_move || !_1stp) {
				surface_set_shader(drawing_surface, noone, false, BLEND.alpha);
					if(_1stp) draw_point_wrap(true);
					
					draw_line_wrap(true);
				surface_reset_shader();
			}
				
			mouse_pre_draw_x = mouse_cur_tx;
			mouse_pre_draw_y = mouse_cur_ty;	
				
			warp_block_px = warp_block_x;
			warp_block_py = warp_block_y;
			
			if(mouse_release(mb_left)) {
				mouse_holding = false;
				apply_draw_surface();
			}
			
		}
			
		BLEND_NORMAL
			
		mouse_pre_x = mouse_cur_x;
		mouse_pre_y = mouse_cur_y;
		
	}
	
	function drawPreview(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		if(isEraser) draw_set_color(c_white);
		
		mouse_line_drawing = false;
		
		if(mouse_pre_draw_x != undefined && mouse_pre_draw_y != undefined && key_mod_press(SHIFT)) {
			
			draw_line_wrap(false);
			mouse_line_drawing = true;
			mouse_line_x0 = min(mouse_cur_x, mouse_pre_draw_x);
			mouse_line_y0 = min(mouse_cur_y, mouse_pre_draw_y);
			mouse_line_x1 = max(mouse_cur_x, mouse_pre_draw_x) + 1;
			mouse_line_y1 = max(mouse_cur_y, mouse_pre_draw_y) + 1;
			
			return;
		}
		
		draw_point_wrap(false);
	}
	
	function drawPostOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		if(!mouse_line_drawing) return;
		if(brush.brush_sizing)  return;
		if(!node.attributes.show_slope_check)  return;
		
		var _x0 = _x + mouse_line_x0 * _s;
		var _y0 = _y + mouse_line_y0 * _s;
		var _x1 = _x + mouse_line_x1 * _s;
		var _y1 = _y + mouse_line_y1 * _s;
		
		var _w  = mouse_line_x1 - mouse_line_x0;
		var _h  = mouse_line_y1 - mouse_line_y0;
		var _as = max(_w, _h) % min(_w, _h) == 0;
		
		draw_set_alpha(0.5);
		draw_set_color(_as? COLORS._main_value_positive : COLORS._main_accent);
		draw_rectangle(_x0, _y0, _x1, _y1, true);
		
		draw_set_text(f_p3, fa_center, fa_top);
		draw_text((_x0 + _x1) / 2, _y1 + 8, _w);
		
		draw_set_text(f_p3, fa_left, fa_center);
		draw_text(_x1 + 8, (_y0 + _y1) / 2, _h);
		draw_set_alpha(1);
	}
}