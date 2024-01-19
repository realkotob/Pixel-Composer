enum SPRITE_STACK {
	horizontal,
	vertical,
	grid
}

enum SPRITE_ANIM_GROUP {
	animation,
	all_sprites
}

function Node_Render_Sprite_Sheet(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	static log = false;
	
	name		= "Render Spritesheet";
	anim_drawn	= array_create(TOTAL_FRAMES + 1, false);
	
	inputs[| 0] = nodeValue("Sprites", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 1] = nodeValue("Sprite set", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Animation", "Sprite array" ])
		.rejectArray();
	
	inputs[| 2] = nodeValue("Frame step", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1, "Number of frames until next sprite. Can be seen as (Step - 1) frame skip.")
		.rejectArray();
	
	inputs[| 3] = nodeValue("Packing type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Horizontal", "Vertical", "Grid" ])
		.rejectArray();
	
	inputs[| 4] = nodeValue("Grid column", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 4)
		.rejectArray();
	
	inputs[| 5] = nodeValue("Alignment", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "First", "Middle", "Last" ])
		.rejectArray();
	
	inputs[| 6] = nodeValue("Spacing", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0);
	
	inputs[| 7] = nodeValue("Padding", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [ 0, 0, 0, 0 ])
		.setDisplay(VALUE_DISPLAY.padding)
	
	inputs[| 8] = nodeValue("Range", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [ 0, 0 ], "Starting/ending frames, set end to 0 to default to last frame.")
		.setDisplay(VALUE_DISPLAY.slider_range)
		
	inputs[| 9] = nodeValue("Spacing", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 10] = nodeValue("Overlappable", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	inputs[| 11] = nodeValue("Custom Range", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
		
	outputs[| 1] = nodeValue("Atlas Data", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, [])
		.setArrayDepth(1);
	
	input_display_list = [
		["Surfaces",  false], 0, 1, 2,
		["Sprite",	  false], 3, 
		["Packing",	  false], 4, 5, 6, 9, 7, 
		["Rendering", false], 10, 
		["Custom Range", true, 11], 8, 
	]
	
	attribute_surface_depth();

	static onInspector1Update = function(updateAll = true) { #region
		var key = ds_map_find_first(PROJECT.nodeMap);
		
		repeat(ds_map_size(PROJECT.nodeMap)) {
			var node = PROJECT.nodeMap[? key];
			key = ds_map_find_next(PROJECT.nodeMap, key);
			
			if(!node.active) continue;
			if(instanceof(node) != "Node_Render_Sprite_Sheet") continue;
			
			initSurface();
		}
		
		PROJECT.animator.render();
	} #endregion
	
	static step = function() { #region
		var grup = getInputData(1);
		var pack = getInputData(3);
		var user = getInputData(11);
		
		if(pack == 0)	inputs[| 5].editWidget.data = [ "Top", "Center", "Bottom" ];
		else			inputs[| 5].editWidget.data = [ "Left", "Center", "Right" ];
		
		inputs[| 2].setVisible(grup == SPRITE_ANIM_GROUP.animation);
		inputs[| 4].setVisible(pack == SPRITE_STACK.grid);
		inputs[| 5].setVisible(pack != SPRITE_STACK.grid);
		inputs[| 6].setVisible(pack != SPRITE_STACK.grid);
		inputs[| 9].setVisible(pack == SPRITE_STACK.grid);
		
		inputs[| 8].editWidget.minn = FIRST_FRAME + 1;
		inputs[| 8].editWidget.maxx = LAST_FRAME + 1;
		if(!user) inputs[| 8].setValueDirect([ FIRST_FRAME + 1, LAST_FRAME + 1], noone, false, 0, false);
		
		update_on_frame = grup == 0;
	} #endregion
	
	static update = function(frame = CURRENT_FRAME) { #region
		var grup = getInputData(1);
		
		if(grup == SPRITE_ANIM_GROUP.animation) 
			animationRender();
		else 
			arrayRender();
	} #endregion
	
	static initSurface = function() { #region
		for(var i = 0; i < TOTAL_FRAMES; i++) anim_drawn[i] = false;
		
		var grup = getInputData(1);
		
		if(grup == SPRITE_ANIM_GROUP.animation) 
			animationInit();
		else 
			arrayRender();
	} #endregion
	
	static arrayRender = function() { #region
		var inpt = getInputData(0);
		var grup = getInputData(1);
		var pack = getInputData(3);
		var alig = getInputData(5);
		var spac = getInputData(6);
		var padd = getInputData(7);
		var rang = getInputData(8);
		var spc2 = getInputData(9);
		var ovlp = getInputData(10);
		
		var cDep = attrDepth();
		
		if(!is_array(inpt)) {
			outputs[| 0].setValue(inpt);
			outputs[| 1].setValue([]);
			return;	
		}
		
		#region frame
			var _st, _ed;
			var _ln = array_length(inpt);
			
			if(rang[0] < 0)  _st = _ln + rang[0];
			else             _st = rang[0];
			
			     if(rang[1] == 0) _ed = _ln;
			else if(rang[1] < 0)  _ed = _ln + rang[1];
			else                  _ed = rang[1];
			
			_st = clamp(_st, 0, _ln);
			_ed = clamp(_ed, 0, _ln);
			
			if(_ed <= _st) return;
			var amo = _ed - _st;
		#endregion
		
		var ww   = 0;
		var hh   = 0;
		var _atl = [];
		
		#region surface generate
			switch(pack) { 
				case SPRITE_STACK.horizontal :
					for(var i = _st; i < _ed; i++) {
						ww += surface_get_width_safe(inpt[i]);
						if(i > _st) ww += spac;
						hh  = max(hh, surface_get_height_safe(inpt[i]));
					}
					break;
				case SPRITE_STACK.vertical :
					for(var i = _st; i < _ed; i++) {
						ww  = max(ww, surface_get_width_safe(inpt[i]));
						hh += surface_get_height_safe(inpt[i]);
						if(i > _st) hh += spac;
					}
					break;
				case SPRITE_STACK.grid :
					var col = getInputData(4);
					var row = ceil(amo / col);
				
					for(var i = 0; i < row; i++) {
						var row_w = 0;
						var row_h = 0;
							
						for(var j = 0; j < col; j++) {
							var index = _st + i * col + j;
							if(index >= _ed) break;
						
							row_w += surface_get_width_safe(inpt[index]);
							if(j) row_w += spc2[0];
							row_h  = max(row_h, surface_get_height_safe(inpt[index]));
						}
							
						ww  = max(ww, row_w);
						hh += row_h							
						if(i) hh += spc2[1];
					}
					break;
			} 
				
			ww += padd[0] + padd[2];
			hh += padd[1] + padd[3];
			var _surf = surface_create_valid(ww, hh, cDep);
		#endregion
		
		#region draw
			surface_set_target(_surf);
			DRAW_CLEAR
				
			if(ovlp) BLEND_ALPHA_MULP
			else     BLEND_OVERRIDE
			
			switch(pack) {
				case SPRITE_STACK.horizontal :
					var px = padd[2];
					var py = padd[1];
					for(var i = _st; i < _ed; i++) {
						var _w  = surface_get_width_safe(inpt[i]);
						var _h  = surface_get_height_safe(inpt[i]);
						var _sx = px;
						var _sy = py;
					
						switch(alig) {
							case 1 : _sy = py + (hh - _h) / 2;	break;
							case 2 : _sy = py + (hh - _h);		break;
						}
					
						array_push(_atl, new SurfaceAtlas(inpt[i], _sx, _sy));
						draw_surface_safe(inpt[i], _sx, _sy);
					
						px += _w + spac;
					}
					break;
				case SPRITE_STACK.vertical :
					var px = padd[2];
					var py = padd[1];
					for(var i = _st; i < _ed; i++) {
						var _w = surface_get_width_safe(inpt[i]);
						var _h = surface_get_height_safe(inpt[i]);
						var _sx = px;
						var _sy = py;
							
						switch(alig) {
							case 1 : _sx = px + (ww - _w) / 2;	break;
							case 2 : _sx = px + (ww - _w);		break;
						}
					
						array_push(_atl, new SurfaceAtlas(inpt[i], _sx, _sy));
						draw_surface_safe(inpt[i], _sx, _sy);
					
						py += _h + spac;
					}
					break;
				case SPRITE_STACK.grid :
					var amo = array_length(inpt);
					var col = getInputData(4);
					var row = ceil(amo / col);
						
					var row_w = 0;
					var row_h = 0;
					var px = padd[2];
					var py = padd[1];
						
					for(var i = 0; i < row; i++) {
						row_w = 0;
						row_h = 0;
						px    = padd[2];
								
						for(var j = 0; j < col; j++) {
							var index = _st + i * col + j;
							if(index >= _ed) break;
								
							var _w = surface_get_width_safe(inpt[index]);
							var _h = surface_get_height_safe(inpt[index]);
						
							array_push(_atl, new SurfaceAtlas(inpt[index], px, py));
							draw_surface_safe(inpt[index], px, py);
								
							px += _w + spc2[0];
							row_h = max(row_h, _h);
						}
						py += row_h + spc2[1];
					}
					break;
				}
				BLEND_NORMAL;
			surface_reset_target();
		#endregion
		
		outputs[| 0].setValue(_surf);
		outputs[| 1].setValue(_atl);
	} #endregion
	
	static animationInit = function() { #region
		var inpt = getInputData(0);
		var skip = getInputData(2);
		var pack = getInputData(3);
		var grid = getInputData(4);
		var alig = getInputData(5);
		var spac = getInputData(6);
		var padd = getInputData(7);
		var rang = getInputData(8);
		var spc2 = getInputData(9);
		var ovlp = getInputData(10);
		var user = getInputData(11);
		
		var _atl = outputs[| 1].getValue();
		var cDep = attrDepth();
		
		printIf(log, $"Init animation");
		
		var arr = is_array(inpt);
		if(arr && array_length(inpt) == 0) return;
		if(!arr) inpt = [ inpt ];
		
		#region frame
			var _st = FIRST_FRAME;
			var _ed = LAST_FRAME  + 1;
			
			if(user) {
				if(rang[0] < 0)  _st = LAST_FRAME + rang[0] - 1;
				else             _st = rang[0] - 1;
			
				if(rang[1] < 0)  _ed = LAST_FRAME + rang[1];
				else             _ed = rang[1];
			}
			
			if(_ed <= _st) return;
			var amo = floor((_ed - _st) / skip);
		#endregion
		
		var skip  = getInputData(2);
		var _surf = [];
		
		var ww = 1, hh = 1;
				
		for(var i = 0; i < array_length(inpt); i++) { 
			var _surfi = inpt[i];
			if(!is_surface(_surfi)) continue;
					
			_atl[i]    = [];
					
			var sw = surface_get_width_safe(_surfi);
			var sh = surface_get_height_safe(_surfi);
			ww = sw;
			hh = sh;
				
			switch(pack) {
				case SPRITE_STACK.horizontal :						
					ww = sw * amo + spac * (amo - 1);
					break;
				case SPRITE_STACK.vertical :
					hh = sh * amo + spac * (amo - 1);
					break;
				case SPRITE_STACK.grid :
					var row = ceil(amo / grid);
						
					ww = sw * grid + spc2[0] * (grid - 1);
					hh = sh * row  + spc2[1] * (row - 1);
					break;
			}
				
			ww += padd[0] + padd[2];
			hh += padd[1] + padd[3];
				
			_surf[i] = surface_create_valid(ww, hh, cDep);
			surface_set_target(_surf[i]);
				DRAW_CLEAR
			surface_reset_target();
		}
			
		if(!arr) _surf = array_safe_get(_surf, 0);
		outputs[| 0].setValue(_surf);
		outputs[| 1].setValue(_atl);
				
		printIf(log, $"Surface generated [{ww}, {hh}]");
	} #endregion
	
	static animationRender = function() { #region
		if(!IS_RENDERING) return;
		
		var inpt = getInputData(0);
		var skip = getInputData(2);
		var pack = getInputData(3);
		var grid = getInputData(4);
		var alig = getInputData(5);
		var spac = getInputData(6);
		var padd = getInputData(7);
		var rang = getInputData(8);
		var spc2 = getInputData(9);
		var ovlp = getInputData(10);
		var user = getInputData(11);
		
		var _atl = outputs[| 1].getValue();
		var cDep = attrDepth();
		
		printIf(log, $"Rendering animation {name}/{CURRENT_FRAME}");
		
		var arr = is_array(inpt);
		if(arr && array_length(inpt) == 0) return;
		if(!arr) inpt = [ inpt ];
		
		#region frame
			var _st = FIRST_FRAME;
			var _ed = LAST_FRAME  + 1;
			
			if(user) {
				if(rang[0] < 0)  _st = LAST_FRAME + rang[0] - 1;
				else             _st = rang[0] - 1;
			
				if(rang[1] < 0)  _ed = LAST_FRAME + rang[1] + 1;
				else             _ed = rang[1] + 1;
			}
			
			if(_ed <= _st) return;
			var amo = floor((_ed - _st) / skip);
		#endregion
		
		if(safe_mod(CURRENT_FRAME - _st, skip) != 0) {
			printIf(log, $"   > Skip frame");
			return;
		}
		
		#region check overlap
			if(array_length(anim_drawn) != TOTAL_FRAMES)
				array_resize(anim_drawn, TOTAL_FRAMES);
				
			if(CURRENT_FRAME >= 0 && CURRENT_FRAME < TOTAL_FRAMES && anim_drawn[CURRENT_FRAME]) {
				printIf(log, $"   > Skip drawn");
				return;
			}
		#endregion
		
		var oupt   = outputs[| 0].getValue();
		var _frame = floor((CURRENT_FRAME - _st) / skip);
		var drawn  = false;
		var px = padd[2];
		var py = padd[1];
		
		for(var i = 0; i < array_length(inpt); i++) { #region
			var _surfi = inpt[i];
			
			if(!is_surface(_surfi)) {
				printIf(log, $"   > Skip input not surface");
				_atl[i] = noone;
				break;
			} 
			
			if(!is_array(array_safe_get(_atl, i)))
				_atl[i] = [];
			var _atli = _atl[i];
			
			var oo = noone;
			if(!is_array(oupt))	oo = oupt;
			else				oo = oupt[i];
			
			if(!is_surface(oo)) {
				printIf(log, $"   > Skip output not surface");
				break;
			}
			
			var ww = surface_get_width_safe(oo);
			var hh = surface_get_height_safe(oo);
			
			var _w = surface_get_width_safe(_surfi);
			var _h = surface_get_height_safe(_surfi);
			
			var px;
			var _sx = 0;
			var _sy = 0;
			
			surface_set_target(oo);
			if(ovlp) BLEND_ALPHA_MULP
			else     BLEND_OVERRIDE
			
			switch(pack) {
				case SPRITE_STACK.horizontal :
					px  = padd[2] + _frame * _w + max(0, _frame) * spac;
					_sx = px;
					_sy = py;
					
					switch(alig) {
						case 1 : _sy = py + (hh - _h) / 2;	break;
						case 2 : _sy = py + (hh - _h);		break;
					}
					
					break;
				case SPRITE_STACK.vertical :
					py = padd[1] + _frame * _h + max(0, _frame) * spac;
					_sx = px;
					_sy = py;
					
					switch(alig) {
						case 1 : _sx = px + (ww - _w) / 2;	break;
						case 2 : _sx = px + (ww - _w);		break;
					}
					
					break;
				case SPRITE_STACK.grid :
					var col  = getInputData(4);
					var _row = floor(_frame / col);
					var _col = safe_mod(_frame, col);
					
					_sx = px + _col * _w + max(0, _col) * spc2[0];
					_sy = py + _row * _h + max(0, _row) * spc2[1];
					break;
			}
			
			printIf(log, $"   > Drawing frame ({CURRENT_FRAME}) at {_sx}, {_sy}");
			array_push(_atli, new SurfaceAtlas(_surfi, _sx, _sy));
			draw_surface_safe(inpt[i], _sx, _sy);
			
			drawn = true;
			
			BLEND_NORMAL;
			surface_reset_target();
		} #endregion
		
		if(drawn) array_safe_set(anim_drawn, CURRENT_FRAME, true);
		outputs[| 1].setValue(_atl);
	} #endregion
}