function Node_Area(_x, _y, _group = -1) : Node_Processor(_x, _y, _group) constructor {
	name = "Area";
	color = COLORS.node_blend_number;
	previewable   = false;
	
	w = 96;
	
	
	newInput(| 0, nodeValue_vector(0, "Postion", self, [ 0, 0 ] ))
		.setVisible(true, true);
	newInput(| 1, nodeValue_vector(1, "Size", self, [ 16, 16 ] ))
		.setVisible(true, true);
	
	newInput(| 2, nodeValue(2, "Shape", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, AREA_SHAPE.rectangle ))
		.setDisplay(VALUE_DISPLAY.enum_scroll, ["Rectangle", "Elipse"]);
	
	outputs[| 0] = nodeValue_Output(0, "Area", self, VALUE_TYPE.float, [ 0, 0, 0, 0, AREA_SHAPE.rectangle ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _pos	= inputs[| 0].getValue();
		var _span	= inputs[| 1].getValue();
		var _shape	= inputs[| 2].getValue();
		var px = _x + _pos[0] * _s;
		var py = _y + _pos[1] * _s;
		var ex = _span[0] * _s;
		var ey = _span[1] * _s;
		
		draw_set_color(COLORS._main_accent);
		switch(_shape) {
			case AREA_SHAPE.rectangle :
				draw_rectangle(px - ex, py - ey, px + ex, py + ey, true);
				break;
			case AREA_SHAPE.elipse :
				draw_ellipse(px - ex, py - ey, px + ex, py + ey, true);
				break;
		}
		
		inputs[| 0].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny);
		inputs[| 1].drawOverlay(active, px, py, _s, _mx, _my, _snx, _sny);
	}
	
	function process_data(_output, _data, index = 0) { 
		return [_data[0][0], _data[0][1], _data[1][0], _data[1][1], _data[2]];
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(THEME.node_draw_area, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}