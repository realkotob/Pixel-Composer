function Node_Rigid_Object_Spawner(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Object Spawner";
	color = COLORS.node_blend_simulation;
	icon  = THEME.rigidSim;
	setDimension(96, 96);
	
	manual_ungroupable	 = false;
	
	object = [];
	
	newInput(0, nodeValue("Object", self, CONNECT_TYPE.input, VALUE_TYPE.rigid, noone))
		.setVisible(true, true);
	
	newInput(1, nodeValue_Area("Spawn area", self, DEF_AREA))
		.rejectArray();
	
	newInput(2, nodeValue_Enum_Button("Spawn type", self,  0, [ "Stream", "Burst" ]))
		.rejectArray();
	
	newInput(3, nodeValue_Int("Spawn delay", self, 4))
		.rejectArray();
	
	newInput(4, nodeValue_Int("Spawn amount", self, 1))
		.rejectArray();
	
	newInput(5, nodeValue_Int("Spawn frame", self, 0))
		.rejectArray();
	
	newInput(6, nodeValue_Bool("Spawn", self, true))
		.rejectArray();
	
	newInput(7, nodeValueSeed(self));
	
	newOutput(0, nodeValue_Output("Object", self, VALUE_TYPE.rigid, object));
	
	input_display_list = [ 0, 7, 
		["Spawn",	false],	6, 1, 2, 3, 5, 4,
	];
	
	spawn_index = 0;
	
	attributes.show_objects = true;
	array_push(attributeEditors, "Display");
	array_push(attributeEditors, ["Show objects", function() { return attributes.show_objects; }, 
		new checkBox(function() { 
			attributes.show_objects = !attributes.show_objects;
		})]);
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var gr = is_instanceof(group, Node_Rigid_Group)? group : noone;
		if(inline_context != noone) gr = inline_context;
		
		if(attributes.show_objects && gr != noone) 
		for( var i = 0, n = array_length(gr.nodes); i < n; i++ ) {
			var _node = gr.nodes[i];
			if(!is_instanceof(_node, Node_Rigid_Object)) continue;
			var _hov = _node.drawOverlayPreview(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
			active &= !_hov;
		}
		
		return inputs[1].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
	}
	
	static reset = function() {
		spawn_index = 0;
		object = [];
	}
	
	static step = function() {
		var _typ = getInputData(2);
		
		inputs[3].setVisible(_typ == 0);
		inputs[5].setVisible(_typ == 1);
	}
	
	static spawn = function(seed = 0) {
		var _obj = getInputData(0);
		var _are = getInputData(1);
		var _amo = getInputData(4);
		
		random_set_seed(seed);
		
		repeat(_amo) {
			var pos = area_get_random_point(_are);
			var _o = _obj;
			if(is_array(_o))
				_o = _o[irandom_range(0, array_length(_o) - 1)];
				
			array_push(object, _o.spawn(pos, spawn_index++));
		}
	}
	
	static update = function(frame = CURRENT_FRAME) {
		RETURN_ON_REST
			
		var _obj = getInputData(0);
		if(_obj == noone) return;
		
		var _spw = getInputData(6);
		if(!_spw) return;
		
		var _typ = getInputData(2);
		var _del = getInputData(3);
		var _frm = getInputData(5);
		var _amo = getInputData(4);
		var _sed = getInputData(7) + frame * _amo * 20;
		
		if(_typ == 0 && (safe_mod(CURRENT_FRAME, _del) == 0)) 
			spawn(_sed);
		else if(_typ == 1 && CURRENT_FRAME == _frm) 
			spawn(_sed);
			
		outputs[0].setValue(object);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		
		var _obj = getInputData(0);
		if(_obj == noone) return;
		if(is_array(_obj)) return;
		
		var _tex  = _obj.getInputData(6);
		var _spos = _obj.getInputData(7);
		
		draw_surface_stretch_fit(_tex, bbox.xc, bbox.yc, bbox.w, bbox.h, _spos[2], _spos[3]);
	}
}