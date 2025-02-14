function Node_Iterator_Output(_x, _y, _group = noone) : Node_Group_Output(_x, _y, _group) constructor {
	name  = "Loop Output";
	color = COLORS.node_blend_loop;
	is_group_io = true;
	
	manual_ungroupable = false;
	setDimension(96, 48);
	
	inputs[0].setFrom_condition = function(_valueFrom) {
		if(instanceof(_valueFrom.node) != "Node_Iterator_Input") return true;
		if(inputs[1].value_from == noone) return true;
		if(inputs[1].value_from.node == _valueFrom.node) {
			noti_warning("setFrom: Immediate cycle disallowed",, self);
			return false;
		}
		return true;
	}
	
	newInput(1, nodeValue("Loop exit", self, CONNECT_TYPE.input, VALUE_TYPE.node, -1))
		.uncache()
		.setVisible(true, true);
	
	inputs[1].setFrom_condition = function(_valueFrom) {
		if(instanceof(_valueFrom.node) != "Node_Iterator_Input") return true;
		if(inputs[0].value_from == noone) return true;
		if(inputs[0].value_from.node == _valueFrom.node) {
			noti_warning("setFrom: Immediate cycle disallowed",, self);
			return false;
		}
		return true;
	}
	
	cache_value = -1;
	
	static getNextNodes = function(checkLoop = false) {
		if(!struct_has(group, "outputNextNode")) return [];
		return group.outputNextNode();
	}
	
	static initLoop = function() {
		cache_value = noone;
	}
	
	static cloneValue = function(_prev_val, _val) {
		if(inputs[0].value_from == noone) return _prev_val;
		
		var is_surf	 = inputs[0].value_from.type == VALUE_TYPE.surface;
		var _new_val;
		
		surface_array_free(_prev_val);
		_new_val = is_surf? surface_array_clone(_val) : array_clone(_val);
		
		return _new_val;
	}
	
	static update = function(frame = CURRENT_FRAME) {
		if(inputs[0].value_from == noone) {
			group.iterationUpdate();
			return;
		}
		
		var _val = getInputData(0);
		cache_value = cloneValue(cache_value, _val);
		group.iterationUpdate();
	}
}