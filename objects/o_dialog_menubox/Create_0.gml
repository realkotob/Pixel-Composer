/// @description init
event_inherited();

#region data
	draggable = false;
	destroy_on_click_out = false;
	alarm[0] = -1;
	menu = 1;
	hght = ui(36);
	children = ds_list_create();
	ds_list_add(children, self);
	
	function setMenu(_menu) {
		menu = _menu;
		dialog_x = x;
		dialog_y = y;
		
		dialog_w = 0;
		dialog_h = 0;
		
		while(ds_list_size(children) > 1) {
			var ch = children[| 1];
			instance_destroy(children[| 1]);
			ds_list_delete(children, 1);
		}
		
		draw_set_text(f_p0, fa_center, fa_center, COLORS._main_text);
		for(var i = 0; i < array_length(menu); i++) {
			if(!is_array(menu[i])) {
				dialog_h += ui(8);
				continue;
			}
			draw_set_font(f_p0);
			var ww = string_width(menu[i][0]) + ui(64);
				
			if(array_length(menu[i]) > 2) {
				if(menu[i][2] == ">") {
					
				} else if(is_array(menu[i][2])) {
					var _key = find_hotkey(menu[i][2][0], menu[i][2][1]);
					if(_key) {
						draw_set_font(f_p1);
						var ss = key_get_name(_key.key, _key.modi);	
						ww += string_width(ss) + ui(16);
					}
				}
			}
			dialog_w = max(dialog_w, ww);
			
			if(is_array(menu[i][1]))
				dialog_h += hght;
			dialog_h += hght;
		}
		
		if(dialog_x + dialog_w > WIN_W - ui(16))
			dialog_x = WIN_W - ui(16) - dialog_w;
		if(dialog_y + dialog_h > WIN_H - ui(16))
			dialog_y = WIN_H - ui(16) - dialog_h;
		
		ready = true;
	}
#endregion