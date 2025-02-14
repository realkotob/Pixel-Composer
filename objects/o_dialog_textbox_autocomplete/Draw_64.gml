/// @description 
active = textbox != noone && array_length(data);
if(textbox == noone)				exit;
if(textbox != WIDGET_CURRENT)		exit;
if(array_empty(data))				exit;
if(dialog_x == 0 && dialog_y == 0)	exit;

#region dialog
	dialog_x = clamp(dialog_x, 0, WIN_W - dialog_w - 1);
	dialog_y = clamp(dialog_y, 0, WIN_H - dialog_h - 1);

	var _w = 300;
	var _h = min(show_items, array_length(data)) * line_get_height(font, pad_item);
	
	for( var i = 0, n = array_length(data); i < n; i++ ) {
		var _dat = data[i];
		var __w  = ui(40 + 32);
		
		draw_set_font(font);
		__w += string_width(_dat[2]);
		__w += string_width(_dat[1]);
		
		_w = max(_w, __w);
	}
	
	dialog_w = _w + 6;
	dialog_h = _h;
	
	sc_content.resize(_w, dialog_h);
#endregion

#region draw
	draw_sprite_stretched(THEME.textbox, 3, dialog_x, dialog_y, dialog_w, dialog_h);
	sc_content.setFocusHover(true, true);
	sc_content.draw(dialog_x, dialog_y);
	draw_sprite_stretched(THEME.textbox, 1, dialog_x, dialog_y, dialog_w, dialog_h);
#endregion

if(keyboard_check_pressed(vk_escape))
	textbox = noone;