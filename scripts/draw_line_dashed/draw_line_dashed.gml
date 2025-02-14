function draw_line_dashed(x0, y0, x1, y1, th = 1, dash_distance = 8, dash_shift = 0) {
	var dis  = point_distance(x0, y0, x1, y1);
	var dir  = point_direction(x0, y0, x1, y1);
	var part = ceil(dis / dash_distance);
	
	var dx = lengthdir_x(1, dir);
	var dy = lengthdir_y(1, dir);
	
	var ox, oy, nx, ny, od, nd;
	var rat = dash_distance / dis;
	
	for( var i = 0; i <= part; i++ ) {
		nd = dis * frac(i * rat + dash_shift / dis);
		nx = x0 + dx * nd;
		ny = y0 + dy * nd;
		
		if(i && i % 2 && nd > od)
			draw_line_width(ox, oy, nx, ny, th);
		
		ox = nx;
		oy = ny;
		od = nd;
	}
}

function draw_line_dashed_color(x0, y0, x1, y1, th, c0, c1, dash_distance = 8) {
	var dis  = point_distance(x0, y0, x1, y1);
	var dir  = point_direction(x0, y0, x1, y1);
	var part = ceil(dis / dash_distance);
	
	var dx = lengthdir_x(1, dir);
	var dy = lengthdir_y(1, dir);
	
	var ox, oy, nx, ny, oc, nc;
	var dd = 0;
	
	for( var i = 0; i <= part; i++ ) {
		dd = min(dis, i * dash_distance);
		nx = x0 + dx * dd;
		ny = y0 + dy * dd;
		nc = merge_color(c0, c1, i / part);
		
		if(i % 2) draw_line_width_color(ox, oy, nx, ny, th, oc, nc);
		
		oc = nc;
		ox = nx;
		oy = ny;
	}
}

function draw_line_dotted(x0, y0, x1, y1, radius, shift, distanceMulp = 1) {
	var dis  = point_distance(x0, y0, x1, y1);
	var dir  = point_direction(x0, y0, x1, y1);
	var dtd  = radius * distanceMulp * 2;
	var part = floor(dis / dtd);
	    dtd  = dis / part;
	
	var dx = lengthdir_x(1, dir);
	var dy = lengthdir_y(1, dir);
	
	var nd, nx, ny;
	var rat = dtd / dis;
	
	for( var i = 0; i < part; i++ ) {
		nd = dis * frac(i * rat + shift / dis);
		nx = x0 + dx * nd;
		ny = y0 + dy * nd;
		
		draw_circle(nx, ny, radius, false);
	}
}