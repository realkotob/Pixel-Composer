function Node_Armature_Pose(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Armature Pose";
	setDimension(96, 72);
	
	newInput(0, nodeValue_Armature("Armature", self, noone))
		.setVisible(true, true);
	
	input_display_list = [ 0,
		["Bones", false]
	]
	
	newOutput(0, nodeValue_Output("Armature", self, VALUE_TYPE.armature, noone));
	
	boneMap = ds_map_create();
	
	attributes.display_name = true;
	attributes.display_bone = 0;
	
	array_push(attributeEditors, "Display");
	
	array_push(attributeEditors, ["Display name", function() { return attributes.display_name; }, 
		new checkBox(function() { attributes.display_name = !attributes.display_name; })]);
		
	array_push(attributeEditors, ["Display bone", function() { return attributes.display_bone; }, 
		new scrollBox(["Octahedral", "Stick"], function(ind) { attributes.display_bone = ind; })]);
	
	static createNewInput = function(bone = noone) {
		var index = array_length(inputs);
		
		newInput(index, nodeValue(bone != noone? bone.name : "bone", self, CONNECT_TYPE.input, VALUE_TYPE.float, [ 0, 0, 0, 1 ] ))
			.setDisplay(VALUE_DISPLAY.transform);
		inputs[index].display_data.bone_id = bone != noone? bone.ID : noone;
		
		if(bone != noone) boneMap[? bone.ID] = inputs[index];
		
		array_push(input_display_list, index);
		
		return inputs[index];
	} setDynamicInput(1, false);
	
	static setBone = function() {
		//print("Setting dem bones...");
		var _b = getInputData(0);
		if(_b == noone) return;
		
		var _bones = [];
		var _bst = ds_stack_create();
		ds_stack_push(_bst, _b);
		
		while(!ds_stack_empty(_bst)) {
			var __b = ds_stack_pop(_bst);
			
			for( var i = 0, n = array_length(__b.childs); i < n; i++ ) {
				array_push(_bones, __b.childs[i]);
				ds_stack_push(_bst, __b.childs[i]);
			}
		}
		
		ds_stack_destroy(_bst);
		//print($"Bone counts: {array_length(_bones)}");
		
		var _inputs = [ inputs[0] ];
		
		var _input_display_list = [
			input_display_list[0],
			input_display_list[1]
		];
		
		for( var i = 0, n = array_length(_bones); i < n; i++ ) {
			var bone = _bones[i];
			var _idx = array_length(_inputs);
			array_push(_input_display_list, _idx);
			//print($"  > Adding bone ID: {bone.ID}");
			
			if(ds_map_exists(boneMap, bone.ID)) {
				var _inp = boneMap[? bone.ID];
				
				_inp.index = _idx;
				array_push(_inputs, _inp);
			} else {
				var _inp = createNewInput(bone);
				array_push(_inputs, _inp);
			}
		}
		
		inputs = _inputs;
		input_display_list = _input_display_list;
		
		//print(_input_display_list);
	}
	
	tools = [];
	
	anchor_selecting = noone;
	posing_bone      = noone;
	posing_input     = 0;
	posing_type      = 0;
	posing_sx   = 0;
	posing_sy   = 0;
	posing_sz   = 0;
	posing_mx   = 0;
	posing_my   = 0;
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _b = outputs[0].getValue();
		if(_b == noone) return;
		
		anchor_selecting = _b.draw(attributes, active * 0b111, _x, _y, _s, _mx, _my, anchor_selecting, posing_bone);
		
		var mx = (_mx - _x) / _s;
		var my = (_my - _y) / _s;
		
		var smx = value_snap(mx, _snx);
		var smy = value_snap(my, _sny);
		
		if(posing_bone) {
			if(posing_type == 0 && posing_bone.parent) { //move
				var ang = posing_bone.parent.pose_angle;
				var pp  = point_rotate(smx - posing_mx, smy - posing_my, 0, 0, -ang);
				var bx  = posing_sx + pp[0];
				var by  = posing_sy + pp[1];
				
				var val = array_clone(posing_input.getValue());
				val[TRANSFORM.pos_x] = bx;
				val[TRANSFORM.pos_y] = by;
				
				if(posing_input.setValue(val))
					UNDO_HOLDING = true;
				
			} else if(posing_type == 1) { //scale
				var ss  = point_distance(posing_mx, posing_my, smx, smy) / posing_sx;
				var ori = posing_bone.getHead();
				var ang = point_direction(ori.x, ori.y, smx, smy);
				var rot = ang - posing_sy - posing_bone.parent.pose_angle;
				
				var val = array_clone(posing_input.getValue());
				val[TRANSFORM.sca_x] = ss;
				val[TRANSFORM.rot]   = rot;
				
				if(posing_input.setValue(val))
					UNDO_HOLDING = true;
				
			} else if(posing_type == 2) { //rotate
				var ori = posing_bone.getHead();
				var ang = point_direction(ori.x, ori.y, mx, my);
				var rot = angle_difference(ang, posing_sy);
				posing_sy = ang;
				posing_sx += rot;
				
				var val = array_clone(posing_input.getValue());
				val[TRANSFORM.rot] = posing_sx;
				
				if(posing_input.setValue(val))
					UNDO_HOLDING = true;
			}
			
			if(mouse_release(mb_left)) {
				posing_bone = noone;
				posing_type = noone;
				UNDO_HOLDING = false;
			}
		}
		
		if(anchor_selecting != noone && mouse_press(mb_left, active)) {
			posing_bone = anchor_selecting[0];
			if(!ds_map_exists(boneMap, posing_bone.ID)) setBone();
			posing_input = boneMap[? posing_bone.ID];
			
			if(anchor_selecting[1] == 0 || anchor_selecting[0].IKlength) { // move
				
				posing_type = 0;
				
				var val = posing_input.getValue();
				posing_sx = val[TRANSFORM.pos_x];
				posing_sy = val[TRANSFORM.pos_y];
				
				var _p = anchor_selecting[2];
				posing_mx = _p.x;
				posing_my = _p.y;
				
			} else if(anchor_selecting[1] == 1) { // scale
				
				posing_type = 1;
				
				var ori = posing_bone.getHead();
				var val = posing_input.getValue();
				posing_sx = posing_bone.length / posing_bone.pose_scale * posing_bone.parent.pose_scale;
				posing_sy = posing_bone.angle - posing_bone.pose_local_angle;
				posing_sz = point_direction(ori.x, ori.y, smx, smy);
				
				var pnt = posing_bone.getHead();
				posing_mx = pnt.x;
				posing_my = pnt.y;
				
			} else if(anchor_selecting[1] == 2) { // rotate
				
				posing_type = 2;
				
				var ori = posing_bone.getHead();
				var val = posing_input.getValue();
				posing_sx = val[TRANSFORM.rot];
				posing_sy = point_direction(ori.x, ori.y, mx, my);
				
				posing_mx = mx;
				posing_my = my;
			}
		}
	}
	
	bone_prev = noone;
	static step = function() {
		var _b = getInputData(0);
		if(_b == noone) return;
		if(bone_prev != _b) {
			setBone();
			bone_prev = _b;
			return;
		}
		
		var _boneCount = array_length(inputs) - input_fix_len;
		if(_boneCount != _b.childCount()) setBone();
	}
	
	static update = function(frame = CURRENT_FRAME) {
		var _b = getInputData(0);
		if(_b == noone) return;
		
		var _bone_pose = _b.clone();
		_bone_pose.connect();
		_bone_pose.resetPose();
		
		var _bst = ds_stack_create();
		ds_stack_push(_bst, _bone_pose);
		
		while(!ds_stack_empty(_bst)) {
			var bone = ds_stack_pop(_bst);
			var _id  = bone.ID;
			
			if(ds_map_exists(boneMap, _id)) {
				var _inp  = boneMap[? _id];
				_inp.updateName(bone.name);
				
				var _trn  = _inp.getValue();
				
				bone.pose_posit = [ _trn[TRANSFORM.pos_x], _trn[TRANSFORM.pos_y] ];
				bone.pose_angle = _trn[TRANSFORM.rot];
				bone.pose_scale = _trn[TRANSFORM.sca_x];
			}
			
			for( var i = 0, n = array_length(bone.childs); i < n; i++ )
				ds_stack_push(_bst, bone.childs[i]);
		}
		
		ds_stack_destroy(_bst);
		
		_bone_pose.setPose();
		
		outputs[0].setValue(_bone_pose);
	}
	
	static getPreviewBoundingBox = function() {
		var minx =  9999999;
		var miny =  9999999;
		var maxx = -9999999;
		var maxy = -9999999;
		
		var _b = outputs[0].getValue();
		if(_b == noone) return BBOX().fromPoints(0, 0, 1, 1);
		
		var _bst = ds_stack_create();
		ds_stack_push(_bst, _b);
		
		while(!ds_stack_empty(_bst)) {
			var __b = ds_stack_pop(_bst);
			
			for( var i = 0, n = array_length(__b.childs); i < n; i++ ) {
				var p0 = __b.childs[i].getHead();
				var p1 = __b.childs[i].getTail();
				
				minx = min(minx, p0.x); miny = min(miny, p0.y);
				maxx = max(maxx, p0.x); maxy = max(maxy, p0.y);
				
				minx = min(minx, p1.x); miny = min(miny, p1.y);
				maxx = max(maxx, p1.x); maxy = max(maxy, p1.y);
				
				ds_stack_push(_bst, __b.childs[i]);
			}
		}
		
		ds_stack_destroy(_bst);
		
		if(minx == 9999999) return noone;
		return BBOX().fromPoints(minx, miny, maxx, maxy);
	}
	
	static doApplyDeserialize = function() {
		for( var i = input_fix_len; i < array_length(inputs); i += data_length ) {
			var inp = inputs[i];
			var idx = struct_try_get(inp.display_data, "bone_id");
			
			boneMap[? idx] = inp;
		}
		
		setBone();
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_armature_pose, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}

