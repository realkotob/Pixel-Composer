function Node_Counter(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Frame Index";
	update_on_frame = true;
	previewable = false;
	
	w = 96;
	
	inputs[| 0] = nodeValue("Start", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1);
	
	inputs[| 1] = nodeValue("Speed", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1);
	
	inputs[| 2] = nodeValue("Mode", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0, @"Counting mode
    - Frame count: Count value up/down per frame.
    - Animation progress: Count from 0 (first frame) to 1 (last frame). ")
		.setDisplay(VALUE_DISPLAY.enum_scroll, ["Frame count", "Animation progress"])
		.rejectArray();
	
	outputs[| 0] = nodeValue("Value", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, 0);
	
	input_display_list = [
		2, 0, 1
	];
	
	static step = function() {
		var mode = getInputData(2);
		inputs[| 0].setVisible(mode == 0);
	}
	
	static processData = function(_output, _data, _output_index, _array_index = 0) {  
		var time = CURRENT_FRAME;
		var mode = _data[2];
		var val = 0;
		
		switch(mode) {
			case 0 : val = _data[0] + time * _data[1]; break;
			case 1 : val = time / (TOTAL_FRAMES - 1) * _data[1]; break;
		}
		
		return val;
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		var str = outputs[| 0].getValue();
		
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		var ss	= string_scale(str, bbox.w, bbox.h);
		draw_text_transformed(bbox.xc, bbox.yc, str, ss, ss, 0);
	}
}