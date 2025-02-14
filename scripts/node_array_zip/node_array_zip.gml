function Node_Array_Zip(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Array Zip";
	setDimension(96, 48);
	
	newInput(0, nodeValue("Array", self, CONNECT_TYPE.input, VALUE_TYPE.any, 0))
		.setVisible(true, true);
	
	newOutput(0, nodeValue_Output("Output", self, VALUE_TYPE.integer, 0));
	
	static createNewInput = function() {
		var index = array_length(inputs);
		
		newInput(index, nodeValue("Value", self, CONNECT_TYPE.input, VALUE_TYPE.any, -1 ))
			.setVisible(true, true);
		
		return inputs[index];
	} setDynamicInput(1);
	
	static step = function() {
		if(inputs[0].value_from == noone) {
			inputs[0].setType(VALUE_TYPE.any);
			outputs[0].setType(VALUE_TYPE.any);
		} else {
			inputs[0].setType(inputs[0].value_from.type);
			outputs[0].setType(inputs[0].value_from.type);
		}
		
		for( var i = 0; i < array_length(inputs); i += data_length )
			inputs[i].setType(inputs[i].value_from == noone? VALUE_TYPE.any : inputs[i].value_from.type);
	}
	
	static update = function(frame = CURRENT_FRAME) {
		var _arr = getInputData(0);
		
		if(!is_array(_arr)) return;
		var len = 1;
		var val = [];
		for( var i = 0; i < array_length(inputs); i += data_length ) {
			val[i] = getInputData(i);
			
			if(!is_array(val[i])) {
				val[i] = [ val[i] ];
				continue;
			}
			len = max(len, array_length(val[i]));
		}
		
		var _out = array_create(len);
		
		for( var i = 0; i < len; i++ ) {
			for( var j = 0; j < array_length(inputs); j += data_length )
				_out[i][j] = array_safe_get_fast(val[j], i, 0);
		}
		
		outputs[0].setValue(_out);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_array_zip, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}