function Node_Lerp(_x, _y, _group = -1) : Node_Value_Processor(_x, _y, _group) constructor {
	name		= "Lerp";
	color		= COLORS.node_blend_number;
	previewable = false;
	
	w = 96;
	min_h = 0;
	
	inputs[| 0] = nodeValue(1, "a", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0);
	inputs[| 1] = nodeValue(2, "b", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0);
	inputs[| 2] = nodeValue(3, "Progress", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider_range, [0, 1, .01]);
	
	outputs[| 0] = nodeValue(0, "Result", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, 0);
	
	function process_value_data(_data, index = 0) { 
		return lerp(_data[0], _data[1], _data[2]);
	}
	
	function onDrawNode(xx, yy, _mx, _my, _s) {
		draw_set_text(f_h5, fa_center, fa_center, COLORS._main_text);
		var str = "lerp";
		var _ss = min((w - 8) * _s / string_width(str), (h - 8) * _s / string_height(str));
		
		draw_text_transformed(xx + w / 2 * _s, yy + 10 + h / 2 * _s, str, _ss, _ss, 0);
	}
}