function nodeValue_Surface(_name, _node, _value = noone, _tooltip = "") { return new __NodeValue_Surface(_name, _node, _value, _tooltip); }

function __NodeValue_Surface(_name, _node, _value, _tooltip = "") : NodeValue(_name, _node, CONNECT_TYPE.input, VALUE_TYPE.surface, _value, _tooltip) constructor {
	
	animable = false;
	
	/////============== GET =============
	
	static getValue = function(_time = CURRENT_FRAME, applyUnit = true, arrIndex = 0, useCache = false, log = false) { //// Get value
		getValueRecursive(self.__curr_get_val, _time);
		var val = __curr_get_val[0];
		var nod = __curr_get_val[1]; if(!is(nod, NodeValue)) return val;
		
		draw_junction_index = VALUE_TYPE.surface;
		if(is(val, SurfaceAtlas) || (array_valid(val) && is_instanceof(val[0], SurfaceAtlas))) 
			draw_junction_index = VALUE_TYPE.atlas;
		
		if(is(val, dynaDraw)) val.node = node;
		return val;
	}
	
	static __getAnimValue = function(_time = CURRENT_FRAME) { return array_empty(animator.values)? noone : animator.processValue(animator.values[0].value); }
	
	static arrayLength = arrayLengthSimple;
}