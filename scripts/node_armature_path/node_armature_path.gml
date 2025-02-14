function Node_Armature_Path(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Armature Path";
	setDimension(96, 72);
	
	newInput(0, nodeValue_Armature("Armature", self, noone))
		.setVisible(true, true)
		.rejectArray();
	
	newOutput(0, nodeValue_Output("Path", self, VALUE_TYPE.pathnode, noone));
	
	lines = [];
	
	current_length  = 0;
	boundary = new BoundingBox();
	
	attributes.display_name = true;
	attributes.display_bone = 0;
	
	array_push(attributeEditors, "Display");
	array_push(attributeEditors, ["Display name", function() { return attributes.display_name; }, 
		new checkBox(function() { 
			attributes.display_name = !attributes.display_name;
		})]);
	array_push(attributeEditors, ["Display bone", function() { return attributes.display_bone; }, 
		new scrollBox(["Octahedral", "Stick"], function(ind) { 
			attributes.display_bone = ind;
		})]);
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _b = getInputData(0);
		if(_b == noone) return;
		
		_b.draw(attributes, false, _x, _y, _s, _mx, _my);
	}
	
	static getBoundary	= function() { return boundary; }
	
	static getLineCount		= function() { return array_length(lines); }
	static getSegmentCount	= function() { return 1; }
	static getLength		= function() { return current_length; }
	static getAccuLength	= function() { return [ 0, current_length ]; }
	
	static getPointDistance = function(_dist, _ind = 0, out = undefined) { return getPointRatio(_dist / current_length, _ind, out); }
	
	static getPointRatio = function(_rat, _ind = 0, out = undefined) {
		if(out == undefined) out = new __vec2P(); else { out.x = 0; out.y = 0; }
		
		var _p0 = lines[_ind][0];
		var _p1 = lines[_ind][1];
		
		if(!is_array(_p0) || array_length(_p0) < 2) return out;
		if(!is_array(_p1) || array_length(_p1) < 2) return out;
		
		out.x = lerp(_p0[0], _p1[0], _rat);
		out.y = lerp(_p0[1], _p1[1], _rat);
		
		return out;
	}
	
	static update = function() {
		var _bone = getInputData(0);
		if(_bone == noone) return;
		
		lines = [];
		current_length = 0;
		
		var _bst = ds_stack_create();
		ds_stack_push(_bst, _bone);
		
		while(!ds_stack_empty(_bst)) {
			var bone = ds_stack_pop(_bst);
			if(bone.IKlength) continue;
			
			if(!bone.is_main) {
				var _p0  = bone.getHead();
				var _p1  = bone.getTail();
			
				array_push(lines, [ 
					[_p0.x, _p0.y, 1], 
					[_p1.x, _p1.y, 1], 
				]);
				
				current_length += point_distance(_p0.x, _p0.y, _p1.x, _p1.y);
			}
			
			for( var i = 0, n = array_length(bone.childs); i < n; i++ ) {
				var child_bone = bone.childs[i];
				ds_stack_push(_bst, child_bone);
			}
		}
		
		ds_stack_destroy(_bst);
		
		outputs[0].setValue(self);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_armature_path, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}