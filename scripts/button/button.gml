function button(_onClick, _icon = noone) { INLINE return new buttonClass(_onClick, _icon); }

function buttonClass(_onClick, _icon = noone) : widget() constructor {
	icon	   = _icon;
	icon_blend = c_white;
	icon_index = 0;
	
	text	= "";
	tooltip = "";
	blend   = c_white;
	
	onClick = _onClick;
	triggered = false;
	
	activate_on_press = false;
	clicked = false;
	pressed = false;
	
	toggled = false;
	context = noone;
	
	static setLua = function(_lua_thread, _lua_key, _lua_func) { #region
		lua_thread = _lua_thread;
		lua_thread_key = _lua_key;
		onClick = method(self, _lua_func);
	} #endregion
	
	static trigger = function() { #region
		clicked = true;
		
		if(!is_callable(onClick))
			return noone;
		triggered = true;
		onClick();
	} #endregion
	
	static isTriggered = function() { #region
		var t = triggered;
		triggered = false;
		return t;
	} #endregion
	
	static setIcon = function(_icon, _index = 0, _blend = c_white) { #region
		icon       = _icon; 
		icon_index = _index;
		icon_blend = _blend;
		return self; 
	} #endregion
	
	static setText = function(_text) { #region
		text = _text; 
		return self; 
	} #endregion
	
	static setTooltip = function(_tip) { #region
		tooltip = _tip; 
		return self; 
	} #endregion
	
	static drawParam = function(params) { #region
		setParam(params);
		
		return draw(params.x, params.y, params.w, params.h, params.m);
	} #endregion
	
	static draw = function(_x, _y, _w, _h, _m, spr = THEME.button_def, blend = c_white) { #region
		x = _x;
		y = _y;
		w = _w;
		h = _h;
		
		clicked  = false;
		hovering = hover && point_in_rectangle(_m[0], _m[1], _x, _y, _x + _w, _y + _h);
		
		var b = colorMultiply(self.blend, blend);
		
		if(hover && point_in_rectangle(_m[0], _m[1], _x, _y, _x + _w, _y + _h)) {
			draw_sprite_stretched_ext(spr, toggled? 2 : 1, _x, _y, _w, _h, b, 1);
			
			if(!activate_on_press && pressed && mouse_release(mb_left, active))
				trigger();
				
			if(mouse_press(mb_left, active)) {
				pressed = true;
				if(activate_on_press) trigger();
			}
				
			if(mouse_click(mb_left, active)) {
				draw_sprite_stretched_ext(spr, 2, _x, _y, _w, _h, b, 1);
				draw_sprite_stretched_ext(spr, 3, _x, _y, _w, _h, COLORS._main_accent, 1);
			}
			if(tooltip != "") TOOLTIP = tooltip;
		} else {
			draw_sprite_stretched_ext(spr, toggled? 2 : 0, _x, _y, _w, _h, b, 1);
			if(mouse_press(mb_left)) deactivate();
		}
		
		var aa = interactable * 0.25 + 0.75;
		if(icon) {
			var ind = is_array(icon_index)? icon_index[0]() : icon_index;
			draw_sprite_ui_uniform(icon, ind, _x + _w / 2, _y + _h / 2,, icon_blend, aa);
		}
		
		if(text != "") {
			draw_set_alpha(aa);
			draw_set_text(font, fa_center, fa_center, COLORS._main_text);
			draw_text_add(_x + _w / 2, _y + _h / 2, text);
			draw_set_alpha(1);
		}
		
		if(WIDGET_CURRENT == self) draw_sprite_stretched_ext(THEME.widget_selecting, 0, _x - ui(3), _y - ui(3), _w + ui(6), _h + ui(6), COLORS._main_accent, 1);
		
		resetFocus();
		
		if(mouse_release(mb_left)) pressed = false;
		
		return _h;
	} #endregion
		
	static clone = function() { #region
		var cln = new buttonClass(onClick);
		
		cln.icon	   = icon;
		cln.icon_blend = icon_blend;
		cln.icon_index = icon_index;
		
		cln.text	= text;
		cln.tooltip = tooltip;
		cln.blend   = blend;
		
		return cln;
	} #endregion
}

function buttonInstant(spr, _x, _y, _w, _h, _m, _act, _hvr, _tip = "", _icon = noone, _icon_index = 0, _icon_blend = COLORS._main_icon, _icon_alpha = 1, _icon_scale = 1) {
	var res = 0;
	var cc  = is_array(_icon_blend)? _icon_blend[0] : _icon_blend;
	
	if(_hvr && point_in_rectangle(_m[0], _m[1], _x, _y, _x + _w, _y + _h)) {
		if(is_array(_icon_blend))
			cc = _icon_blend[1];
			
		res = 1;
		if(spr) draw_sprite_stretched(spr, 1, _x, _y, _w, _h);	
		if(_tip != "") TOOLTIP = _tip;
			
		if(mouse_press(mb_left, _act))		res = 2;
		if(mouse_press(mb_right, _act))		res = 3;
			
		if(mouse_release(mb_left, _act))	res = -2;
		if(mouse_release(mb_right, _act))	res = -3;
			
		if(spr && mouse_click(mb_left, _act)) {
			draw_sprite_stretched(spr, 2, _x, _y, _w, _h);	
			draw_sprite_stretched_ext(spr, 3, _x, _y, _w, _h, COLORS._main_accent, 1);	
		}
	} else if(spr)
		draw_sprite_stretched(spr, 0, _x, _y, _w, _h);		
	
	if(_icon)
		draw_sprite_ui_uniform(_icon, _icon_index, _x + _w / 2, _y + _h / 2, _icon_scale, cc, _icon_alpha);
	
	return res;
}

function buttonTextIconInstant(spr, _x, _y, _w, _h, _m, _act, _hvr, _tip = "", _icon = noone, _icon_label = "") {
	var _b = buttonInstant(spr, _x, _y, _w, _h, _m, _act, _hvr, _tip);
	
	draw_set_text(f_p1, fa_left, fa_center, COLORS._main_icon_light);
	var bxc = _x + _w / 2 - (string_width(_icon_label) + ui(64)) / 2;
	var byc = _y + _h / 2;
	draw_sprite_ui(_icon, 0, bxc + ui(24), byc,,,, COLORS._main_icon_light);
	draw_text(bxc + ui(48), byc, _icon_label);
	
	return _b;
}