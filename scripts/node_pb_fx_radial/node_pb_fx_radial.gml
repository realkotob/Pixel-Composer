function Node_PB_Fx_Radial(_x, _y, _group = noone) : Node_PB_Fx(_x, _y, _group) constructor {
	name = "Radial";
	
	newInput(1, nodeValue_Int("Amount", self, 4 ))
		.setVisible(true, true);
		
	input_display_list = [ 0, 
		["Effect",	false], 1,
	];
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _pbox = _data[0];
		if(_pbox == noone) return _pbox;
		if(!is_surface(_pbox.content)) return _pbox;
		
		var _nbox = _pbox.clone();
		
		var _amo  = _data[1];
		
		surface_set_shader(_nbox.content);
			for( var i = 0; i < _amo; i++ ) {
				var aa = i / _amo * 360;
				var p  = point_rotate(0, 0, surface_get_width_safe(_pbox.content) / 2, surface_get_height_safe(_pbox.content) / 2, aa);
				
				draw_surface_ext_safe(_pbox.content, p[0], p[1],,, aa);
			}
		surface_reset_shader();
		
		return _nbox;
	}
}