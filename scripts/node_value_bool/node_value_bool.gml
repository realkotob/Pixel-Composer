function nodeValue_Bool(_name, _node, _value, _tooltip = "") { return new __NodeValue_Bool(_name, _node, _value, _tooltip); }

function __NodeValue_Bool(_name, _node, _value, _tooltip = "") : NodeValue(_name, _node, CONNECT_TYPE.input, VALUE_TYPE.boolean, _value, _tooltip) constructor {
	
	/////============== GET =============
	
	function toBool(a) { return is_array(a)? array_map(a, function(v) /*=>*/ {return toBool(v)}) : bool(a) };
	
	static getValue = function(_time = CURRENT_FRAME, applyUnit = true, arrIndex = 0, useCache = false, log = false) { //// Get value
		getValueRecursive(self.__curr_get_val, _time);
		var val = __curr_get_val[0];
		return toBool(val);
	}
	
	static __getAnimValue = function(_time = CURRENT_FRAME) {
		if(is_anim) return animator.getValue(_time);
		return array_empty(animator.values)? 0 : animator.values[0].value;
	}
	
	static arrayLength = arrayLengthSimple;
}

function nodeValue_Bool_single(_name, _node, _value, _tooltip = "") { return new __NodeValue_Bool_single(_name, _node, _value, _tooltip); }

function __NodeValue_Bool_single(_name, _node, _value, _tooltip = "") : NodeValue(_name, _node, CONNECT_TYPE.input, VALUE_TYPE.boolean, _value, _tooltip) constructor {
	rejectArray();
	
	/////============== GET =============
	
	static getValue = function(_time = CURRENT_FRAME, applyUnit = true, arrIndex = 0, useCache = false, log = false) { //// Get value
		getValueRecursive(self.__curr_get_val, _time);
		return bool(__curr_get_val[0]);
	}
	
	static __getAnimValue = function(_time = CURRENT_FRAME) {
		if(is_anim) return animator.getValue(_time);
		return array_empty(animator.values)? 0 : animator.values[0].value;
	}
	
	static arrayLength = arrayLengthSimple;
}