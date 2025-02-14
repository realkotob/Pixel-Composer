globalvar FONT_DEF, FONT_ISLOADED, FONT_CACHE, FONT_CUST_CACHE, GLYPH_MAP, FONT_LIST;
globalvar f_h1, f_h2, f_h3, f_h5, f_p0, f_p0b, f_p1, f_p1b, f_p2, f_p2b, f_p3, f_p4;
globalvar f_code, f_sdf, f_sdf_medium;

global.LINE_HEIGHTS = {};

#region default
	FONT_DEF        = true;
	FONT_CACHE      = {};
	FONT_CUST_CACHE = {};
	FONT_ISLOADED   = false;
	GLYPH_MAP       = {};
	FONT_LIST       = {};
	
	f_h1   = _f_h1;
	f_h2   = _f_h2;
	f_h3   = _f_h3;
	f_h5   = _f_h5;
	f_p0   = _f_p0;
	f_p0b  = _f_p0b;
	f_p1   = _f_p1;
	f_p1b  = _f_p1b;
	f_p2   = _f_p2;
	f_p2b  = _f_p2b;
	f_p3   = _f_p3;
	f_p4   = _f_p4;
	
	f_code = _f_code;
	f_sdf  = _f_sdf;
	f_sdf_medium  = _f_sdf_medium;
	FONT_ISLOADED = false;
#endregion

function __font_add_height(font) {
	INLINE 
	
	draw_set_font(font);
	global.LINE_HEIGHTS[$ font] = string_height("l");
}

function __font_refresh() {
	__font_add_height(f_h1);
	__font_add_height(f_h2);
	__font_add_height(f_h3);
	__font_add_height(f_h5);
					
	__font_add_height(f_p0);
	__font_add_height(f_p0b);
		
	__font_add_height(f_p1);
	__font_add_height(f_p1b);
	
	__font_add_height(f_p2);
	__font_add_height(f_p2b);
	
	__font_add_height(f_p3);
	__font_add_height(f_p4);
		
	__font_add_height(f_code);
	__font_add_height(f_sdf);
	__font_add_height(f_sdf_medium);
}

function _font_add(path, size, sdf = false, custom = false) {
	var _cache = custom? FONT_CUST_CACHE : FONT_CACHE;
	var font_cache_dir = DIRECTORY + "font_cache";
	directory_verify(font_cache_dir);
	
	var _key = $"{filename_name_only(path)}_{size}_{sdf}";
	if(struct_has(_cache, _key) && font_exists(_cache[$ _key]))
		return _cache[$ _key];
	
	var _t = current_time;
	var _f = font_add(path, size, false, false, 0, 0);
	if(sdf) font_enable_sdf(_f, true);
	_cache[$ _key] = _f;
	
	_font_extend_locale(_f, _f);
	
	return _f;
}

function _font_extend_locale(baseFont, localFont, override = false) {
	if(!struct_exists(GLYPH_MAP, baseFont))
		GLYPH_MAP[$ baseFont] = {};
	
	var Gmap    = GLYPH_MAP[$ baseFont];
	var _fInfo  = font_get_info(localFont);
	var _gMap   = _fInfo.glyphs;
	var _glyphs = variable_struct_get_names(_gMap);
	
	for( var i = 0, n = array_length(_glyphs); i < n; i++ ) {
		var _g = _glyphs[i];
		if(_gMap[$ _g] == undefined) continue;
		
		if(override || !struct_has(Gmap, _g))
			Gmap[$ _g] = localFont;
	}
}

function _font_path(rel) {
	rel = string_replace_all(rel, "./", "");
	var defPath = $"{DIRECTORY}Themes/{PREFERENCES.theme}/fonts/{rel}";
	
	if(LOCALE.fontDir == noone)
		return defPath;
	
	var overridePath = $"{LOCALE.fontDir}{rel}";
	if(file_exists_empty(overridePath))
		return overridePath;
	
	return defPath;
}

function _font_load_default(name, def) {
	FONT_LIST[$ name] = { data: noone, font: def }
	return def;
}

function _font_load_from_struct(str, name, def, over = true) {
	if(!struct_has(str, name)) return def;
	
	var font = str[$ name];
	var path = "";
	
	if(over && file_exists_empty(PREFERENCES.font_overwrite)) 
		path = PREFERENCES.font_overwrite;
	else
		path = _font_path(font.path);
	
	if(!file_exists_empty(path)) {
		noti_status($"Font resource {path} not found. Rollback to default font.");
		return def;
	}
	
	font_add_enable_aa(THEME_VALUE.font_aa);
	var _sdf  = struct_try_get(font, "sdf", false);
	var _font = _font_add(path, round(font.size * UI_SCALE), _sdf);
	
	FONT_LIST[$ name] = { data: str, font: _font }
	
	return _font;
}

function font_clear(font) { if(font_exists(font)) font_delete(font); }

function loadFonts() {
	
	if(FONT_ISLOADED) {
		font_clear(f_h1);
		font_clear(f_h2);
		font_clear(f_h3);
		font_clear(f_h5);
					
		font_clear(f_p0);
		font_clear(f_p0b);
					
		font_clear(f_p1);
		font_clear(f_p1b);
		
		font_clear(f_p2);
		font_clear(f_p2b);
		
		font_clear(f_p3);
		font_clear(f_p4);
		
		font_clear(f_code);
		font_clear(f_sdf);
		font_clear(f_sdf_medium);
	}
	
	var path = _font_path("./fonts.json");
	
	FONT_LIST = {};
	
	if(FONT_DEF) {
		f_h1   = _font_load_default("h1",  _f_h1);
		f_h2   = _font_load_default("h2",  _f_h2);
		f_h3   = _font_load_default("h3",  _f_h3);
		f_h5   = _font_load_default("h5",  _f_h5);
		f_p0   = _font_load_default("p0",  _f_p0);
		f_p0b  = _font_load_default("p0b", _f_p0b);
		f_p1   = _font_load_default("p1",  _f_p1);
		f_p1b  = _font_load_default("p1b", _f_p1b);
		f_p2   = _font_load_default("p2",  _f_p2);
		f_p2b  = _font_load_default("p2b", _f_p2b);
		
		f_p3   = _font_load_default("p3",  _f_p3);
		f_p4   = _font_load_default("p4",  _f_p4);
		
		f_code = _font_load_default("code", _f_code);
		f_sdf  = _font_load_default("sdf",  _f_sdf);
		f_sdf_medium  = _font_load_default("sdf_medium", _f_sdf_medium);
		FONT_ISLOADED = false;
		
		__font_refresh();
		return;
	}
	
	var s = file_read_all(path);
	var fontDef = json_try_parse(s);
	
	f_h1  = _font_load_from_struct(fontDef, "h1", _f_h1);
	f_h2  = _font_load_from_struct(fontDef, "h2", _f_h2);
	f_h3  = _font_load_from_struct(fontDef, "h3", _f_h3);
	f_h5  = _font_load_from_struct(fontDef, "h5", _f_h5);
	
	f_p0  = _font_load_from_struct(fontDef, "p0",  _f_p0);
	f_p0b = _font_load_from_struct(fontDef, "p0b", _f_p0b);
	
	f_p1  = _font_load_from_struct(fontDef, "p1",  _f_p1);
	f_p1b = _font_load_from_struct(fontDef, "p1b", _f_p1b);
	
	f_p2  = _font_load_from_struct(fontDef, "p2", _f_p2);
	f_p3  = _font_load_from_struct(fontDef, "p3", _f_p3);
	f_p4  = _font_load_from_struct(fontDef, "p4", _f_p4);
	
	f_code = _font_load_from_struct(fontDef, "code", _f_code, false);
	f_sdf  = _font_load_from_struct(fontDef, "sdf",  _f_sdf);
	f_sdf_medium = _font_load_from_struct(fontDef, "sdf_medium",  _f_sdf_medium);
	
	FONT_ISLOADED = true;
	
	__font_refresh();
}

#region unused font cache
	//function __fontCache() { 
	//	var _f = font_add("LXGWWenKaiMonoLite-Bold.ttf", 16, false, false, 0, 0);
	//	var _fInfo  = font_get_info(_f);
	//	var _gMap   = _fInfo.glyphs;
	//	var _glyphs = variable_struct_get_names(_gMap);
	
	//	draw_set_text(_f, fa_left, fa_top, c_white);
	
	//	for( var i = 0, n = array_length(_glyphs); i < n; i++ ) {
	//		var _g     = _glyphs[i];
	//		var _glyph = _gMap[$ _g];
		
	//		if(_glyph.w == 0 || _glyph.h == 0) continue;
		
	//		var _s = surface_create(_glyph.w, _glyph.h);
	//		surface_set_target(_s); DRAW_CLEAR
	//			draw_text(0, 0, chr(_glyph.char));
	//		surface_reset_target();
		
	//		surface_save(_s, $"{DIRECTORY}Locale/extend/cache/{_glyph.char}.png");
	//		surface_clear(_s);
	//	}
	//} run_in(1, __fontCache); 
#endregion
