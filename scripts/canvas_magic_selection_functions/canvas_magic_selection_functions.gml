
function canvas_ms_fillable(colorBase, colorFill, _x, _y, _thres) { #region
	var c = _ff_getPixel(_x, _y);
	var d = color_diff_alpha(colorBase, c);
	return d <= _thres;
} #endregion

function canvas_magic_selection_scanline(_surf, _x, _y, _thres, _corner = false) { #region
	
	var colorBase = int64(surface_getpixel_ext(_surf, _x, _y));
	var colorFill = colorBase;
	
	var x1, y1, x_start;
	var spanAbove, spanBelow;
	var thr = _thres * _thres;
	
	_ff_w    = surface_get_width(_surf);
	_ff_h    = surface_get_height(_surf);
	_ff_buff = buffer_create(_ff_w * _ff_h * 4, buffer_fixed, 4);
	buffer_get_surface(_ff_buff, _surf, 0);
	
	var qx = ds_queue_create();
	var qy = ds_queue_create();
	ds_queue_enqueue(qx, _x);
	ds_queue_enqueue(qy, _y);
	
	var sel_x0 = surface_w;
	var sel_y0 = surface_h;
	var sel_x1 = 0;
	var sel_y1 = 0;
	
	var _arr = array_create(surface_w * surface_h, 0);
	
	draw_set_color(c_white);
	while(!ds_queue_empty(qx)) {
		
		x1 = ds_queue_dequeue(qx);
		y1 = ds_queue_dequeue(qy);
		
		if(_arr[y1 * surface_w + x1] == 1) continue; //Color in queue is already filled
			
		while(x1 > 0 && canvas_ms_fillable(colorBase, colorFill, x1 - 1, y1, thr)) //Move to the leftmost connected pixel in the same row.
			x1--;
		x_start = x1;
			
		spanAbove = false;
		spanBelow = false;
			
		//print($"Searching {x1}, {y1} | {canvas_ms_fillable(colorBase, colorFill, x1, y1, thr)}");
		
		while(x1 < surface_w && canvas_ms_fillable(colorBase, colorFill, x1, y1, thr)) {
			draw_point(x1, y1);
			
			if(_arr[y1 * surface_w + x1] == 1) continue;
			_arr[y1 * surface_w + x1] = 1;
			
			sel_x0 = min(sel_x0, x1);
			sel_y0 = min(sel_y0, y1);
			sel_x1 = max(sel_x1, x1);
			sel_y1 = max(sel_y1, y1);
			    
			//print($"> Filling {x1}, {y1}: {canvas_get_color_buffer(x1, y1)}");
				
			if(y1 > 0) {
				if(_corner && x1 > 0 && canvas_ms_fillable(colorBase, colorFill, x1 - 1, y1 - 1, thr)) {	//Check top left pixel
					ds_queue_enqueue(qx, x1 - 1);
					ds_queue_enqueue(qy, y1 - 1);
				}
					
				if(canvas_ms_fillable(colorBase, colorFill, x1, y1 - 1, thr)) {								//Check top pixel
					ds_queue_enqueue(qx, x1);
					ds_queue_enqueue(qy, y1 - 1);
				}
			}
				
			if(y1 < surface_h - 1) {
				if(_corner && x1 > 0 && canvas_ms_fillable(colorBase, colorFill, x1 - 1, y1 + 1, thr)) {	//Check bottom left pixel
					ds_queue_enqueue(qx, x1 - 1);
					ds_queue_enqueue(qy, y1 + 1);
				}
					
				if(canvas_ms_fillable(colorBase, colorFill, x1, y1 + 1, thr)) {								//Check bottom pixel
					ds_queue_enqueue(qx, x1);
					ds_queue_enqueue(qy, y1 + 1);
				}
			}
				
			if(_corner && x1 < surface_w - 1) {
				if(y1 > 0 && canvas_ms_fillable(colorBase, colorFill, x1 + 1, y1 - 1, thr)) {				//Check top right pixel
					ds_queue_enqueue(qx, x1 + 1);
					ds_queue_enqueue(qy, y1 - 1);
				}
					
				if(y1 < surface_h - 1 && canvas_ms_fillable(colorBase, colorFill, x1 + 1, y1 + 1, thr)) {	//Check bottom right pixel
					ds_queue_enqueue(qx, x1 + 1);
					ds_queue_enqueue(qy, y1 + 1);
				}
			}
				
			x1++;
		}
	}
	
	ds_queue_destroy(qx);
	ds_queue_destroy(qy);
		
	buffer_delete(_ff_buff);
	
	return [ sel_x0, sel_y0, sel_x1, sel_y1 ];
} #endregion

function canvas_magic_selection_all(_surf, _x, _y, _thres) { #region
	
	var colorBase = surface_getpixel_ext(_surf, _x, _y);
	var colorFill = colorBase;
	
	var thr = _thres * _thres;
	
	var _ff_w    = surface_get_width(_surf);
	var _ff_h    = surface_get_height(_surf);
	var _ff_buff = buffer_create(_ff_w * _ff_h * 4, buffer_fixed, 4);
	buffer_get_surface(_ff_buff, _surf, 0);
	buffer_seek(_ff_buff, buffer_seek_start, 0);
	
	var sel_x0 = surface_w;
	var sel_y0 = surface_h;
	var sel_x1 = 0;
	var sel_y1 = 0;
	
	for (var i = 0; i < _ff_h; i++)
	for (var j = 0; j < _ff_w; j++) {
		
		var c = buffer_read(_ff_buff, buffer_u32);
		var d = color_diff_alpha(colorBase, c);
		
		if(d > _thres) continue;
		draw_point(j, i);
		
		sel_x0 = min(sel_x0, j);
		sel_y0 = min(sel_y0, i);
		sel_x1 = max(sel_x1, j);
		sel_y1 = max(sel_y1, i);
		    
	}
	
	buffer_delete(_ff_buff);
	
	return [ sel_x0, sel_y0, sel_x1, sel_y1 ];
} #endregion