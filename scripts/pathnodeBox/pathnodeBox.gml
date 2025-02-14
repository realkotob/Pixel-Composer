function pathnodeBox(_junction) : widget() constructor {
	self.junction = _junction;
	
    b_newTileset = button(function() /*=>*/ { 
    	var b = nodeBuild("Node_Path", junction.node.x - 128, junction.ry - 32);
    	junction.setFrom(b.outputs[1]);
	});
	
	b_newTileset.text       = __txt("New path");
	b_newTileset.icon       = THEME.add_16;
	b_newTileset.icon_size  = .75;
	b_newTileset.icon_blend = COLORS._main_value_positive;
    
	static trigger = function() { }
	
	static drawParam = function(params) {
		setParam(params);
		return draw(params.x, params.y, params.w, params.data, params.m);
	}
	
	static draw = function(_x, _y, _w, _path, _m) {
		x = _x;
		y = _y;
		w = _w;
		h = TEXTBOX_HEIGHT;
        
        // if(junction.connect_type == CONNECT_TYPE.output) {
        	
        // 	return h;
        // }
        
        if(_path == noone) {
            b_newTileset.setFocusHover(active, hover);
            var param = new widgetParam(x, y, w, h, noone, {}, _m, rx, ry);
            b_newTileset.drawParam(param);
            
        } else {
        	var ic = s_node_path;
        	
        	switch(instanceof(_path)) {
        		case "Node_Path" : ic = s_node_path; break;
        	}
        	
        	var iw = ui(24);
        	var _s = (iw - ui(8)) / max(sprite_get_width(ic), sprite_get_height(ic));
        	var bi = 0;
        	
        	if(ihover && point_in_rectangle(_m[0], _m[1], x, y, x + iw, y + h)) {
        		TOOLTIP = __txt("View node");
        		bi = 1;
        		
        		if(mouse_click(mb_left, iactive))
        			bi = 2;
        			
        		if(mouse_press(mb_left, iactive) && is(_path, Node))
        			New_Inspect_Node_Panel(_path);
        	}
        	
        	draw_sprite_stretched_ext(THEME.button_def, bi, x, y, iw, h);
        	
            draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, x + iw + ui(4), y, w - iw - ui(4), h, COLORS._main_icon_light);
            draw_sprite_ext(ic, 0, x + iw / 2, y + h / 2, _s, _s);
            
            draw_set_text(f_p2, fa_left, fa_center, COLORS._main_text_sub);
            draw_text_add(x + iw + ui(4 + 8), y + h / 2, is(_path, Node)? _path.getDisplayName() : "Path");
        }
        
		return h;
	}
	
	static clone = function() { return new pathnodeBox(); }
}
