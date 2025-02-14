/// @description init
if !ready exit;

#region dim BG
	var lowest = true;

	draw_set_color(c_black);
	draw_set_alpha(0.5);
	draw_rectangle(0, 0, WIN_W, WIN_H, false);
	draw_set_alpha(1);
#endregion

#region base UI
	DIALOG_DRAW_BG
	if(DIALOG_SHOW_FOCUS) DIALOG_DRAW_FOCUS
#endregion

#region text
	var py  = dialog_y + ui(20);
	var txt = __txt($"Running shell script");
	draw_set_text(f_h5, fa_left, fa_top, COLORS._main_text);
	draw_text(dialog_x + ui(24), py, txt);
	py += line_get_height(, 8);
	
	draw_set_text(f_p0, fa_left, fa_top, COLORS._main_text_sub);
	draw_text_ext(dialog_x + ui(24), py, ctxt[0], -1, dialog_w - ui(48));
	py += string_height_ext(ctxt[0], -1, dialog_w - ui(48)) + ui(16);
	
	draw_set_text(f_code, fa_left, fa_top, COLORS._main_text);
	var _hh = string_height_ext(ctxt[1], -1, dialog_w - ui(64));
	draw_sprite_stretched(THEME.ui_panel_bg, 1, dialog_x + ui(24), py - ui(8), dialog_w - ui(48), _hh + ui(16));
	
	draw_text_ext(dialog_x + ui(32), py, ctxt[1], -1, dialog_w - ui(64));
	py += _hh + ui(16);
	
	draw_set_text(f_p0, fa_left, fa_top, COLORS._main_text_sub);
	draw_text_ext(dialog_x + ui(24), py, ctxt[2], -1, dialog_w - ui(48));
	py += string_height_ext(ctxt[2], -1, dialog_w - ui(48));
	
	var bw = ui(96), bh = BUTTON_HEIGHT;
	var bx1 = dialog_x + dialog_w - ui(16);
	var by1 = dialog_y + dialog_h - ui(16);
	var bx0 = bx1 - bw;
	var by0 = by1 - bh;
	
	draw_set_text(f_p1, fa_center, fa_center, COLORS._main_text);
	var b = buttonInstant(THEME.button_def, bx0, by0, bw, bh, mouse_ui, sHOVER, sFOCUS);
	draw_text(bx0 + bw / 2, by0 + bh / 2, __txt("Cancel"));
	if(b == 2) 
		instance_destroy();
	
	bx0 -= bw + ui(12);
	var b = buttonInstant(THEME.button_def, bx0, by0, bw, bh, mouse_ui, sHOVER, sFOCUS);
	draw_text(bx0 + bw / 2, by0 + bh / 2, __txtx("run", "Run"));
	if(b == 2) {
		shell_execute_async(prog, cmd);		
		node.trusted = true;
		
		instance_destroy();
	}
#endregion