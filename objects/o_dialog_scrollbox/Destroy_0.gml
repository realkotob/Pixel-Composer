/// @description init
event_inherited();

if(initVal > -1)
	scrollbox.onModify(initVal);
scrollbox.open = false;

if(FOCUS == noone && instance_number(o_dialog_scrollbox_horizontal) == 1) FOCUS = FOCUS_BEFORE;