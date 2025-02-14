function preview_overlay_rotation(interact, active, _x, _y, _s, _mx, _my, _snx, _sny, _rad) {
	var _val  = getValue();
	var hover = -1;
	if(is_array(_val)) return hover;
	
	var _ax   = _x + lengthdir_x(_rad, _val);
	var _ay   = _y + lengthdir_y(_rad, _val);
	var index = 0;
	var _r    = 10;
						
	if(drag_type) {
		index = 1;
		
		var angle = point_direction(_x, _y, _mx, _my);
		if(key_mod_press(CTRL))
			angle = round(angle / 15) * 15;
								
		if(setValueInspector( angle ))
			UNDO_HOLDING = true;
							
		if(mouse_release(mb_left)) {
			drag_type = 0;
			UNDO_HOLDING = false;
		}
	}
						
	if(interact && point_in_circle(_mx, _my, _ax, _ay, _r)) {
		hover = 1;
		index = 1;
		
		if(mouse_press(mb_left, active)) {
			drag_type = 1;
			drag_mx   = _mx;
			drag_my   = _my;
			drag_sx   = _ax;
			drag_sy   = _ay;
		}
	} 
	
	if(index) {
		draw_set_color(COLORS._main_accent);
		draw_set_alpha(0.5);
		draw_circle_prec(_x, _y, _rad, true);
		draw_set_alpha(1);
	}
	
	__overlay_hover = array_verify(__overlay_hover, 1);
	__overlay_hover[0] = lerp_float(__overlay_hover[0], index, 4);
	
	shader_set(sh_node_widget_rotator);
		shader_set_color("color", COLORS._main_accent);
		shader_set_f("index",     __overlay_hover[0]);
		shader_set_f("angle",     degtorad(_val + 90));
		
		var _arx = _x + lengthdir_x(_rad - 4, _val);
		var _ary = _y + lengthdir_y(_rad - 4, _val);
		draw_sprite_stretched(s_fx_pixel, 0, _arx - _r * 2, _ary - _r * 2, _r * 4, _r * 4);
	shader_reset();
	
	//draw_sprite_colored(THEME.anchor_rotate, index, _ax, _ay, 1, _val - 90);
	
	draw_set_text(_f_p2b, fa_center, fa_bottom, COLORS._main_accent);
	draw_text_add(round(_ax), round(_ay - 4), name);
	
	return hover;
}