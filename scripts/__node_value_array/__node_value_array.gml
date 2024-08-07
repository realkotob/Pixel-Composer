function nodeValue_Vector(_name, _node, _value, _data = {}) {
	var _len = array_length(_value);
	
	switch(_len) {
		case 2 : return new NodeValue_Vec2(_name, _node, _value, _data);
		case 3 : return new NodeValue_Vec3(_name, _node, _value, _data);
		case 4 : return new NodeValue_Vec4(_name, _node, _value, _data);
	}
	
	return new NodeValue_Array(_name, _node, _value, "", _len);
}

function NodeValue_Array(_name, _node, _value, _tooltip = "", _length = 2) : NodeValue(_name, _node, JUNCTION_CONNECT.input, VALUE_TYPE.float, _value, _tooltip) constructor {
	
	data_array_length = _length;
	
	/////============== GET =============
	
	static getValue = function(_time = CURRENT_FRAME, applyUnit = true, arrIndex = 0, useCache = false, log = false) { //// Get value
		getValueRecursive(self.__curr_get_val, _time);
		var val = __curr_get_val[0];
		
		val = array_verify(val, data_array_length);
		return val;
	}
	
	static __getAnimValue = function(_time = CURRENT_FRAME) {
		if(!is_anim) {
			if(sep_axis) return array_create_ext(data_array_length, function(i) /*=>*/ {return animators[i].processType(animators[i].values[| 0].value)});
			return ds_list_empty(animator.values)? 0 : animator.processType(animator.values[| 0].value);
		}
		
		if(sep_axis) {
			__temp_time = _time;
			return array_create_ext(data_array_length, function(i) /*=>*/ {return animators[i].getValue(__temp_time)});
		} 
		
		return animator.getValue(_time);
	}
}