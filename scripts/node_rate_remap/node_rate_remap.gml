function Node_Rate_Remap(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Rate Remap";
	use_cache = CACHE_USE.manual;
	
	newInput(0, nodeValue_Surface("Surface", self));
	
	newInput(1, nodeValue_Float("Framerate", self, 10))
		.setValidator(VV_min(1));
	
	newInput(2, nodeValue_Bool("Active", self, true));
		active_index = 2;
	
	newOutput(0, nodeValue_Output("Surface", self, VALUE_TYPE.surface, noone));
	
	input_display_list = [ 2,
		["Remap",  false], 0, 1
	];
	
	static processData = function(_output, _data, _output_index, _array_index = 0) {  
		var _surf = _data[0];
		var _rate = _data[1];
		var _time = CURRENT_FRAME;
		var _step = PROJECT.animator.framerate / _rate;
		var _targ = floor(_time / _step) * _step;
		
		cacheCurrentFrameIndex(_array_index, _surf);
		return getCacheFrameIndex(_array_index, _targ);
	}
}