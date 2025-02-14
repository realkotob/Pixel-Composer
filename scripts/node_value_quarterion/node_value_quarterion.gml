function nodeValue_Quaternion(_name, _node, _value, _tooltip = "") { return new __NodeValue_Quaternion(_name, _node, _value, _tooltip); }

function __NodeValue_Quaternion(_name, _node, _value, _tooltip = "") : __NodeValue_Array(_name, _node, _value, _tooltip, 4) constructor {
	setDisplay(VALUE_DISPLAY.d3quarternion);
	
	/////============== GET =============
	
	static getValue = function(_time = CURRENT_FRAME, applyUnit = true, arrIndex = 0, useCache = false, log = false) { //// Get value
		getValueRecursive(self.__curr_get_val, _time);
		var val = __curr_get_val[0];
		var nod = __curr_get_val[1]; if(!is(nod, NodeValue)) return val;
		
		var typ = nod.type;
		var dis = nod.display_type;
		
		if(!is_array(val)) return array_create(4, val);
		
		var _convert = applyUnit && attributes.angle_display == QUARTERNION_DISPLAY.euler;
		if(!_convert) return array_verify(val, 4);
		
		var _d = array_get_depth(val);
		
		if(_d == 1) return quarternionFromEuler(val[0], val[1], val[2]);
		if(_d == 2) return array_map(val, function(v, i) /*=>*/ {return quarternionFromEuler(v[0], v[1], v[2])});
		
		return val;
	}
}