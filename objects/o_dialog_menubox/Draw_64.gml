/// @description init
if(!ready) exit;

DIALOG_PREDRAW
DIALOG_WINCLEAR1

#region draw
	var yy = dialog_y;
	var _lclick = sFOCUS && (!mouse_init_inside && mouse_release(mb_left)) || (keyboard_check_pressed(vk_enter) && hk_editing == noone);
	var _rclick = sFOCUS && !mouse_init_inside && !mouse_init_r_pressed && mouse_release(mb_right);
	if(!mouse_init_inside && mouse_press(mb_right) && item_sel_submenu) {
		if(instance_exists(item_sel_submenu))
			instance_destroy(item_sel_submenu);
		item_sel_submenu = noone;
	}
	
	draw_sprite_stretched(THEME.box_r2_clr, 0, dialog_x, dialog_y, dialog_w, dialog_h);
	
	var to_del = noone;
	for( var i = 0, n = array_length(menu); i < n; i++ ) {
		var _menuItem = menu[i];
		
		if(is_string(_menuItem)) {
			draw_set_text(f_p3, fa_left, fa_top, COLORS._main_text_sub);
			draw_text(dialog_x + ui(8), yy + ui(4), _menuItem);
			
			yy += string_height(_menuItem) + ui(8);
			continue;
		}
		
		if(is(_menuItem, MenuItem) && _menuItem.shiftMenu != noone && key_mod_press(SHIFT))
			_menuItem = _menuItem.shiftMenu;
			
		if(_menuItem == -1) {
			var bx = dialog_x + ui(16);
			var bw = dialog_w - ui(32);
			draw_set_color(CDEF.main_mdblack);
			draw_line_width(bx, yy + ui(3), bx + bw, yy + ui(3), 2);
			yy += ui(8);
			
			continue;
		}
		
		var label = _menuItem.name;
		var _h    = is(_menuItem, MenuItemGroup)? hght * 2 : hght;
		var cc    = struct_try_get(_menuItem, "color", c_white);
		var _key  = _menuItem.hoykeyObject;
		
		if(_key == noone && _menuItem.hotkey != noone) {
			_key = find_hotkey(_menuItem.hotkey[0], _menuItem.hotkey[1]);
			_menuItem.hoykeyObject = _key;
		}
		
		//print($"{i}: {sHOVER} && {point_in_rectangle(mouse_mx, mouse_my, dialog_x, yy + 1, dialog_x + dialog_w, yy + _h - 1)}")
		if(sHOVER && point_in_rectangle(mouse_mx, mouse_my, dialog_x, yy + 1, dialog_x + dialog_w, yy + _h - 1)) {
			selecting = i;
			var tips  = array_safe_get_fast(tooltips, i, noone);
			if(tips != noone) TOOLTIP = tips;
		}
		
		if(selecting == i) {
			if(_menuItem.active && cc == c_white) cc = COLORS.dialog_menubox_highlight;
			
			if(_hovering_ch) {
				if(is(_menuItem, MenuItem) && _menuItem.active && _lclick) {
					var _par = _menuItem.params;
					
					if(_menuItem.isShelf) {
						FOCUS_CONTENT = context;
						
						if(instance_exists(submenu)) {
							instance_destroy(submenu);
							submenu   = noone;
						}
						
						if(submenuIt == _menuItem) {
							submenuIt = noone;
							
						} else {
							var _dat = {
								_x:      dialog_x,
								x:       dialog_x + dialog_w,
								y:       yy,
								name:    _menuItem.name,
								index:   i,
								depth:   depth,
								context: context,
								params:  _par,
							};
							
							var _res  = _menuItem.func(_dat);
							submenu   = _res;
							submenuIt = _menuItem;
						}
						
					} else {
						FOCUS_CONTENT = context;
						
						if(_par != noone) _menuItem.func(_par);
						else              _menuItem.func();
						
						to_del = remove_parents? o_dialog_menubox : self;
					}
				}
				
				if((is(_menuItem, MenuItem) || is(_menuItem, MenuItemGroup)) && (_key && _rclick)) {
					var _dat = {
						_x:      mouse_mx + ui(4),
						x:       mouse_mx + ui(4),
						y:       mouse_my + ui(4),
						depth:   depth,
						name:    _menuItem.name,
						index:   i,
						context: context,
						params:  _menuItem.params,
					};
					
					selecting_menu = _menuItem;
					
					with(o_dialog_menubox) { if(!remove_parents) instance_destroy(); }
					var context_menu_settings = [
						_key.full_name(),
						menuItem(__txt("Edit hotkey"), function() /*=>*/ { hk_editing = selecting_menu; keyboard_lastchar = hk_editing.hoykeyObject.key; }),
					];
					
					item_sel_submenu = submenuCall(_dat, context_menu_settings);
					item_sel_submenu.remove_parents = false;
					
				}
			}
		} 
		
		if(cc != c_white) draw_sprite_stretched_ext(THEME.textbox, 3, dialog_x, yy, dialog_w, _h, cc);
		
		var _hx = dialog_x + dialog_w - ui(16);
		var _hy = yy + hght / 2 + ui(2);
			
		if(is(_menuItem, MenuItemGroup)) {
			var _submenus = _menuItem.group;
			draw_set_text(font, fa_center, fa_center, COLORS._main_text_sub);
			draw_set_alpha(_menuItem.active * 0.75 + 0.25);
			draw_text(dialog_x + dialog_w / 2, yy + hght / 2, label);
			draw_set_alpha(1);
			
			var amo = array_length(_submenus);
			var _w  = (amo - 1) / 2 * (_menuItem.spacing + ui(4));
			var _sx = dialog_x + dialog_w / 2 - _w;
			
			for(var j = 0; j < amo; j++) {
				var _submenu = _submenus[j];
				var _bx	  = _sx + j * (_menuItem.spacing + ui(4));
				var _by	  = yy + hght + hght / 2 - ui(4);
				var _spr  = noone, _ind = 0;
				var _sprs = _submenu[0];
				var _tlp  = array_safe_get_fast(_submenu, 2, "");
				var _dat  = array_safe_get_fast(_submenu, 3, {});
				var _clr  = c_white;
				var _str  = "";
				
				var _sw = _menuItem.spacing;
				var _sh = _menuItem.spacing;
				
				if(is_string(_sprs)) {
					_str = _sprs;
					draw_set_text(font, fa_center, fa_center, COLORS._main_text);
					
					_sw = string_width(_str) + ui(12);
					_sh = string_height(_str) + ui(8);
					
				} else {
					if(is_array(_sprs)) {
						_spr = _sprs[0];
						_ind = _sprs[1];
						_clr = array_safe_get_fast(_sprs, 2, c_white);
					} else _spr = _sprs;
					
					_sw = sprite_get_width(_spr)  + ui(8);
					_sh = sprite_get_height(_spr) + ui(8);
				}
				
				if(_hovering_ch && point_in_rectangle(mouse_mx, mouse_my, _bx - _sw / 2, _by - _sh / 2, _bx + _sw / 2, _by + _sh / 2)) {
					if(_tlp != "") TOOLTIP = _tlp;
					draw_sprite_stretched_ext(THEME.textbox, 3, _bx - _sw / 2, _by - _sh / 2, _sw, _sh, COLORS.dialog_menubox_highlight, 1);
					draw_sprite_stretched_ext(THEME.textbox, 1, _bx - _sw / 2, _by - _sh / 2, _sw, _sh, COLORS.dialog_menubox_highlight, 1);
					
					if(mouse_press(mb_left, sFOCUS)) {
						DIALOG_POSTDRAW
						
						_submenu[1](_dat);
						instance_destroy(o_dialog_menubox);
						exit;
					}
				}
				
				if(_spr != noone) draw_sprite_ui_uniform(_spr, _ind, _bx, _by, 1, _clr);
				if(_str != "")    draw_text(_bx, _by, _str);
			}
			
		} else {
			if(_menuItem.spr != noone) {
				var spr = array_safe_get_fast(_menuItem.spr, 0, _menuItem.spr);
				var ind = array_safe_get_fast(_menuItem.spr, 1, 0);
				var sca = array_safe_get_fast(_menuItem.spr, 2, 0.8);
				var clr = array_safe_get_fast(_menuItem.spr, 3, COLORS._main_icon);
				
				gpu_set_tex_filter(true);
				draw_sprite_ui(spr, ind, dialog_x + ui(24), yy + hght / 2, sca, sca, 0, clr, _menuItem.active * 0.5 + 0.25);
				gpu_set_tex_filter(false);
			}
			
			if(_menuItem.toggle != noone) {
				var tog = _menuItem.toggle(_menuItem);
				if(tog) draw_sprite_ui(THEME.icon_toggle, 0, dialog_x + ui(24), yy + hght / 2,,,, COLORS._main_icon);
			}
			
			var tx = dialog_x + show_icon * ui(32) + ui(16);
			draw_set_text(font, fa_left, fa_center, COLORS._main_text);
			draw_set_alpha(_menuItem.active * 0.75 + 0.25);
			draw_text(tx, yy + hght / 2, label);
			draw_set_alpha(1);
			
			if(_menuItem.isShelf) {
				draw_sprite_ui_uniform(THEME.arrow, 0, dialog_x + dialog_w - ui(20), yy + hght / 2, 1, COLORS._main_icon);	
				_hx -= ui(24);
			}
		}
		
		if(_key) {
			draw_set_font(font);
			
			var _ktxt = key_get_name(_key.key, _key.modi);
			var _tw = string_width(_ktxt);
			var _th = line_get_height();
			
			var _bx = _hx - _tw - ui(4);
			var _by = _hy - _th / 2 - ui(3);
			var _bw = _tw + ui(8);
			var _bh = _th + ui(3);
			
			draw_set_text(font, fa_right, fa_center, COLORS._main_accent);
			
			if(hk_editing == _menuItem) {
				draw_set_color(COLORS._main_accent);
				if(_ktxt == "") _ktxt = "-";
				
			} else if(_ktxt != "") {
				draw_set_color(COLORS._main_text_sub);
			}
			
			draw_text(_hx, _hy - ui(2), _ktxt);
		}
		
		yy += _h;
	}
	
	if(hk_editing != noone) {
		if(keyboard_check_pressed(vk_enter))
			hk_editing = noone;
		else 
			hotkey_editing(hk_editing.hoykeyObject);
			
		if(keyboard_check_pressed(vk_escape))
			hk_editing = noone;
			
	} else if(sFOCUS) {
		if(KEYBOARD_PRESSED == vk_up) {
			selecting--;
			if(selecting < 0) selecting = array_length(menu) - 1;
		}
			
		if(KEYBOARD_PRESSED == vk_down)
			selecting = safe_mod(selecting + 1, array_length(menu));
		
		if(keyboard_check_pressed(vk_escape)) {
			DIALOG_POSTDRAW
			instance_destroy();
			exit;
		}
	}
	
	draw_sprite_stretched(THEME.box_r2_clr, 1, dialog_x, dialog_y, dialog_w, dialog_h);
	
	if(mouse_init_inside && (mouse_release(mb_left) || mouse_release(mb_right))) 
		mouse_init_inside = false;
		
	if(mouse_release(mb_right)) 
		mouse_init_r_pressed = false;
#endregion

#region debug
	if(global.FLAG[$ "context_menu_id"]) {
		draw_set_color(c_white);
		draw_rectangle_border(dialog_x, dialog_y, dialog_x + dialog_w, dialog_y + dialog_h, 2);
		
		draw_set_text(f_p0, fa_left, fa_bottom);
		draw_text(dialog_x, dialog_y - ui(2), menu_id);
	}
#endregion

DIALOG_POSTDRAW

if(to_del != noone) instance_destroy(to_del);