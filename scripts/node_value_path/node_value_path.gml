function nodeValue_Path(_name, _node, _value, _tooltip = "") { return new __NodeValue_Path(_name, _node, _value, _tooltip); }

function __NodeValue_Path(_name, _node, _value, _tooltip = "") : NodeValue(_name, _node, CONNECT_TYPE.input, VALUE_TYPE.path, _value, _tooltip) constructor {
	
	/////============== GET =============
	
	static valueProcess = function(value, nodeFrom = undefined, applyUnit = true, arrIndex = 0) {
		return is_string(value)? filepath_resolve(value) : value; 
	}
	
	static getValue = function(_time = CURRENT_FRAME, applyUnit = true, arrIndex = 0, useCache = false, log = false) { //// Get value
		getValueRecursive(self.__curr_get_val, _time);
		var val = __curr_get_val[0];
		
		if(is_array(val)) val = array_map(val, function(v) /*=>*/ {return valueProcess(v)});
		else              val = valueProcess(val);
			
		return val;
	}
	
	static __getAnimValue = function(_time = CURRENT_FRAME) {
		if(is_anim) return animator.getValue(_time);
		return array_empty(animator.values)? 0 : animator.values[0].value;
	}
	
	static arrayLength = arrayLengthSimple;
}