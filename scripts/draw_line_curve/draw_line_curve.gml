enum LINE_STYLE {
	solid,
	dashed
}

function draw_line_curve(x0, y0, x1, y1, thick = 1) {
	var xc = (x0 + x1) / 2;
	var sample = max(8, ceil((abs(x0 - x1) + abs(y0 - y1)) / 4));
	
	//var buff = vertex_create_buffer();
	//vertex_begin(buff, global.format_pc);
	
	var c = draw_get_color();
	var ox, oy, nx, ny, t, it;
	for( var i = 0; i <= sample; i++ )  {
		t = i / sample;
		it = 1 - t;
		
		nx = x0 * t * t * t + 3 * xc * it * t * t + 3 * xc * it * it * t + x1 * it * it * it;
		ny = y0 * t * t * t + 3 * y0 * it * t * t + 3 * y1 * it * it * t + y1 * it * it * it;
		
		if(i) {
			draw_line_width(ox, oy, nx, ny, thick);
			//vertex_position(buff, ox, oy); vertex_color(buff, c, 1);
			//vertex_position(buff, nx, ny); vertex_color(buff, c, 1);
		}
		
		ox = nx;
		oy = ny;
	}
	
	//vertex_end(buff);
	//vertex_submit(buff, pr_linelist, -1);
	
	//buffer_delete(buff);
}

function draw_line_curve_color(x0, y0, x1, y1, thick, col1, col2, type = LINE_STYLE.solid) {
	var xc = (x0 + x1) / 2;
	var sample = max(8, ceil((abs(x0 - x1) + abs(y0 - y1)) / 4));
	
	var c = draw_get_color();
	var ox, oy, nx, ny, t, it, oc, nc;
	var dash_distance = 2;
	
	for( var i = 0; i <= sample; i++ )  {
		t = i / sample;
		it = 1 - t;
		
		nx = x0 * t * t * t + 3 * xc * it * t * t + 3 * xc * it * it * t + x1 * it * it * it;
		ny = y0 * t * t * t + 3 * y0 * it * t * t + 3 * y1 * it * it * t + y1 * it * it * it;
		nc = merge_color(col1, col2, t);
		
		if(i) {
			switch(type) {
				case LINE_STYLE.solid :
					draw_line_width_color(ox, oy, nx, ny, thick, oc, nc);
					break;
				case LINE_STYLE.dashed :
					if(floor(i / dash_distance) % 2)
						draw_line_width_color(ox, oy, nx, ny, thick, oc, nc);
					break;
			}
		}
		
		ox = nx;
		oy = ny;
		oc = nc;
	}
}

function distance_to_curve(mx, my, x0, y0, x1, y1) {
	var xc = (x0 + x1) / 2;
	var sample = max(8, ceil((abs(x0 - x1) + abs(y0 - y1)) / 4));
	
	var dist = 999999;
	var ox, oy, nx, ny, t, it;
	
	for( var i = 0; i <= sample; i++ )  {
		t = i / sample;
		it = 1 - t;
		
		nx = x0 * t * t * t + 3 * xc * it * t * t + 3 * xc * it * it * t + x1 * it * it * it;
		ny = y0 * t * t * t + 3 * y0 * it * t * t + 3 * y1 * it * it * t + y1 * it * it * it;
		
		if(i)
			dist = min(dist, distance_to_line(mx, my, ox, oy, nx, ny));
		
		ox = nx;
		oy = ny;
	}
	
	return dist;
}

function draw_line_elbow(x0, y0, x1, y1, thick = 1, type = LINE_STYLE.solid) {
	var cx = (x0 + x1) / 2;
	draw_line_width(x0, y0, cx, y0, thick);
	draw_line_width(cx, y0 - thick / 2, cx, y1 + thick / 2, thick);
	draw_line_width(cx, y1, x1, y1, thick);
}

function draw_line_elbow_color(x0, y0, x1, y1, thick, col1, col2, type = LINE_STYLE.solid) {
	var cx = (x0 + x1) / 2;
	var cm = merge_color(col1, col2, 0.5);
						
	if(type == LINE_STYLE.solid) {
		draw_line_width_color(x0, y0, cx, y0, thick, col1, cm);
		draw_line_width_color(cx, y0 - thick / 2, cx, y1 + thick / 2, thick, cm, cm);
		draw_line_width_color(cx, y1, x1, y1, thick, cm, col2);
	} else {
		draw_line_dashed_color(x0, y0, cx, y0, thick, col1, cm, 12);
		draw_line_dashed_color(cx, y0 - thick / 2, cx, y1 + thick / 2, thick, cm, cm, 12);
		draw_line_dashed_color(cx, y1, x1, y1, thick, cm, col2, 12);
	}	
}