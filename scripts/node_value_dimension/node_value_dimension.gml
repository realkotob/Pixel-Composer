function nodeValue_Dimension(_node, value = DEF_SURF) { return new __NodeValue_Dimension(_node, value); }

function __NodeValue_Dimension(_node, value) : NodeValue("Dimension", _node, CONNECT_TYPE.input, VALUE_TYPE.integer, value, "") constructor {
	setDisplay(VALUE_DISPLAY.vector);
	def_length = 2;
	
	attributes.use_project_dimension = true;
	editWidget.side_button = button(function() /*=>*/ {
		attributes.use_project_dimension = !attributes.use_project_dimension;
		node.triggerRender();
	}).setIcon(THEME.node_use_project, 0, COLORS._main_icon).setTooltip("Use project dimension");
	
	/////============== GET =============
	
	static getValue = function(_time = CURRENT_FRAME, applyUnit = true, arrIndex = 0, useCache = false, log = false) { //// Get value
		getValueRecursive(self.__curr_get_val, _time);
		var val = __curr_get_val[0];
		var nod = __curr_get_val[1]; if(!is(nod, NodeValue)) return val;
		var typ = nod.type;
		
		if(typ != VALUE_TYPE.surface) {
			var _d = array_get_depth(val);
			
			__nod       = nod;
			__applyUnit = applyUnit;
			__arrIndex  = arrIndex;
			
			if(_d == 0) return [ val, val ];
			if(_d == 1) return array_verify(val, 2);
			if(_d == 2) return array_map(val, function(v, i) /*=>*/ {return array_verify(v, 2)});
			
			return val;
		}
		
		// Dimension conversion
		if(is_array(val)) {
			var eqSize = true;
			var sArr = [];
			var _osZ = 0;
			
			for( var i = 0, n = array_length(val); i < n; i++ ) {
				if(!is_surface(val[i])) continue;
				
				var surfSz = surface_get_dimension(val[i]);
				array_push(sArr, surfSz);
				
				if(i && !array_equals(surfSz, _osZ))
					eqSize = false;
				
				_osZ = surfSz;
			}
			
			if(eqSize) return _osZ;
			return sArr;
		} else if (is_surface(val)) 
			return [ surface_get_width_safe(val), surface_get_height_safe(val) ];
			
		return [ 1, 1 ];
	}
	
	static __getAnimValue = function(_time = CURRENT_FRAME) {
		if(attributes.use_project_dimension) 
			return PROJECT.attributes.surface_dimension;
		
		if(!is_anim) {
			if(sep_axis) return array_create_ext(2, function(i) /*=>*/ {return animators[i].processType(animators[i].values[0].value)});
			return array_empty(animator.values)? 0 : animator.processType(animator.values[0].value);
		}
		
		if(sep_axis) {
			__temp_time = _time;
			return array_create_ext(2, function(i) /*=>*/ {return animators[i].getValue(__temp_time)});
		} 
		
		return animator.getValue(_time);
	}
	
}