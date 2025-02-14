function Node_DynaSurf_Out(_x, _y, _group = noone) : Node_PCX(_x, _y, _group) constructor {
	name  = "Output";
	color = COLORS.node_blend_dynaSurf;
	
	manual_deletable	 = false;
	destroy_when_upgroup = true;
	
	newInput(0, nodeValue("Surface", self, CONNECT_TYPE.input, VALUE_TYPE.PCXnode, noone));
	
	newInput(1, nodeValue("x", self, CONNECT_TYPE.input, VALUE_TYPE.PCXnode, noone));
	
	newInput(2, nodeValue("y", self, CONNECT_TYPE.input, VALUE_TYPE.PCXnode, noone));
	
	newInput(3, nodeValue("sx", self, CONNECT_TYPE.input, VALUE_TYPE.PCXnode, noone));
	
	newInput(4, nodeValue("sy", self, CONNECT_TYPE.input, VALUE_TYPE.PCXnode, noone));
	
	newInput(5, nodeValue("angle", self, CONNECT_TYPE.input, VALUE_TYPE.PCXnode, noone));
	
	newInput(6, nodeValue("color", self, CONNECT_TYPE.input, VALUE_TYPE.PCXnode, noone));
	
	newInput(7, nodeValue("alpha", self, CONNECT_TYPE.input, VALUE_TYPE.PCXnode, noone));
	 
	newOutput(0, nodeValue_Output("PCX", self, VALUE_TYPE.PCXnode, noone))
		.setVisible(false);
	
	input_display_list = [ 0, 
		["Transform", false], 1, 2, 3, 4, 5, 
		["Draw",      false], 6, 7, 
	];
	
	static getNextNodes = method(self, dynaSurf_output_getNextNode);
	
	static setRenderStatus = function(result) {
		rendered = result;
		if(group) group.setRenderStatus(result);
	}
	
	static update = function() {
		var _surf = getInputData(0);
		var _x    = getInputData(1);
		var _y    = getInputData(2);
		var _sx   = getInputData(3);
		var _sy   = getInputData(4);
		var _ang  = getInputData(5);
		var _clr  = getInputData(6);
		var _alp  = getInputData(7);
		
		outputs[0].setValue(new __funcTree("draw", [ _surf, _x, _y, _sx, _sy, _ang, _clr, _alp ]));
		
		if(group) group.setDynamicSurface();
	}
}