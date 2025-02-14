function Node_Array_Remove(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Array Remove";
	setDimension(96, 48);
	
	newInput(0, nodeValue("Array", self, CONNECT_TYPE.input, VALUE_TYPE.any, 0))
		.setVisible(true, true);
	
	newInput(1, nodeValue_Enum_Button("Type", self,  0, [ "Index", "Value" ]))
		.rejectArray();
	
	newInput(2, nodeValue_Int("Index", self, 0));
	
	newInput(3, nodeValue("Value", self, CONNECT_TYPE.input, VALUE_TYPE.any, 0))
		.setVisible(true, true);
	
	newInput(4, nodeValue_Bool("Spread array", self, false ))
		.rejectArray();
		
	newOutput(0, nodeValue_Output("Array", self, VALUE_TYPE.any, 0));
	
	static step = function() {
		var type  = getInputData(1);
		
		inputs[2].setVisible(type == 0, type == 0);
		inputs[3].setVisible(type == 1, type == 1);
		
		inputs[0].setType(VALUE_TYPE.any);
		inputs[3].setType(VALUE_TYPE.any);
		outputs[0].setType(VALUE_TYPE.any);
		
		if(inputs[0].value_from != noone) {
			var type = inputs[0].value_from.type;
			inputs[0].setType(type);
			inputs[3].setType(type);
			outputs[0].setType(type);
		}
		
	}
	
	static update = function(frame = CURRENT_FRAME) {
		var _arr = getInputData(0);
		if(!is_array(_arr)) return;
		
		var type  = getInputData(1);
		var index = getInputData(2);
		var value = getInputData(3);
		var spred = getInputData(4);
		
		_arr = array_clone(_arr);
		
		if(type == 0) {
			if(!is_array(index)) index = [ index ];
			array_sort(index, false);
			
			for( var i = 0, n = array_length(index); i < n; i++ ) {
				if(index[i] < 0) index[i] = array_length(_arr) + index[i];
				array_delete(_arr, index[i], 1);
			}
		} else {
			if(!spred || !is_array(value)) value = [ value ];
			
			for( var i = 0, n = array_length(value); i < n; i++ )
				array_remove(_arr, value[i]);
		}
		
		outputs[0].setValue(_arr);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_array_remove, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}