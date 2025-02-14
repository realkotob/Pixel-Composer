function draw_corner(x1, y1, xc, yc, x3, y3, thick = 1, col = c_white, sample = 10) {
	var dir0 = point_direction(x1, y1, xc, yc);
	var dir1 = point_direction(x3, y3, xc, yc);
	
	var dis  = point_distance(x1, y1, x3, y3);
	if(dis < 8) {
		__draw_set_color(col);
		draw_line_width(x1, y1, x3, y3, thick);
		return;
	}
	
	var p2 = point_rotate(xc, yc, x1, y1, -90);
	var x2 = p2[0];
	var y2 = p2[1];
	
	var p4 = point_rotate(xc, yc, x3, y3, 90);
	var x4 = p4[0];
	var y4 = p4[1];
	
	var ra = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4);
	if(ra == 0) {
		__draw_set_color(col);
		draw_line_width(x1, y1, x3, y3, thick);
		return;
	}
	
	var px = ((x1 * y2 - y1 * x2) * (x3 - x4) - (x1 - x2) * (x3 * y4 - y3 * x4)) / ra;
	var py = ((x1 * y2 - y1 * x2) * (y3 - y4) - (y1 - y2) * (x3 * y4 - y3 * x4)) / ra;
	
	var r  = point_distance(px, py, x1, y1);
	var d0 = point_direction(px, py, x1, y1);
	var d1 = point_direction(px, py, x3, y3);
		
	__draw_set_color(col);
	draw_primitive_begin(pr_trianglestrip);
	
	var ox, oy, nx, ny;
	var aa = angle_difference(d1, d0);
	sample = round(sample);
	
	for( var i = 0; i <= sample; i++ ) {
		var a = d0 + aa * (i / sample);
		nx = px + lengthdir_x(r - thick / 2, a) + 1;
		ny = py + lengthdir_y(r - thick / 2, a) + 1;
		ox = px + lengthdir_x(r + thick / 2, a) + 1;
		oy = py + lengthdir_y(r + thick / 2, a) + 1;
		
		draw_vertex(nx, ny);
		draw_vertex(ox, oy);
	}
	
	draw_primitive_end();
}

function get_corner(x1, y1, xc, yc, x3, y3, sample = 10, thres = 8) {
	var dir0 = point_direction(x1, y1, xc, yc);
	var dir1 = point_direction(x3, y3, xc, yc);
	
	var dis  = point_distance(x1, y1, x3, y3);
	if(dis < thres) return [ [x1, y1], [x3, y3] ];
	
	var p2 = point_rotate(xc, yc, x1, y1, -90);
	var x2 = p2[0];
	var y2 = p2[1];
	
	var p4 = point_rotate(xc, yc, x3, y3, 90);
	var x4 = p4[0];
	var y4 = p4[1];
	
	var ra = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4);
	if(ra == 0) return [];
	
	var px = ((x1 * y2 - y1 * x2) * (x3 - x4) - (x1 - x2) * (x3 * y4 - y3 * x4)) / ra;
	var py = ((x1 * y2 - y1 * x2) * (y3 - y4) - (y1 - y2) * (x3 * y4 - y3 * x4)) / ra;
	
	var r  = point_distance(px, py, x1, y1);
	var d0 = point_direction(px, py, x1, y1);
	var d1 = point_direction(px, py, x3, y3);
	
	var ox, oy, nx, ny;
	var aa = angle_difference(d1, d0);
	sample = round(sample);
	
	var pnt = array_create(sample + 1)
	for( var i = 0; i <= sample; i++ ) {
		var a = d0 + aa * (i / sample);
		nx = px + lengthdir_x(r, a);
		ny = py + lengthdir_y(r, a);
		
		pnt[i] = [ nx, ny ];
	}
	
	return pnt;
}

function get_corner_radius(x1, y1, xc, yc, x3, y3, rad, sample = 10, thres = 8) {
	var dir0 = point_direction(xc, yc, x1, y1);
	var dir1 = point_direction(xc, yc, x3, y3);
	
	x1 = xc + lengthdir_x(rad, dir0);
	y1 = yc + lengthdir_y(rad, dir0);
	
	x3 = xc + lengthdir_x(rad, dir1);
	y3 = yc + lengthdir_y(rad, dir1);
	
	return get_corner(x1, y1, xc, yc, x3, y3, sample, thres);
}