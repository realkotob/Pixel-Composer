#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Noise_Strand", "Mode > Toggle", "M", MOD_KEY.none, function() /*=>*/ { PANEL_GRAPH_FOCUS_STR _n.inputs[10].setValue((_n.inputs[10].getValue() + 1) % 2); });
		addHotkey("Node_Noise_Strand", "Axis > Toggle", "A", MOD_KEY.none, function() /*=>*/ { PANEL_GRAPH_FOCUS_STR _n.inputs[ 9].setValue((_n.inputs[ 9].getValue() + 1) % 2); });
	});
#endregion

function Node_Noise_Strand(_x, _y, _group = noone) : Node_Shader_Generator(_x, _y, _group) constructor {
	name   = "Strand Noise";
	shader = sh_noise_strand;
	
	newInput(1, nodeValue_Vec2("Position", self, [ 0, 0 ]))
		.setUnitRef(function(index) { return getDimension(index); });
		addShaderProp(SHADER_UNIFORM.float, "position");
		
	newInput(2, nodeValue_Float("Density", self, 0.5 ))
		.setDisplay(VALUE_DISPLAY.slider);
		addShaderProp(SHADER_UNIFORM.float, "density");
		
	newInput(3, nodeValueSeed(self));
		addShaderProp(SHADER_UNIFORM.float, "seed");
				
	newInput(4, nodeValue_Float("Slope", self, 0.5 ))
		.setDisplay(VALUE_DISPLAY.slider);
		addShaderProp(SHADER_UNIFORM.float, "slope");
				
	newInput(5, nodeValue_Slider_Range("Curve", self, [ 0, 0 ] , { range: [ 0, 4, 0.01 ] }));
		addShaderProp(SHADER_UNIFORM.float, "curve");
				
	newInput(6, nodeValue_Float("Curve scale", self, 1 ));
		addShaderProp(SHADER_UNIFORM.float, "curveDetail");
		
	newInput(7, nodeValue_Float("Thickness", self, 0 ))
		.setDisplay(VALUE_DISPLAY.slider);
		addShaderProp(SHADER_UNIFORM.float, "thickness");
		
	newInput(8, nodeValue_Float("Curve shift", self, 0 ));
		addShaderProp(SHADER_UNIFORM.float, "curveShift");
		
	newInput(9, nodeValue_Enum_Button("Axis", self,  0 , [ "x", "y" ] ));
		addShaderProp(SHADER_UNIFORM.integer, "axis");
		
	newInput(10, nodeValue_Enum_Button("Mode", self,  0 , [ "Line", "Area" ] ));
		addShaderProp(SHADER_UNIFORM.integer, "mode");
		
	newInput(11, nodeValue_Slider_Range("Opacity", self, [ 0., 1. ] ));
		addShaderProp(SHADER_UNIFORM.float, "alpha");
		
	input_display_list = [ 3, 
		["Output", 	 true],	0, 
		["Noise",	false],	9, 1, 2, 4, 
		["Curve",	false],	5, 6, 8, 
		["Render",	false], 10, 7, 11, 
	];
}