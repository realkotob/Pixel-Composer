function _ff_getPixel(_x, _y) { return buffer_read_at(_ff_buff, (_y * _ff_w + _x) * 4, buffer_u32); }
	
function canvas_ff_fillable(colorBase, colorFill, _x, _y, _thres) {
	var c = _ff_getPixel(_x, _y);
	var d = color_diff_alpha(colorBase, c);
	return d <= _thres && c != colorFill;
}

function canvas_flood_fill_scanline(_surf, _x, _y, _thres, _corner = false) {

	var colorFill = CURRENT_COLOR;
	var colorBase = int64(surface_getpixel_ext(_surf, _x, _y));
	
	if(colorFill == colorBase) return; //Clicking on the same color as the fill color
	
	var _c = CURRENT_COLOR;
	draw_set_color(_c);
	
	_ff_w    = surface_get_width(_surf);
	_ff_h    = surface_get_height(_surf);
	_ff_buff = buffer_create(_ff_w * _ff_h * 4, buffer_fixed, 4);
	buffer_get_surface(_ff_buff, _surf, 0);
	
	var x1, y1, x_start;
	var spanAbove, spanBelow;
	var thr = _thres * _thres;

	var qx = ds_queue_create();
	var qy = ds_queue_create();
	ds_queue_enqueue(qx, _x);
	ds_queue_enqueue(qy, _y);
	
	while(!ds_queue_empty(qx)) {
		
		x1 = ds_queue_dequeue(qx);
		y1 = ds_queue_dequeue(qy);
		
		if(_ff_getPixel(x1, y1) == colorFill) continue; //Color in queue is already filled
		
		while(x1 > 0 && canvas_ff_fillable(colorBase, colorFill, x1 - 1, y1, thr)) //Move to the leftmost connected pixel in the same row.
			x1--;
		x_start = x1;
		
		spanAbove = false;
		spanBelow = false;
		
		while(x1 < surface_w && canvas_ff_fillable(colorBase, colorFill, x1, y1, thr)) {
			draw_point(x1, y1);
			buffer_seek(_ff_buff, buffer_seek_start, (y1 * _ff_w + x1) * 4)
			buffer_write(_ff_buff, buffer_u32, _c);
			
			if(y1 > 0) {
				if(_corner && x1 > 0 && canvas_ff_fillable(colorBase, colorFill, x1 - 1, y1 - 1, thr)) {	//Check top left pixel
					ds_queue_enqueue(qx, x1 - 1);
					ds_queue_enqueue(qy, y1 - 1);
				}
					
				if(canvas_ff_fillable(colorBase, colorFill, x1, y1 - 1, thr)) {								//Check top pixel
					ds_queue_enqueue(qx, x1);
					ds_queue_enqueue(qy, y1 - 1);
				}
			}
				
			if(y1 < surface_h - 1) {
				if(_corner && x1 > 0 && canvas_ff_fillable(colorBase, colorFill, x1 - 1, y1 + 1, thr)) {	//Check bottom left pixel
					ds_queue_enqueue(qx, x1 - 1);
					ds_queue_enqueue(qy, y1 + 1);
				}
					
				if(canvas_ff_fillable(colorBase, colorFill, x1, y1 + 1, thr)) {								//Check bottom pixel
					ds_queue_enqueue(qx, x1);
					ds_queue_enqueue(qy, y1 + 1);
				}
			}
				
			if(_corner && x1 < surface_w - 1) {
				if(y1 > 0 && canvas_ff_fillable(colorBase, colorFill, x1 + 1, y1 - 1, thr)) {				//Check top right pixel
					ds_queue_enqueue(qx, x1 + 1);
					ds_queue_enqueue(qy, y1 - 1);
				}
					
				if(y1 < surface_h - 1 && canvas_ff_fillable(colorBase, colorFill, x1 + 1, y1 + 1, thr)) {	//Check bottom right pixel
					ds_queue_enqueue(qx, x1 + 1);
					ds_queue_enqueue(qy, y1 + 1);
				}
			}
				
			x1++;
		}
	}
	
	ds_queue_destroy(qx);
	ds_queue_destroy(qy);
		
	draw_set_alpha(1);
	buffer_delete(_ff_buff);
}

function canvas_flood_fill_all(_surf, _x, _y, _thres) {
	
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
}