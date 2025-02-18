function Node_Array_Add(_x, _y, _group = -1) : Node(_x, _y, _group) constructor {
	name = "Array add";
	previewable = false;
	
	w = 96;
	h = 32 + 24;
	min_h = h;
	
	inputs[| 0] = nodeValue(0, "Array", self, JUNCTION_CONNECT.input, VALUE_TYPE.any, 0)
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue(1, "Value", self, JUNCTION_CONNECT.input, VALUE_TYPE.any, 0)
		.setVisible(true, true);
	
	inputs[| 2] = nodeValue(2, "Spread array", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
	
	outputs[| 0] = nodeValue(0, "Size", self, JUNCTION_CONNECT.output, VALUE_TYPE.integer, 0);
	
	static update = function() {
		var _arr = inputs[| 0].getValue();
		var _val = inputs[| 1].getValue();
		var _app = inputs[| 2].getValue();
		
		inputs[| 2].setVisible(is_array(_val));
		
		if(!is_array(_arr)) return;
		var _out = array_clone(_arr);
		if(is_array(_val) && _app)
			array_append(_out, _val);
		else
			array_push(_out, _val);
		outputs[| 0].setValue(_out);
	}
	
	doUpdate();
}