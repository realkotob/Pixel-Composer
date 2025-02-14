globalvar THEME_DEF; THEME_DEF = true;

function __initTheme() {
	var root = DIRECTORY + "Themes";
	var t    = get_timer();
	
	directory_verify(root);
	
	if(check_version($"{root}/version")) {
		zip_unzip("data/Theme.zip", root);	printDebug($"     > Unzip theme  | complete in {get_timer() - t}");    t = get_timer();
	}
	
	loadGraphic(PREFERENCES.theme);			printDebug($"     > Load graphic | complete in {get_timer() - t}");    t = get_timer();
	loadColor(PREFERENCES.theme);			printDebug($"     > Load color   | complete in {get_timer() - t}");    t = get_timer();
}

function _sprite_path(rel, theme) { INLINE return $"{DIRECTORY}Themes/{theme}/graphics/{string_replace_all(rel, "./", "")}"; }

function _sprite_load_from_struct(str, theme, key) {
	var path = _sprite_path(str.path, theme);
	var numb = struct_try_get(str, "s", 1);
	var sx   = struct_try_get(str, "x", 0);
	var sy   = struct_try_get(str, "y", 0);
	
	var s    = sprite_add(path, numb, false, true, sx, sy);
	if(s < 0) { log_message("THEME", $"Load sprite {path} failed."); return 0; }
		
	if(!struct_has(str, "slice")) return s;
	
	var slice = sprite_nineslice_create();	
	slice.enabled = true;
	
	if(is_array(str.slice)) {
		slice.left    = str.slice[0];
		slice.right   = str.slice[1];
		slice.top     = str.slice[2];
		slice.bottom  = str.slice[3];
		
	} else if(is_real(str.slice)) {
		slice.left    = str.slice;
		slice.right   = str.slice;
		slice.top     = str.slice;
		slice.bottom  = str.slice;
		
	}
	
	if(struct_has(str, "slicemode"))
		slice.tilemode = array_create(5, str.slicemode);
	
	sprite_set_nineslice(s, slice);
	
	return s; 
}

function loadGraphic(theme = "default") {
	THEME = {};
	
	var path   = _sprite_path("./graphics.json", theme);
	var sprDef = json_load_struct(_sprite_path("./graphics.json", "default"));
	var _metaP = $"{DIRECTORY}Themes/{theme}/meta.json";
	
	if(!file_exists_empty(_metaP))
		noti_warning("Loading theme made for older version.");
	else {
		var _meta = json_load_struct(_metaP);
		if(_meta[$ "version"] < VERSION)
			noti_warning("Loading theme made for older version.");
	}
	
	printDebug($"Loading theme {theme}");
	if(!file_exists_empty(path)) { print($"Theme not defined at {path}, rollback to default theme."); return; }
	
	var sprStr   = json_load_struct(path);
	var graphics = variable_struct_get_names(sprStr);
	var str, key;
	
	for( var i = 0, n = array_length(graphics); i < n; i++ ) {
		key = graphics[i];
		str = sprStr[$ key];
		
		THEME[$ key] = _sprite_load_from_struct(str, theme, key);
	}
}