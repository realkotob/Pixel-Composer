function Node_Transform_Array(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name  = "Transform Array";
	color = COLORS.node_blend_number;
	
	setDimension(96, 48);
	
	newInput(0, nodeValue_Vec2("Postion", self, [ 0, 0 ] ))
		.setVisible(true, true);
		
	newInput(1, nodeValue_Rotation("Rotation", self, 0))
		.setVisible(true, true);
	
	newInput(2, nodeValue_Vec2("Scale", self, [ 1, 1 ] ))
		.setVisible(true, true);
	
	newOutput(0, nodeValue_Output("Transform", self, VALUE_TYPE.float, [ 0, 0, 0, 1, 1 ]))
		.setDisplay(VALUE_DISPLAY.vector);
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		PROCESSOR_OVERLAY_CHECK
		
		var pos = current_data[0];
		var px  = _x + pos[0] * _s;
		var py  = _y + pos[1] * _s;
		
		inputs[0].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
		inputs[1].drawOverlay(hover, active, px, py, _s, _mx, _my, _snx, _sny);
	}
	
	static processData = function(_output, _data, _output_index, _array_index = 0) {  
		return [_data[0][0], _data[0][1], _data[1], _data[2][0], _data[2][0]];
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_transform_array, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}