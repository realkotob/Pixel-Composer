function canvas_tool_resize() : canvas_tool() constructor {
	
	override = true;
	
	dragging = -1;
	drag_mx  = 0;
	drag_my  = 0;
	drag_sw  = 0;
	drag_sh  = 0;
	
	drag_display = [ 0, 0, 0, 0 ];
	
	__hover_anim = array_create(4);
	overlay_surface = noone;
	
	function step(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		
		var _sw = node.attributes.dimension[0];
		var _sh = node.attributes.dimension[1];
		var x0, y0, x1, y1;
		
		if(dragging >= 0) {
			x0 = _x + drag_display[0] * _s;
			y0 = _y + drag_display[1] * _s;
			x1 = _x + drag_display[2] * _s;
			y1 = _y + drag_display[3] * _s;
			
		} else {
			x0 = _x;
			y0 = _y;
			x1 = _x + _sw * _s;
			y1 = _y + _sh * _s;
		}
		
		var _r = 10;
		
		var _sr  = surface_get_target();
		var _srw = surface_get_width(_sr);
		var _srh = surface_get_height(_sr);
		
		overlay_surface = surface_verify(overlay_surface, _srw, _srh);
		surface_set_target(overlay_surface);
			draw_clear_alpha(0, 0.3);
			
			BLEND_SUBTRACT
				draw_set_color(c_white);
				draw_rectangle(x0, y0, x1, y1, false);
			BLEND_NORMAL
		surface_reset_target();
		
		draw_surface_safe(overlay_surface);
		
		draw_set_color(c_black);
		draw_rectangle(x0, y0, x1, y1, true);
		
		draw_set_color(c_white);
		draw_rectangle_dashed(x0, y0, x1, y1, true, 6, current_time / 100);
		
		var _hovering = -1;
		
		     if(point_in_circle(_mx, _my, x0, y0, _r)) _hovering = 0;
		else if(point_in_circle(_mx, _my, x1, y0, _r)) _hovering = 1;
		else if(point_in_circle(_mx, _my, x0, y1, _r)) _hovering = 2;
		else if(point_in_circle(_mx, _my, x1, y1, _r)) _hovering = 3;
		
		for( var i = 0; i < 4; i++ ) __hover_anim[i] = lerp_float(__hover_anim[i], i == _hovering, 4);
		
		draw_anchor(__hover_anim[0], x0, y0, _r);
		draw_anchor(__hover_anim[1], x1, y0, _r);
		draw_anchor(__hover_anim[2], x0, y1, _r);
		draw_anchor(__hover_anim[3], x1, y1, _r);
		
		if(dragging >= 0) {
			var _dx = (_mx - drag_mx) / _s;
			var _dy = (_my - drag_my) / _s;
			
			var _sw = drag_sw;
			var _sh = drag_sh;
			
			if(key_mod_press(SHIFT)) _dy = _dx * (drag_sh / drag_sw);
			
			switch(dragging) {
				case 0 : drag_display = [ round(_dx), round(_dy), _sw,              _sh              ];	break;
				case 1 : drag_display = [          0, round(_dy), _sw + round(_dx), _sh              ];	break;
				case 2 : drag_display = [ round(_dx),          0, _sw,              _sh + round(_dy) ];	break;
				case 3 : drag_display = [          0,          0, _sw + round(_dx), _sh + round(_dy) ];	break;
			}
			
			if(mouse_release(mb_left)) {
				dragging = -1;
				
				var _sw = drag_display[2] - drag_display[0];
				var _sh = drag_display[3] - drag_display[1];
				
				if(_sw > 0 && _sh > 0) {
					node.storeAction();
					node.attributes.dimension = [ _sw, _sh ];
					
					for( var i = 0; i < node.attributes.frames; i++ ) {
						var _canvas_surface = node.getCanvasSurface(i);
						
						var _cbuff = array_safe_get_fast(node.canvas_buffer, i);
						if(buffer_exists(_cbuff)) buffer_delete(_cbuff);
			
						node.canvas_buffer[i] = buffer_create(_sw * _sh * 4, buffer_fixed, 4);
						
						var _newCanvas = surface_create(_sw, _sh);
						
						surface_set_shader(_newCanvas, noone);
							draw_surface(_canvas_surface, -drag_display[0], -drag_display[1]);
						surface_reset_shader();
						
						node.setCanvasSurface(_newCanvas, i);
						surface_free(_canvas_surface);
					}
					
					node.inputs[0].setValue([_sw, _sh]);
				}
			}
			
		} else if(_hovering >= 0 && mouse_click(mb_left, active)) {
			dragging = _hovering;
			
			drag_mx = _mx;
			drag_my = _my;
			drag_sw = _sw;
			drag_sh = _sh;
			
			drag_display = [ 0, 0, _sw, _sh ];
		}
	}
	
}