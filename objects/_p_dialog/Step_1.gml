/// @description init
if(init_pressing && mouse_release(mb_left))
	init_pressing = false;

if !ready  exit;
if !active exit;

#region window control
	if(sFOCUS) {
		if(destroy_on_escape && keyboard_check_pressed(vk_escape) && checkClosable())
			instance_destroy();
	}
#endregion

#region resize
	if(window != noone) {
		dialog_w = winwin_get_width_safe(window);
		dialog_h = winwin_get_height_safe(window);
	}
	
	if(_dialog_h != dialog_h || _dialog_w != dialog_w) {
		_dialog_h = dialog_h;
		_dialog_w = dialog_w;
		
		if(onResize != -1) onResize();
	}
#endregion

