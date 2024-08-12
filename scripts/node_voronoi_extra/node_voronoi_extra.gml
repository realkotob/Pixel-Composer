function Node_Voronoi_Extra(_x, _y, _group = noone) : Node_Shader_Generator(_x, _y, _group) constructor {
	name   = "Extra Voronoi";
	shader = sh_voronoi_extra;
	
	inputs[1] = nodeValue_Vec2("Position", self, [ 0, 0 ])
		.setUnitRef(function(index) { return getDimension(index); });
		addShaderProp(SHADER_UNIFORM.float, "position");
		
	inputs[2] = nodeValue_Vec2("Scale", self, [ 4, 4 ]);
		addShaderProp(SHADER_UNIFORM.float, "scale");
				
	inputs[3] = nodeValue_Float("Seed", self, seed_random(6))
		.setDisplay(VALUE_DISPLAY._default, { side_button : button(function() { randomize(); inputs[3].setValue(seed_random(6)); }).setIcon(THEME.icon_random, 0, COLORS._main_icon) });
		addShaderProp(SHADER_UNIFORM.float, "seed");
				
	inputs[4] = nodeValue_Float("Progress", self, 0)
		addShaderProp(SHADER_UNIFORM.float, "progress");
				
	inputs[5] = nodeValue_Enum_Scroll("Mode", self,  0, [ "Block", "Triangle" ]);
		addShaderProp(SHADER_UNIFORM.integer, "mode");
	
	inputs[6] = nodeValue_Float("Parameter A", self, 0)
		.setDisplay(VALUE_DISPLAY.slider, { range: [ -1, 1, 0.01 ] });
		addShaderProp(SHADER_UNIFORM.float, "paramA");
		
	inputs[7] = nodeValue_Rotation("Rotation", self, 0);
		addShaderProp(SHADER_UNIFORM.float, "rotation");
			
	input_display_list = [
		["Output", 	 true],	0, 
		["Noise",	false],	5, 1, 7, 2, 4, 6, 
	];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _hov = false;
		var  hv  = inputs[1].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny); _hov |= hv;
		
		return _hov;
	}
}