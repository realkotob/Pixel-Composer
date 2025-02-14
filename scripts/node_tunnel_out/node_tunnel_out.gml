function Node_Tunnel_Out(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Tunnel Out";
	color = COLORS.node_blend_tunnel;
	is_group_io  = true;
	preview_draw = false;
	
	setDimension(32, 32);
	
	isHovering     = false;
	hover_scale    = 0;
	hover_scale_to = 0;
	hover_alpha    = 0;
	
	preview_connecting = false;
	preview_scale  = 1;
	junction_hover = false;
	
	var tname = "";
	if(!LOADING && !APPENDING && !ds_map_empty(project.tunnels_in))
		tname = ds_map_find_first(project.tunnels_in);
	
	newInput(0, nodeValue_Text("Name", self, tname ))
		.setDisplay(VALUE_DISPLAY.text_tunnel)
		.rejectArray();
	
	newOutput(0, nodeValue_Output("Value out", self, VALUE_TYPE.any, noone ));
	
	setTrigger(2, "Goto tunnel in", [ THEME.tunnel, 1, c_white ]);
	
	static onInspector2Update = function() {
		var _key = inputs[0].getValue();
		if(!ds_map_exists(project.tunnels_in, _key)) return;
		
		var _node = project.tunnels_in[? _key].node;
		graphFocusNode(_node);
	}
	
	static isRenderable = function() {
		var _key = inputs[0].getValue();
		if(!ds_map_exists(project.tunnels_in, _key)) return false;
		
		return project.tunnels_in[? _key].node.rendered;
	}
	
	static onValueUpdate = function(index = -1) {
		var _key = inputs[0].getValue();
		
		if(index == 0) { RENDER_ALL_REORDER }
	}
	
	static step = function() {
		var _key = inputs[0].getValue();
		project.tunnels_out[? node_id] = _key;
	}
	
	static update = function(frame = CURRENT_FRAME) {
		var _key = inputs[0].getValue();
		
		if(ds_map_exists(project.tunnels_in, _key)) {
			outputs[0].setType(project.tunnels_in[? _key].type);
			outputs[0].setDisplay(project.tunnels_in[? _key].display_type);
			outputs[0].setValue(project.tunnels_in[? _key].getValue());
		} else {
			outputs[0].setType(VALUE_TYPE.any);
			outputs[0].setDisplay(VALUE_DISPLAY._default);
		}
		
		outputs[0].updateColor();
	}
	
	/////////////////////////////////////////////////////////////////////////////
	
	static pointIn = function(_x, _y, _mx, _my, _s) {
		var xx =  x      * _s + _x;
		var yy = (y + 8) * _s + _y;
		
		return point_in_circle(_mx, _my, xx, yy, _s * 24);
	}
	
	static preDraw = function(_x, _y, _s) {
		var xx =  x      * _s + _x;
		var yy = (y + 8) * _s + _y;
		
		inputs[0].x = xx;
		inputs[0].y = yy;
		
		outputs[0].x = xx;
		outputs[0].y = yy;
	}
	
	static drawBadge = function(_x, _y, _s) {}
	static drawJunctionNames = function(_x, _y, _mx, _my, _s, _panel = noone) {}
	
	static onDrawNodeBehind = function(_x, _y, _mx, _my, _s) {
		var xx =  x      * _s + _x;
		var yy = (y + 8) * _s + _y;
		
		var hover = isHovering || hover_alpha == 1;
		var tun   = findPanel("Panel_Tunnels");
		hover |= tun && tun.tunnel_hover == self;
		if(!hover) return;
		
		var _key = inputs[0].getValue();
		if(!ds_map_exists(project.tunnels_in, _key)) return;
		
		var node = project.tunnels_in[? _key].node;
		if(node.group != group) return;
		
		preview_connecting      = true;
		node.preview_connecting = true;
		
		draw_set_color(outputs[0].color_display);
		draw_set_alpha(0.5);
		
		var frx = _x +  node.x      * _s;
		var fry = _y + (node.y + 8) * _s;
		draw_line_dotted(frx, fry, xx, yy, 2 * _s, current_time / 10, 3);
		
		draw_set_alpha(1);
	}
	
	static drawJunctions = function(_draw, _x, _y, _mx, _my, _s) {
		var xx =  x      * _s + _x;
		var yy = (y + 8) * _s + _y;
		isHovering = point_in_circle(_mx, _my, xx, yy, _s * 24);
		
		gpu_set_tex_filter(true);
		junction_hover = outputs[0].drawJunction(_draw, _s, _mx, _my);
		gpu_set_tex_filter(false);
		
		if(!isHovering) return noone;
		if(!junction_hover) draw_sprite_ext(THEME.view_pan, 0, _mx + ui(16), _my + ui(24), 1, 1, 0, COLORS._main_accent);
		
		hover_scale_to = 1;
		return junction_hover? outputs[0] : noone;
	}
	
	static drawNode = function(_draw, _x, _y, _mx, _my, _s) {
		if(!_draw) return drawJunctions(_draw, _x, _y, _mx, _my, _s);
		
		var xx =  x      * _s + _x;
		var yy = (y + 8) * _s + _y;
		
		hover_alpha = 0.5;
		if(active_draw_index > -1) {
			hover_alpha		  =  1;
			hover_scale_to	  =  1;
			active_draw_index = -1;
		}
		
		#region draw arc
			var prev_s = preview_connecting? 1 + sin(current_time / 100) * 0.1 : 1;
			preview_scale      = lerp_float(preview_scale, prev_s, 5);
			preview_connecting = false;
			
			shader_set(sh_node_arc);
				shader_set_color("color", outputs[0].color_display, hover_alpha);
				shader_set_f("angle", degtorad(-90));
				
				var _r = preview_scale * _s * 20;
				shader_set_f("amount", 0.4, 0.5);
				draw_sprite_stretched(s_fx_pixel, 0, xx - _r, yy - _r, _r * 2, _r * 2);
				
				var _r = preview_scale * _s * 30;
				shader_set_f("amount", 0.45, 0.525);
				draw_sprite_stretched(s_fx_pixel, 0, xx - _r, yy - _r, _r * 2, _r * 2);
				
				var _r = preview_scale * _s * 40;
				shader_set_f("amount", 0.475, 0.55);
				draw_sprite_stretched(s_fx_pixel, 0, xx - _r, yy - _r, _r * 2, _r * 2);
				
			shader_reset();
		#endregion
			
		if(hover_scale > 0) {
			var _r = hover_scale * _s * 16;
			shader_set(sh_node_circle);
				shader_set_color("color", COLORS._main_accent, hover_alpha);
				draw_sprite_stretched(s_fx_pixel, 0, xx - _r, yy - _r, _r * 2, _r * 2);
			shader_reset();
		}
		
		hover_scale    = lerp_float(hover_scale, hover_scale_to && !junction_hover, 3);
		hover_scale_to = 0;
		
		draw_set_text(f_sdf, fa_center, fa_bottom, COLORS._main_text);
		draw_text_transformed(xx, yy - 12 * _s, string(inputs[0].getValue()), _s * .3, _s * .3, 0);
		
		return drawJunctions(_draw, _x, _y, _mx, _my, _s);
	}
	
	static onClone = function() { onValueUpdate(0); }
	
	static postConnect = function() { step(); onValueUpdate(0); }
}