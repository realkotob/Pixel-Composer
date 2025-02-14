global.node_rm_primitive_keys = [ 
	"plane", "box", "box frame", "box round", "cube", 
	"sphere", "ellipse", "cut sphere", "cut hollow sphere", "torus", "capped torus",
	"cylinder", "prism", "capsule", "cone", "capped cone", "round cone", "3d arc", "pie", 
	"octahedron", "pyramid", 
];

function Node_create_RM_Primitive(_x, _y, _group = noone, _param = {}) {
	var query = struct_try_get(_param, "query", "");
	var node  = new Node_RM_Primitive(_x, _y, _group);
	node.skipDefault();
	
	switch(query) {
		case "cube" : ind = array_find_string(node.shape_types, "box");	break;
		default     : ind = array_find_string(node.shape_types, query);
	}
	
	if(ind >= 0) node.inputs[1].setValue(ind);
	return node;
}

function Node_RM_Primitive(_x, _y, _group = noone) : Node_RM(_x, _y, _group) constructor {
	name  = "RM Primitive";
	
	newInput(0, nodeValue_Dimension(self));
	
	shape_types = [ 
		"Plane", "Box", "Box Frame", "Box Round", 
		-1, 
		"Sphere", "Ellipse", "Cut Sphere", "Cut Hollow Sphere", "Torus", "Capped Torus",
		-1,
		"Cylinder", "Prism", "Capsule", "Cone", "Capped Cone", "Round Cone", "3D Arc", "Pie", 
		-1, 
		"Octahedron", "Pyramid", 
	];
	shape_types_str = [];
	
	var _ind = 0;
	for( var i = 0, n = array_length(shape_types); i < n; i++ )
		shape_types_str[i] = shape_types[i] == -1? -1 : new scrollItem(shape_types[i], s_node_shape_3d, _ind++, COLORS._main_icon_light);
	
	newInput(1, nodeValue_Enum_Scroll("Shape", self,  1, { data: shape_types_str, horizontal: true, text_pad: ui(16) }));
	
	newInput(2, nodeValue_Vec3("Position", self, [ 0, 0, 0 ]));
	
	newInput(3, nodeValue_Vec3("Rotation", self, [ 0, 0, 0 ]));
	
	newInput(4, nodeValue_Float("Scale", self, 1))
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 0, 4, 0.01 ] });
	
	newInput(5, nodeValue_Float("FOV", self, 30))
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 0, 90, 1 ] });
	
	newInput(6, nodeValue_Vec2("View Range", self, [ 3, 6 ]));
	
	newInput(7, nodeValue_Float("Depth", self, 0))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(8, nodeValue_Vec3("Light Position", self, [ -.4, -.5, 1 ]));
	
	newInput(9, nodeValue_Color("Base Color", self, cola(c_white)));
	
	newInput(10, nodeValue_Float("Ambient Level", self, 0.2))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(11, nodeValue_Vec3("Elongate", self, [ 0, 0, 0 ]));
	
	newInput(12, nodeValue_Float("Rounded", self, 0.))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(13, nodeValue_Enum_Button("Projection", self,  0, [ "Perspective", "Orthographic" ]));
	
	newInput(14, nodeValue_Float("Ortho Scale", self, 1.))
	
	newInput(15, nodeValue_Vec3("Wave Amplitude", self, [ 4, 4, 4 ]));
	
	newInput(16, nodeValue_Vec3("Wave Intensity", self, [ 0, 0, 0 ]));
	
	newInput(17, nodeValue_Vec3("Wave Phase", self, [ 0, 0, 0 ]));
	
	newInput(18, nodeValue_Enum_Button("Twist Axis", self,  0, [ "X", "Y", "Z" ]));
	
	newInput(19, nodeValue_Float("Twist Amount", self, 0))
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 0, 8, 0.1 ] });
	
	newInput(20, nodeValue_Vec3("Tile Distance", self, [ 1, 1, 1 ]));
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	newInput(21, nodeValue_Vec3("Size", self, [ 1, 1, 1 ]));
	
	newInput(22, nodeValue_Float("Radius", self, .7))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(23, nodeValue_Float("Thickness", self, .2))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(24, nodeValue_Float("Crop", self, 0.))
		.setDisplay(VALUE_DISPLAY.slider, { range: [ -1, 1, 0.01 ] });
	
	newInput(25, nodeValue_Rotation("Angle", self, 30));
	
	newInput(26, nodeValue_Float("Height", self, .5))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(27, nodeValue_Slider_Range("Radius Range", self, [ .7, .1 ]));
	
	newInput(28, nodeValue_Float("Uniform Size", self, 1))
		.setDisplay(VALUE_DISPLAY.slider);
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	newInput(29, nodeValue_Vec3("Tile Amount", self, [ 1, 1, 1 ]));
	
	newInput(30, nodeValue_Color("Background", self, cola(c_black)));
	
	newInput(31, nodeValue_Bool("Draw BG", self, false));
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	newInput(32, nodeValue_Bool("Volumetric", self, false));
	
	newInput(33, nodeValue_Float("Density", self, 0.3))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(34, nodeValue_Surface("Environment", self));
	
	newInput(35, nodeValue_Float("Reflective", self, 0.))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(36, nodeValue_Surface("Texture", self));
	
	newInput(37, nodeValue_Float("Triplanar Smoothing", self, 1.))
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 0, 10, 0.1 ] });
	
	newInput(38, nodeValue_Float("Texture Scale", self, 1.));
	
	newInput(39, nodeValue_Vec4("Corner", self, [ 0.25, 0.25, 0.25, 0.25 ]));
	
	newInput(40, nodeValue_Vec2("2D Size", self, [ 0.5, 0.5 ]));
	
	newInput(41, nodeValue_Int("Side", self, 3));
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
	newInput(42, nodeValue_Vec3("Camera Rotation", self, [ 30, 45, 0 ]));
	
	newInput(43, nodeValue_Float("Camera Scale", self, 1))
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 0, 4, 0.01 ] });
	
	newInput(44, nodeValue_Bool("Render", self, true));
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	newInput(45, nodeValue_Bool("Tile", self, false));
		
	newInput(46, nodeValue_Vec3("Tiled Shift", self, [ 0, 0, 0 ]));
		
	newInput(47, nodeValue_Vec3("Tiled Rotation", self, [ 0, 0, 0 ]));
		
	newInput(48, nodeValue_Float("Tiled Scale", self, 0));
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	newInput(49, nodeValue_Bool("Env Interpolation", self, false));
	
	newInput(50, nodeValue_Bool("Texture Interpolation", self, false));
	
	newOutput(0, nodeValue_Output("Surface Out", self, VALUE_TYPE.surface, noone));
	
	newOutput(1, nodeValue_Output("Shape Data", self, VALUE_TYPE.sdf, noone));
	
	input_display_list = [ 0,
		["Primitive",  false],  1, 21, 22, 23, 24, 25, 26, 27, 28, 39, 40, 41, 
		["Modify",     false], 12, 11, 
		["Deform",      true], 15, 16, 17, 18, 19, 
		["Transform",  false],  2,  3,  4, 
		["Tile",       false, 45], 20, 29, /*46, 47, 48,*/
		["Material",   false],  9, 36, 50, 35, 37, 38, 
		
		["Camera",     false], 42, 43, 13, 14,  5,  6, 
		["Render",     false, 44], 31, 30, 34, 49, 10,  7,  8, 
		["Volumetric",  true, 32], 33, 
	];
	
	temp_surface = [ 0, 0 ];
	environ = new RM_Environment();
	object  = new RM_Shape();
	
	tool_pos = new NodeTool( "Transform", THEME.tools_3d_transform, "Node_3D_Object" );
	
	tools = [ tool_pos ];
	
	#region ---- overlay ----
		drag_axis  = noone;
		drag_sv    = 0;
		drag_delta = 0;
		drag_pre0  = 0;
		drag_pre1  = 0;
		drag_dist  = 0;
		drag_val   = 0;
		
		drag_mx = 0;
		drag_my = 0;
		drag_px = 0;
		drag_py = 0;
		drag_cx = 0;
		drag_cy = 0;
		drag_rot_axis = new BBMOD_Quaternion();
		
		drag_original = 0;
		
		axis_hover = noone;
	#endregion
	
	static drawGizmoPosition = function(index, _vpos, active, params, _mx, _my, _snx, _sny, _panel) { #region
		#region ---- main ----
			var _pos  = inputs[index].getValue(,,, true);
			    // _pos  = [ -_pos[0], _pos[2], -_pos[1] ];
			var _qinv = new BBMOD_Quaternion().FromAxisAngle(new BBMOD_Vec3(1, 0, 0), 90);
			
			var _camera = params.camera;
			var _qview  = new BBMOD_Quaternion().FromEuler(_camera.focus_angle_y, -_camera.focus_angle_x, 0);
			
			var _hover     = noone;
			var _hoverDist = 10;
			var th;
		
			var _posView = _camera.worldPointToViewPoint(_vpos);
		
			var cx = _posView.x;
			var cy = _posView.y;
			
			var ga   = [];
			var size = 64;
			var hs = size / 2;
			var sq = 8;
		#endregion
			
		#region display
			ga[0] = new BBMOD_Vec3(-size, 0, 0);
			ga[1] = new BBMOD_Vec3(0, 0,  size);
			ga[2] = new BBMOD_Vec3(0, -size, 0);
			
			ga[3] = [	new BBMOD_Vec3(-hs + sq,        0,  hs - sq),
						new BBMOD_Vec3(-hs - sq,        0,  hs - sq), 
						new BBMOD_Vec3(-hs - sq,        0,  hs + sq), 
						new BBMOD_Vec3(-hs + sq,        0,  hs + sq), ];
			ga[4] = [	new BBMOD_Vec3(       0, -hs + sq,  hs - sq),
						new BBMOD_Vec3(       0, -hs - sq,  hs - sq), 
						new BBMOD_Vec3(       0, -hs - sq,  hs + sq), 
						new BBMOD_Vec3(       0, -hs + sq,  hs + sq), ];
			ga[5] = [	new BBMOD_Vec3(-hs + sq, -hs - sq,        0),
						new BBMOD_Vec3(-hs - sq, -hs - sq,        0), 
						new BBMOD_Vec3(-hs - sq, -hs + sq,        0), 
						new BBMOD_Vec3(-hs + sq, -hs + sq,        0), ];
			
			ga[0] = new BBMOD_Vec3(-size, 0, 0);
			ga[1] = new BBMOD_Vec3(0, -size, 0);
			ga[2] = new BBMOD_Vec3(0, 0, -size);
			
			ga[3] = [	new BBMOD_Vec3(-hs + sq, -hs - sq,        0),
						new BBMOD_Vec3(-hs - sq, -hs - sq,        0), 
						new BBMOD_Vec3(-hs - sq, -hs + sq,        0), 
						new BBMOD_Vec3(-hs + sq, -hs + sq,        0), ];
			ga[4] = [	new BBMOD_Vec3(       0, -hs + sq, -hs - sq),
						new BBMOD_Vec3(       0, -hs - sq, -hs - sq), 
						new BBMOD_Vec3(       0, -hs - sq, -hs + sq), 
						new BBMOD_Vec3(       0, -hs + sq, -hs + sq), ];
			ga[5] = [	new BBMOD_Vec3(-hs + sq,        0, -hs - sq),
						new BBMOD_Vec3(-hs - sq,        0, -hs - sq), 
						new BBMOD_Vec3(-hs - sq,        0, -hs + sq), 
						new BBMOD_Vec3(-hs + sq,        0, -hs + sq), ];
				
			for( var i = 0; i < 3; i++ ) {
				ga[i] = _qview.Rotate(_qinv.Rotate(ga[i]));
				
				th = 2 + (axis_hover == i || drag_axis == i);
				if(drag_axis != noone && drag_axis != i)
					continue;
				
				draw_set_color(COLORS.axis[i]);
				if(point_distance(cx, cy, cx + ga[i].X, cy + ga[i].Y) < 5)
					draw_line_round(cx, cy, cx + ga[i].X, cy + ga[i].Y, th);
				else 
					draw_line_round_arrow(cx, cy, cx + ga[i].X, cy + ga[i].Y, th, 3);
				
				var _d = distance_to_line(_mx, _my, cx, cy, cx + ga[i].X, cy + ga[i].Y);
				if(_d < _hoverDist) {
					_hover = i;
					_hoverDist = _d;
				}
			}
			
			// for( var i = 3; i < 6; i++ ) {
			// 	for( var j = 0; j < 4; j++ )
			// 		ga[i][j] = _qview.Rotate(_qinv.Rotate(ga[i][j]));
				
			// 	th = 1;
				
			// 	var p0x = cx + ga[i][0].X, p0y = cy + ga[i][0].Y;
			// 	var p1x = cx + ga[i][1].X, p1y = cy + ga[i][1].Y;
			// 	var p2x = cx + ga[i][2].X, p2y = cy + ga[i][2].Y;
			// 	var p3x = cx + ga[i][3].X, p3y = cy + ga[i][3].Y;
				
			// 	var _pax = (p0x + p1x + p2x + p3x) / 4;
			// 	var _pay = (p0y + p1y + p2y + p3y) / 4;
				
			// 	if((abs(p0x - _pax) + abs(p1x - _pax) + abs(p2x - _pax) + abs(p3x - _pax)) / 4 < 1)
			// 		continue;
			// 	if((abs(p0y - _pay) + abs(p1y - _pay) + abs(p2y - _pay) + abs(p3y - _pay)) / 4 < 1)
			// 		continue;
				
			// 	draw_set_color(COLORS.axis[(i - 3 - 1 + 3) % 3]);
			// 	if(axis_hover == i || drag_axis == i) {
			// 		draw_primitive_begin(pr_trianglestrip);
			// 			draw_vertex(p0x, p0y);
			// 			draw_vertex(p1x, p1y);
			// 			draw_vertex(p3x, p3y);
			// 			draw_vertex(p2x, p2y);
			// 		draw_primitive_end();
					
			// 	} else if (drag_axis == noone) {
			// 		draw_line(p0x, p0y, p1x, p1y);
			// 		draw_line(p1x, p1y, p2x, p2y);
			// 		draw_line(p2x, p2y, p3x, p3y);
			// 		draw_line(p3x, p3y, p0x, p0y);
			// 	} else 
			// 		continue;
				
			// 	if(point_in_rectangle_points(_mx, _my, p0x, p0y, p1x, p1y, p3x, p3y, p2x, p2y))
			// 		_hover = i;
			// }
			
			axis_hover = _hover;
		#endregion display
		
		if(drag_axis != noone) { #region editing
			if(!MOUSE_WRAPPING) {
				drag_mx += _mx - drag_px;
				drag_my += _my - drag_py;
					
				var mAdj, nor, prj, app;
					
				var ray = _camera.viewPointToWorldRay(drag_mx, drag_my);
				var val = [ drag_val[0], drag_val[1], drag_val[2] ];
				
				switch(drag_axis) {
					case 0 : 
					case 3 : nor = new __vec3(0, 1, 0); prj = new __vec3(1, 0, 0); app =  0; break;
					case 1 : 
					case 4 : nor = new __vec3(0, 0, 1); prj = new __vec3(0, 1, 0); app = -2; break;
					case 2 : 
					case 5 : nor = new __vec3(1, 0, 0); prj = new __vec3(0, 0, 1); app =  1; break;
				}
				
				var pln = new __plane(drag_original, nor);
				mAdj = d3d_intersect_ray_plane(ray, pln);
				
				if(drag_pre0 != undefined) {
					var _diff = mAdj.subtract(drag_pre0);
					var _dist = _diff.dot(prj);
					
					val[abs(app)] -= _dist * (app >= 0? 1 : -1);
				}
				
				drag_pre0 = mAdj;
				
				if(inputs[index].setValue(value_snap(val, _snx)))
					UNDO_HOLDING = true;
				
				drag_val  = [ val[0], val[1], val[2] ];
			}
				
			setMouseWrap();
			drag_px = _mx;
			drag_py = _my;
		} #endregion
			
		if(_hover != noone && mouse_press(mb_left, active)) { #region
			drag_axis = _hover;
			drag_pre0 = undefined;
			drag_pre1 = undefined;
			drag_mx	= _mx;
			drag_my	= _my;
			drag_px = _mx;
			drag_py = _my;
			drag_cx = cx;
			drag_cy = cy;
			
			drag_val = _pos;
			drag_original = new __vec3(_pos);
		} #endregion
	} #endregion
	
	static drawOverlay3D = function(active, params, _mx, _my, _snx, _sny, _panel) {
		var _pos    = getSingleValue(2);
		var _camera = params.camera;
		var _vpos   = new __vec3( -_pos[0], _pos[2], -_pos[1] );
		
		if(isUsingTool("Transform"))	drawGizmoPosition(2, _vpos, active, params, _mx, _my, _snx, _sny, _panel);
		
		if(drag_axis != noone && mouse_release(mb_left)) {
			drag_axis = noone;
			UNDO_HOLDING = false;
		}
		
	}
	
	static step = function() {
		var _shp = getSingleValue( 1);
		var _ort = getSingleValue(13);
		var _ren = getSingleValue(44);
		
		inputs[21].setVisible(false);
		inputs[22].setVisible(false);
		inputs[23].setVisible(false);
		inputs[24].setVisible(false);
		inputs[25].setVisible(false);
		inputs[26].setVisible(false);
		inputs[27].setVisible(false);
		inputs[28].setVisible(false);
		inputs[39].setVisible(false);
		inputs[40].setVisible(false);
		inputs[41].setVisible(false);
		
		outputs[0].setVisible(_ren, _ren);
		
		var _shape = shape_types[_shp];
		switch(_shape) { // Size
			case "Box" : 
			case "Box Frame" : 
			case "Ellipse" : 
				inputs[21].setVisible(true);
				break;
		}
		
		switch(_shape) { // Radius
			case "Sphere" : 
			case "Torus" : 
			case "Cut Sphere" : 
			case "Cut Hollow Sphere" : 
			case "Capped Torus" : 
			case "Cylinder" : 
			case "Capsule" : 
			case "3D Arc" : 
			case "Pie" : 
				inputs[22].setVisible(true);
				break;
		}
		
		switch(_shape) { // Thickness
			case "Box Frame" : 
			case "Box Round" : 
			case "Torus" : 
			case "Cut Hollow Sphere" : 
			case "Capped Torus" : 
			case "Terrain" : 
			case "Extrude" : 
			case "Prism" : 
			case "Pie" : 
				inputs[23].setVisible(true);
				break;
		}
		
		switch(_shape) { // Crop
			case "Cut Sphere" : 
			case "Cut Hollow Sphere" : 
				inputs[24].setVisible(true);
				break;
		}
		
		switch(_shape) { // Angle
			case "Capped Torus" : 
			case "Cone" : 
			case "3D Arc" : 
			case "Pie" : 
				inputs[25].setVisible(true);
				break;
		}
		
		switch(_shape) { // Height
			case "Cylinder" : 
			case "Capsule" : 
			case "Cone" : 
			case "Capped Cone" : 
			case "Round Cone" : 
				inputs[26].setVisible(true);
				break;
		}
		
		switch(_shape) { // Radius Range
			case "Capped Cone" : 
			case "Round Cone" : 
				inputs[27].setVisible(true);
				break;
		}
		
		switch(_shape) { // Uniform Size
			case "Octahedron" : 
			case "Pyramid" : 
			case "Terrain" : 
			case "Extrude" : 
				inputs[28].setVisible(true);
				break;
		}
		
		switch(_shape) { // Corner
			case "Box Round" : 
				inputs[39].setVisible(true);
				break;
		}
		
		switch(_shape) { // Size 2D
			case "Box Round" : 
				inputs[40].setVisible(true);
				break;
		}
		
		switch(_shape) { // Sides
			case "Prism" : 
				inputs[41].setVisible(true);
				break;
		}
		
		inputs[ 5].setVisible(_ort == 0);
		inputs[14].setVisible(_ort == 1);
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index = 0) {
		var _dim  = _data[0];
		var _shp  = _data[1];
		
		var _pos  = _data[2];
		var _rot  = _data[3];
		var _sca  = _data[4];
		
		var _fov  = _data[5];
		var _rng  = _data[6];
		
		var _dpi  = _data[7];
		var _lPos = _data[8];
		var _amb  = _data[9];
		var _ambI = _data[10];
		var _elon = _data[11];
		var _rond = _data[12];
		
		var _ort  = _data[13];
		var _ortS = _data[14];
		
		var _wavA = _data[15];
		var _wavI = _data[16];
		var _wavS = _data[17];
		var _twsX = _data[18];
		var _twsA = _data[19];
		
		var _size = _data[21];
		var _rad  = _data[22];
		var _thk  = _data[23];
		var _crop = _data[24];
		var _angl = _data[25];
		var _heig = _data[26];
		var _radR = _data[27];
		var _sizz = _data[28];
		var _bgc  = _data[30];
		var _bgd  = _data[31];
		
		var _vol  = _data[32];
		var _vden = _data[33];
		var bgEnv = _data[34];
		var _refl = _data[35];
		
		var _text = _data[36];
		var _triS = _data[37];
		var _texs = _data[38];
		var _corn = _data[39];
		var _sz2d = _data[40];
		var _side = _data[41];
		
		var _crt  = _data[42];
		var _csa  = _data[43];
		var _ren  = _data[44];
		
		var _tileActive  = _data[45];
		var _tileAmount  = _data[29];
		var _tileSpace   = _data[20];
		var _tilePos     = _data[46];
		var _tileRot     = _data[47];
		var _tileSca     = _data[48];
		
		var _eint        = _data[49];
		var _textFilter  = _data[50];
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1]);
		
		for (var i = 0, n = array_length(temp_surface); i < n; i++)
			temp_surface[i] = surface_verify(temp_surface[i], 8192, 8192);
		
		var tx = 1024;
		surface_set_shader(temp_surface[0]);
			gpu_set_tex_filter(_eint);
			draw_surface_stretched_safe(bgEnv, tx * 0, tx * 0, tx, tx);
			gpu_set_tex_filter(false);
		surface_reset_shader();
		
		var _shape = shape_types[_shp];
		var _shpI  = 0;
		
		switch(_shape) {
			case "Plane" :				_shpI = 100;							break;
			case "Box" :				_shpI = 101;							break;
			case "Box Frame" :      	_shpI = 102;							break;
			case "Box Round" :      	_shpI = 103;							break;
								
			case "Sphere" :         	_shpI = 200;							break;
			case "Ellipse" :        	_shpI = 201;							break;
			case "Cut Sphere" :     	_shpI = 202;							break;
			case "Cut Hollow Sphere" :	_shpI = 203; _crop = _crop / pi * 2.15;	break;
			case "Torus" :          	_shpI = 204;							break;
			case "Capped Torus" :   	_shpI = 205;							break;
			
			case "Cylinder" :       	_shpI = 300;							break;
			case "Capsule" :        	_shpI = 301;							break;
			case "Cone" :           	_shpI = 302;							break;
			case "Capped Cone" :    	_shpI = 303;							break;
			case "Round Cone" :     	_shpI = 304;							break;
			case "3D Arc" :         	_shpI = 305;							break;
			case "Prism" :         		_shpI = 306;							break;
			case "Pie" :         		_shpI = 307;							break;
			
			case "Octahedron" :     	_shpI = 400;							break;
			case "Pyramid" :        	_shpI = 401;							break;
		}
		
		object.operations    = -1;
		object.shapeAmount   =  1;
		
		object.shape         = _shpI;
		object.size          = _size;
		object.radius        = _rad ;
		object.thickness     = _thk ;
		object.crop          = _crop;
		object.angle         = degtorad(_angl);
		object.height        = _heig;
		object.radRange      = _radR;
		object.sizeUni       = _sizz;
		object.elongate      = _elon;
		object.rounded       = _rond;
		object.corner        = _corn;
		object.size2D        = _sz2d;
		object.sides         = _side;
		
		object.waveAmp       = _wavA;
		object.waveInt       = _wavI;
		object.waveShift     = _wavS;
		
		object.twistAxis     = _twsX;
		object.twistAmount   = _twsA;
		
		object.position      = _pos;
		object.rotation      = _rot;
		object.objectScale   = _sca;
		
		object.tileActive    = _tileActive;
		object.tileAmount    = _tileAmount;
		object.tileSpace     = _tileSpace;
		object.tilePos       = _tilePos;
		object.tileRot       = _tileRot;
		object.tileSca       = _tileSca;
		
		object.diffuseColor  = colorToArray(_amb, true);
		object.reflective    = _refl;
		    
		object.volumetric    = _vol;
		object.volumeDensity = _vden;
		    
		object.texture       = [ _text ];
		object.textureFilter = [ _textFilter ];
		object.useTexture    = is_surface(_text);
		object.textureScale  = _texs;
		object.triplanar     = _triS;
			
		object.setTexture(temp_surface[1]);
		
		environ.surface   = temp_surface[0];
		environ.bgEnv     = bgEnv;
		environ.envFilter = _eint;
		
		environ.projection = _ort;
		environ.fov        = _fov;
		environ.orthoScale = _ortS;
		environ.viewRange  = _rng;
		environ.depthInt   = _dpi;
		
		environ.bgColor    = _bgc;
		environ.bgDraw     = _bgd;
		environ.ambInten   = _ambI;
		environ.light      = _lPos;
		
		if(_ren) {
			gpu_set_texfilter(true);
			surface_set_shader(_outSurf, sh_rm_primitive);
				
				shader_set_f("camRotation", _crt);
				shader_set_f("camScale",    _csa);
				shader_set_f("camRatio",    _dim[0] / _dim[1]);
				
				environ.apply();
				object.apply();
				
				draw_sprite_stretched(s_fx_pixel, 0, 0, 0, _dim[0], _dim[1]);
			surface_reset_shader();
			gpu_set_texfilter(false);
		}
		
		return [ _outSurf, object ]; 
	}
	
} 
