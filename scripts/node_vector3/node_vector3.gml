function Node_Vector3(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name  = "Vector3";
	color = COLORS.node_blend_number;
	setDimension(96, 32 + 24 * 3);
	
	newInput(0, nodeValue_Float("x", self, 0))
		.setVisible(true, true);
		
	newInput(1, nodeValue_Float("y", self, 0))
		.setVisible(true, true);
		
	newInput(2, nodeValue_Float("z", self, 0))
		.setVisible(true, true);
	
	newInput(3, nodeValue_Bool("Integer", self, false));
	
	////////////////////////////////////////////////////////////////////////////////////////////////////
	
	newOutput(0, nodeValue_Output("Vector", self, VALUE_TYPE.float, [ 0, 0, 0 ]))
		.setDisplay(VALUE_DISPLAY.vector);
	
	newOutput(1, nodeValue_Output("x", self, VALUE_TYPE.float, 0))
		
	newOutput(2, nodeValue_Output("y", self, VALUE_TYPE.float, 0))
	
	newOutput(3, nodeValue_Output("z", self, VALUE_TYPE.float, 0))
		
	input_display_list = [ 0, 1, 2, 3, 
	];
	
	static step = function() {
		var int = getInputData(3);
		for( var i = 0; i < 3; i++ )
			inputs[i].setType(int? VALUE_TYPE.integer : VALUE_TYPE.float);
		
		outputs[0].setType(int? VALUE_TYPE.integer : VALUE_TYPE.float);
	}
	
	static processData = function(_outData, _data, _output_index, _array_index = 0) {
		var _x   = _data[0];
		var _y   = _data[1];
		var _z   = _data[2];
		var _int = _data[3];
		
		_outData[0][0] = _int? round(_x) : _x;
		_outData[0][1] = _int? round(_y) : _y;
		_outData[0][2] = _int? round(_z) : _z;
		
		_outData[1] = _outData[0][0];
		_outData[2] = _outData[0][1];
		_outData[3] = _outData[0][2];
		
		return _outData;
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		var vec = getSingleValue(0,, true);
		var v0 = array_safe_get_fast(vec, 0);
		var v1 = array_safe_get_fast(vec, 1);
		var v2 = array_safe_get_fast(vec, 2);

		var str	= $"{v0}\n{v1}\n{v2}";
		
		var bbox = drawGetBbox(xx, yy, _s);
		var ss	= string_scale(str, bbox.w, bbox.h);
		draw_text_transformed(bbox.xc, bbox.yc, str, ss, ss, 0);
	}
}