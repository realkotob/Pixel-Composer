function Node_Color_to_RGB(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Color RGB";
	setDimension(96, 48);
	
	newInput(0, nodeValue_Color("Color", self, cola(c_white)))
		.setVisible(true, true);
	
	newOutput(0, nodeValue_Output("Red",   self, VALUE_TYPE.float, 0));
	newOutput(1, nodeValue_Output("Green", self, VALUE_TYPE.float, 0));
	newOutput(2, nodeValue_Output("Blue",  self, VALUE_TYPE.float, 0));
	
	static processData = function(_outData, _data, _output_index, _array_index = 0) {  
		var _c = _data[0];
		
		if(!is_numeric(_c)) return _outData;
		
		_outData[0] = _color_get_red(_c);
		_outData[1] = _color_get_green(_c);
		_outData[2] = _color_get_blue(_c);
		
		return _outData;
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_set_text(f_sdf, fa_right, fa_center, COLORS._main_text);
		
		for(var i = 0; i < array_length(outputs); i++) {
			var val = outputs[i];
			if(!val.isVisible()) continue;
			
			var tx = bbox.x1 -  8 * _s;
			var ty = val.y;
			
			draw_text_ext_add(tx, ty, string_char_at(val.name, 1), -1, w * _s, _s * .25);
		}
	}
	
}