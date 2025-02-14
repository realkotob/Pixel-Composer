function Node_PCX_Array_Get(_x, _y, _group = noone) : Node_PCX(_x, _y, _group) constructor {
	name = "Array Get";
	
	newInput(0, nodeValue("Array", self, CONNECT_TYPE.input, VALUE_TYPE.PCXnode, noone));
	
	newInput(1, nodeValue("Index", self, CONNECT_TYPE.input, VALUE_TYPE.PCXnode, noone));
	
	newOutput(0, nodeValue_Output("PCX", self, VALUE_TYPE.PCXnode, noone));
	
	static update = function() {
		var _arr = getInputData(0);
		var _ind = getInputData(1);
		
		outputs[0].setValue(new __funcTree("@", _arr, _ind));
	}
}