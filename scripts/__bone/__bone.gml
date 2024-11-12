function __Bone(_parent = noone, distance = 0, direction = 0, angle = 0, length = 0, node = noone) constructor {
	ID   = UUID_generate();
	name = "New bone";
	
	self.distance	 = distance;
	self.direction	 = direction;
	self.angle		 = angle;
	self.length		 = length;
	self.node		 = node;
	
	init_length      = length;
	init_angle       = angle;
	init_direction   = 0;
	init_distance    = 0;
	
	pose_angle       = 0;
	pose_scale       = 1;
	pose_posit       = [ 0, 0 ];
	
	pose_local_angle = 0;
	pose_local_scale = 1;
	pose_local_posit = [ 0, 0 ];
	
	angular_constrain = -1;
	
	bone_head_init  = new __vec2();
	bone_head_pose  = new __vec2();
	bone_tail_init  = new __vec2();
	bone_tail_pose  = new __vec2();
	
	apply_scale      = true;
	apply_rotation   = true;
	
	childs  		 = [];
	is_main 		 = false;
	parent_anchor	 = true;
	
	tb_name 		 = new textBox(TEXTBOX_INPUT.text, function(_name) /*=>*/ { name = _name; if(node) node.triggerRender(); });
	tb_name.font	 = f_p2;
	tb_name.hide	 = true;
	
	updated 		 = false;
	
	IKlength		 = 0;
	IKTargetID		 = "";
	IKTarget		 = noone;
	
	freeze_data      = {};
	
	parent = _parent;
	if(parent != noone) {
		distance  = parent.length;
		direction = parent.angle;
	}
	
	static addChild = function(bone) {
		array_push(childs, bone);
		bone.parent = self;
		return self;
	}
	
	static childCount = function() {
		var amo = array_length(childs);
		for( var i = 0, n = array_length(childs); i < n; i++ )
			amo += childs[i].childCount();
		return amo;
	}
	
	static freeze = function() {
		freeze_data = { angle, length, distance, direction };
		
		for( var i = 0, n = array_length(childs); i < n; i++ )
			childs[i].freeze();
	}
	
	static findBone = function(_id) {
		if(ID == _id) 
			return self;
		
		for( var i = 0, n = array_length(childs); i < n; i++ ) {
			var b = childs[i].findBone(_id);
			if(b != noone)
				return b;
		}
		
		return noone;
	}
	
	static findBoneByName = function(_name) {
		//print($"Print {string_length(string_trim(name))} : {string_length(string_trim(_name))}");
		if(string_trim(name) == string_trim(_name)) 
			return self;
		
		for( var i = 0, n = array_length(childs); i < n; i++ ) {
			var b = childs[i].findBoneByName(_name);
			if(b != noone)
				return b;
		}
		
		return noone;
	}
	
	static getHead = function(pose = true) { return pose? bone_head_pose.clone() : bone_head_init.clone(); }
	static getTail = function(pose = true) { return pose? bone_tail_pose.clone() : bone_tail_init.clone(); }
	
	static getPoint = function(progress, pose = true) {
		var _len = pose? length : init_length;
		var _ang = pose? angle  : init_angle;
		
		var _dir = pose? direction : init_direction;
		var _dis = pose? distance  : init_distance;
		
		var len = _len * progress;
		
		var _dx = lengthdir_x(_dis, _dir), _dy = lengthdir_y(_dis, _dir);
		var _lx = lengthdir_x( len, _ang), _ly = lengthdir_y( len, _ang);
		
		if(parent == noone)
			return new __vec2(_dx, _dy)
						.addElement(_lx, _ly);
		
		if(parent_anchor)
			return parent.getTail(pose)
						.addElement(_lx, _ly);
		
		return parent.getHead(pose)
				  .addElement(_dx, _dy)
				  .addElement(_lx, _ly);
	}
	
	static draw = function(attributes, edit = false, _x = 0, _y = 0, _s = 1, _mx = 0, _my = 0, _hover = noone, _select = noone, _blend = c_white, _alpha = 1) {
		var hover = _drawBone(attributes, edit, _x, _y, _s, _mx, _my, _hover, _select, _blend, _alpha);
		drawControl(attributes);
		return hover;
	}
	
	control_x0 = 0; control_y0 = 0; control_i0 = 0;
	control_x1 = 0; control_y1 = 0; control_i1 = 0;
	
	static _drawBone = function(attributes, edit = false, _x = 0, _y = 0, _s = 1, _mx = 0, _my = 0, _hover = noone, _select = noone, _blend = c_white, _alpha = 1) {
		var hover = noone;
		
		control_x0 = _x + bone_head_pose.x * _s;
		control_y0 = _y + bone_head_pose.y * _s;
		control_x1 = _x + bone_tail_pose.x * _s;
		control_y1 = _y + bone_tail_pose.y * _s;
		
		if(parent != noone) {
			var h = __drawBoneUI(attributes, edit, _x, _y, _s, _mx, _my, _hover, _select, _blend, _alpha);
			if(h != noone) hover = h;
		}
		
		for( var i = 0, n = array_length(childs); i < n; i++ ) {
			var h = childs[i]._drawBone(attributes, edit, _x, _y, _s, _mx, _my, _hover, _select, _blend, _alpha);
			if(hover == noone && h != noone)
				hover = h;
		}
		
		return hover;
	}
	
	static __drawBoneUI = function(attributes, edit = false, _x = 0, _y = 0, _s = 1, _mx = 0, _my = 0, _hover = noone, _select = noone, _blend = c_white, _alpha = 1) {
		var hover = noone;
		
		var p0x = _x + bone_head_pose.x * _s;
		var p0y = _y + bone_head_pose.y * _s;
		var p1x = _x + bone_tail_pose.x * _s;
		var p1y = _y + bone_tail_pose.y * _s;
		
		if(_select && _select.ID == self.ID) {
			draw_set_color(COLORS._main_value_positive);
			draw_set_alpha(0.75 * _alpha);
			
		} else if(_hover != noone && _hover[0].ID == self.ID && _hover[1] == 2) {
			draw_set_color(c_white);
			draw_set_alpha(1 * _alpha);
			
		} else {
			draw_set_color(COLORS._main_accent);
			draw_set_alpha(0.75 * _alpha);
		}
		
		if(IKlength == 0) {
			if(angular_constrain != -1) {
				var _a0 = init_angle - angular_constrain;
				var _a1 = init_angle + angular_constrain;
				var ox, oy, nx, ny;
				
				for( var i = 0; i <= 32; i++ ) {
					var _t = lerp(_a0, _a1, i / 32);
					
					nx = p0x + lengthdir_x(32 * _s, _t);
					ny = p0y + lengthdir_y(32 * _s, _t);
					
					if(i == 0)  draw_line(p0x, p0y, nx, ny);
					if(i == 32) draw_line(p0x, p0y, nx, ny);
					if(i)       draw_line(ox, oy, nx, ny);
					
					ox = nx;
					oy = ny;
				}
			}
			
			if(pose_angle != 0) {
				var nx = p0x + lengthdir_x(16, angle + pose_angle);
				var ny = p0y + lengthdir_y(16, angle + pose_angle);
				
				draw_line_width(p0x, p0y, nx, ny, 2);
			}
			
			if(!parent_anchor && parent.parent != noone) {
				var _p  = parent.getHead();
				var _px = _x + _p.x * _s;
				var _py = _y + _p.y * _s;
				draw_line_dashed(_px, _py, p0x, p0y, 2, 8);
			}
			
			if(attributes.display_bone == 0) {
				var _ppx = lerp(p0x, p1x, 0.2);
				var _ppy = lerp(p0y, p1y, 0.2);
				var _prr = point_direction(p0x, p0y, p1x, p1y) + 90;
				var _prx = lengthdir_x(6 * pose_scale, _prr);
				var _pry = lengthdir_y(6 * pose_scale, _prr);
				
				draw_primitive_begin(pr_trianglelist);
					draw_vertex(p0x, p0y);
					draw_vertex(_ppx, _ppy);
					draw_vertex(_ppx + _prx, _ppy + _pry);
					
					draw_vertex(p0x, p0y);
					draw_vertex(_ppx, _ppy);
					draw_vertex(_ppx - _prx, _ppy - _pry);
					
					draw_vertex(p1x, p1y);
					draw_vertex(_ppx, _ppy);
					draw_vertex(_ppx + _prx, _ppy + _pry);
					
					draw_vertex(p1x, p1y);
					draw_vertex(_ppx, _ppy);
					draw_vertex(_ppx - _prx, _ppy - _pry);
				draw_primitive_end();
				
				if((edit & 0b100) && distance_to_line(_mx, _my, p0x, p0y, p1x, p1y) <= 12) //drag bone
					hover = [ self, 2, bone_head_pose ];
					
			} else if(attributes.display_bone == 1) {
				draw_line_width(p0x, p0y, p1x, p1y, 3);
				
				if((edit & 0b100) && distance_to_line(_mx, _my, p0x, p0y, p1x, p1y) <= 6) //drag bone
					hover = [ self, 2, bone_head_pose ];
			} 
			
		} else {
			draw_set_color(c_white);
			if(!parent_anchor && parent.parent != noone) {
				var _p  = parent.getTail();
				var _px = _x + _p.x * _s;
				var _py = _y + _p.y * _s;
				draw_line_dashed(_px, _py, p0x, p0y, 1);
			}
			
			draw_sprite_ui(THEME.preview_bone_IK, 0, p0x, p0y,,,, COLORS._main_accent, draw_get_alpha());
			
			if((edit & 0b100) && point_in_circle(_mx, _my, p0x, p0y, 24))
				hover = [ self, 2, bone_head_pose ];
		}
		draw_set_alpha(1);
		
		if(attributes.display_name && IKlength == 0) {
			if(abs(p0y - p1y) < abs(p0x - p1x)) {
				draw_set_text(f_p3, fa_center, fa_bottom, COLORS._main_accent);
				draw_text_add((p0x + p1x) / 2, (p0y + p1y) / 2 - 4, name);
				
			} else {
				draw_set_text(f_p3, fa_left, fa_center, COLORS._main_accent);
				draw_text_add((p0x + p1x) / 2 + 4, (p0y + p1y) / 2, name);
			}
		}
		
		if(IKlength == 0) {
			if(!parent_anchor) {
				control_i0 = (_hover != noone && _hover[0] == self && _hover[1] == 0)? 0 : 2;
				
				if((edit & 0b001) && point_in_circle(_mx, _my, p0x, p0y, ui(16))) //drag head
					hover = [ self, 0, bone_head_pose ];
			}
		
			control_i1 = (_hover != noone && _hover[0] == self && _hover[1] == 1)? 0 : 2;
			
			if((edit & 0b010) && point_in_circle(_mx, _my, p1x, p1y, ui(16))) //drag tail
				hover = [ self, 1, bone_tail_pose ];
		}
		
		return hover;
	}
	
	static drawControl = function(attributes) {
		if(parent != noone && IKlength == 0) {
			var spr, ind0, ind1;
			if(attributes.display_bone == 0) {
				if(!parent_anchor) 
					draw_sprite_colored(THEME.anchor_selector, control_i0, control_x0, control_y0); 
				draw_sprite_colored(THEME.anchor_selector, control_i1, control_x1, control_y1); 
			} else {
				if(!parent_anchor) 
					draw_sprite_ext(THEME.anchor_bone_stick, control_i0 / 2, control_x0, control_y0, 1, 1, 0, COLORS._main_accent, 1); 
				draw_sprite_ext(THEME.anchor_bone_stick, control_i1 / 2, control_x1, control_y1, 1, 1, 0, COLORS._main_accent, 1); 
			}
		}
		
		for( var i = 0, n = array_length(childs); i < n; i++ )
			childs[i].drawControl(attributes);
	}
	
	static resetPose = function() {
		pose_angle = 0;
		pose_scale = 1;
		pose_posit = [ 0, 0 ];
		
		init_direction   = direction;
		init_distance    = distance;
		
		for( var i = 0, n = array_length(childs); i < n; i++ )
			childs[i].resetPose();
	}
	
	static setPosition = function() {
		bone_head_init = getPoint(0, false);
		bone_head_pose = getPoint(0, true);
		bone_tail_init = getPoint(1, false);
		bone_tail_pose = getPoint(1, true);
		
		for( var i = 0, n = array_length(childs); i < n; i++ )
			childs[i].setPosition();
	}
	
	static setPose = function(_position = [ 0, 0 ], _angle = 0, _scale = 1, _ik = true) {
		setPosition();
			setPoseTransform(_position, _angle, _scale);
			if(_ik) {
				setPosition();
				setIKconstrain();
			}
		setPosition();
	}
	
	static setPoseTransform = function(_position = [ 0, 0 ], _angle = 0, _scale = 1) {
		if(is_main) {
			for( var i = 0, n = array_length(childs); i < n; i++ )
				childs[i].setPoseTransform(_position, _angle, _scale);
			return;
		}
		
		pose_posit[0] += _position[0];
		pose_posit[1] += _position[1];
		if(apply_rotation)	pose_angle += _angle;
		if(apply_scale)		pose_scale *= _scale;
		
		if(angular_constrain != -1) pose_angle = clamp(pose_angle, -angular_constrain, angular_constrain);
		
		pose_local_angle = pose_angle;
		pose_local_scale = pose_scale;
		pose_local_posit = pose_posit;
		
		var _x = lengthdir_x(distance, direction) + pose_posit[0];
		var _y = lengthdir_y(distance, direction) + pose_posit[1];
		
		direction = point_direction(0, 0, _x, _y) + _angle;
		distance  = point_distance(0, 0, _x, _y)  * _scale;
		
		init_length = length;
		init_angle  = angle;
		angle  += pose_angle;
		length *= pose_scale;
		
		for( var i = 0, n = array_length(childs); i < n; i++ )
			childs[i].setPoseTransform(_position, pose_angle, pose_scale);
	}
	
	static setIKconstrain = function() {
		if(IKlength > 0 && IKTarget != noone) {
			var points  = array_create(IKlength + 1);
			var lengths = array_create(IKlength);
			var bones   = array_create(IKlength);
			var bn      = IKTarget;
			
			for( var i = IKlength; i > 0; i-- ) {
				var _p = bn.getTail();
				bones[i - 1] = bn;
				points[i] = { x: _p.x, y: _p.y };
				bn = bn.parent;
			}
			
			_p = bn.getTail();
			points[0] = { x: _p.x, y: _p.y };
			
			for( var i = 0; i < IKlength; i++ ) {
				var p0 = points[i];
				var p1 = points[i + 1];
				
				lengths[i] = point_distance(p0.x, p0.y, p1.x, p1.y);
			}
			
			var p  = parent.getHead();
			var px = p.x + lengthdir_x(distance, direction);
			var py = p.y + lengthdir_y(distance, direction);
			
			FABRIK(bones, points, lengths, px, py);
		}
		
		for( var i = 0, n = array_length(childs); i < n; i++ )
			childs[i].setIKconstrain();
	}
	
	FABRIK_result = [];
	static FABRIK = function(bones, points, lengths, dx, dy) {
		
		var threshold = 0.01;
		var _bo = array_create(array_length(points));
		for( var i = 0, n = array_length(points); i < n; i++ )
			_bo[i] = { x: points[i].x, y: points[i].y };
			
		var sx = points[0].x;
		var sy = points[0].y;
		var itr = 0;
		
		do {
			FABRIK_backward(bones, points, lengths, dx, dy);
			FABRIK_forward(bones, points, lengths, sx, sy);
			
			var delta = 0;
			var _bn = array_create(array_length(points));
			for( var i = 0, n = array_length(points); i < n; i++ ) {
				_bn[i] = { x: points[i].x, y: points[i].y };
				delta += point_distance(_bo[i].x, _bo[i].y, _bn[i].x, _bn[i].y);
			}
			
			_bo = _bn;
			if(++itr >= 64) break;
		} until(delta <= threshold);
		
		for( var i = 0, n = array_length(points) - 1; i < n; i++ ) {
			var _b = bones[i];
			var p0 = points[i];
			var p1 = points[i + 1];
			
			var dir  = point_direction(p0.x, p0.y, p1.x, p1.y);
			var dis  = point_distance( p0.x, p0.y, p1.x, p1.y);
			
			// _b.pose_scale = dis / _b.init_length;
			// _b.length     = dis;
			
			// _b.pose_angle = dir - _b.init_angle;
			// _b.angle      = _b.init_angle + _b.pose_angle;
			
			_b.angle = dir;
		
			FABRIK_result[i] = p0;
		}
		
		FABRIK_result[i] = p1;
		
	}
	
	static FABRIK_backward = function(bones, points, lengths, dx, dy) {
		var tx = dx;
		var ty = dy;
		
		for( var i = array_length(points) - 1; i > 0; i-- ) {
			var p1  = points[i];
			var p0  = points[i - 1];
			var len = lengths[i - 1];
			var dir = point_direction(tx, ty, p0.x, p0.y);
			
			p1.x = tx;
			p1.y = ty;
			
			p0.x = p1.x + lengthdir_x(len, dir);
			p0.y = p1.y + lengthdir_y(len, dir);
			
			tx = p0.x;
			ty = p0.y;
		}
	}
	
	static FABRIK_forward = function(bones, points, lengths, sx, sy) {
		var tx = sx;
		var ty = sy;
		
		for( var i = 0, n = array_length(points) - 1; i < n; i++ ) {
			var _b  = bones[i];
			var p0  = points[i];
			var p1  = points[i + 1];
			var len = lengths[i];
			var dir = point_direction(tx, ty, p1.x, p1.y);
			
			if(_b.angular_constrain != -1) dir = clamp(dir, _b.init_angle - _b.angular_constrain, _b.init_angle + _b.angular_constrain);
			
			p0.x = tx;
			p0.y = ty;
			
			p1.x = p0.x + lengthdir_x(len, dir);
			p1.y = p0.y + lengthdir_y(len, dir);
			
			tx = p1.x;
			ty = p1.y;
		}
	}
	
	static __getBBOX = function() {
		var p0 = bone_head_pose;
		var p1 = bone_tail_pose;
		
		var x0 = min(p0.x, p1.x);
		var y0 = min(p0.y, p1.y);
		var x1 = max(p0.x, p1.x);
		var y1 = max(p0.y, p1.y);
		
		return [ x0, y0, x1, y1 ];
	}
	
	static bbox = function() {
		var _bbox = __getBBOX();
		//print($"BBOX: {_bbox}")
		
		for( var i = 0, n = array_length(childs); i < n; i++ ) {
			var _bbox_ch = childs[i].bbox();
			//print($"BBOX ch: {_bbox_ch}")
			
			_bbox[0] = min(_bbox[0], _bbox_ch[0]);
			_bbox[1] = min(_bbox[1], _bbox_ch[1]);
			_bbox[2] = max(_bbox[2], _bbox_ch[2]);
			_bbox[3] = max(_bbox[3], _bbox_ch[3]);
		}
		
		return _bbox;
	}
	
	static serialize = function() {
		var bone = {};
		
		bone.ID			= ID;
		bone.name		= name;
		bone.distance	= distance;
		bone.direction	= direction;
		bone.angle		= angle;
		bone.length		= length;
		
		bone.is_main		= is_main;
		bone.parent_anchor	= parent_anchor;
		
		bone.IKlength	= IKlength;
		bone.IKTargetID	= IKTargetID;
		
		bone.apply_rotation	= apply_rotation;
		bone.apply_scale	= apply_scale;
		
		bone.angular_constrain = angular_constrain;
		
		bone.childs = [];
		for( var i = 0, n = array_length(childs); i < n; i++ )
			bone.childs[i] = childs[i].serialize();
			
		return bone;
	}
	
	static deserialize = function(bone, node) {
		ID			= bone.ID;
		name		= bone.name;
		distance	= bone.distance;
		direction	= bone.direction;
		angle		= bone.angle;
		length		= bone.length;
		
		is_main			= bone.is_main;
		parent_anchor	= bone.parent_anchor;
		
		self.node	= node;
		
		IKlength	= bone.IKlength;
		IKTargetID	= struct_try_get(bone, "IKTargetID", "");
		
		apply_rotation	= bone.apply_rotation;
		apply_scale		= bone.apply_scale;
		
		angular_constrain = struct_try_get(bone, "angular_constrain", -1);
		angular_constrain = -1;
		
		childs = [];
		for( var i = 0, n = array_length(bone.childs); i < n; i++ ) {
			var _b = new __Bone().deserialize(bone.childs[i], node);
			addChild(_b);
		}
		
		return self;
	}
	
	static connect = function() {
		IKTarget = noone;
		if(parent != noone && IKTargetID != "") 
			IKTarget = parent.findBone(IKTargetID);
		
		for( var i = 0, n = array_length(childs); i < n; i++ )
			childs[i].connect();
	}
	
	static clone = function() {
		var _b = new __Bone(parent, distance, direction, angle, length);
		_b.ID		= ID;
		_b.name		= name;
		_b.is_main	= is_main;
		_b.parent_anchor = parent_anchor;
		
		_b.IKlength		= IKlength;
		_b.IKTargetID	= IKTargetID;
		
		_b.apply_rotation	 = apply_rotation;
		_b.apply_scale		 = apply_scale;
		_b.angular_constrain = angular_constrain;
		
		for( var i = 0, n = array_length(childs); i < n; i++ )
			_b.addChild(childs[i].clone());
		
		return _b;
	}
	
	static toString = function() { return $"Bone {name} [{ID}]"; }
	
	static toArray = function(arr = []) {
		if(!is_main) array_push(arr, self);
		for( var i = 0, n = array_length(childs); i < n; i++ )
			childs[i].toArray(arr);
			
		return arr;
	}
}