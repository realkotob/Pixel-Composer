function Node_String_Regex_Replace(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "RegEx Replace";
	
	setDimension(96, 48);
	
	newInput(0, nodeValue_Text("Text", self, ""))
		.setVisible(true, true);
	
	newInput(1, nodeValue_Text("Regex", self, ""));
	
	newInput(2, nodeValue_Text("Replacement", self, ""));
	
	newOutput(0, nodeValue_Output("Results", self, VALUE_TYPE.text, ""));
	
	input_display_list = [
		0, 1, 2, 
	];
	
	static processData = function(_output, _data, _index = 0) { 
		var str = _data[0];
		var reg = _data[1];
		var rep = _data[2];
		
		return RegexReplace(str, reg, rep);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var str  = outputs[0].getValue();
		var bbox = drawGetBbox(xx, yy, _s);
		
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		draw_text_bbox(bbox, str);
	}
}