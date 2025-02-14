function checkBox(_onClick) : widget() constructor {
	onClick   = _onClick;
	triggered = false;
	spr       = THEME.checkbox_def;
	
	static setLua = function(_lua_thread, _lua_key, _lua_func) { 
		lua_thread = _lua_thread;
		lua_thread_key = _lua_key;
		onClick = method(self, _lua_func);
	}
	
	static trigger = function() { 
		if(!is_callable(onClick))
			return noone;
		triggered = true;
		onClick();
	}
	
	static isTriggered = function() {
		var t = triggered;
		triggered = false;
		return t;
	}
	
	static drawParam = function(params) {
		var ss = params.s;
		var x0, y0;
		
		switch(params.halign) {
			case fa_left :	 x0 = params.x; break;
			case fa_center : x0 = params.x + (params.w - ss) / 2; break;
			case fa_right :  x0 = params.x +  params.w - ss; break;
		}
		
		switch(params.valign) {
			case fa_top :	 y0 = params.y; break;
			case fa_center : y0 = params.y + (params.h - ss) / 2; break;
			case fa_bottom : y0 = params.y +  params.h - ss; break;
		}
		
		return draw(x0, y0, params.data, params.m, params.s);
	}
	
	static draw = function(_x, _y, _value, _m, ss = ui(28), halign = fa_left, valign = fa_top) {
		x = _x;
		y = _y;
		w = ss;
		h = ss;
		
		var _dx, _dy;
		switch(halign) {
			case fa_left:   _dx = _x;			break;	
			case fa_center: _dx = _x - ss / 2;	break;	
			case fa_right:  _dx = _x - ss;		break;	
		}
		
		switch(valign) {
			case fa_top:    _dy = _y;			break;	
			case fa_center: _dy = _y - ss / 2;	break;	
			case fa_bottom: _dy = _y - ss;		break;	
		}
		
		var aa = interactable * 0.25 + 0.75;
		draw_sprite_stretched_ext(spr, 0, _dx, _dy, ss, ss, c_white, aa);
		
		if(hover && point_in_rectangle(_m[0], _m[1], _dx, _dy, _dx + ss, _dy + ss)) {
			draw_sprite_stretched_ext(spr, 1, _dx, _dy, ss, ss, c_white, aa);	
			
			if(mouse_press(mb_left, active))
				trigger();
		} else
			if(mouse_press(mb_left)) deactivate();
		
		if(is_array(_value))
			draw_sprite_stretched_ext(spr, 3, _dx, _dy + ss / 2 - 8, ss, 16, COLORS._main_accent, aa);
		else if(_value) 
			draw_sprite_stretched_ext(spr, 2, _dx, _dy, ss, ss, COLORS._main_accent, aa);
		
		if(WIDGET_CURRENT == self)
			draw_sprite_stretched_ext(THEME.widget_selecting, 0, _dx - ui(3), _dy - ui(3), ss + ui(6), ss + ui(6), COLORS._main_accent, 1);	
		
		resetFocus();
		
		return h;
	}
	
	static clone = function() { #region
		var cln = new checkBox(onClick);
		
		return cln;
	} #endregion
}
