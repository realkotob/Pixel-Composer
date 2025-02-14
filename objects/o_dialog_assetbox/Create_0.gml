/// @description init
event_inherited();

#region display
	draggable = true;
	destroy_on_click_out = true;
	
	target = noone;
	
	dialog_w = ui(632);
	dialog_h = ui(360);
	title_height = 48;
	
	anchor = ANCHOR.top | ANCHOR.left;
	
	dialog_resizable = true;
	dialog_w_min     = ui(200);
	dialog_h_min     = ui(120);
	dialog_w_max     = ui(1080);
	dialog_h_max     = ui(640);
#endregion

#region context
	context = global.ASSETS;
	
	function gotoDir(dirName) {
		for(var i = 0; i < ds_list_size(global.ASSETS.subDir); i++) {
			var d = global.ASSETS.subDir[| i];
			if(d.name != dirName) continue;
			
			d.open = true;
			setContext(d);
		}
	}
	
	function setContext(cont) {
		context = cont;
		contentPane.scroll_y_raw = 0;
		contentPane.scroll_y_to	 = 0;
	}
#endregion

#region surface
	folderW = ui(200);
	folderW_dragging = false;
	folderW_drag_mx  = 0;
	folderW_drag_sx  = 0;
	
	content_w = dialog_w - ui(26) - folderW;
	content_h = dialog_h - ui(24);
	
	function onResize() {
		content_w = dialog_w - ui(26) - folderW;
		content_h = dialog_h - ui(24);
		
		contentPane.resize(content_w, content_h);
		folderPane.resize(folderW - ui(12), content_h - ui(32));
	}
	
	folderPane = new scrollPane(folderW - ui(12), content_h - ui(32), function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear, 1);
		var hh = ui(8);
		var ww = folderPane.surface_w - ui(16);
		var hg;
		
		hg = DYNADRAW_FOLDER.draw(self, ui(8), _y + ui(8), _m, ww, sHOVER, sFOCUS, global.ASSETS);
		hh += hg;
		_y += hg;
		
		for(var i = 0; i < ds_list_size(global.ASSETS.subDir); i++) {
			hg = global.ASSETS.subDir[| i].draw(self, ui(8), _y + ui(8), _m, ww, sHOVER, sFOCUS, global.ASSETS);
			hh += hg;
			_y += hg;
		}
		
		folderPane.hover_content = true;
		return hh + 8;
	});
	folderPane.scroll_color_bg = CDEF.main_mdblack;
	
	contentPane = new scrollPane(content_w, content_h, function(_y, _m) {
		draw_clear_alpha(c_white, 0);
		
		var contents = context.content;
		var amo   = ds_list_size(contents);
		var hh    = 0;
		var surfh = contentPane.surface_h + 4;
		var frame = current_time * PREFERENCES.collection_preview_speed / 8000;
		
		var grid_size = ui(64);
		var img_size  = grid_size - ui(16);
		var grid_space = ui(12);
		var col = max(1, floor(contentPane.surface_w / (grid_size + grid_space)));
		var row = ceil(amo / col);
		var yy  = _y + grid_space;
		var hght = grid_size + grid_space;
		
		hh += grid_space + hght * row;
		
		for(var i = 0; i < row; i++) {
			if(yy + grid_size < -4) {
				yy += hght;
				continue;
			}
			
			if(yy > surfh) break;
			
			for(var j = 0; j < col; j++) {
				var index = i * col + j;
				if(index >= amo) break;
				
				var content = contents[| index];
				var xx = grid_space + (grid_size + grid_space) * j;
				
				BLEND_OVERRIDE
				draw_sprite_stretched(THEME.node_bg, 0, xx, yy, grid_size, grid_size);
				BLEND_NORMAL
				
				var spr = -1;
				
				if(is(content, dynaSurf)) {
					var _sw = grid_size - ui(16);
					var _sh = grid_size - ui(16);
					
					var sx = xx + grid_size / 2;
					var sy = yy + grid_size / 2;
					content.draw(sx, sy, _sw, _sh);
					draw_sprite_ext(THEME.dynadraw, 0, xx + grid_size - ui(14), yy + grid_size - ui(14));
					
				} else {
					spr = content.getSpr();
					
					if(sprite_exists(spr)) {
						var sw = sprite_get_width(spr);
						var sh = sprite_get_height(spr);
						var ss = img_size / max(sw, sh);
						var sx = xx + (grid_size - sw * ss) / 2;
						var sy = yy + (grid_size - sh * ss) / 2;
						var sn = sprite_get_number(spr);
						
						draw_sprite_ext(spr, frame, sx, sy, ss, ss, 0, c_white, 1);
						
						var _txt = $"{sw}x{sh}";
						if(sn) _txt = $"[{sn}] " + _txt;
						
						draw_set_text(_f_p4, fa_right, fa_bottom, COLORS._main_text_inner);
						var _tw = string_width(_txt) + ui(6);
						var _th = 14;
						var _nx = xx + grid_size - 1 - _tw;
						var _ny = yy + grid_size - _th;
						
						draw_sprite_stretched_ext(THEME.ui_panel, 0, _nx, _ny, _tw, _th - 1, COLORS.panel_bg_clear_inner, 0.85);
						draw_text_add(xx + grid_size - ui(3), yy + grid_size - ui(2), _txt);
						
					} else if(spr == -1) {
						var _rr = lerp(.075, .2, abs(dsin(current_time / 2)));
						draw_circle_ui(xx + grid_size / 2, yy + grid_size / 2, grid_size * .25, _rr, COLORS._main_icon, 1);
					}
				}
				
				if(sHOVER && contentPane.hover && point_in_rectangle(_m[0], _m[1], xx, yy, xx + grid_size, yy + grid_size)) {
					contentPane.hover_content = true;
					TOOLTIP = [ spr, "sprite" ];
					
					draw_sprite_stretched_ext(THEME.node_bg, 1, xx, yy, grid_size, grid_size, COLORS._main_accent, 1);
					
					if(mouse_press(mb_left, sFOCUS)) {
						if(is(content, dynaSurf))
							target.onModify(content.clone());
						else 
							target.onModify(content.path);
						instance_destroy();
					}
				}
			}
			
			yy += hght;
		}
		
		return hh;
	});
#endregion