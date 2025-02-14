function Node_Array_Range(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Array Range";
	setDimension(96, 48);
	
	newInput(0, nodeValue_Float("Start", self, 0))
		.rejectArray();
	
	newInput(1, nodeValue_Float("End", self, 10))
		.rejectArray();
	
	newInput(2, nodeValue_Float("Step", self, 1))
		.rejectArray();
	
	newOutput(0, nodeValue_Output("Array", self, VALUE_TYPE.float, []));
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var st  = _data[0];
		var ed  = _data[1];
		var stp = _data[2];
		
		if(st == ed)
			return array_create(abs(stp), st);
		
		stp = abs(stp) * sign(ed - st);
		
		var _amo = floor(abs((ed - st) / stp));
		var  arr = array_create(_amo);
		
		for( var i = 0; i < _amo; i++ )
			arr[i] = st + i * stp;
		
		return arr;
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		var str = getSingleValue(0);
		var edd = getSingleValue(1);
		var stp = getSingleValue(2);
		var arr = outputs[0].getValue();
		
		var str	= "";
		switch(array_length(arr)) {
			case 0 : str = $"[]" break;
			case 1 : 
			case 2 : 
			case 3 : str = $"{arr}" break;
			
			default : str = $"[{arr[0]}, {arr[1]}, ..., {array_safe_get(arr, -1,, ARRAY_OVERFLOW.loop)}]"; break;
		}
		
		var bbox = drawGetBbox(xx, yy, _s);
		draw_text_bbox(bbox, str);
	}
}