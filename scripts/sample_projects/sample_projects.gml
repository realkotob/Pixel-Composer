#region samples
	globalvar SAMPLE_PROJECTS;
	SAMPLE_PROJECTS = ds_list_create();
#endregion

function LOAD_FOLDER(list, folder) {
	var path = $"{DIRECTORY}Welcome files/{folder}";
	if(!directory_exists(path)) return;
	
	var file = file_find_first(path + "/*", fa_directory);
	
	while(file != "") {		
		var f = file;
		var full_path = path + "/" + file;
		file = file_find_next();
		
		if(!path_is_project(full_path)) continue;
		
		var f = new FileObject(full_path);
		var icon_path = string_replace(full_path, filename_ext(full_path), ".png");
			
		if(file_exists_empty(icon_path)) {
			f.spr = sprite_add(icon_path, 0, false, false, 0, 0);
			sprite_set_offset(f.spr, sprite_get_width(f.spr) / 2, sprite_get_height(f.spr) / 2);
		}
		
		f.tag = folder;
		
		ds_list_add(list, f);
	}
	file_find_close();
}

function LOAD_SAMPLE() {
	ds_list_clear(SAMPLE_PROJECTS);
	var zzip = "data/Welcome files/Welcome files.zip";
	var targ = $"{DIRECTORY}Welcome files";
	
	directory_verify(targ);
	zip_unzip(zzip, targ);
	
	var _dir = [];
	var path = $"{DIRECTORY}Welcome files/";
	var file = file_find_first(path + "/*", fa_directory);
	
	while(file != "") {		
		if(directory_exists(path + "/" + file)) 
			array_push(_dir, file);
		file = file_find_next();
	}
	file_find_close();
	
	for (var i = 0, n = array_length(PREFERENCES.welcome_file_order); i < n; i++) {
		LOAD_FOLDER(SAMPLE_PROJECTS, PREFERENCES.welcome_file_order[i]); 
		array_remove(_dir, PREFERENCES.welcome_file_order[i]);
	}	
	
	for (var i = 0, n = array_length(_dir); i < n; i++) 
		LOAD_FOLDER(SAMPLE_PROJECTS, _dir[i]); 
}