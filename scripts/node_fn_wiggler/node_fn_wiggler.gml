function Node_Wiggler(_x, _y, _group = noone) : Node_Fn(_x, _y, _group) constructor {
	name = "Wiggler";
	
	newInput(inl + 0, nodeValue_Vec2("Range", self, [ 0, 1 ]));
	
	newInput(inl + 1, nodeValue_Int("Frequency", self, 4 ))
		.setDisplay(VALUE_DISPLAY.slider, { range: [1, 32, 0.1] });
	
	newInput(inl + 2, nodeValueSeed(self));
	
	newInput(inl + 3, nodeValue_Toggle("Clip", self, 0b11 , { data : [ "Start", "End" ] }));
	
	array_append(input_display_list, [
		["Wiggle",	false], inl + 2, inl + 0, inl + 1, inl + 3, 
	]);
	
	range_min    = 0;
	range_max    = 0;
	wiggle_seed  = 0;
	wiggle_freq  = 1;
	
	clip_start = true;
	clip_end   = true;
	
	static __fnEval = function(_x = 0) {
		var _ed = TOTAL_FRAMES;
		_x *= _ed;
		
		var sdMin = floor(_x / wiggle_freq) * wiggle_freq;
		var sdMax = min(_ed, sdMin + wiggle_freq);
		
		var _x0 = (clip_start && sdMin <= 0)?    0.5 : random1D(PROJECT.seed + wiggle_seed + sdMin);
		var _x1 = (clip_end && sdMax >= _ed)?	 0.5 : random1D(PROJECT.seed + wiggle_seed + sdMax);
		
		var t = (_x - sdMin) / (sdMax - sdMin);
		    t = -(cos(pi * t) - 1) / 2;
		    
		var _lrp = lerp(_x0, _x1, t);
		
		return lerp(range_min, range_max, _lrp);
	}
	
	static processData = function(_output, _data, _output_index, _array_index = 0) {
		var ran     = _data[inl + 0];
		range_min   = array_safe_get_fast(ran, 0);
		range_max   = array_safe_get_fast(ran, 1);
		
		var fre     = _data[inl + 1];
		wiggle_freq = fre == 0? 1 : max(1, TOTAL_FRAMES / fre);
		wiggle_seed = _data[inl + 2];
		
		var clp     = _data[inl + 3];
		clip_start  = bool(clp & 0b01);
		clip_end    = bool(clp & 0b10);
		
		var val = __fnEval(CURRENT_FRAME / TOTAL_FRAMES);
		text_display = val;
		
		return val;
	}
}