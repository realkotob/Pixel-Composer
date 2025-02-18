function Node(_x, _y, _group = PANEL_GRAPH.getCurrentContext()) constructor {
	active  = true;
	node_id = generateUUID();
	group   = _group;
	ds_list_add(PANEL_GRAPH.getNodeList(_group), self);
	
	color   = c_white;
	icon    = noone;
	bg_spr  = THEME.node_bg;
	bg_sel_spr = THEME.node_active;
	anim_priority = ds_map_size(NODE_MAP);
	
	if(!LOADING && !APPENDING) {
		recordAction(ACTION_TYPE.node_added, self);
		NODE_MAP[? node_id] = self;
	}
	
	name = "";
	x = _x;
	y = _y;
	
	w = 128;
	h = 128;
	min_h = 128;
	auto_height = true;
	
	input_display_list = -1;
	output_display_list = -1;
	inspector_display_list = -1;
	is_dynamic_output = false;
	inputs  = ds_list_create();
	outputs = ds_list_create();
	attributes = ds_map_create();
	
	show_input_name = false;
	show_output_name = false;
	
	always_output = false;
	inspecting = false;
	previewing = 0;
	
	previewable   = true;
	preview_speed = 0;
	preview_index = 0;
	preview_channel = 0;
	preview_alpha = 1;
	preview_x     = 0;
	preview_y     = 0;
	
	rendered        = false;
	auto_update     = true;
	update_on_frame = false;
	render_time		= 0;
	
	use_cache		= false;
	cached_output	= [];
	cache_result	= [];
	
	tools			= -1;
	
	on_dragdrop_file = -1;
	
	anim_show = true;
	
	value_validation = array_create(3);
	MODIFIED = true;
	
	static getInputJunctionIndex = function(index) {
		if(input_display_list == -1)
			return index;
		
		var jun_list_arr = input_display_list[index];
		if(is_array(jun_list_arr)) return noone;
		if(is_struct(jun_list_arr)) return noone;
		return jun_list_arr;
	}
	
	static getOutputJunctionIndex = function(index) {
		if(output_display_list == -1)
			return index;
		return output_display_list[index];
	}
	
	static setHeight = function() {
		var _hi = ui(32);
		var _ho = ui(32);
		for( var i = 0; i < ds_list_size(inputs); i++ )  {
			if(inputs[| i].isVisible()) _hi += 24;
		}
		
		for( var i = 0; i < ds_list_size(outputs); i++ )  {
			if(outputs[| i].isVisible()) _ho += 24;
		}
		
		h = max(min_h, _hi, _ho);
	}
	
	static move = function(_x, _y) {
		x = _x;
		y = _y;
		MODIFIED = true;
	}
	
	static stepBegin = function() {
		if(use_cache)
			cacheArrayCheck();
		var stack_push = false;
		
		if(always_output) {
			for(var i = 0; i < ds_list_size(outputs); i++) {
				if(outputs[| i].type != VALUE_TYPE.surface) 
					continue;
				var val = outputs[| i].getValue();
					
				if(is_array(val)) {
					for(var j = 0; j < array_length(val); j++) {
						var _surf = val[j];
						if(is_surface(_surf) && _surf != DEF_SURFACE)
							continue;
						stack_push = true;
					}
				} else if(!is_surface(val) || val == DEF_SURFACE) {
					stack_push = true;
				}
			}
		}
		
		if(ANIMATOR.frame_progress) {
			if(update_on_frame)
				doUpdate();
			for(var i = 0; i < ds_list_size(inputs); i++) {
				if(inputs[| i].isAnimated())
					stack_push = true;
			}
		}
		
		if(stack_push) {
			setRenderStatus(false);
			UPDATE |= RENDER_TYPE.partial;
		}
		
		if(auto_height)
			setHeight();
		
		doStepBegin();
	}
	static doStepBegin = function() {}
	
	static step = function() {}
	static focusStep = function() {}
	
	static doUpdate = function() {
		var t = get_timer();
		update();
		setRenderStatus(true);
		render_time = get_timer() - t;
	}
	
	static onValueUpdate = function(index) {}
	
	static isUpdateReady = function() {
		//if(rendered) return false;
		
		for(var j = 0; j < ds_list_size(inputs); j++) {
			var _in = inputs[| j];
			if(_in.value_from) {
				if (!_in.value_from.node.rendered)
					return false;
			} 
		}
		
		return true;
	}
	
	static update = function() {}
	
	static updateValueFrom = function(index) {}
	
	static triggerRender = function() {
		setRenderStatus(false);
		UPDATE |= RENDER_TYPE.partial;
		//ds_stack_push(RENDER_STACK, self);
		
		for(var i = 0; i < ds_list_size(outputs); i++) {
			var jun = outputs[| i];
			for(var j = 0; j < ds_list_size(jun.value_to); j++) {
				var _to = jun.value_to[| j];
				if(_to.value_from != jun) continue;
				
				_to.node.triggerRender();
			}
		}
	}
	
	static onInspect = function() {}
	
	static setRenderStatus = function(result) {
		rendered = result;
		
		if(!result && group != -1) 
			group.setRenderStatus(result);
	}
	
	static pointIn = function(_x, _y, _mx, _my, _s) {
		var xx = x * _s + _x;
		var yy = y * _s + _y;
		
		return point_in_rectangle(_mx, _my, xx, yy, xx + w * _s, yy + h * _s);
	}
	
	static preDraw = function(_x, _y, _s) {
		var xx = x * _s + _x;
		var yy = y * _s + _y;
		var jun;
		
		var inamo = input_display_list == -1? ds_list_size(inputs) : array_length(input_display_list);
		var _in = yy + ui(32) * _s;
		
		for(var i = 0; i < inamo; i++) {
			var idx = getInputJunctionIndex(i);
			if(idx == noone) continue;
			
			jun = ds_list_get(inputs, idx, noone);
			if(jun == noone) continue;
			jun.x = xx;
			jun.y = _in;
			_in += 24 * _s * jun.isVisible();
		}
		
		var outamo = output_display_list == -1? ds_list_size(outputs) : array_length(output_display_list);
		
		xx = xx + w * _s;
		_in = yy + ui(32) * _s;
		for(var i = 0; i < outamo; i++) {
			var idx = getOutputJunctionIndex(i);
			jun = outputs[| idx];
			
			jun.x = xx;
			jun.y = _in;
			_in += 24 * _s * jun.isVisible();
		}
	}
	
	static drawNodeBase = function(xx, yy, _s) {
		draw_sprite_stretched_ext(bg_spr, 0, xx, yy, w * _s, h * _s, color, 0.75);
	}
	
	static drawNodeName = function(xx, yy, _s) {
		if(name == "") return;
		if(_s * w <= 48) return;
		
		draw_sprite_stretched_ext(THEME.node_bg_name, 0, xx, yy, w * _s, ui(20), color, 0.75);
		
		var cc = COLORS._main_text;
		if(PREF_MAP[? "node_show_render_status"] && !rendered)
			cc = isUpdateReady()? COLORS._main_value_positive : COLORS._main_value_negative;
		
		draw_set_text(f_p1, fa_left, fa_center, cc);
		
		if(!auto_update) icon = THEME.refresh_s;
		var ts = clamp(power(_s, 0.5), 0.5, 1);
		if(icon) {
			draw_sprite_ui_uniform(icon, 0, xx + ui(12), yy + ui(10));	
			draw_text_cut(xx + ui(24), yy + ui(10), name, w * _s - ui(24), ts);
		} else {
			draw_text_cut(xx + ui(8), yy + ui(10), name, w * _s - ui(8), ts);
		}
	}
	
	static drawJunctions = function(_x, _y, _mx, _my, _s) {
		var hover = noone;
		var amo = input_display_list == -1? ds_list_size(inputs) : array_length(input_display_list);
		var jun;
		
		for(var i = 0; i < amo; i++) {
			var ind = getInputJunctionIndex(i);
			if(ind == noone) continue;
			jun = ds_list_get(inputs, ind, noone);
			if(jun == noone) continue;
			
			if(jun.drawJunction(_s, _mx, _my))
				hover = jun;
		}
		
		for(var i = 0; i < ds_list_size(outputs); i++) {
			jun = outputs[| i];
			
			if(jun.drawJunction(_s, _mx, _my))
				hover = jun;
		}
		
		return hover;
	}
	
	static drawJunctionNames = function(_x, _y, _mx, _my, _s) {
		var amo = input_display_list == -1? ds_list_size(inputs) : array_length(input_display_list);
		var jun;
		
		var xx = x * _s + _x;
		var yy = y * _s + _y;
		
		show_input_name = point_in_rectangle(_mx, _my, xx - 8 * _s, yy + 20 * _s, xx + 8 * _s, yy + h * _s);
		show_output_name = point_in_rectangle(_mx, _my, xx + (w - 8) * _s, yy + 20 * _s, xx + (w + 8) * _s, yy + h * _s);
		
		if(show_input_name) {
			for(var i = 0; i < amo; i++) {
				var ind = getInputJunctionIndex(i);
				if(ind == noone) continue;
				inputs[| ind].drawNameBG(_s);
			}
			
			for(var i = 0; i < amo; i++) {
				var ind = getInputJunctionIndex(i);
				if(ind == noone) continue;
				inputs[| ind].drawName(_s, _mx, _my);
			}
		}
		
		if(show_output_name) {
			for(var i = 0; i < ds_list_size(outputs); i++) {
				outputs[| i].drawNameBG(_s);
			}
			
			for(var i = 0; i < ds_list_size(outputs); i++) {
				outputs[| i].drawName(_s, _mx, _my);
			}
		}
	}
	
	static drawConnections = function(_x, _y, _s, mx, my, active) {
		var hovering = noone;
		for(var i = 0; i < ds_list_size(inputs); i++) {
			var jun = inputs[| i];
			var jx = jun.x;
			var jy = jun.y;	
			
			if(jun.value_from && jun.isVisible()) {
				var frx = jun.value_from.x;
				var fry = jun.value_from.y;
					
				var c0 = value_color(jun.value_from.type);
				var c1 = value_color(jun.type);
				var hover = false;
				var th = max(1, 2 * _s);
				
				switch(PREF_MAP[? "curve_connection_line"]) {
					case 0 : 
						hover = distance_to_line(mx, my, jx, jy, frx, fry) < 6;
						break;
					case 1 : 
						hover = distance_to_curve(mx, my, jx, jy, frx, fry) < 6;
						break;
					case 2 : 
						var cx = (jx + frx) / 2;
						hover = distance_to_line(mx, my, jx, jy, cx, jy) < 6;
						hover |= distance_to_line(mx, my, cx, jy, cx, fry) < 6;
						hover |= distance_to_line(mx, my, cx, fry, frx, fry) < 6;
						break;
				}
				
				if(active && hover)
					hovering = jun;
				if(PANEL_GRAPH.junction_hovering == jun || (instance_exists(o_dialog_add_node) && o_dialog_add_node.junction_hovering == jun))
					th *= 2;
				
				var ty = LINE_STYLE.solid;
				if(jun.type == VALUE_TYPE.node)
					ty = LINE_STYLE.dashed;
				
				switch(PREF_MAP[? "curve_connection_line"]) {
					case 0 : 
						if(ty == LINE_STYLE.solid)
							draw_line_width_color(jx, jy, frx, fry, th, c0, c1);
						else 
							draw_line_dashed_color(jx, jy, frx, fry, th, c0, c1, 12);
						break;
					case 1 : draw_line_curve_color(jx, jy, frx, fry, th, c0, c1, ty); break;
					case 2 : draw_line_elbow_color(jx, jy, frx, fry, th, c0, c1, ty); break;
				}
			}
		}
		
		return hovering;
	}
	
	static drawPreview = function(_node, xx, yy, _s) {
		if(_node.type != VALUE_TYPE.surface) return;
		var surf = _node.getValue();
		if(is_array(surf)) {
			if(array_length(surf) == 0) return;
			
			if(preview_speed != 0) {
				preview_index += preview_speed;
				if(preview_index <= 0)
					preview_index = array_length(surf) - 1;
			}
			
			if(floor(preview_index) > array_length(surf) - 1) preview_index = 0;
			surf = surf[preview_index];
		}
		
		if(!is_surface(surf)) return;
		
		var pw = surface_get_width(surf);
		var ph = surface_get_height(surf);
		var ps = min((w * _s - 8) / pw, (h * _s - 8) / ph);
		var px = xx + w * _s / 2 - pw * ps / 2;
		var py = yy + h * _s / 2 - ph * ps / 2;
			
		draw_surface_ext_safe(surf, px, py, ps, ps, 0, c_white, 1);
			
		if(_s * w > 64) {
			draw_set_text(_s >= 1? f_p1 : f_p2, fa_center, fa_top, COLORS.panel_graph_node_dimension);
			var tx = xx + w * _s / 2;
			var ty = yy + (h + 4) * _s;
			draw_text(round(tx), round(ty), string(pw) + " x " + string(ph) + "px");
				
			if(PREF_MAP[? "node_show_time"]) {
				ty += line_height() * 0.8;
				var rt, unit;
				if(render_time < 1000) {
					rt = round(render_time / 10) * 10;
					unit = "us";
					draw_set_color(COLORS.speed[2]);
				} else if(render_time < 1000000) {
					rt = string_format(render_time / 1000, -1, 2);
					unit = "ms";
					draw_set_color(COLORS.speed[1]);
				} else {
					rt = string_format(render_time / 1000000, -1, 2);
					unit = "s";
					draw_set_color(COLORS.speed[0]);
				}
				draw_text(round(tx), round(ty), string(rt) + " " + unit);
			}
			
			//ty += line_height();
			//draw_text(round(tx), round(ty), rendered);
		}
	}
	
	static drawNode = function(_x, _y, _mx, _my, _s) {
		if(group != PANEL_GRAPH.getCurrentContext()) return;
		
		var xx = x * _s + _x;
		var yy = y * _s + _y;
		
		if(value_validation[VALIDATION.error])
			draw_sprite_stretched(THEME.node_error, 0, xx - 9, yy - 9, w * _s + 18, h * _s + 18);
		
		drawNodeBase(xx, yy, _s);
		if(previewable && ds_list_size(outputs) > 0) 
			drawPreview(outputs[| preview_channel], xx, yy, _s);
		onDrawNode(xx, yy, _mx, _my, _s);
		drawNodeName(xx, yy, _s);

		if(active_draw_index > -1) {
			draw_sprite_stretched_ext(bg_sel_spr, 0, xx, yy, w * _s, h * _s, active_draw_index > 1? COLORS.node_border_file_drop : COLORS._main_accent, 1);
			active_draw_index = -1;
		}
		
		return drawJunctions(xx, yy, _mx, _my, _s);
	}
	static onDrawNode = function(xx, yy, _mx, _my, _s) {}
	
	static drawBadge = function(_x, _y, _s) {
		var xx = x * _s + _x + w * _s;
		var yy = y * _s + _y;
		
		if(previewing) {
			draw_sprite(THEME.node_state, 0, xx, yy);
			xx -= max(32 * _s, 16);
		}
		if(inspecting) {
			draw_sprite(THEME.node_state, 1, xx, yy);
		}
		
		inspecting = false;
		previewing = 0;
	}
	
	active_draw_index = -1;
	static drawActive = function(_x, _y, _s, ind = 0) {
		active_draw_index = ind;
	}
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my) {}
	
	static getPreviewValue = function() {
		if(preview_channel > ds_list_size(outputs)) return noone;
		return outputs[| preview_channel];
	}
	
	static destroy = function(_merge = false) {
		active = false;
		if(PANEL_GRAPH.node_hover         == self) PANEL_GRAPH.node_hover        = noone;
		if(PANEL_GRAPH.node_focus         == self) PANEL_GRAPH.node_focus        = noone;
		if(PANEL_PREVIEW.preview_node[0]  == self) PANEL_PREVIEW.preview_node[0] = noone;
		if(PANEL_PREVIEW.preview_node[1]  == self) PANEL_PREVIEW.preview_node[1] = noone;
		if(PANEL_INSPECTOR.inspecting     == self) PANEL_INSPECTOR.inspecting    = noone;
		PANEL_ANIMATION.updatePropertyList();
		
		for(var i = 0; i < ds_list_size(outputs); i++) {
			var jun = outputs[| i];
			
			for(var j = 0; j < ds_list_size(jun.value_to); j++) {
				var _vt = jun.value_to[| j];
				if(_vt.value_from == noone) return;
				if(_vt.value_from.node != self) return;
				
				_vt.removeFrom(false);
				
				if(_merge) {
					for( var k = 0; k < ds_list_size(inputs); k++ ) {
						if(inputs[| k].value_from == noone) continue;
						if(_vt.setFrom(inputs[| k].value_from)) break;
					}
				}
			}
			
			ds_list_clear(jun.value_to);
		}
		
		onDestroy();
	}
	static onValidate = function() {
		value_validation[VALIDATION.pass]	 = 0;
		value_validation[VALIDATION.warning] = 0;
		value_validation[VALIDATION.error]   = 0;
		
		for( var i = 0; i < ds_list_size(inputs); i++ ) {
			var jun = inputs[| i];
			if(jun.value_validation)
				value_validation[jun.value_validation]++;
		}
	}
	
	static onDestroy = function() {}
	
	static isRenderable = function(trigger = false) {
		var _startNode = true;
		for(var j = 0; j < ds_list_size(inputs); j++) {
			var _in = inputs[| j];
			if(_in.type == VALUE_TYPE.node) continue;
			
			if(trigger)
				triggerRender();
					
			if(_in.value_from != noone && !_in.value_from.node.rendered)
				_startNode = false;
		}
		return _startNode;
	}
	
	static getNextNodes = function() {
		for(var i = 0; i < ds_list_size(outputs); i++) {
			var _ot = outputs[| i];
			if(_ot.type == VALUE_TYPE.node) continue;
			
			for(var j = 0; j < ds_list_size(_ot.value_to); j++) {
				var _to = _ot.value_to[| j];
				if(!_to.node.active || _to.value_from == noone) continue; 
				if(_to.value_from.node != self) continue;
					
				_to.node.triggerRender();
				if(_to.node.isUpdateReady()) {
					ds_stack_push(RENDER_STACK, _to.node);
					printIf(global.RENDER_LOG, "    > Push " + _to.node.name + " node to stack");
				} else 
					printIf(global.RENDER_LOG, "    > Node " + _to.node.name + " not ready");
			}
		}	
	}
	
	static cacheArrayCheck = function() {
		if(array_length(cached_output) != ANIMATOR.frames_total + 1)
			array_resize(cached_output, ANIMATOR.frames_total + 1);
		if(array_length(cache_result) != ANIMATOR.frames_total + 1)
			array_resize(cache_result, ANIMATOR.frames_total + 1);
	}
	
	static cacheCurrentFrame = function(_frame) {
		cacheArrayCheck();
		if(ANIMATOR.current_frame > ANIMATOR.frames_total) return;
		
		var _os = cached_output[ANIMATOR.current_frame];
		if(is_surface(_os))
			surface_copy_size(_os, _frame);
		else {
			_os = surface_clone(_frame);
			cached_output[ANIMATOR.current_frame] = _os;
		}
		
		cache_result[ANIMATOR.current_frame] = true;
	}
	static cacheExist = function(frame = ANIMATOR.current_frame) {
		if(frame >= array_length(cached_output)) return false;
		if(frame >= array_length(cache_result)) return false;
		if(!cache_result[frame]) return false;
		return true;
	}
	
	static recoverCache = function(frame = ANIMATOR.current_frame) {
		if(!cacheExist(frame)) return false;
		
		var _s = cached_output[ANIMATOR.current_frame];
		if(!is_surface(_s)) return false;
		
		var _outSurf	= outputs[| 0].getValue();
		if(is_surface(_outSurf)) 
			surface_copy_size(_outSurf, _s);
		else {
			_outSurf = surface_clone(_s);
			outputs[| 0].setValue(_outSurf);
		}
			
		return true;
	}
	static clearCache = function() {
		if(array_length(cached_output) != ANIMATOR.frames_total + 1)
			array_resize(cached_output, ANIMATOR.frames_total + 1);
		for(var i = 0; i < array_length(cached_output); i++) {
			var _s = cached_output[i];
			if(is_surface(_s))
				surface_free(_s);
			cached_output[i] = 0;
			cache_result[i] = false;
		}
	}
	
	static checkConnectGroup = function(_type = "group") {
		for(var i = 0; i < ds_list_size(inputs); i++) {
			var _in = inputs[| i];
			if(_in.value_from && _in.value_from.node.group != group) {
				var input_node = noone;
				switch(_type) {
					case "group" : input_node = new Node_Group_Input(x - w - 64, y, group); break;	
					case "loop" : input_node = new Node_Iterator_Input(x - w - 64, y, group); break;	
				}
				
				if(input_node == noone) continue;
				input_node.inputs[| 2].setValue(_in.type);
				input_node.inputs[| 0].setValue(_in.display_type);
				
				ds_list_add(group.nodes, input_node);
				
				input_node.inParent.setFrom(_in.value_from);
				input_node.onValueUpdate(0);
				_in.setFrom(input_node.outputs[| 0]);
			}
		}	
		for(var i = 0; i < ds_list_size(outputs); i++) {
			var _ou = outputs[| i];
			for(var j = 0; j < ds_list_size(_ou.value_to); j++) {
				var _to = _ou.value_to[| j];
				if(_to.value_from != _ou) continue;
				if(!_to.node.active) continue;
				if(_to.node.group == group) continue;
				
				var output_node = noone;
				switch(_type) {
					case "group" : output_node = new Node_Group_Output(x + w + 64, y, group); break;
					case "loop" : output_node = new Node_Iterator_Output(x + w + 64, y, group); break;	
				}
					
				if(output_node == noone) continue;
				ds_list_add(group.nodes, output_node);
					
				_to.setFrom(output_node.outParent);
				output_node.inputs[| 0].setFrom(_ou);
			}
		}
	}
	
	static clone = function() {
		var _type = instanceof(self);
		var _node = nodeBuild(_type, x, y);
		
		var _data = serialize();
		_node.deserialize(ds_map_clone(_data));
		_node.node_id = generateUUID();
		
		NODE_MAP[? node_id] = self;
		NODE_MAP[? _node.node_id] = _node;
		
		return _node;
	}
	
	static serialize = function(scale = false, preset = false) {
		var _map = ds_map_create();
		
		if(!preset) {
			_map[? "id"]	= node_id;
			_map[? "name"]	= name;
			_map[? "x"]		= x;
			_map[? "y"]		= y;
			_map[? "type"]  = instanceof(self);
			_map[? "group"] = group == -1? -1 : group.node_id;
		}
		
		ds_map_add_map(_map, "attri", attributeSerialize());
		
		var _inputs = ds_list_create();
		for(var i = 0; i < ds_list_size(inputs); i++) {
			ds_list_add(_inputs, inputs[| i].serialize(scale));
			ds_list_mark_as_map(_inputs, i);
		}
		ds_map_add_list(_map, "inputs", _inputs);
		
		doSerialize(_map);
		return _map;
	}
	
	static attributeSerialize = function() {
		var att = ds_map_create();
		ds_map_override(att, attributes);
		return att;
	}
	static doSerialize = function(_map) {}
	
	load_scale = false;
	load_map = -1;
	static deserialize = function(_map, scale = false, preset = false) {
		load_map = _map;
		load_scale = scale;
		
		if(!preset) {
			if(APPENDING) {
				APPEND_MAP[? load_map[? "id"]] = node_id;
			} else {
				node_id = ds_map_try_get(load_map, "id");
			}
		
			NODE_MAP[? node_id] = self;
		
			if(ds_map_exists(load_map, "name"))
				name  = ds_map_try_get(load_map, "name", "");
			_group = ds_map_try_get(load_map, "group");
		
			x = ds_map_try_get(load_map, "x");
			y = ds_map_try_get(load_map, "y");
		}
		
		if(ds_map_exists(load_map, "attri"))
			attributeDeserialize(load_map[? "attri"]);
		
		if(!ds_map_exists(load_map, "inputs"))
			return;
		
		var _inputs = load_map[? "inputs"];
		if(!ds_list_empty(_inputs) && !ds_list_empty(inputs)) {
			var _siz = min(ds_list_size(_inputs), ds_list_size(inputs));
			for(var i = 0; i < _siz; i++) {
				inputs[| i].deserialize(_inputs[| i], scale);
			}
		}
	}
	
	static attributeDeserialize = function(attr) {
		ds_map_override(attributes, attr);
	}
	static postDeserialize = function() {}
	
	static loadGroup = function() {
		if(_group == -1) {
			var c = PANEL_GRAPH.getCurrentContext();
			if(c != -1) c.add(self);
		} else {
			if(APPENDING) _group = GetAppendID(_group);
			
			if(ds_map_exists(NODE_MAP, _group)) {
				NODE_MAP[? _group].add(self);
			} else {
				var txt = "Group load failed. Can't find node ID " + string(_group);
				log_warning("LOAD", txt);
			}
		}
	}
	
	static connect = function(log = false) {
		var connected = true;
		for(var i = 0; i < ds_list_size(inputs); i++) {
			connected &= inputs[| i].connect(log);
		}
		if(!connected) ds_queue_enqueue(CONNECTION_CONFLICT, self);
		
		return connected;
	}
	
	static preConnect = function() {}
	static postConnect = function() {}
	
	static cleanUp = function() {
		for( var i = 0; i < ds_list_size(inputs); i++ ) {
			inputs[| i].cleanUp();
		}
		for( var i = 0; i < ds_list_size(outputs); i++ ) {
			outputs[| i].cleanUp();
		}
		
		ds_list_destroy(inputs);
		ds_list_destroy(outputs);
		ds_map_destroy(attributes);
	}
}