/// @description init
if(sHOVER) HOVER = noone;
if(sFOCUS) setFocus(noone);

WIDGET_CURRENT = noone;
ds_list_remove(DIALOGS, self);

if(parent) array_remove(parent.children, id);

if(!passthrough) MOUSE_BLOCK = true;

if(window != noone && winwin_exists(window)) 
	winwin_destroy(window);