function pathArrayBox(_target, _data, _onClick) : widget() constructor {
	target  = _target;
	data    = _data;
	onClick = _onClick;
	
	openPath = button(function() {
		var path = get_open_filenames_compat(data[0], data[1]);
		key_release();
		if(path == "") return noone;
		
		var paths = string_splice(path, "\n");
		onClick(paths);
	}, THEME.button_path_icon);
	
	static trigger = function() { 
		dialogPanelCall(new Panel_Image_Array_Editor(target));
	}
	
	static drawParam = function(params) {
		setParam(params);
		
		return draw(params.x, params.y, params.w, params.h, params.data, params.m);
	}
	
	static draw = function(_x, _y, _w, _h, _files, _m) {
		x = _x;
		y = _y;
		w = _w;
		h = _h;
		
		hovering = false;
		
		var _bs = min(_h, ui(32));
		if(_w - _bs > ui(100)) {
			openPath.setFocusHover(active, hover);
			openPath.draw(_x + _w - _bs, _y + _h / 2 - _bs / 2, _bs, _bs, _m, THEME.button_hide_fill);
			_w -= _bs + ui(4);
		}
		
		var click = false;
		draw_sprite_stretched_ext(THEME.textbox, 3, _x, _y, _w, _h, boxColor);
		
		if(hover && point_in_rectangle(_m[0], _m[1], _x, _y, _x + _w, _y + _h)) {
			hovering = true;
			draw_sprite_stretched_ext(THEME.textbox, 1, _x, _y, _w, _h, boxColor);
			
			if(mouse_press(mb_left, active)) {
				trigger();
				click = true;
			}
			
			if(mouse_click(mb_left, active))
				draw_sprite_stretched(THEME.textbox, 2, _x, _y, _w, _h);
		} else {
			draw_sprite_stretched_ext(THEME.textbox, 0, _x, _y, _w, _h, boxColor);
			if(mouse_press(mb_left)) deactivate();
		}
		
		var aa = interactable * 0.25 + 0.75;
		
		if(!is_array(_files)) _files = [ _files ];
		var len = array_length(_files);
		
		var txt = $"({len}) [";
		for( var i = 0; i < len; i++ )
			txt += (i? ", " : "") + filename_name_only(_files[i]);
		txt += "]";
		
		draw_set_text(font, fa_left, fa_center, COLORS._main_text);
		if(_h >= line_get_height()) {
			draw_set_alpha(aa);
			draw_text_cut(_x + ui(8), _y + _h / 2, txt, _w - ui(16));
			draw_set_alpha(1);
		}
		
		if(WIDGET_CURRENT == self)
			draw_sprite_stretched_ext(THEME.widget_selecting, 0, _x - ui(3), _y - ui(3), _w + ui(6), _h + ui(6), COLORS._main_accent, 1);	
		
		resetFocus();
		
		return h;
	}
	
	static clone = function() {
		var cln = new pathArrayBox(target, data, onClick);
		return cln;
	}
}