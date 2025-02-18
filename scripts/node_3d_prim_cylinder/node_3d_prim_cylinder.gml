function Node_3D_Cylinder(_x, _y, _group = -1) : Node(_x, _y, _group) constructor {
	name = "3D Cylinder";
	
	uniVertex_lightFor = shader_get_uniform(sh_vertex_pnt_light, "u_LightForward");
	uniLightAmb = shader_get_uniform(sh_vertex_pnt_light, "u_AmbientLight");
	uniLightClr = shader_get_uniform(sh_vertex_pnt_light, "u_LightColor");
	uniLightInt = shader_get_uniform(sh_vertex_pnt_light, "u_LightIntensity");
	uniLightNrm = shader_get_uniform(sh_vertex_pnt_light, "useNormal");
	
	inputs[| 0] = nodeValue(0, "Sides", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 16);
	
	inputs[| 1] = nodeValue(1, "Thickness", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.2);
		
	inputs[| 2] = nodeValue(2, "Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, def_surf_size2)
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 3] = nodeValue(3, "Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ def_surf_size / 2, def_surf_size / 2 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 4] = nodeValue(4, "Rotation", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 5] = nodeValue(5, "Render scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 1, 1 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 6] = nodeValue(6, "Textures top",	self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	inputs[| 7] = nodeValue(7, "Textures bottom", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	inputs[| 8] = nodeValue(8, "Textures side",	self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 9] = nodeValue(9, "Scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 1, 1, 1 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 10] = nodeValue(10, "Light direction", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.rotation);
		
	inputs[| 11] = nodeValue(11, "Light height", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.5)
		.setDisplay(VALUE_DISPLAY.slider, [-1, 1, 0.01]);
		
	inputs[| 12] = nodeValue(12, "Light intensity", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider, [0, 1, 0.01]);
	
	inputs[| 13] = nodeValue(13, "Light color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white);
	inputs[| 14] = nodeValue(14, "Ambient color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_grey);
	
	input_display_list = [2, 
		["Geometry",	false], 0, 1, 
		["Transform",	false], 3, 4, 9, 5, 
		["Texture",		true], 6, 7, 8,
		["Light",		false], 10, 11, 12, 13, 14,
	];
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	
	sides = 16;
	thick =  0.5;
	VB_top = vertex_create_buffer();
	VB_sid = vertex_create_buffer();
	
	static generate_vb = function() {
		var _ox, _oy, _nx, _ny, _ou, _nu;
		
		vertex_begin(VB_top, FORMAT_PNT);
		for(var i = 0; i <= sides; i++)  {
			_nx = lengthdir_x(0.5, i * 360 / sides);
			_ny = lengthdir_y(0.5, i * 360 / sides);
			
			if(i) {
				vertex_add_pnt(VB_top, [  0, thick / 2,   0], [0, 1, 0], [  0 + 0.5,   0 + 0.5]);
				vertex_add_pnt(VB_top, [_ox, thick / 2, _oy], [0, 1, 0], [_ox + 0.5, _oy + 0.5]);
				vertex_add_pnt(VB_top, [_nx, thick / 2, _ny], [0, 1, 0], [_nx + 0.5, _ny + 0.5]);
			}
			
			_ox = _nx;
			_oy = _ny;
		}
		
		vertex_end(VB_top);
		
		vertex_begin(VB_sid, FORMAT_PNT);
		for(var i = 0; i <= sides; i++)  {
			_nx = lengthdir_x(0.5, i * 360 / sides);
			_ny = lengthdir_y(0.5, i * 360 / sides);
			_nu = i / sides;
			
			if(i) {
				vertex_add_pnt(VB_sid, [_ox, -thick / 2, _oy], [_nx, 0, _ny], [_ou, 0]);
				vertex_add_pnt(VB_sid, [_ox,  thick / 2, _oy], [_nx, 0, _ny], [_ou, 1]);
				vertex_add_pnt(VB_sid, [_nx,  thick / 2, _ny], [_nx, 0, _ny], [_nu, 1]);
				
				vertex_add_pnt(VB_sid, [_nx,  thick / 2, _ny], [_nx, 0, _ny], [_nu, 1]);
				vertex_add_pnt(VB_sid, [_nx, -thick / 2, _ny], [_nx, 0, _ny], [_nu, 0]);
				vertex_add_pnt(VB_sid, [_ox, -thick / 2, _oy], [_nx, 0, _ny], [_ou, 0]);
			}
			
			_ox = _nx;
			_oy = _ny;
			_ou = _nu;
		}
		vertex_end(VB_sid);
	}
	generate_vb();
	
	drag_index = -1;
	drag_sv = 0;
	drag_mx = 0;
	drag_my = 0;
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my) {
		if(inputs[| 3].drawOverlay(active, _x, _y, _s, _mx, _my)) 
			active = false;
		
		var _dim = inputs[| 2].getValue();
		var _pos = inputs[| 3].getValue();
		var _rot = inputs[| 4].getValue();
		var cx = _x + _pos[0] * _s;
		var cy = _y + _pos[1] * _s;
		
		draw_set_color(COLORS.axis[0]);
		draw_line(cx - 64, cy, cx + 64, cy);
		
		draw_set_color(COLORS.axis[1]);
		draw_line(cx, cy - 64, cx, cy + 64);
		
		draw_set_color(COLORS.axis[2]);
		draw_circle(cx, cy, 64, true);
		
		if(drag_index == 0) {
			var dx  = (_mx - drag_mx) / _s * 6;
			_rot[1] = drag_sv + dx;
			
			if(inputs[| 4].setValue(_rot)) 
				UNDO_HOLDING = true;
			
			if(mouse_release(mb_left)) {
				drag_index = -1;
				UNDO_HOLDING = false;
			}
		} else if(drag_index == 1) {
			var dy  = (_my - drag_my) / _s * -6;
			_rot[0] = drag_sv + dy;
			
			if(inputs[| 4].setValue(_rot)) 
				UNDO_HOLDING = true;
			
			if(mouse_release(mb_left)) {
				drag_index = -1;
				UNDO_HOLDING = false;
			}
		} else if(drag_index == 2) {
			var da  = point_direction(cx, cy, _mx, _my);
			_rot[2] = da;
			
			if(inputs[| 4].setValue(_rot)) 
				UNDO_HOLDING = true;
			
			if(mouse_release(mb_left)) {
				drag_index = -1;
				UNDO_HOLDING = false;
			}
		} else {
			if(distance_to_line(_mx, _my, cx - 64, cy, cx + 64, cy) < 16) {
				draw_set_color(COLORS.axis[0]);
				draw_line_width(cx - 64, cy, cx + 64, cy, 3);
				if(mouse_press(mb_left, active)) {
					drag_index	= 0;
					drag_sv		= _rot[1];
					drag_mx		= _mx;
					drag_my		= _my;
				}
			} else if(distance_to_line(_mx, _my, cx, cy - 64, cx, cy + 64) < 16) {
				draw_set_color(COLORS.axis[1]);
				draw_line_width(cx, cy - 64, cx, cy + 64, 3);
				if(mouse_press(mb_left, active)) {
					drag_index	= 1;
					drag_sv		= _rot[0];
					drag_mx		= _mx;
					drag_my		= _my;
				}
			} else if(abs(point_distance(_mx, _my, cx, cy) - 64) < 8) {
				draw_set_color(COLORS.axis[2]);
				draw_circle_border(cx, cy, 64, 3);
				if(mouse_press(mb_left, active)) {
					drag_index	= 2;
					drag_sv		= _rot[2];
					drag_mx		= _mx;
					drag_my		= _my;
				}
			}
		}
		
		inputs[| 3].drawOverlay(active, _x, _y, _s, _mx, _my);
	}
	
	#region 3D setup
		TM = matrix_build(0, 0, 0, 0, 0, 0, 1, 1, 1);
		cam = camera_create();
		cam_view = matrix_build_lookat(0, 0, 1, 0, 0, 0, 0, 1, 0);
		cam_proj = matrix_build_projection_ortho(1, 1, 1, 100);
		
		camera_set_proj_mat(cam, cam_view);
		camera_set_view_mat(cam, cam_proj);
	#endregion
	
	static update = function() {
		var _sides = inputs[| 0].getValue();
		var _thick = inputs[| 1].getValue();
		
		if(_sides != sides || _thick != thick) {
			sides = _sides;
			thick = _thick;
			generate_vb();	
		}
		
		var _dim		= inputs[| 2].getValue();
		var _pos		= inputs[| 3].getValue();
		var _rot		= inputs[| 4].getValue();
		var _sca		= inputs[| 5].getValue();
		var face_top	= inputs[| 6].getValue();
		var face_bot	= inputs[| 7].getValue();
		var face_sid	= inputs[| 8].getValue();
		var _lsc		= inputs[| 9].getValue();
		
		var _ldir = inputs[| 10].getValue();
		var _lhgt = inputs[| 11].getValue();
		var _lint = inputs[| 12].getValue();
		var _lclr = inputs[| 13].getValue();
		var _aclr = inputs[| 14].getValue();
		
		var _outSurf = outputs[| 0].getValue();
		if(!is_surface(_outSurf)) {
			_outSurf = surface_create_valid(_dim[0], _dim[1]);
			outputs[| 0].setValue(_outSurf);
		} else
			surface_size_to(_outSurf, _dim[0], _dim[1]);
		
		TM = matrix_build(_pos[0], _pos[1], 0, _rot[0], _rot[1], _rot[2], _dim[0] * _sca[0], _dim[1] * _sca[1], 1);
		cam_proj = matrix_build_projection_ortho(_dim[0], _dim[1], 1, 100);
		camera_set_view_mat(cam, cam_proj);
		camera_set_view_size(cam, _dim[0], _dim[1]);
		
		var lightFor = [ -cos(degtorad(_ldir)), -_lhgt, -sin(degtorad(_ldir)) ];
		
		gpu_set_ztestenable(true);
		surface_set_target(_outSurf);
			shader_set(sh_vertex_pnt_light);
			shader_set_uniform_f_array(uniVertex_lightFor, lightFor);
			shader_set_uniform_f_array(uniLightAmb, colorArrayFromReal(_aclr));
			shader_set_uniform_f_array(uniLightClr, colorArrayFromReal(_lclr));
			shader_set_uniform_f(uniLightInt, _lint);
			shader_set_uniform_i(uniLightNrm, 1);
			
			camera_apply(cam);
			draw_clear_alpha(0, 0);
				
			matrix_stack_push(TM);
			matrix_stack_push(matrix_build(0, 0, 0, 0, 0, 0, _lsc[0], _lsc[1], _lsc[2]));
				
			matrix_set(matrix_world, matrix_stack_top());
			vertex_submit(VB_top, pr_trianglelist, surface_get_texture(face_top));
				
			matrix_stack_push(matrix_build(0, -thick, 0, 0, 0, 0, 1, 1, 1));
			matrix_set(matrix_world, matrix_stack_top());
			vertex_submit(VB_top, pr_trianglelist, surface_get_texture(face_bot));
			matrix_stack_pop();
				
			matrix_set(matrix_world, matrix_stack_top());
			vertex_submit(VB_sid, pr_trianglelist, surface_get_texture(face_sid));
			
			shader_reset();
			matrix_stack_pop();
			matrix_stack_pop();
			matrix_set(matrix_world, MATRIX_IDENTITY);
		surface_reset_target();
		
		gpu_set_ztestenable(false);
		camera_apply(0);
		
		return _outSurf;
	}
}