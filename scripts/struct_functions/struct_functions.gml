#macro struct_key variable_struct_get_names

function struct_has(s, k) { return is_struct(s) && variable_struct_exists(s, k); }

function struct_override(original, override) {
	var args = variable_struct_get_names(override);
	
	for( var i = 0, n = array_length(args); i < n; i++ ) {
		var _key = array_safe_get(args, i);
		
		if(!struct_has(original, _key)) continue;
		if(is_struct(original[$ _key]))
			original[$ _key] = struct_override(original[$ _key], override[$ _key]);
		else 
			original[$ _key] = override[$ _key];
	}
	
	return original;
}

function struct_override_nested(original, override) {
	var args = variable_struct_get_names(override);
	
	for( var i = 0, n = array_length(args); i < n; i++ ) {
		var _key = array_safe_get(args, i);
		
		if(!struct_has(original, _key)) continue;
		if(is_struct(original[$ _key]))
			struct_override_nested(original[$ _key], override[$ _key])
		else 
			original[$ _key] = override[$ _key];
	}
	
	return original;
}

function struct_append(original, append) {
	var args = variable_struct_get_names(append);
	
	for( var i = 0, n = array_length(args); i < n; i++ ) {
		var _key = array_safe_get(args, i);
		original[$ _key] = append[$ _key];
	}
	
	return original;
}

function struct_try_get(struct, key, def = 0) {
	if(struct[$ key] != undefined) return struct[$ key];
	
	key = string_replace_all(key, "_", " ");
	return struct[$ key] ?? def;
}

function struct_try_override(original, override, key) {
	if(!is_struct(original) || !is_struct(override)) return;
	if(!struct_has(override, key)) return;
	
	original[$ key] = override[$ key];
}

function struct_toggle(struct, key) {
	if(struct_has(struct, key)) struct_remove(struct, key);
	else                        struct[$ key] = 1;
}

function struct_find_key(struct, value) {
	var _keys = struct_get_names(struct);
	for( var i = 0, n = array_length(_keys); i < n; i++ )
		if(value == struct[$ _keys[i]]) return _keys[i];
	return undefined;
}