function Node_ASE_Tag(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "ASE Tag";
	ase_data = noone;
	
	newInput(0, nodeValue("ASE data", self, CONNECT_TYPE.input, VALUE_TYPE.object, noone))
		.setIcon(s_junc_aseprite, c_white)
		.setVisible(false, true)
		.rejectArray();
	
	newInput(1, nodeValue_Text("Tag", self, ""));
	
	newOutput(0, nodeValue_Output("Surface Out", self, VALUE_TYPE.surface, noone));
	
	tag_renderer = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus) {
		if(ase_data == noone) {
			draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _x, _y, _w, 28, COLORS.node_composite_bg_blend, 1);	
			
			draw_set_text(f_p3, fa_center, fa_center, COLORS._main_text_sub);
			draw_text_add(_x + _w / 2, _y + 14, "No data");
			return 32;
		}
		
		var _tag = getSingleValue(1);
		var _amo = array_length(ase_data.tags);
		var hh   = 24;
		var _h   = hh * _amo + 16;
		
		draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _x, _y, _w, _h, COLORS.node_composite_bg_blend, 1);
		for( var i = 0, n = array_length(ase_data.tags); i < n; i++ ) {
			var _bx    = _x + 24;
			var _yy    = _y + 8 + i * hh;
			
			var tag   = ase_data.tags[i];
			var tName = tag[$ "Name"];
			var tColr = tag[$ "Color"];
			
			draw_sprite_ui_uniform(THEME.tag, 0, _bx, _yy + hh / 2 + 2, 1, tColr);
			
			var cc = COLORS._main_text_sub;
			
			if(_hover && point_in_rectangle(_m[0], _m[1], _x, _yy, _x + _w, _yy + hh - 1)) {
				cc = COLORS._main_text;
				
				if(mouse_press(mb_left, _focus))
					inputs[1].setValue(tName);
			}
			
			if(tName == _tag)
				cc = COLORS._main_text_accent;
			
			draw_set_text(f_p2, fa_left, fa_center, cc);
			draw_text_add(_bx + 16, _yy + hh / 2, tName);
		}
		
		return _h;
	}); 
	
	input_display_list = [
		0, tag_renderer, 1, 
	];
	
	temp_surface = [ 0, 0, 0 ];
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _ase = _data[0];
		var _tag = _data[1];
		
		ase_data = _ase;
		if(_ase == noone || _ase.content == noone) return;
		
		var _cnt = _ase.content;
		var ww   = _cnt[$ "Width"];
		var hh   = _cnt[$ "Height"];
		_outSurf = surface_verify(_outSurf, ww, hh);
		
		var tag = noone;
		for( var i = 0, n = array_length(_ase.tags); i < n; i++ ) {
			if(_ase.tags[i][$ "Name"] == _tag) {
				tag = _ase.tags[i];
				break;
			}
		}
		
		if(tag == noone) return;
		
		for (var i = 0, n = array_length(temp_surface); i < n; i++) {
			temp_surface[i] = surface_verify(temp_surface[i], ww, hh);
			surface_clear(temp_surface[i]);
		}
		
		blend_temp_surface = temp_surface[2];
		
		var st = tag[$ "Frame start"];
		var ed = tag[$ "Frame end"];
		var fr = st + CURRENT_FRAME % (ed - st);
		var bg = 0;
		
		for( var i = 0, n = array_length(_ase.layers); i < n; i++ ) {
			var cel = _ase.layers[i].getCel(fr);
			if(!cel) continue;
			
			var _inSurf = cel.getSurface();
			if(!is_surface(_inSurf)) continue;
			
			var xx = cel.data[$ "X"];
			var yy = cel.data[$ "Y"];
			
			surface_set_shader(temp_surface[bg], sh_sample, true, BLEND.over);
				draw_surface_blend_ext(temp_surface[!bg], _inSurf, xx, yy);
			surface_reset_shader();
			
			bg = !bg;
		}
		
		surface_set_shader(_outSurf);
			DRAW_CLEAR
			draw_surface_safe(temp_surface[!bg]);
		surface_reset_shader();
		
		return _outSurf;
	}
}