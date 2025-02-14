function checkBoxGroup(sprs, _onClick) : widget() constructor {
	self.sprs = sprs;
	self.size = sprite_get_number(sprs);
	onClick   = _onClick;
	
	holding   = noone;
	tooltips  = [];
	
	static trigger     = function(value, index) { onClick(value, index); }
	static setTooltips = function(tt) { tooltips = tt; return self; } 
	
	static drawParam = function(params) {
		setParam(params);
		
		return draw(params.x, params.y, params.data, params.m, params.s);
	}
	
	static draw = function(_x, _y, _value, _m, ss = ui(28), halign = fa_left, valign = fa_top) {
		x = _x;
		y = _y;
		w = ss * size;
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
		
		if(mouse_release(mb_left))
			holding = noone;
		
		var aa = interactable * 0.25 + 0.75;
		for( var i = 0; i < size; i++ ) {
			var spr = i == 0 ? THEME.button_left : (i == size - 1? THEME.button_right : THEME.button_middle);
			var ind = _value[i] * 2;
				
			if(hover && point_in_rectangle(_m[0], _m[1], _dx, _dy, _dx + ss, _dy + ss)) {			
				ind = 1
				TOOLTIP = array_safe_get(tooltips, i, "");
				
				if(holding != noone)
					trigger(holding, i);
				
				if(mouse_press(mb_left, active)) {
					trigger(!_value[i], i);
					holding = _value[i];
				}
			} else
				if(mouse_press(mb_left)) deactivate();
			
			draw_sprite_stretched_ext(spr, ind, _dx, _dy, ss, ss, c_white, aa);
			if(_value[i])
				draw_sprite_stretched_ext(spr, 3, _dx, _dy, ss, ss, COLORS._main_accent, 1);
			draw_sprite_ext(sprs, i, _dx + ss / 2, _dy + ss / 2, 1, 1, 0, c_white, 0.5 + _value[i] * 0.5);
			
			_dx += ss;
		}
		
		if(WIDGET_CURRENT == self)
			draw_sprite_stretched_ext(THEME.widget_selecting, 0, _dx - ui(3), _dy - ui(3), ss + ui(6), ss + ui(6), COLORS._main_accent, 1);	
		
		resetFocus();
		
		return h;
	}
	
	static clone = function() { #region
		var cln = new checkBoxGroup(sprs, onClick);
		
		return cln;
	} #endregion
}
