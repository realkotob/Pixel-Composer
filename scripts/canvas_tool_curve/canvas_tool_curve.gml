function canvas_tool_curve_bezier(brush) : canvas_tool() constructor {
	self.brush = brush;
	brush_resizable = true;
	
	anchors = [];
	
	mouse_cur_x = 0;
	mouse_cur_y = 0;
	editing = [ noone, 0 ];
	
	mouse_edit_mx = 0;
	mouse_edit_my = 0;
	mouse_edit_sx = 0;
	mouse_edit_sy = 0;
	
	mouse_hovering = [ noone, 0 ];
	draw_hovering  = [];
	
	function init() {
		anchors = [];
		editing = [ noone, 0 ];
	}
	
	function apply() {
		apply_draw_surface();
		
		disable();
	}
	
	function cancel() {
		surface_clear(drawing_surface);
		disable();
	}
	
	function step(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		
		mouse_cur_x = (_mx - _x) / _s;
		mouse_cur_y = (_my - _y) / _s;
		
		if(editing[0] != noone) {
			var _a  = anchors[editing[0]];
			var _dx = mouse_cur_x - mouse_edit_mx;
			var _dy = mouse_cur_y - mouse_edit_my;
			
			if(editing[1] == 0) {
				_a[2] += _dx;
				_a[3] += _dy;
				
			} else if(editing[1] == -1) {
				_a[0] += _dx;
				_a[1] += _dy;
				
				_a[4] -= _dx;
				_a[5] -= _dy;
				
			} else if(editing[1] == 1) {
				_a[0] -= _dx;
				_a[1] -= _dy;
				
				_a[4] += _dx;
				_a[5] += _dy;
				
			}
			
			mouse_edit_mx = mouse_cur_x;
			mouse_edit_my = mouse_cur_y;
			
			if(mouse_release(mb_left))
				editing[0] = noone;
		}
		
		if(mouse_press(mb_left, active)) {
			recordAction(ACTION_TYPE.var_modify, self, [ array_clone(anchors), "anchors" ]);
			
			if(mouse_hovering[0] == noone) {
				array_push(anchors, [ 0, 0, mouse_cur_x, mouse_cur_y, 0, 0 ]);
				editing[0] = array_length(anchors) - 1;
				editing[1] = 1;
				
			} else {
				if(key_mod_press(SHIFT))
					array_delete(anchors, mouse_hovering[0], 1);
				else {
					editing[0] = mouse_hovering[0];
					editing[1] = mouse_hovering[1];
				}
			}
			
			mouse_edit_mx = mouse_cur_x;
			mouse_edit_my = mouse_cur_y;
			mouse_edit_sx = mouse_cur_x;
			mouse_edit_sy = mouse_cur_y;
		} 
		
		surface_set_shader(drawing_surface, noone);
			var ox, oy, nx, ny;
			var oax1, oay1, nax0, nay0;
			
			for (var i = 0, n = array_length(anchors); i < n; i++) {
				nx = anchors[i][2];
				ny = anchors[i][3];
				
				nax0 = nx + anchors[i][0];
				nay0 = ny + anchors[i][1];
			
				if(i) canvas_draw_curve_brush(brush, ox, oy, oax1, oay1, nax0, nay0, nx, ny);
				
				oax1 = nx + anchors[i][4];
				oay1 = ny + anchors[i][5];
				
				ox = nx;
				oy = ny;
			}
			
		surface_reset_shader();
		
		node.tool_curve_apply.setInteract(!array_empty(anchors));
		node.tool_curve_cancel.setInteract(!array_empty(anchors));
		if(key_press(vk_enter))  apply();
		if(key_press(vk_escape)) disable();
	}
	
	function drawPreview(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		draw_surface_ext_safe(drawing_surface, _x, _y, _s, _s);
		canvas_draw_point_brush(brush, mouse_cur_x, mouse_cur_y);
	}
	
	function drawMask(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		
	}
	
	function drawPostOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var ox, oy, nx, ny, ax0, ay0, ax1, ay1;
		var oax1, oay1, nax0, nay0;
		
		draw_set_color(c_white);
		for (var i = 0, n = array_length(anchors); i < n; i++) {
			nx = _x + anchors[i][2]  * _s;
			ny = _y + anchors[i][3]  * _s;
			
			nax0 = nx + anchors[i][0] * _s;
			nay0 = ny + anchors[i][1] * _s;
			
			if(i) draw_curve_bezier(ox, oy, oax1, oay1, nax0, nay0, nx, ny);
			
			oax1 = nx + anchors[i][4] * _s;
			oay1 = ny + anchors[i][5] * _s;
			
			draw_line(nx, ny, nax0, nay0);
			draw_line(nx, ny, oax1, oay1);
			
			ox = nx;
			oy = ny;
		}
		
		mouse_hovering = [ noone, 0 ];
		
		draw_hovering = array_verify(draw_hovering, array_length(anchors) * 3);
		
		for (var i = 0, n = array_length(anchors); i < n; i++) {
			nx = _x + anchors[i][2] * _s;
			ny = _y + anchors[i][3] * _s;
			
			ax0 = nx + anchors[i][0] * _s;
			ay0 = ny + anchors[i][1] * _s;
			
			ax1 = nx + anchors[i][4] * _s;
			ay1 = ny + anchors[i][5] * _s;
			
			draw_anchor(0,  nx,  ny, lerp(10, 13, draw_hovering[i * 3 + 1]));
			draw_anchor(0, ax0, ay0, lerp( 7, 10, draw_hovering[i * 3 + 0]));
			draw_anchor(0, ax1, ay1, lerp( 7, 10, draw_hovering[i * 3 + 2]));
			
			     if(point_in_circle(_mx, _my, nx, ny,   10)) mouse_hovering = [ i,  0 ];
			else if(point_in_circle(_mx, _my, ax0, ay0, 10)) mouse_hovering = [ i, -1 ];
			else if(point_in_circle(_mx, _my, ax1, ay1, 10)) mouse_hovering = [ i,  1 ];
		}
		
		if(mouse_hovering[0] != noone) {
			var index = mouse_hovering[0] * 3 + mouse_hovering[1] + 1;
			
			for (var i = 0, n = array_length(draw_hovering); i < n; i++)
				draw_hovering[i] = lerp_float(draw_hovering[i], i == index, 4);
		}
	}
	
}