function preview_overlay_vector(interact, active, _x, _y, _s, _mx, _my, _snx, _sny, _type = 0) {
	var _val  = array_clone(getValue());
	var hover = -1;
	if(!is_array(_val) || array_empty(_val)) return hover;
	if(is_array(_val[0])) return hover;
	
	var __ax = _val[0];
	var __ay = _val[1];
	var _r   = 10;
						
	var _ax    = __ax * _s + _x;
	var _ay    = __ay * _s + _y;
	var _index = 0;
						
	if(drag_type) {
		_index = 1;
		
		var _nx = (drag_sx + (_mx - drag_mx) - _x) / _s;
		var _ny = (drag_sy + (_my - drag_my) - _y) / _s;
		
		_nx = value_snap(_nx, _snx);
		_ny = value_snap(_ny, _sny);
		
		if(key_mod_press(SHIFT)) {
			if(abs(_mx - drag_mx) > abs(_my - drag_my)) 
				_ny = drag_ry;
			else
				_nx = drag_rx;
			
			draw_set_color(COLORS._main_accent);
			draw_line(drag_sx, drag_sy, _x + _nx * _s, _y + _ny * _s);
		}
		
		if(key_mod_press(CTRL)) {
			_val[0] = round(_nx);
			_val[1] = round(_ny);
		} else {
			_val[0] = _nx;
			_val[1] = _ny;
		}
							
		if(setValueInspector( unit.invApply(_val) )) 
			UNDO_HOLDING = true;
							
		if(mouse_release(mb_left)) {
			drag_type = 0;
			UNDO_HOLDING = false;
		}
	}
						
	if(interact && point_in_circle(_mx, _my, _ax, _ay, _r)) {
		hover  = 1;
		_index = 1;
		
		if(mouse_press(mb_left, active)) {
			drag_type = 1;
			drag_mx   = _mx;
			drag_my   = _my;
			drag_sx   = _ax;
			drag_sy   = _ay;
			drag_rx   = __ax;
			drag_ry   = __ay;
		}
	} 
	
	__overlay_hover = array_verify(__overlay_hover, 1);
	__overlay_hover[0] = lerp_float(__overlay_hover[0], _index, 4);
	draw_anchor(__overlay_hover[0], _ax, _ay, _r, _type);
	
	if(overlay_draw_text) {
		draw_set_text(_f_p2b, fa_center, fa_bottom, COLORS._main_accent);
		draw_text_add(round(_ax), round(_ay - 4), name);
	}
	
	return hover;
}