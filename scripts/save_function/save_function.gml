globalvar SAVING, IS_SAVING;
SAVING    = false;
IS_SAVING = false;

function NEW() {
	CALL("new");
	
	PROJECT = new Project();
	array_push(PROJECTS, PROJECT);
	
	var graph = new Panel_Graph(PROJECT);
	PANEL_GRAPH.panel.setContent(graph, true);
	PANEL_GRAPH = graph;
}

function SERIALIZE_PROJECT(project = PROJECT) {
	var _map = project.serialize();
	return PREFERENCES.save_file_minify? json_stringify_minify(_map) : json_stringify(_map, true);
}

function SET_PATH(project, path) {
	if(ASSERTING) return;
	
	if(path == "") {
		project.readonly = false;
		
	} else if(!project.readonly) {
		ds_list_remove(RECENT_FILES, path);
		ds_list_insert(RECENT_FILES, 0, path);
		while(ds_list_size(RECENT_FILES) > 64)
			ds_list_delete(RECENT_FILES, ds_list_size(RECENT_FILES) - 1);
		RECENT_SAVE();
		RECENT_REFRESH();
	}
	
	project.path = path;
}

function SAVE_ALL() {
	for( var i = 0, n = array_length(PROJECTS); i < n; i++ )
		SAVE(PROJECTS[i]);
}

function SAVE(project = PROJECT) {
	if(DEMO) return false;
	
	if(project.path == "" || project.freeze || project.readonly || path_is_backup(project.path))
		return SAVE_AS(project);
		
	return SAVE_AT(project, project.path);
}

function SAVE_AS(project = PROJECT) {
	if(DEMO) return false;
	
	var path = get_save_filename_pxc("Pixel Composer project (.pxc)|*.pxc|Compressed Pixel Composer project (.cpxc)|*.cpxc", "");
	key_release();
	if(path == "") return false;
	
	if(!path_is_project(path, false))
		path = filename_name_only(path) + ".pxc";
	
	if(file_exists_empty(path))
		log_warning("SAVE", "Overrided file : " + path);
	SAVE_AT(project, path);
	SET_PATH(project, path);
	
	return true;
}

function SAVE_AT(project = PROJECT, path = "", log = "save at ") {
	CALL("save");
	
	if(DEMO) return false;
	
	IS_SAVING = true;
	SAVING    = true;
	
	if(PREFERENCES.save_backup) {
		for(var i = PREFERENCES.save_backup - 1; i >= 0; i--) {
			var _p = path;
			if(i) _p = $"{path}{i}"
			
			if(file_exists(_p)) file_rename(_p, $"{path}{i + 1}");
		}
	}
	
	if(file_exists_empty(path)) file_delete(path);
	var _ext = filename_ext_raw(path);
	var _prj = SERIALIZE_PROJECT(project);
	var _cmp = PREFERENCES.save_compress;
	
    if(_cmp) buffer_save(buffer_compress_string(_prj), path);
	else     file_text_write_all(path, _prj);
	
	SAVING = false;
	project.readonly  = false;
	project.modified  = false;
	
	log_message("FILE", log + path, THEME.noti_icon_file_save);
	PANEL_MENU.setNotiIcon(THEME.noti_icon_file_save);
	
	return true;
}

/////////////////////////////////////////////////////// COLLECTION ///////////////////////////////////////////////////////

function SAVE_COLLECTIONS(_list, _path, save_surface = true, metadata = noone, context = PANEL_GRAPH.getCurrentContext()) {
	var _content = {};
	_content.version = SAVE_VERSION;
	
	var _nodes = [];
	var cx     = 0;
	var cy     = 0;
	var amo    = array_length(_list);
	
	for(var i = 0; i < amo; i++) {
		cx += _list[i].x;
		cy += _list[i].y;
	}
	
	cx = round((cx / amo) / 32) * 32;
	cy = round((cy / amo) / 32) * 32;
	
	if(save_surface) {
		var preview_surface = PANEL_PREVIEW.getNodePreviewSurface();
		if(is_surface(preview_surface)) {
			var icon_path = string_copy(_path, 1, string_length(_path) - 5) + ".png";
			surface_save_safe(preview_surface, icon_path);
		}
	}
	
	for(var i = 0; i < amo; i++)
		SAVE_NODE(_nodes, _list[i], cx, cy, true, context);
	_content.nodes = _nodes;
	
	json_save_struct(_path, _content, !PREFERENCES.save_file_minify);
	
	if(metadata != noone) {
		var _meta  = metadata.serialize();
		var _dir   = filename_dir(_path);
		var _name  = filename_name_only(_path);
		var _mpath = $"{_dir}/{_name}.meta";
		
		json_save_struct(_mpath, _meta, true);
	}
	
	var pane = findPanel("Panel_Collection");
	if(pane) pane.refreshContext();
	
	log_message("COLLECTION", "save collection at " + _path, THEME.noti_icon_file_save);
	PANEL_MENU.setNotiIcon(THEME.noti_icon_file_save);
}

function SAVE_NODE(_arr, _node, dx = 0, dy = 0, scale = false, context = PANEL_GRAPH.getCurrentContext()) {
	if(struct_has(_node, "nodes")) {
		for(var i = 0; i < array_length(_node.nodes); i++)
			SAVE_NODE(_arr, _node.nodes[i], dx, dy, scale, context);
	}
	
	var m = _node.serialize(scale);
	if(!is_struct(m)) return;
	
	m.x -= dx;
	m.y -= dy;
	
	if(context != noone && struct_has(m, "group") && m.group == context.node_id) 
		m.group = noone;
	
	array_push(_arr, m);
}

function SAVE_COLLECTION(_node, _path, save_surface = true, metadata = noone, context = PANEL_GRAPH.getCurrentContext()) {
	if(save_surface) {
		var preview_surface = PANEL_PREVIEW.getNodePreviewSurface();
		if(is_surface(preview_surface)) {
			var icon_path = string_replace(_path, filename_ext(_path), "") + ".png";
			surface_save_safe(preview_surface, icon_path);
		}
	}
	
	var _content = {};
	_content.version = SAVE_VERSION;
	
	var _nodes = [];
	SAVE_NODE(_nodes, _node, _node.x, _node.y, true, context);
	_content.nodes = _nodes;
	
	json_save_struct(_path, _content, !PREFERENCES.save_file_minify);
	
	if(metadata != noone) {
		var _meta  = metadata.serialize();
		var _dir   = filename_dir(_path);
		var _name  = filename_name_only(_path);
		var _mpath = $"{_dir}/{_name}.meta";
		
		_meta.version = SAVE_VERSION;
		json_save_struct(_mpath, _meta, true);
	}
	
	var pane = findPanel("Panel_Collection");
	if(pane) pane.refreshContext();
	
	log_message("COLLECTION", "save collection at " + _path, THEME.noti_icon_file_save);
	PANEL_MENU.setNotiIcon(THEME.noti_icon_file_save);
}

function SAVE_PXZ_COLLECTION(_node, _path, _surf = noone, metadata = noone, context = PANEL_GRAPH.getCurrentContext()) {
	var _name = filename_name_only(_path);
	var _path_icon = "";
	var _path_node = "";
	var _path_meta = "";
	
	if(is_surface(_surf)) {
		_path_icon = $"{TEMPDIR}{_name}.png";
		surface_save_safe(_surf, _path_icon);
	}
	
	var _content = {};
	_content.version = SAVE_VERSION;
	
	var _nodes = [];
	SAVE_NODE(_nodes, _node, _node.x, _node.y, true, context);
	_content.nodes = _nodes;
	
	_path_node = $"{TEMPDIR}{_name}.pxcc";
	json_save_struct(_path_node, _content, !PREFERENCES.save_file_minify);
	
	if(metadata != noone) {
		var _meta  = metadata.serialize();
		var _dir   = filename_dir(_path);
		var _name  = filename_name_only(_path);
		_path_meta = $"{TEMPDIR}{_name}.meta";
		
		_meta.version = SAVE_VERSION;
		json_save_struct(_path_meta, _meta, true);
	}
	
	print(_path_node);
	
	var _z = zip_create();
	if(_path_icon != "") zip_add_file(_z, $"{_name}.png",  _path_icon);
	if(_path_node != "") zip_add_file(_z, $"{_name}.pxcc", _path_node);
	if(_path_meta != "") zip_add_file(_z, $"{_name}.meta", _path_meta);
	zip_save(_z, _path);
	
	var pane = findPanel("Panel_Collection");
	if(pane) pane.refreshContext();
	
	log_message("COLLECTION", "save collection at " + _path, THEME.noti_icon_file_save);
	PANEL_MENU.setNotiIcon(THEME.noti_icon_file_save);
}