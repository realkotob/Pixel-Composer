function Node_PCX_Condition(_x, _y, _group = noone) : Node_PCX(_x, _y, _group) constructor {
	name  = "Condition";
	
	newInput(0, nodeValue("Condition", self, CONNECT_TYPE.input, VALUE_TYPE.PCXnode, noone));
	
	newInput(1, nodeValue("True", self, CONNECT_TYPE.input, VALUE_TYPE.PCXnode, noone));
	
	newInput(2, nodeValue("False", self, CONNECT_TYPE.input, VALUE_TYPE.PCXnode, noone));
	
	newOutput(0, nodeValue_Output("PCX", self, VALUE_TYPE.PCXnode, noone));
	
	static update = function() {
		var _cond = getInputData(0);
		var _true = getInputData(1);
		var _fals = getInputData(2);
		
		var _fn = new __funcIf();
		_fn.condition = _cond;
		_fn.if_true   = _true;
		_fn.if_false  = _fals;
		
		outputs[0].setValue(_fn);
	}
}