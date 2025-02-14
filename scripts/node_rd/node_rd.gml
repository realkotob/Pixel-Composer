function Node_RD(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Reaction Diffusion";
	
	newInput(0, nodeValue_Surface("Seed", self));
	
	newInput(1, nodeValue_Float("Kill rate", self, 0.058))
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 0, 0.1, 0.001] })
		.setMappable(8);
	
	newInput(2, nodeValue_Float("Feed rate", self, 0.043))
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 0, 0.1, 0.001] })
		.setMappable(9);
	
	newInput(3, nodeValue_Float("Timestep", self, 1))
		.setMappable(10);
	
	newInput(4, nodeValue_Int("Iteration", self, 16));
	
	newInput(5, nodeValue_Float("Diffusion A", self, 1.))
		.setDisplay(VALUE_DISPLAY.slider)
		.setMappable(11);
	
	newInput(6, nodeValue_Float("Diffusion B", self, .2))
		.setDisplay(VALUE_DISPLAY.slider)
		.setMappable(12);
	
	newInput(7, nodeValue_Surface("Add B", self));
	
	//////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	newInput(8, nodeValue_Surface("Kill map", self))
		.setVisible(false, false);
	
	newInput(9, nodeValue_Surface("Feed map", self))
		.setVisible(false, false);
	
	newInput(10, nodeValue_Surface("Time map", self))
		.setVisible(false, false);
	
	newInput(11, nodeValue_Surface("DfA map", self))
		.setVisible(false, false);
	
	newInput(12, nodeValue_Surface("DfB map", self))
		.setVisible(false, false);
	
	//////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	newInput(13, nodeValue_Float("Diffusion", self, 1.))
		.setDisplay(VALUE_DISPLAY.slider)
		
	newOutput(0, nodeValue_Output("Reacted", self, VALUE_TYPE.surface, noone));
	
	newOutput(1, nodeValue_Output("Rendered", self, VALUE_TYPE.surface, noone));
	
	preview_channel = 1;
	
	input_display_list = [ 
		["Surfaces",	false], 0, 7, 
		["Diffusion",	false], 13, 5, 11, 6, 12, 
		["Paramaters",	false], 1, 8, 2, 9, 
		["Simulation",	false], 3, 10, 4, 
	];
	
	attribute_surface_depth();
		
	temp_surface = [ surface_create(1, 1), surface_create(1, 1) ];
		
	static step = function() { #region
		inputs[1].mappableStep();
		inputs[2].mappableStep();
		inputs[3].mappableStep();
		inputs[5].mappableStep();
		inputs[6].mappableStep();
	} #endregion
	
	static update = function() {
		var _surf = getInputData(0);
		var _k    = getInputData(1);
		var _f    = getInputData(2);
		var _dt   = getInputData(3);
		var _it   = getInputData(4);
		var _dd   = getInputData(13);
		var _da   = getInputData(5);
		var _db   = getInputData(6);
		var _b    = getInputData(7);
		
		var _outp = outputs[0].getValue();
		var _rend = outputs[1].getValue();
		
		var _sw = surface_get_width_safe(_surf);
		var _sh = surface_get_height_safe(_surf);
		
		_outp           = surface_verify(_outp, _sw, _sh);
		_rend           = surface_verify(_rend, _sw, _sh);
		temp_surface[0] = surface_verify(temp_surface[0], _sw, _sh);
		temp_surface[1] = surface_verify(temp_surface[1], _sw, _sh);
		
		surface_set_shader(temp_surface[0], sh_rd_convert);
			draw_surface_safe(_surf);
		surface_reset_shader();
		
		if(is_surface(_b)) {
			surface_set_target(temp_surface[0]);
				gpu_set_colorwriteenable(0, 1, 0, 0);
				BLEND_ADD
				draw_surface_safe(_b);
				BLEND_NORMAL
				gpu_set_colorwriteenable(1, 1, 1, 1);
			surface_reset_target();
		}
		
		var _ind = 0;
		
		repeat(_it) {
			surface_set_shader(temp_surface[!_ind], sh_rd_propagate);
				shader_set_f("dimension", _sw, _sh);
				shader_set_f_map("k",  _k , getInputData( 8), inputs[1]);
				shader_set_f_map("f",  _f , getInputData( 9), inputs[2]);
				shader_set_f_map("dt", _dt, getInputData(10), inputs[3]);
				
				shader_set_f("dd", _dd);
				shader_set_f_map("da", _da, getInputData(11), inputs[5]);
				shader_set_f_map("db", _db, getInputData(12), inputs[6]);
				
				draw_surface_safe(temp_surface[_ind]);
			surface_reset_shader();
			
			_ind = !_ind;
		}
		
		surface_set_shader(_outp);
			draw_surface_safe(temp_surface[_ind]);
		surface_reset_shader();
		
		surface_set_shader(_rend, sh_rd_render);
			draw_surface_safe(_surf);
		surface_reset_shader();
		
		outputs[0].setValue(_outp);
		outputs[1].setValue(_rend);
	}
}