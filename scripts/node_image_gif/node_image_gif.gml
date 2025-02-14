function Node_create_Image_gif(_x, _y, _group = noone) {
	var path = "";
	if(NODE_NEW_MANUAL) {
		path = get_open_filename_pxc("animated gif|*.gif", "");
		key_release();
		if(path == "") return noone;
	}
	
	var node = new Node_Image_gif(_x, _y, _group);
	node.skipDefault();
	node.inputs[0].setValue(path);
	if(NODE_NEW_MANUAL) node.doUpdate();
	
	return node;
}

function Node_create_Image_gif_path(_x, _y, path) {
	if(!file_exists_empty(path)) return noone;
	
	var node = new Node_Image_gif(_x, _y, PANEL_GRAPH.getCurrentContext());
	node.skipDefault();
	node.inputs[0].setValue(path);
	node.doUpdate();
	
	return node;
}

function Node_Image_gif(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name			= "Image GIF";
	color			= COLORS.node_blend_input;
	update_on_frame = true;
	setAlwaysTimeline(new timelineItemNode_Image_gif(self));
	
	newInput(0, nodeValue_Path("Path", self, ""))
		.setDisplay(VALUE_DISPLAY.path_load, { filter: "Animated gif|*.gif" });
		
	newInput(1, nodeValue_Trigger("Set animation length to gif", self, false ))
		.setDisplay(VALUE_DISPLAY.button, { name: "Match length", UI : true, onClick: function() /*=>*/ { 
				if(!spr || !sprite_exists(spr)) return;
				TOTAL_FRAMES = sprite_get_number(spr);
				PROJECT.animator.framerate = 12;
			} });
	
	newInput(2, nodeValue_Bool("Output as array", self, false));
	
	newInput(3, nodeValue_Enum_Scroll("Loop modes", self,  0, ["Loop", "Ping pong", "Hold last frame", "Hide"]))
		.rejectArray();
	
	newInput(4, nodeValue_Int("Start frame", self, 0));
	
	newInput(5, nodeValue_Bool("Custom frame order", self, false));
	
	newInput(6, nodeValue_Int("Frame", self, 0));
	
	newInput(7, nodeValue_Float("Animation speed", self, 1));
	
	newOutput(0, nodeValue_Output("Surface Out", self, VALUE_TYPE.surface, noone));
	newOutput(1, nodeValue_Output("Path", self, VALUE_TYPE.path, ""))
		.setVisible(true, true);
	
	detail = new Inspector_Label("Gif file");
	
	input_display_list = [ 
		["Image",	  false], 0, detail, 
		["Output",	  false], 2, 
		["Animation", false], 1, 3, 4, 7, 
		["Custom Frame Order", false, 5], 6,
	];
	
	attribute_surface_depth();
	
	spr			 = noone;
	path_current = "";
	loading		 = 0;
	spr_builder	 = noone; 
	surfaces	 = [];
	
	edit_time = 0;
	attributes.file_checker = true;
	array_push(attributeEditors, [ "File Watcher", function() /*=>*/ {return attributes.file_checker}, new checkBox(function() /*=>*/ { attributes.file_checker = !attributes.file_checker; }) ]);
	
	on_drop_file = function(path) {
		inputs[0].setValue(path);
		
		if(updatePaths(path)) { doUpdate(); return true; }
		return false;
	}
	
	setTrigger(1, __txt("Refresh"), [ THEME.refresh_icon, 1, COLORS._main_value_positive ], function() /*=>*/ { updatePaths(path_get(getInputData(0))); });
	
	function updatePaths(path = path_current) {
		if(path == -1) return false;
		
		var ext   = string_lower(filename_ext(path));
		var _name = string_replace(filename_name(path), filename_ext(path), "");
		
		if(ext != ".gif")
			return false;
		
		setDisplayName(_name);
		outputs[1].setValue(path);
		
		if(spr) sprite_delete(spr);
		sprite_add_gif(path, function(_spr) { 
			spr_builder = _spr; 
			loading = 2;
		});
		loading = 1;
				
		if(path_current == "") 
			first_update = true;
		path_current = path;
		edit_time    = max(edit_time, file_get_modify_s(path_current));	
		
		return true;
	}
	
	static step = function() {
		var _arr = getInputData(2);
		var _lop = getInputData(3);
		var _cus = getInputData(5);
		
		inputs[3].setVisible(!_arr);
		inputs[4].setVisible(!_cus);
		inputs[6].setVisible( _cus);
		inputs[7].setVisible(!_cus);
		
		if(loading == 2 && spr_builder != noone && spr_builder.building()) {
			surfaces = [];
			spr = spr_builder._spr;
			//print($"{spr}: {sprite_get_width(spr)}, {sprite_get_height(spr)}");
			detail.text = $"{filename_name(path_current)}\n{sprite_get_number(spr)} frames";
			
			triggerRender();
			loading = 0;
			
			gc_collect();
		}
		
		if(attributes.file_checker && file_exists_empty(path_current)) {
			var _modi = file_get_modify_s(path_current);
			
			if(_modi > edit_time) {
				edit_time = _modi;
				
				run_in(2, function() { updatePaths(); triggerRender(); });
			}
			
		}
	}
	
	static update = function(frame = CURRENT_FRAME) {
		var path = path_get(getInputData(0));
		if(path_current != path) updatePaths(path);
		
		if(!spr || !sprite_exists(spr)) return;
		
		var ww = sprite_get_width(spr);
		var hh = sprite_get_height(spr);
		
		var _outsurf = outputs[0].getValue();
		var array = getInputData(2);
		
		if(array) {
			var amo = sprite_get_number(spr);
			if(array_length(surfaces) == amo && is_surface(surfaces[0])) {
				outputs[0].setValue(surfaces);
				return;
			}
			
			surface_array_free(_outsurf);
			surfaces = array_create(amo);
			
			for( var i = 0; i < amo; i++ ) {
				surfaces[i] = surface_create_valid(ww, hh, attrDepth());
				
				surface_set_shader(surfaces[i]);
					draw_sprite(spr, i, 0, 0);
				surface_reset_shader();
			}
			
			outputs[0].setValue(surfaces);
			return;
		}
		
		var _loop = getInputData(3);
		var _strt = getInputData(4);
		var _cust = getInputData(5);
		var _spd  = getInputData(7);
		var _frm  = _cust? getInputData(6) : CURRENT_FRAME * _spd - _strt;
		
		var _len = sprite_get_number(spr);
		var _drw = true;
		
		switch(_loop) {
			case ANIMATION_END.loop : 
				_frm = safe_mod(_frm, _len);
				break;
			case ANIMATION_END.ping :
				_frm = safe_mod(_frm, _len * 2 - 2);
				if(_frm >= _len)
					_frm = _len * 2 - 2 - _frm;
				break;
			case ANIMATION_END.hold :
				_frm = clamp(_frm, -_len, _len - 1);
				break;
			case ANIMATION_END.hide :	
				if(_frm < 0 || _frm >= _len) 
					_drw = false;
				break;
		}
		
		_outsurf = surface_verify(_outsurf, ww, hh, attrDepth());
		outputs[0].setValue(_outsurf);
		
		surface_set_shader(_outsurf);
			if(_drw) draw_sprite(spr, _frm, 0, 0);
		surface_reset_shader();
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		if(loading) draw_sprite_ui(THEME.loading, 0, xx + w * _s / 2, yy + h * _s / 2, _s, _s, current_time / 2, COLORS._main_icon, 1);
	}
	
	static onDestroy = function() {
		if(sprite_exists(spr)) sprite_flush(spr);
	}
	
	static dropPath = function(path) {
		if(is_array(path)) path = array_safe_get(path, 0);
		if(!file_exists_empty(path)) return;
		
		inputs[0].setValue(path);
	}
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

function timelineItemNode_Image_gif(node) : timelineItemNode(node) constructor {
	
	static drawDopesheet = function(_x, _y, _s, _msx, _msy) {
		if(!is_instanceof(node, Node_Image_gif)) return;
		if(!node.attributes.show_timeline) return;
		
		var _spr = node.spr;
		if(!sprite_exists(_spr)) return;
		
		var _rx, _ry;
		var _sw = sprite_get_width(_spr);
		var _sh = sprite_get_height(_spr);
		var _ss = h / max(_sw, _sh);
		
		for (var i = 0, n = sprite_get_number(_spr); i < n; i++) {
			_rx = _x + (i + 1) * _s;
			_ry = h / 2 + _y;
			
			draw_sprite_ext(_spr, i, _rx - _sw * _ss / 2, _ry - _sh * _ss / 2, _ss, _ss, 0, c_white, .5);
		}
	}
	
	static drawDopesheetOver = function(_x, _y, _s, _msx, _msy, _hover, _focus) {
		if(!is_instanceof(node, Node_Image_gif)) return;
		if(!node.attributes.show_timeline) return;
		
		drawDopesheetOutput(_x, _y, _s, _msx, _msy);
	}
	
	static onSerialize = function(_map) {
		_map.type = "timelineItemNode_Image_gif";
	}
	
}