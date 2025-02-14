/// @description init
if(winMan_isMinimized()) exit;
winManStep();

//print("===== Step start =====");

if(!LOADING && PROJECT.active && !PROJECT.safeMode) { //node step
	PROJECT.step();
	LIVE_UPDATE = false;
	
	try {
		if(PANEL_MAIN != 0) PANEL_MAIN.step();
		array_foreach(PROJECT.allNodes, function(_node) /*=>*/ { 
			if(!_node.active) return; 
			if(_node.input_button_length || _node.use_trigger) _node.triggerCheck(); 
			_node.step(); 
		});
	} catch(e) {
		noti_warning("Step error: " + exception_print(e));
	}
	
	PROJECT.postStep();
	IS_SAVING = false;
}

#region hotkey
	if(!HOTKEY_BLOCK) {
		var _action = false;
		
		if(!HOTKEY_ACT && struct_has(HOTKEYS, 0)) {
			var l = HOTKEYS[$ 0];
			for(var i = 0, n = ds_list_size(l); i < n; i++) {
				var hotkey = l[| i];
				if(hotkey.key == 0 && hotkey.modi == MOD_KEY.none) continue;
				
				if(key_press(hotkey.key, hotkey.modi, true)) {
					hotkey.action();
					_action |= hotkey.key != noone;
				}
			}
		}
		
		if(!HOTKEY_ACT && struct_has(HOTKEYS, FOCUS_STR)) {
			var list = HOTKEYS[$ FOCUS_STR];
			for(var i = 0, n = ds_list_size(list); i < n; i++) {
				var hotkey = list[| i];
				if(hotkey.key == 0 && hotkey.modi == MOD_KEY.none) continue;
				
				if(key_press(hotkey.key, hotkey.modi, true)) {
					hotkey.action();
					_action |= hotkey.key != noone;
				}
			}
		}
		
		HOTKEY_ACT |= _action;
	}
	
	HOTKEY_BLOCK = false;
#endregion

#region GIF builder
	for( var i = 0; i < ds_list_size(GIF_READER); i++ ) {
		var _reader = GIF_READER[| i];
		
		var _reading = _reader[0].reading();
		if(_reading) {
			var ret = _reader[2];
			ret(new __gif_sprite_builder(_reader[0]));
			ds_stack_push(gif_complete_st, i);
		}
	}
	
	while(!ds_stack_empty(gif_complete_st)) {
		var i = ds_stack_pop(gif_complete_st);
		buffer_delete(GIF_READER[| i][1]);
		delete GIF_READER[| i][0];
		ds_list_delete(GIF_READER, i);
	}
#endregion

#region file drop
	if(OS == os_macosx) {		
		file_dnd_set_files(file_dnd_pattern, file_dnd_allowfiles, file_dnd_allowdirs, file_dnd_allowmulti);
		file_dnd_filelist = file_dnd_get_files();
		
		if(file_dnd_filelist != "" && _file_dnd_filelist != file_dnd_filelist) {
			var path  = string_trim(file_dnd_filelist);
			load_file_path(string_splice(path, "\n"));
		}
		
		_file_dnd_filelist = file_dnd_filelist;
	}
#endregion

#region window
	if(_modified != PROJECT.modified) {
		_modified = PROJECT.modified;
		
		var cap = "";
		if(PROJECT.safeMode) cap += "[SAFE MODE] ";
		if(PROJECT.readonly) cap += "[READ ONLY] ";
		cap += PROJECT.path + (PROJECT.modified? "*" : "") + " - Pixel Composer";
		
		window_set_caption(cap);
	}
#endregion

#region notification
	if(!ds_list_empty(WARNING)) {
		var rem = ds_stack_create();
		
		for( var i = 0; i < ds_list_size(WARNING); i++ ) {
			var w = WARNING[| i];
			if(--w.life <= 0)
				ds_stack_push(rem, w);
		}
		
		while(!ds_stack_empty(rem)) {
			ds_list_delete(WARNING, ds_stack_pop(rem));	
		}
		
		ds_stack_destroy(rem);
	}
#endregion

#region steam
	steam_update();
	
	if(STEAM_ENABLED) {
		if (steam_is_screenshot_requested()) {
		    var file = $"PixelComposer_{seed_random(6)}.png";
		    screen_save(file);
		    steam_send_screenshot(file, window_get_width(), window_get_height());
		}
		
		if (steam_avatar_id > 0 && STEAM_AVATAR == 0) {
		    var _l_dims    = steam_image_get_size(steam_avatar_id);
		    var _buff_size = _l_dims[0] * _l_dims[1] * 4;
		    var _l_cols    = buffer_create(_buff_size, buffer_fixed, 1);
			var _l_ok      = steam_image_get_rgba(steam_avatar_id, _l_cols, _buff_size);
		
		    if(_l_ok) {
			    var _l_surf = surface_create(_l_dims[0], _l_dims[1]);
			    buffer_set_surface(_l_cols, _l_surf, 0);
			    
				STEAM_AVATAR = sprite_create_from_surface(_l_surf, 0, 0, _l_dims[0], _l_dims[1], false, false, 0, 0);
				surface_free(_l_surf);
		    }
		    
		    buffer_delete(_l_cols);
		}
	}
	
	// var _s = gc_get_stats();
	// if(_s.objects_touched) print($"{string_lead_zero(_s.objects_touched, 7, " ")}, {string_lead_zero(_s.objects_collected, 7, " ")}, {string_lead_zero(_s.traversal_time, 6, " ")}");
#endregion