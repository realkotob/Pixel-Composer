enum FILE_EXPLORER_VIEW {
	list,
	grid
}

global.__temp_fileMap = {}

function ExpCreateFile(path) {
	INLINE
	if(struct_has(global.__temp_fileMap, path)) return global.__temp_fileMap[$ path];
	
	var f = directory_exists(path)? new ExpDir(path) : new ExpFile(path);
	global.__temp_fileMap[$ path] = f;
	return f;
}

function ExpFile(path) constructor {
	self.path = string_trim(path, [ "/", "\\" ]);
	name      = filename_name_only(path);
	ext       = filename_ext_raw(path);
	parent    = noone;
	
	load_thumb = false;
	thumbnail  = noone;
	th_w = 1;
	th_h = 1;
	
	static getThumbnail = function() {
		if(thumbnail == -1) return noone;
		else if(thumbnail != noone && sprite_exists(thumbnail)) return thumbnail;
		
		thumbnail = -1;
		switch(ext) {
			case "png" :
			case "jpg" :
				thumbnail = sprite_add(path, 0, 0, 0, 0, 0);
				if(thumbnail) {
					load_thumb = true;
					th_w = sprite_get_width(thumbnail);
					th_h = sprite_get_height(thumbnail);
					sprite_set_offset(thumbnail, th_w / 2, th_h / 2);
				}
				break;
				
			case "cpxc":
			case "pxc":
			case "pxcc":
				thumbnail = THEME.icon_64;
				th_w = 64;
				th_h = 64;
				break;
		}
		
		return thumbnail;
	}
	
	static refreshThumbnail = function() {
		if(sprite_exists(thumbnail))
			sprite_delete(thumbnail);
		thumbnail = noone;
	}
	
	static destroy = function() {
		if(load_thumb) sprite_delete(thumbnail);
	}
}

function ExpDir(path) : ExpFile(path) constructor {
	directories = [];
	files       = [];
	
	open = -1; 
	
	static getContent = function() {
		directories = [];
		files       = [];
		
		if(!directory_exists(path)) return;
		var f = file_find_first(path + "/*", fa_directory), fp;
		
		while (f != "") {
			fp = $"{path}/{f}";
		    f  = file_find_next();
		    if(!directory_exists(fp)) continue;
			
			var _fileObj = ExpCreateFile(fp);
			_fileObj.parent = self;
	    	array_push(directories, _fileObj);
		}
		
		file_find_close();
		var f = file_find_first(path + "/*", fa_none);
		while (f != "") {
			fp = $"{path}/{f}";
		    f  = file_find_next();
			if(!file_exists(fp) || directory_exists(fp)) continue;
		    
			var _fileObj = ExpCreateFile(fp);
			_fileObj.parent = self;
	    	array_push(files, _fileObj);
		}
		
		file_find_close();
		
		return self;
	}
	
	static destroy = function() {
		array_foreach(directories, function(dir) { dir.destroy(); return true; });
		array_foreach(files,       function(fil) { fil.destroy(); return true; });
	}
}

function ExpRoot() constructor {
	name = "Computer";
	directories = [];
	files       = [];
	
	open = -1; 
	
	static getContent = function() {
		directories = [];
		for(var i = 0; i < 26; i++) {
			var _dr = $"{chr(ord("A") + i)}:";
			if(directory_exists(_dr))
				array_push(directories, new ExpDir(_dr));
		}
	} getContent();
	
	static destroy = function() {
		array_foreach(directories, function(dir) { dir.destroy(); return true; });
	}
}

function Panel_File_Explorer() : PanelContent() constructor {
	title    = "File Explorer";
	w        = ui(320);
	h        = ui(540);
	auto_pin = true;
	
	fileMap  = {};
	global.__temp_fileMap = fileMap;
	
	rootFile = noone;
	function setRoot(_root = "") {
		if(rootFile) rootFile.destroy();
		
		if(_root != "" && directory_exists(_root)) {
			root = _root;
			rootFile = new ExpDir(root).getContent();
			
			PREFERENCES.file_explorer = root;
			return;
		}
		
		rootFile = new ExpRoot();
		root = "";
		
		PREFERENCES.file_explorer = root;
		
	} setRoot(PREFERENCES.file_explorer);
	
	view_mode = PREFERENCES.file_explorer_view;
	view_mode_tooltip = new tooltipSelector(__txt("View mode"), [ __txt("List"), __txt("Grid") ]);
	
	scroll_y     = 0;
	scroll_y_to  = 0;
	scroll_y_max = 0;
	
	item_height  = ui(20);
	grid_size    = ui(64);
	
	cntPad  = ui(4);
	padding = ui(8);
	top_bar = ui(44);
	tb_root = new textBox(TEXTBOX_INPUT.text, function(v) /*=>*/ {return setRoot(v)});
	
	file_selectings  = [];
	file_hovering    = noone;
	context_hovering = noone;
	
	file_dragging    = false;
	file_drag_mx     = 0;
	file_drag_my     = 0;
	
	draggable        = true;
	frame_dragging   = false;
	frame_drag_mx    = false;
	frame_drag_my    = false;
	
	path_dragging    = -1;
	file_focus       = noone;
	
	#region menu
		__menu_file_selecting = noone;
		__menu_cnxt_selecting = noone;
		
		menu_file_image = [
			menuItem("Add as node", function() /*=>*/ {
				var node = Node_create_Image_path(PANEL_GRAPH.graph_cx, PANEL_GRAPH.graph_cy, __menu_file_selecting.path);
				PANEL_PREVIEW.setNodePreview(node);
				PANEL_INSPECTOR.inspecting = node;
			}),
			
			menuItem("Add as canvas", function() /*=>*/ {
				var node = nodeBuild("Node_Canvas", PANEL_GRAPH.graph_cx, PANEL_GRAPH.graph_cy).loadImagePath(__menu_file_selecting.path);
				PANEL_PREVIEW.setNodePreview(node);
				PANEL_INSPECTOR.inspecting = node;
			}),
			
			menuItem("Copy path", function() /*=>*/ { clipboard_set_text(__menu_file_selecting.path); }, THEME.copy),
		];
		
		menu_file_project = [ 
			menuItem("Open",      function() /*=>*/ { LOAD_AT(__menu_file_selecting.path); }), 
			menuItem("Copy path", function() /*=>*/ { clipboard_set_text(__menu_file_selecting.path); }, THEME.copy),
		];
		
		menu_general = [ 
			menuItem("New Canvas", function() /*=>*/ { 
				var dia = dialogCall(o_dialog_file_name, mouse_mx + 8, mouse_my + 8);
				dia.onModify = function (txt) {
					var _s = surface_create(DEF_SURF_W, DEF_SURF_H);
					surface_clear(_s);
					surface_save(_s, txt);
					surface_free(_s);
					
					var node = nodeBuild("Node_Canvas", PANEL_GRAPH.graph_cx, PANEL_GRAPH.graph_cy).loadImagePath(txt);
					PANEL_PREVIEW.setNodePreview(node);
					PANEL_INSPECTOR.inspecting = node;
					
					__menu_cnxt_selecting.getContent();
				};
				dia.path = __menu_cnxt_selecting.path + "/";
			}, THEME.new_file), 
			
			menuItem("New Folder", function() /*=>*/ { 
				var dia = dialogCall(o_dialog_file_name, mouse_mx + 8, mouse_my + 8);
				dia.name = "New Folder";
				dia.onModify = function (txt) {
					directory_create(txt);
					__menu_cnxt_selecting.getContent();
				};
				dia.path = __menu_cnxt_selecting.path + "/";
			}, THEME.folder), 
			
			-1,
			menuItem("Refresh", function() /*=>*/ { if(rootFile) rootFile.getContent() }), 
		];
	#endregion
	
	function onFocusBegin() { PANEL_FILE = self; }
	
	function drawDir(dirObject, _x, _y, _w, _m) {
		var _h  = 0;
		var _sy = _y;
		
		draw_set_text(f_p2, fa_left, fa_top, COLORS._main_text);
		var _ith = line_get_height() + ui(4);
		
		var _graph_x = PANEL_GRAPH.graph_cx;
		var _graph_y = PANEL_GRAPH.graph_cy;
		
		for (var i = 0, n = array_length(dirObject.directories); i < n; i++) {
			draw_set_text(f_p2, fa_left, fa_top, COLORS._main_text);
			var _dir = dirObject.directories[i];
			
			var _px  = _x  + ui(2);
			var _py  = _sy + ui(2);
			var _pw  = _w  - ui(4);
			var _ph  = _ith;
			
			var _ind = 0;
			var _ppw = _pw;
			
			if(point_in_rectangle(_m[0], _m[1], _px, _py, _px + _pw, _py + _ph)) {
				if(buttonInstant(THEME.button_hide_fill, _px + _ppw - _ph, _py, _ph, _ph, _m, pHOVER, pFOCUS, "Set as root", THEME.path_open_20) == 2)
					setRoot(_dir.path);
				_ppw -= _ph + ui(2);
				
				if(buttonInstant(THEME.button_hide_fill, _px + _ppw - _ph, _py, _ph, _ph, _m, pHOVER, pFOCUS, "Copy path", THEME.copy_20) == 2)
					clipboard_set_text(_dir.path);
				_ppw -= _ph + ui(2);
				
			}
			
			if(contentPane.hover && point_in_rectangle(_m[0], _m[1], _px, _py, _px + _ppw, _py + _ph)) {
				file_hovering = _dir;
				_ind = 3;
				
				if(mouse_press(mb_left)) {
					if(_dir.open == -1)
						_dir.getContent();
					_dir.open = !_dir.open;
				}
				
			}
			
			draw_sprite_stretched(THEME.ui_panel_bg, _ind, _px, _py, _ppw, _ph);
			
			var _tx = _px + ui(2);
			var _ty = _py + ui(2);
			
			draw_sprite_ext(THEME.arrow, _dir.open? 3 : 0, _tx + _ph / 2, _py + _ph / 2, 1, 1, 0, COLORS._main_icon, 1);
			_tx += _ph + ui(2);
			draw_set_color(merge_color(COLORS._main_text, COLORS._main_text_sub, 0.5));
			draw_text_add(_tx, _ty, _dir.name);
			
			_h  += _ith + ui(2);
			_sy += _ith + ui(2);
			
			if(_dir.open) {
				var _drh = drawDir(_dir, _x + ui(8), _sy, _w - ui(8), _m);
				_h  += _drh;
				_sy += _drh;
			}
		}
		
		if(array_length(dirObject.files)) { _h  += ui(4); _sy += ui(4); }
		
		if(view_mode == FILE_EXPLORER_VIEW.list) {
			draw_set_text(f_p2, fa_left, fa_top, COLORS._main_text);
			
			for (var i = 0, n = array_length(dirObject.files); i < n; i++) {
				var _fil = dirObject.files[i];
				
				var _px  = _x  + ui(2);
				var _py  = _sy + ui(2);
				var _pw  = _w  - ui(4);
				var _ph  = _ith;
				
				var _tw = ui(4) + _ph + string_width(_fil.name) + ui(8);
				
				if(frame_dragging && rectangle_in_rectangle(_px, _py, _px + _tw, _py + _ph, frame_drag_mx, frame_drag_my, _m[0], _m[1]))
					array_push(file_selectings, _fil);
				
				var _sel = array_exists(file_selectings, _fil);
				var _tx = _px + ui(2);
				var _ty = _py + ui(2);
				var _th = _fil.getThumbnail();
				
				if(_sel) draw_sprite_stretched_ext(THEME.ui_panel_bg, 4, _px, _py, _tw, _ph, merge_color(COLORS._main_icon_dark, COLORS._main_icon, 0.2), 1);
				
				if(point_in_rectangle(_m[0], _m[1], _px, _py, _px + _pw, _py + _ph)) {
					var _bx = _px + _tw + ui(4);
					
					if(path_is_image(_fil.path)) {
						if(buttonInstant(noone, _bx, _py, _ph, _ph, _m, pHOVER, pFOCUS, "Import as Image", THEME.image_20, 0, [ COLORS._main_icon, c_white ]) == 2) {
							Node_create_Image_path(_graph_x, _graph_y, _fil.path);
							draggable = false;
						} _bx += _ph + ui(2);
						
						if(buttonInstant(noone, _bx, _py, _ph, _ph, _m, pHOVER, pFOCUS, "Import as Canvas", THEME.canvas_20, 0, [ COLORS._main_icon, c_white ]) == 2) {
							var node = nodeBuild("Node_Canvas", _graph_x, _graph_y).loadImagePath(_fil.path);
							PANEL_PREVIEW.setNodePreview(node);
							PANEL_INSPECTOR.inspecting = node;
							
							draggable = false;
						} _bx += _ph + ui(2);
						
					} else if(path_is_project(_fil.path)) {
						if(buttonInstant(noone, _bx, _py, _ph, _ph, _m, pHOVER, pFOCUS, "Open Project", THEME.path_open_20, 0, [ COLORS._main_icon, c_white ]) == 2) {
							LOAD_AT(_fil.path);
							draggable = false;
						} _bx += _ph + ui(2);
						
					}
				}
				
				if(contentPane.hover && point_in_rectangle(_m[0], _m[1], _px, _py, _px + _tw, _py + _ph)) {
					if(!mouse_click(mb_left)) {
						draw_sprite_stretched_ext(THEME.ui_panel, 1, _px, _py, _tw, _ph, COLORS._main_icon, .75);
						if(!instance_exists(o_dialog_menubox))
							TOOLTIP = [ _th, "sprite" ];
					}
					
					file_hovering = _fil;
					
					if(pFOCUS && mouse_press(mb_left) && key_mod_press(CTRL)) {
						if(_sel) array_remove(file_selectings, _fil);
						else     array_push(file_selectings, _fil);
					} 
					
					if(pFOCUS && mouse_press(mb_right)) {
						__menu_file_selecting = _fil;
						
							 if(path_is_image(_fil.path))   menuCall("", menu_file_image);
						else if(path_is_project(_fil.path)) menuCall("", menu_file_project);
					}
					
					if(pFOCUS && DOUBLE_CLICK)
						load_file_path([ _fil.path ], _graph_x, _graph_y);
				}
				
				if(sprite_exists(_th)) {
					gpu_set_texfilter(true);
					var _ths = min(1, (_ph - ui(4)) / _fil.th_w, (_ph - ui(4)) / _fil.th_h);
					draw_sprite_ext(_th, 0, _tx + _ph / 2, _py + _ph / 2, _ths, _ths, 0, c_white, 1);
					gpu_set_texfilter(false);
				}
				_tx += _ph + ui(4);
				
				var _cc = COLORS._main_text;
				if(_fil == file_focus)        _cc = COLORS._main_value_positive;
				if(_fil.path == PROJECT.path) _cc = COLORS._main_accent;
				
				draw_set_color(_cc);
				draw_text_add(_tx, _ty, _fil.name);
				
				_h  += _ith + ui(2);
				_sy += _ith + ui(2);
			}
			
		} else if(view_mode == FILE_EXPLORER_VIEW.grid) {
			var _grid_width  = grid_size + 1.25;
			var _grid_height = grid_size;
			var _grid_spac   = ui(4);
			var _title_heigh = ui(24);
			draw_set_text(f_p3, fa_center, fa_bottom, COLORS._main_text);
			
			var _amo = array_length(dirObject.files);
			var _col = floor(_w / (_grid_width + _grid_spac));
			_grid_width = (_w - (_col - 1) * _grid_spac) / _col;
			
			for (var i = 0; i < _amo; i++) {
				var _cind = i % _col;
				var _rind = floor(i / _col);
				
				var _px  = _x  + _cind * (_grid_width  + _grid_spac);
				var _py  = _sy + _rind * (_grid_height + _title_heigh + _grid_spac);
				var _pw  = _grid_width;
				var _ph  = _grid_height + _title_heigh;
				
				var _fil = dirObject.files[i];
				if(frame_dragging && rectangle_in_rectangle(_px, _py, _px + _pw, _py + _ph, frame_drag_mx, frame_drag_my, _m[0], _m[1]))
					array_push(file_selectings, _fil);
				
				var _sel = array_exists(file_selectings, _fil);
				var _tx = _px + _grid_width / 2;
				var _ty = _py + _grid_height + _title_heigh;
				var _th = _fil.getThumbnail();
				
				if(_sel) draw_sprite_stretched_ext(THEME.ui_panel_bg, 4, _px, _py, _pw, _ph, merge_color(COLORS._main_icon_dark, COLORS._main_icon, 0.2), 1);
				
				if(contentPane.hover && point_in_rectangle(_m[0], _m[1], _px, _py, _px + _pw, _py + _ph)) {
					if(!mouse_click(mb_left)) {
						draw_sprite_stretched_ext(THEME.ui_panel, 1, _px, _py, _pw, _ph, COLORS._main_icon, .75);
						if(!instance_exists(o_dialog_menubox))
							TOOLTIP = [ _th, "sprite" ];
					}
					
					file_hovering = _fil;
					
					if(pFOCUS && mouse_press(mb_left) && key_mod_press(CTRL)) {
						if(_sel) array_remove(file_selectings, _fil);
						else     array_push(file_selectings, _fil);
					}
					
					if(pFOCUS && mouse_press(mb_right)) {
						__menu_file_selecting = _fil;
						
							 if(path_is_image(_fil.path))   menuCall("", menu_file_image);
						else if(path_is_project(_fil.path)) menuCall("", menu_file_project);
					}
					
					if(pFOCUS && DOUBLE_CLICK)
						load_file_path([ _fil.path ], _graph_x, _graph_y);
				}
				
				if(sprite_exists(_th)) {
					gpu_set_texfilter(true);
					var _ths = min((_grid_width - ui(4)) / _fil.th_w, (_grid_height - ui(4)) / _fil.th_h);
					draw_sprite_ext(_th, 0, _px + _grid_width / 2, _py + _grid_height / 2, _ths, _ths, 0, c_white, 1);
					gpu_set_texfilter(false);
				}
				
				var _cc = COLORS._main_text;
				if(_fil == file_focus)        _cc = COLORS._main_value_positive;
				if(_fil.path == PROJECT.path) _cc = COLORS._main_accent;
				
				draw_set_color(_cc);
				draw_text_ext_add(_tx, _ty, _fil.name, -1, _grid_width, 1, true);
				
			}
			
			_h += ceil(_amo / _col) * (_grid_height + _title_heigh + _grid_spac);
		}
		
		if(context_hovering == noone && pHOVER && point_in_rectangle(_m[0], _m[1], 0, _y, _w, _y + _h))
			context_hovering = dirObject;
		
		return _h;
	}
	
	contentPane = new scrollPane(w - padding - padding - cntPad * 2, h - padding - top_bar - cntPad * 2, function(_y, _m, _r) {
		draw_clear_alpha(COLORS.panel_bg_clear_inner, 1);
		
		if(frame_dragging) file_selectings = [];
		
		file_hovering    = noone;
		context_hovering = noone;
		draggable        = true;
		
		contentPane.hover_content = true;
		
		var _h = drawDir(rootFile, 0, _y, contentPane.surface_w, _m);
		
		if(frame_dragging) draw_sprite_stretched_points_clamp(THEME.ui_selection, 0, frame_drag_mx, frame_drag_my, _m[0], _m[1], COLORS._main_accent);
		if(context_hovering == noone) context_hovering = rootFile;
		
		if(draggable && mouse_press(mb_left, pFOCUS)) {
			if(file_hovering == noone) {
				file_selectings = [];
				frame_dragging  = true;
				frame_drag_mx   = _m[0];
				frame_drag_my   = _m[1];
				
			} else {
				if(key_mod_press(SHIFT)) {
					if(!array_empty(file_selectings)) {
						var _frm = file_selectings[array_length(file_selectings) - 1];
						var _to  = file_hovering;
						
						if(is(_frm, ExpFile) && is(_to, ExpFile) && _frm.parent && _frm.parent == _to.parent) {
							var _par = _frm.parent;
							var _ifrm = array_find(_par.files, _frm);
							var _ito  = array_find(_par.files, _to);
							
							file_selectings = array_create(abs(_ifrm - _ito) + 1);
							var _i = min(_ifrm, _ito);
							var _j = max(_ifrm, _ito);
							var _ind = 0;
							
							for(; _i <= _j; _i++) file_selectings[_ind++] = _par.files[_i];
						}
					}
					
				} else if(!array_exists(file_selectings, file_hovering))
					file_selectings = [ file_hovering ];
					
				path_dragging = -1;
				file_dragging = true;
				file_drag_mx  = mouse_mx;
				file_drag_my  = mouse_my;
			}
		}
		
		if(mouse_release(mb_left)) frame_dragging = false;
		
		if(pFOCUS && mouse_press(mb_right)) {
			__menu_cnxt_selecting = context_hovering;
			
			if(file_hovering == noone || is(file_hovering, ExpDir)) 
				menuCall("", menu_general);
		}
		
		if(file_dragging) {
			if(path_dragging == -1 && point_distance(file_drag_mx, file_drag_my, mouse_mx, mouse_my) > 8) {
				path_dragging = [];
				
				for (var i = 0, n = array_length(file_selectings); i < n; i++)
					path_dragging[i] = file_selectings[i].path;
			}
			
			if(path_dragging != -1 && !array_empty(path_dragging) && !pHOVER) {
				if(HOVER && is(HOVER, Panel)) {
					var _cont = HOVER.getContent();
					if(is(_cont, Panel_Preview) || is(_cont, Panel_Graph)) 
						HOVER.draw_droppable = true;
				}
			}
			
			if(mouse_release(mb_left)) {
				var _file_focus = file_focus;
				file_focus = noone;
				
				if(path_dragging != -1 && !array_empty(path_dragging) && !pHOVER) {
					var _dropped = false;
					
					if(HOVER && is(HOVER, Panel)) {
						var _cont = HOVER.getContent();
						
						if(is(_cont, Panel_Preview)) {
							var _node = _cont.getNodePreview();
							
							if(_node && _node.on_drop_file) {
								_node.on_drop_file(path_dragging[0]);
								_dropped = true;
							}
						}
						
						if(array_length(file_selectings) == 1)
							file_focus = file_selectings[0];
					} 
					
					if(!_dropped)
						load_file_path(path_dragging);
				}
				
				if(_file_focus != file_focus)
					recordAction_variable_change(self, "file_focus", _file_focus);
				
				file_dragging = false;	
				path_dragging = -1;
				
			} else if(keyboard_check_pressed(vk_control)) {
				__menu_file_selecting = file_selectings[0];
				
				if(path_is_image(__menu_file_selecting.path))
					pieMenuCall("",,, menu_file_image);
					
				else if(path_is_project(__menu_file_selecting.path))
					pieMenuCall("",,, menu_file_project);
				
				file_dragging = false;	
				path_dragging = -1;
				
			}
		}
		
		if(view_mode == FILE_EXPLORER_VIEW.grid && pHOVER && key_mod_press(CTRL)) {
			if(mouse_wheel_down()) grid_size = clamp(grid_size - ui(8), ui(32), ui(128));
			if(mouse_wheel_up())   grid_size = clamp(grid_size + ui(8), ui(32), ui(128));
		}
		
		return _h;
		
	} );
	
	function onResize() {
		initSize();
		contentPane.resize(w - padding - padding - cntPad * 2, h - padding - top_bar - cntPad * 2);
	}
	
	function drawContent(panel) {
		draw_clear_alpha(COLORS.panel_bg_clear, 1);
		
		var pad   = padding;
		var cnt_x = pad;
		var cnt_y = top_bar;
		var cnt_w = w - pad - cnt_x;
		var cnt_h = h - pad - cnt_y;
			
		draw_sprite_stretched(THEME.ui_panel_bg, 1, cnt_x, cnt_y, cnt_w, cnt_h);
		
		var bs = top_bar - pad - ui(8);
		var bx = pad;
		var bc = root != ""? COLORS._main_icon : COLORS._main_icon_dark;
		if(buttonInstant(THEME.button_hide_fill, bx, pad, bs, bs, [mx, my], pHOVER, pFOCUS, "Go up", THEME.arrow, 1, bc) == 2)
			if(root != "") setRoot(filename_dir(root));
		bx += bs + ui(4);
		
		if(buttonInstant(THEME.button_hide_fill, bx, pad, bs, bs, [mx, my], pHOVER, pFOCUS, "Go to current project", s_icon_16_white) == 2) {
			var _pth = PROJECT.path;
			if(_pth == "") return;
			setRoot(filename_dir(_pth));
		}
		bx += bs + ui(4);
		
		var tb_x = bx;
		var tb_y = pad;
		var tb_w = w - pad - tb_x - bs - ui(4);
		var tb_h = top_bar - pad - ui(8);
		
		var b = buttonInstant(THEME.button_hide_fill, w - pad - bs, pad, bs, bs, [mx, my], pHOVER, pFOCUS, view_mode_tooltip, THEME.view_mode, !view_mode);
		if(b == 1) {
			if(key_mod_press(SHIFT) && mouse_wheel_up())   { view_mode = !view_mode; PREFERENCES.file_explorer_view = view_mode; }
			if(key_mod_press(SHIFT) && mouse_wheel_down()) { view_mode = !view_mode; PREFERENCES.file_explorer_view = view_mode; }
		}
		if(b == 2) { view_mode = !view_mode; PREFERENCES.file_explorer_view = view_mode; }
		view_mode_tooltip.index = view_mode;
			
		tb_root.setFocusHover(pFOCUS, pHOVER);
		tb_root.font = f_p2;
		tb_root.draw(tb_x, tb_y, tb_w, tb_h, root, [mx, my]);
		
		contentPane.setFocusHover(pFOCUS, pHOVER);
		contentPane.draw(cnt_x + cntPad, cnt_y + cntPad, mx - cnt_x - cntPad, my - cnt_y - cntPad);
	}
	
	function drawGUI() {
		if(path_dragging == -1) return;
			
		for (var i = 0, n = array_length(file_selectings); i < n; i++) {
			var f  = file_selectings[i];
			
			if(is(f, ExpDir)) {
				draw_sprite_ext(THEME.folder_content, 0, mouse_mx + 20 + 8 * i, mouse_my + 20 + 8 * i, 1, 1, 0, c_white, 1);
				
			} else if(is(f, ExpFile)) {
				var _s = 64 / max(f.th_w, f.th_h);
				if(f.thumbnail) draw_sprite_ext(f.thumbnail, 0, mouse_mx + f.th_w * _s / 2 + 8 * i, mouse_my + f.th_h * _s / 2 + 8 * i, _s, _s, 0, c_white, 1);
			}
		}
	}
	
}