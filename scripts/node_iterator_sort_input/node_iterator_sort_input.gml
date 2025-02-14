function Node_Iterator_Sort_Input(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Sort Input";
	color = COLORS.node_blend_loop;
	
	manual_deletable = false;
	
	newInput(0, nodeValue("Value in", self, CONNECT_TYPE.input, VALUE_TYPE.any, 0 ))
		.setVisible(false, false);
	
	newOutput(0, nodeValue_Output("Value in", self, VALUE_TYPE.any, 0 ));
	
	attributes.sort_inputs = 0;
	
	static update = function() {
		var val = getInputData(0);
		outputs[0].setValue(val);
	}
	
}