function nodeValue_Vector(_name, _node, _value, _data = {}) {
	return new __NodeValue_Array(_name, _node, _value, "", -1);
}

function __NodeValue_Array(_name, _node, _value, _tooltip = "", _length = 2) : NodeValue(_name, _node, CONNECT_TYPE.input, VALUE_TYPE.float, _value, _tooltip) constructor {
	
	type_array = 1;
	def_length = _length;
	
	/////============== GET =============
	
	static getValue = function(_time = CURRENT_FRAME, applyUnit = true, arrIndex = 0, useCache = false, log = false) { //// Get value
		getValueRecursive(self.__curr_get_val, _time);
		var val = __curr_get_val[0];
		
		var _d = array_get_depth(val);
		
		if(def_length > -1) {
			if(_d == 0) return array_create(def_length, val);
			if(_d == 1) return array_verify(val, def_length);
			if(_d == 2) return array_map(val, function(v, i) /*=>*/ {return array_verify(v, def_length)});
		}
		
		return val;
	}
	
	static __getAnimValue = function(_time = CURRENT_FRAME) {
		if(!is_anim) {
			if(sep_axis) return array_create_ext(def_length, function(i) /*=>*/ {return animators[i].processType(animators[i].values[0].value)});
			return array_empty(animator.values)? 0 : animator.processType(animator.values[0].value);
		}
		
		if(sep_axis) {
			__temp_time = _time;
			return array_create_ext(def_length, function(i) /*=>*/ {return animators[i].getValue(__temp_time)});
		} 
		
		return animator.getValue(_time);
	}
}