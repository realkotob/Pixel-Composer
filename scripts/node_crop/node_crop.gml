function Node_Crop(_x, _y, _group = -1) : Node_Processor(_x, _y, _group) constructor {
	name = "Crop";
	preview_alpha = 0.5;
	
	inputs[| 0] = nodeValue(0, "Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	inputs[| 1] = nodeValue(1, "Crop", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [ 0, 0, 0, 0 ])
		.setDisplay(VALUE_DISPLAY.padding);
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	
	drag_side = -1;
	drag_mx   = 0;
	drag_my   = 0;
	drag_sv   = 0;
	
	static getPreviewValue = function() { return inputs[| 0]; }
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my) {
		if(array_length(current_data) < 2) return;
		
		var _inSurf		= current_data[0];
		var _splice		= current_data[1];
		
		var dim = [ surface_get_width(_inSurf), surface_get_height(_inSurf) ]
		
		var sp_r = _x + (dim[0] - _splice[0]) * _s;
		var sp_l = _x + _splice[2] * _s;
		
		var sp_t = _y + _splice[1] * _s;
		var sp_b = _y + (dim[1] - _splice[3]) * _s;
		
		var ww = WIN_W;
		var hh = WIN_H;
		
		var _out = outputs[| 0].getValue();
		draw_surface_ext_safe(_out, sp_l, sp_t, _s, _s);
		
		draw_set_color(COLORS._main_accent);
		draw_line(sp_r, -hh, sp_r, hh);
		draw_line(sp_l, -hh, sp_l, hh);
		draw_line(-ww, sp_t, ww, sp_t);
		draw_line(-ww, sp_b, ww, sp_b);
		
		if(drag_side > -1) {
			var vv;
			
			if(drag_side == 0)		vv = drag_sv - (_mx - drag_mx) / _s;
			else if(drag_side == 2)	vv = drag_sv + (_mx - drag_mx) / _s;
			else if(drag_side == 1)	vv = drag_sv + (_my - drag_my) / _s;
			else					vv = drag_sv - (_my - drag_my) / _s;
			
			_splice[drag_side] = vv;
			if(inputs[| 1].setValue(_splice))
				UNDO_HOLDING = true;
			
			if(mouse_release(mb_left, active)) {
				drag_side = -1;
				UNDO_HOLDING = false;
			}
		}
		
		if(distance_to_line_infinite(_mx, _my, sp_r, -hh, sp_r, hh) < 12) {
			draw_line_width(sp_r, -hh, sp_r, hh, 3);
			if(mouse_press(mb_left, active)) {
				drag_side = 0;
				drag_mx   = _mx;
				drag_my   = _my;
				drag_sv   = _splice[0];
			}
		} else if(distance_to_line_infinite(_mx, _my, -ww, sp_t, ww, sp_t) < 12) {
			draw_line_width(-ww, sp_t, ww, sp_t, 3);
			if(mouse_press(mb_left, active)) {
				drag_side = 1;
				drag_mx   = _mx;
				drag_my   = _my;
				drag_sv   = _splice[1];
			}
		} else if(distance_to_line_infinite(_mx, _my, sp_l, -hh, sp_l, hh) < 12) {
			draw_line_width(sp_l, -hh, sp_l, hh, 3);
			if(mouse_press(mb_left, active)) {
				drag_side = 2;
				drag_mx   = _mx;
				drag_my   = _my;
				drag_sv   = _splice[2];
			}
		} else if(distance_to_line_infinite(_mx, _my, -ww, sp_b, ww, sp_b) < 12) {
			draw_line_width(-ww, sp_b, ww, sp_b, 3);
			if(mouse_press(mb_left, active)) {
				drag_side = 3;
				drag_mx   = _mx;
				drag_my   = _my;
				drag_sv   = _splice[3];
			}
		}
	}
	
	static process_data = function(_outSurf, _data, _output_index) {
		var _inSurf		= _data[0];
		var _crop		= _data[1];
		var _dim		= [ surface_get_width(_inSurf) - _crop[0] - _crop[2], surface_get_height(_inSurf) - _crop[1] - _crop[3] ];
		
		surface_size_to(_outSurf, _dim[0], _dim[1]);
		
		surface_set_target(_outSurf);
			draw_clear_alpha(0, 0);
			BLEND_ADD
			
			draw_surface_safe(_inSurf, -_crop[2], -_crop[1]);
			
			BLEND_NORMAL
		surface_reset_target();
	}
}