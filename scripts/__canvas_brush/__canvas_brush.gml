function canvas_brush() constructor {
	
	brush_use_surface = false;
	brush_surface   = noone;
	brush_size      = 1;
	brush_dist_min  = 1;
	brush_dist_max  = 1;
	brush_direction = 0;
	brush_rand_dir  = [ 0, 0, 0, 0, 0 ];
	brush_seed      = irandom_range(100000, 999999);
	brush_next_dist = 0;
	brush_range     = 0;
	
	brush_sizing    = false;
	brush_sizing_s  = 0;
	brush_sizing_mx = 0;
	brush_sizing_my = 0;
	brush_sizing_dx = 0;
	brush_sizing_dy = 0;
	
	mouse_pre_dir_x = undefined;
	mouse_pre_dir_y = undefined;
	
	tileMode = 0;
	node     = noone;
	
	colors = [ c_white, c_black ];
	
	function step(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		
		var _brushSurf	= node.getInputData(6);
		var _brushDist	= node.getInputData(15);
		var _brushRotD	= node.getInputData(16);
		var _brushRotR  = node.getInputData(17);
		
		var attr = node.tool_attribute;
		var _siz = attr.size;
		
		brush_size = _siz;
		
		if(brush_size = PEN_USE && attr.pressure)
			brush_size = round(lerp(attr.pressure_size[0], attr.pressure_size[1], power(PEN_PRESSURE / 1024, 2)));
		
		brush_dist_min = max(1, _brushDist[0]);
		brush_dist_max = max(1, _brushDist[1]);
		
		if(brush_use_surface) {
			if(!is_surface(brush_surface)) {
				brush_surface = noone;
				brush_use_surface = false;
			}
		} else
			brush_surface = is_surface(_brushSurf)? _brushSurf : noone;
		brush_range = brush_surface == noone? ceil(brush_size / 2) : max(surface_get_width_safe(brush_surface), surface_get_height_safe(brush_surface)) / 2;
		
		if(!_brushRotD) 
			brush_direction = 0;
			
		else if(mouse_pre_dir_x == undefined) {
			mouse_pre_dir_x = _mx;
			mouse_pre_dir_y = _my;
			
		} else if(point_distance(mouse_pre_dir_x, mouse_pre_dir_y, _mx, _my) > _s) {
			brush_direction = point_direction(mouse_pre_dir_x, mouse_pre_dir_y, _mx, _my);
			mouse_pre_dir_x = _mx;
			mouse_pre_dir_y = _my;
		}
		
		brush_rand_dir = _brushRotR;
	}
	
	function sizing(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var attr = node.tool_attribute;
		var _siz = attr.size;
		
		if(brush_sizing) {
			var s = brush_sizing_s + (_mx - brush_sizing_mx) / 16;
				s = max(1, s);
			attr.size = s;
			
			if(mouse_release(mb_right)) 
				brush_sizing = false;
					
		} else if(mouse_press(mb_right, active) && key_mod_press(SHIFT) && brush_surface == noone) {
				
			brush_sizing    = true;
			brush_sizing_s  = _siz;
			brush_sizing_mx = _mx;
			brush_sizing_my = _my;
			
			brush_sizing_dx = round((_mx - _x) / _s - 0.5);
			brush_sizing_dy = round((_my - _y) / _s - 0.5);
		}
	}
}