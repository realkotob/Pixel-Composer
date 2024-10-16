function tiler_brush(node) constructor {
    brush_size    = 1;
    brush_indices = [[]];
    brush_width   = 0;
    brush_height  = 0;
    
    brush_surface = noone;
    brush_erase   = false;
    
    brush_sizing    = false;
	brush_sizing_s  = 0;
	brush_sizing_mx = 0;
	brush_sizing_my = 0;
	brush_sizing_dx = 0;
	brush_sizing_dy = 0;
	
	self.node = node;
	
	function step(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var attr = node.tool_attribute;
		var _siz = attr.size;
		
		brush_size = _siz;
		
		if(brush_size = PEN_USE && attr.pressure)
			brush_size = round(lerp(attr.pressure_size[0], attr.pressure_size[1], power(PEN_PRESSURE / 1024, 2)));
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

function tiler_draw_point_brush(brush, _x, _y) {
	if(brush.brush_height * brush.brush_width == 0) return;
	
	shader_set(sh_draw_tile_brush);
	BLEND_OVERRIDE
	
	for( var i = 0, n = brush.brush_height; i < n; i++ ) 
	for( var j = 0, m = brush.brush_width;  j < m; j++ ) {
		shader_set_f("index", brush.brush_erase? -1 : brush.brush_indices[i][j]);
    	
    	var _xx = _x + j;
    	var _yy = _y + i;
    	
    	if(brush.brush_size <= 1) 
    		draw_point(_xx, _yy);
    	
    	else if(brush.brush_size < global.FIX_POINTS_AMOUNT) { 
    		var fx = global.FIX_POINTS[brush.brush_size];
    		for( var i = 0, n = array_length(fx); i < n; i++ )
    			draw_point(_xx + fx[i][0], _yy + fx[i][1]);	
        
    	} else
    		draw_circle_prec(_xx, _yy, brush.brush_size / 2, 0);
	}
	
	BLEND_NORMAL
	shader_reset();
}

function tiler_draw_line_brush(brush, _x0, _y0, _x1, _y1) { 
	if(brush.brush_height * brush.brush_width == 0) return;
	
	shader_set(sh_draw_tile_brush);
	BLEND_OVERRIDE
	
	for( var i = 0, n = brush.brush_height; i < n; i++ ) 
	for( var j = 0, m = brush.brush_width;  j < m; j++ ) {
		shader_set_f("index", brush.brush_erase? -1 : brush.brush_indices[i][j]);
    	
    	var _xx0 = _x0 + j;
    	var _yy0 = _y0 + i;
    	var _xx1 = _x1 + j;
    	var _yy1 = _y1 + i;
    	
    	if(brush.brush_size < global.FIX_POINTS_AMOUNT) {
    		if(_xx1 > _xx0) _xx0--;
    		if(_xx1 < _xx0) _xx1--;
    		
    		if(_yy1 > _yy0) _yy0--;
    		if(_yy1 < _yy0) _yy1--;
    	}
    		
    	if(brush.brush_size == 1) {
    		draw_line(_xx0, _yy0, _xx1, _yy1);
    		
    	} else if(brush.brush_size < global.FIX_POINTS_AMOUNT) { 
    			
    		var fx = global.FIX_POINTS[brush.brush_size];
    		for( var i = 0, n = array_length(fx); i < n; i++ )
    			draw_line(_xx0 + fx[i][0], _yy0 + fx[i][1], _xx1 + fx[i][0], _yy1 + fx[i][1]);	
    				
    	} else {
    		draw_line_width(_xx0, _yy0, _xx1, _yy1, brush.brush_size);
    	}
	}
	
	BLEND_NORMAL
	shader_reset();
}