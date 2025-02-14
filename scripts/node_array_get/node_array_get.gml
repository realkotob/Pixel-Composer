function Node_Array_Get(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Array Get";
	setDimension(96, 48);
	
	newInput(0, nodeValue("Array", self, CONNECT_TYPE.input, VALUE_TYPE.any, 0))
		.setVisible(true, true);
	
	newInput(1, nodeValue_Int("Index", self, 0))
		.setVisible(true, true);
	
	newInput(2, nodeValue_Enum_Scroll("Overflow", self, 0, [ "Clamp", "Loop", "Ping Pong" ]))
		.rejectArray();
	
	newOutput(0, nodeValue_Output("Value", self, VALUE_TYPE.any, 0));
	
	static step = function() {
		inputs[0].setType(VALUE_TYPE.any);
		outputs[0].setType(VALUE_TYPE.any);
		
		if(inputs[0].value_from != noone) {
			inputs[0].setType(inputs[0].value_from.type);
			outputs[0].setType(inputs[0].type);
		}
	}
	
	static getArray = function(_arr, index, _ovf) {
		if(!is_array(_arr)) return;
		if(is_array(index)) return;
		
		var _len  = array_length(_arr);
		
		switch(_ovf) {
			case 0 :
				if(index < 0) index = _len + index;
				index = clamp(index, 0, _len - 1);
				break;
			case 1 :
				index = safe_mod(index, _len);
				if(index < 0) index = _len + index;
				break;
			case 2 :
				var _pplen = (_len - 1) * 2;
				index = safe_mod(abs(index), _pplen);
				if(index >= _len) 
					index = _pplen - index;
				break;
		}
		
		return array_safe_get_fast(_arr, index);
	}
	
	static update = function(frame = CURRENT_FRAME) {
		var _arr = getInputData(0);
		
		if(!is_array(_arr)) return;
		
		var index = getInputData(1);
		var _ovf  = getInputData(2);
		var res   = is_array(index)? array_create(array_length(index)) : 0;
		
		if(is_array(index)) {
			for( var i = 0, n = array_length(index); i < n; i++ )
				res[i] = getArray(_arr, index[i], _ovf);
		} else 
			res = getArray(_arr, index, _ovf);
		
		outputs[0].setValue(res);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		var idx = getInputData(1);
		
		var str	= string(idx);
		var bbox = drawGetBbox(xx, yy, _s);
		var ss	= string_scale(str, bbox.w, bbox.h);
		draw_text_transformed(bbox.xc, bbox.yc, str, ss, ss, 0);
	}
}