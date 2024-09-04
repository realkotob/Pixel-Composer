function Node_Alpha_Grey(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Alpha to Grey";
	
	newInput(0, nodeValue_Surface("Surface in", self));
	
	newInput(1, nodeValue_Bool("Active", self, true));
		active_index = 1;
	
	newOutput(0, nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone));
	
	input_display_list = [ 1, 
		["Surfaces",	 false], 0, 
	]
	
	attribute_surface_depth();
	
	static processData = function(_outSurf, _data, _output_index, _array_index) { #region
		surface_set_shader(_outSurf, sh_alpha_grey);
			draw_surface_safe(_data[0]);
		surface_reset_shader();
		
		return _outSurf;
	} #endregion
}