function Node_Iterator_Each_Inline_Output(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Loop Output";
	color = COLORS.node_blend_loop;
	loop  = noone;
	setDimension(96, 48);
	
	clonable = false;
	inline_output        = false;
	inline_parent_object = "Node_Iterate_Each_Inline";
	manual_ungroupable	 = false;
	
	newInput(0, nodeValue("Value out", self, CONNECT_TYPE.input, VALUE_TYPE.any, 0 ))
		.setVisible(true, true);
	
	newOutput(0, nodeValue_Output("Array out", self, VALUE_TYPE.any, [] ));
	
	static getNextNodes = function(checkLoop = false) {
		if(loop.bypassNextNode())
			return loop.getNextNodes();
		return getNextNodesRaw();
	}
	
	static update = function(frame = CURRENT_FRAME) {
		if(!is_instanceof(loop, Node_Iterate_Each_Inline)) return;
		
		var _typ = inputs[0].value_from == noone? VALUE_TYPE.any : inputs[0].value_from.type;
		inputs[0].setType(_typ);
		outputs[0].setType(_typ);
		
		var val = getInputData(0);
		var arr = outputs[0].getValue();
		var itr = max(0, loop.iterated - 1);
		
		if(!is_array(arr)) return;
		
		if(_typ == VALUE_TYPE.surface) {
				 if(is(val, SurfaceAtlas)) arr[@ itr] = val.clone();
			else if(surface_exists(val))   arr[@ itr] = surface_clone(val);
			else                           arr[@ itr] = val;
			
		} else 
			arr[@ itr] = val;
			
		outputs[0].setValue(arr);
	}
}