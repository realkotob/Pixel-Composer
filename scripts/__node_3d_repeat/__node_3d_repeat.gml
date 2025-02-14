function __Node_3D_Repeat(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "3D Repeat";
	
	newInput(0, nodeValue_Dimension(self));
	
	newInput(1, nodeValue_Vec3("Object position", self, [ 0, 0, 0 ]));
	
	newInput(2, nodeValue_Vec3("Object rotation", self, [ 0, 0, 0 ]));
	
	newInput(3, nodeValue_Vec3("Object scale", self, [ 1, 1, 1 ]));
	
	newInput(4, nodeValue_Vec3("Render position", self, [ 0.5, 0.5 ]))
		.setUnitRef( function() { return getInputData(0); }, VALUE_UNIT.reference);
	
	newInput(5, nodeValue_Vec2("Render scale", self, [ 1, 1 ]));
		
	newInput(6, nodeValue_Rotation("Light direction", self, 0));
		
	newInput(7, nodeValue_Float("Light height", self, 0.5))
		.setDisplay(VALUE_DISPLAY.slider, { range: [-1, 1, 0.01] });
		
	newInput(8, nodeValue_Float("Light intensity", self, 1))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(9, nodeValue_Color("Light color", self, cola(c_white)));
	
	newInput(10, nodeValue_Color("Ambient color", self, cola(c_grey)));
		
	newInput(11, nodeValue("3D object", self, CONNECT_TYPE.input, VALUE_TYPE.d3object, noone))
		.setVisible(true, true);
	
	newInput(12, nodeValue_Int("Repeat", self, 1, "Amount of copies to be generated."));
	
	newInput(13, nodeValue_Vec3("Repeat position", self, [ 1, 0, 0 ]));
	
	newInput(14, nodeValue_Vec3("Repeat rotation", self, [ 0, 0, 0 ]));
	
	newInput(15, nodeValue_Vec3("Repeat scale", self, [ 1, 1, 1 ]));
	
	newInput(16, nodeValue_Enum_Button("Repeat pattern", self,  0, [ "Linear", "Circular" ]))
		.rejectArray();
	
	newInput(17, nodeValue_Enum_Button("Axis", self,  0, [ "x", "y", "z" ]));
	
	newInput(18, nodeValue_Float("Radius", self, 1));
	
	newInput(19, nodeValue_Rotation_Range("Rotation", self, [ 0, 360 ]));
	
	newInput(20, nodeValue_Enum_Button("Projection", self,  0, [ "Orthographic", "Perspective" ]))
		.rejectArray();
		
	newInput(21, nodeValue_Float("Field of view", self, 60))
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 1, 90, 0.1 ] });
	
	newInput(22, nodeValue_Bool("Scale view with dimension", self, true))
	
	input_display_list = [ 11,
		["Output",			false], 0, 22, 
		["Object transform", true], 1, 2, 3,
		["Camera",			 true], 20, 21, 4, 5,
		["Light",			 true], 6, 7, 8, 9, 10,
		["Repeat",			false], 12, 16, 13, 14, 15, 17, 18, 19
	];
	
	
	newOutput(0, nodeValue_Output("Surface Out", self, VALUE_TYPE.surface, noone));
	
	newOutput(1, nodeValue_Output("3D objects", self, VALUE_TYPE.d3object, function() { return submit_vertex(); }));
	
	newOutput(2, nodeValue_Output("Normal pass", self, VALUE_TYPE.surface, noone));
	
	output_display_list = [
		0, 2, 1
	]
	
	_3d_node_init(1, /*Transform*/ 4, 5, 1, 2, 3);
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		_3d_gizmo(active, _x, _y, _s, _mx, _my, _snx, _sny);
	}
	
	static submit_vertex = function() {
		var _lpos = getInputData(1);
		var _lrot = getInputData(2);
		var _lsca = getInputData(3);
		
		var sv = getInputData(11);
		if(sv == noone) return;
		
		var _samo = getInputData(12);
		var _patt = getInputData(16);
		
		var _srot = getInputData(14);
		var _ssca = getInputData(15);
		
		var _spos = getInputData(13);
		
		var _raxs = getInputData(17);
		var _rrad = getInputData(18);
		var _rrot = getInputData(19);
		
		_3d_local_transform(_lpos, _lrot, _lsca);
			for( var i = 0; i < _samo; i++ ) {
				if(_patt == 0) {
					matrix_stack_push(matrix_build(	_spos[0] * i, _spos[1] * i, _spos[2] * i, 0, 0, 0, 1, 1, 1 ));
					matrix_stack_push(matrix_build( 0, 0, 0, _srot[0] * i, _srot[1] * i, _srot[2] * i, 1, 1, 1 ));
					matrix_stack_push(matrix_build(	0, 0, 0, 0, 0, 0, power(_ssca[0], i), power(_ssca[1], i), power(_ssca[2], i)));
				} else if(_patt == 1) {
					var angle = _rrot[0] + i * (_rrot[1] - _rrot[0]) / _samo;
					var ldx = lengthdir_x(_rrad, angle);
					var ldy = lengthdir_y(_rrad, angle);
					
					switch(_raxs) {
						case 0 : matrix_stack_push(matrix_build( 0, ldx, ldy, 0, 0, 0, 1, 1, 1 )); break;
						case 1 : matrix_stack_push(matrix_build( ldy, 0, ldx, 0, 0, 0, 1, 1, 1 )); break;
						case 2 : matrix_stack_push(matrix_build( ldx, ldy, 0, 0, 0, 0, 1, 1, 1 )); break;
					}
					
					matrix_stack_push(matrix_build(	0, 0, 0, _srot[0] * i, _srot[1] * i, _srot[2] * i, 1, 1, 1));
					matrix_stack_push(matrix_build(	0, 0, 0, 0, 0, 0, power(_ssca[0], i), power(_ssca[1], i), power(_ssca[2], i)));
				}
				
				matrix_set(matrix_world, matrix_stack_top());
				
				if(is_array(sv)) {
					var index = safe_mod(i, array_length(sv));
					var _sv = sv[index];
					_sv(index);
				} else
					sv();
				
				matrix_stack_pop();
				matrix_stack_pop();
				matrix_stack_pop();
			}
		_3d_clear_local_transform();
	}
	
	static step = function() {
		var _proj = getInputData(20);
		var _patt = getInputData(16);
		
		inputs[13].setVisible(_patt == 0);
		
		inputs[17].setVisible(_patt == 1);
		inputs[18].setVisible(_patt == 1);
		inputs[19].setVisible(_patt == 1);
		inputs[21].setVisible(_proj);
	}
	
	static update = function(frame = CURRENT_FRAME) {
		var _dim  = getInputData(0);
		var _lpos = getInputData(1);
		var _lrot = getInputData(2);
		var _lsca = getInputData(3);
		
		var _pos  = getInputData(4);
		var _sca  = getInputData(5);
		
		var _ldir = getInputData(6);
		var _lhgt = getInputData(7);
		var _lint = getInputData(8);
		var _lclr = getInputData(9);
		var _aclr = getInputData(10);
		
		var _proj = getInputData(20);
		var _fov  = getInputData(21);
		var _dimS = getInputData(22);
		
		var _patt = getInputData(16);
		
		for( var i = 0, n = array_length(output_display_list) - 1; i < n; i++ ) {
			var ind = output_display_list[i];
			var _outSurf = outputs[ind].getValue();
			
			var pass = "diff";
			switch(ind) {
				case 0 : pass = "diff" break;
				case 2 : pass = "norm" break;
			}
		
			var _transform = new __3d_transform(_pos,, _sca, _lpos, _lrot, _lsca, false, _dimS );
			var _light     = new __3d_light(_ldir, _lhgt, _lint, _lclr, _aclr);
			var _cam	   = new __3d_camera(_proj, _fov);
			
			_outSurf = _3d_pre_setup(_outSurf, _dim, _transform, _light, _cam, pass);
				submit_vertex();
			_3d_post_setup();
			
			outputs[ind].setValue(_outSurf);
		}
	}
}