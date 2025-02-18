function scrollPane(_w, _h, ondraw) constructor {
	scroll_y		= 0;
	scroll_y_raw	= 0;
	scroll_y_to		= 0;
	
	w			= _w;
	h			= _h;
	surface_w   = _w - ui(12);
	surface_h   = _h;
	surface     = surface_create_valid(surface_w, surface_h);
	
	drawFunc    = ondraw;
	
	content_h   = 0;
	is_scroll	= true;
	
	scroll_step = 64;
	active      = false;
	
	is_scrolling = false;
	
	static resize = function(_w, _h) {
		w = _w;
		h = _h;
		surface_w   = _w - is_scroll * ui(12);
		surface_h   = _h;
		
		if(surface_w > 1 && surface_h > 1) {
			if(is_surface(surface))
				surface_size_to(surface, surface_w, surface_h);
			else
				surface = surface_create_valid(surface_w, surface_h);
		}
	}
	
	static draw = function(x, y, _mx = mouse_mx - x, _my = mouse_my - y) {
		var mx = _mx, my = _my;

		if(!point_in_rectangle(mx, my, 0, 0, surface_w, surface_h)) {
			mx = -100;
			my = -100;
		}
		
		if(!is_surface(surface)) surface = surface_create_valid(surface_w, surface_h);
		surface_set_target(surface);
			draw_clear(COLORS.panel_bg_clear);
			var hh = drawFunc(scroll_y, [mx, my], [x, y]);
			content_h = max(0, hh - surface_h);
		surface_reset_target();
		
		var sc = is_scroll;
		is_scroll = hh > surface_h;
		if(sc != is_scroll)
			resize(w, h);
		
		scroll_y_to		= clamp(scroll_y_to, -content_h, 0);
		scroll_y_raw	= lerp_float(scroll_y_raw, scroll_y_to, 4);
		scroll_y		= round(scroll_y_raw);
		draw_surface_safe(surface, x, y);
		
		if(active && point_in_rectangle(mx, my, 0, 0, surface_w, surface_h)) {
			if(mouse_wheel_down())	scroll_y_to = clamp(scroll_y_to - scroll_step, -content_h, 0);
			if(mouse_wheel_up())	scroll_y_to = clamp(scroll_y_to + scroll_step, -content_h, 0);
		}
		
		if(abs(content_h) > 0) {
			draw_scroll(x + surface_w + ui(4), y + ui(6), true, surface_h - ui(12), -scroll_y / content_h, surface_h / (surface_h + content_h), COLORS.scrollbar_idle, COLORS.scrollbar_hover, x + _mx, y + _my);
		}
	}
	
	static draw_scroll = function(scr_x, scr_y, is_vert, scr_s, scr_prog, scr_size, bar_col, bar_hcol, mx, my) {
		var scr_scale_s = scr_s * scr_size;
		var scr_prog_s  = scr_prog * (scr_s - scr_scale_s);
		var scr_w, scr_h, bar_w, bar_h, bar_x, bar_y;
		
		if(is_vert) {
			scr_w	= ui(sprite_get_width(THEME.ui_scrollbar));
			scr_h	= scr_s;
			bar_w	= ui(sprite_get_width(THEME.ui_scrollbar));
			bar_h   = scr_scale_s;
			bar_x	= scr_x;
			bar_y	= scr_y + scr_prog_s;
		} else {
			scr_w	= scr_s;
			scr_h	= ui(sprite_get_width(THEME.ui_scrollbar));
			bar_w	= scr_scale_s;
			bar_h   = ui(sprite_get_width(THEME.ui_scrollbar));
			bar_x	= scr_x + scr_prog_s;
			bar_y	= scr_y;
		}
	
		draw_sprite_stretched_ext(THEME.ui_scrollbar, 0, bar_x, bar_y, bar_w, bar_h, bar_col, 1);
		if(active && point_in_rectangle(mx, my, scr_x - 2, scr_y - 2, scr_x + scr_w + 2, scr_y + scr_h + 2) || is_scrolling) {
			draw_sprite_stretched_ext(THEME.ui_scrollbar, 0, bar_x, bar_y, bar_w, bar_h, bar_hcol, 1);
			if(mouse_click(mb_left, active)) {
				if(is_vert)	
					scroll_y_to = clamp((my - scr_y - scr_scale_s / 2) / (scr_s - scr_scale_s), 0, 1) * -content_h;
				else
					scroll_y_to = clamp((mx - scr_x - scr_scale_s / 2) / (scr_s - scr_scale_s), 0, 1) * -content_h;
				is_scrolling = true;
			} else 
				is_scrolling = false;
		} else 
			is_scrolling = false;
	}
}