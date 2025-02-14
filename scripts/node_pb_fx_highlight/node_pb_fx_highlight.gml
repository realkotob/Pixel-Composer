function Node_PB_Fx_Highlight(_x, _y, _group = noone) : Node_PB_Fx(_x, _y, _group) constructor {
	name = "Highlight";
	
	newInput(1, nodeValue_Int("Highlight Area", self, array_create(9) ))
		.setDisplay(VALUE_DISPLAY.matrix, { size: 3 });
		
	newInput(2, nodeValue_Color("Light Color", self, cola(c_white) ));
		
	newInput(3, nodeValue_Color("Shadow Color", self, cola(c_black) ));
		
	newInput(4, nodeValue_Float("Roughness", self, 0 ))
		.setDisplay(VALUE_DISPLAY.slider);
		
	newInput(5, nodeValue_Float("Roughness Scale", self, 1 ));
		
	newInput(6, nodeValueSeed(self));
	
	holding_side = noone;
	
	side_renderer = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus) {
		var _size  = 32;
		var _space = 8;
		var ww     = (_size * 3) + (_space * 2); 
		var hh     = ww + ui(16);
		
		var _x0 = _x + _w / 2 - ww / 2;
		var _y0 = _y + ui(8);
		
		var _side  = getInputData(1);
		
		if(holding_side != noone && mouse_release(mb_left))
			holding_side = noone;
		
		for( var i = 0; i < 3; i++ ) 
		for( var j = 0; j < 3; j++ ) {
			var ind = i * 3 + j;
			var _sx = _x0 + j * (_space + _size);
			var _sy = _y0 + i * (_space + _size);
			
			if(_hover && point_in_rectangle(_m[0], _m[1], _sx, _sy, _sx + _size, _sy + _size)) {
				draw_sprite_stretched(THEME.button_def, 1, _sx, _sy, _size, _size);
				
				if(mouse_click(mb_left, _focus)) {
					draw_sprite_stretched(THEME.button_def, 2, _sx, _sy, _size, _size);
					
					if(holding_side != noone) {
						_side[ind] = holding_side;
						inputs[1].setValue(_side);
					}
				}
					
				if(mouse_press(mb_left, _focus)) {
					if(ind == 4)
						_side[ind] = !_side[ind];
					else
						_side[ind] = (_side[ind] + 2) % 3 - 1;
					inputs[1].setValue(_side);
					
					holding_side = _side[ind];
				}
			} else
				draw_sprite_stretched(THEME.button_def, 0, _sx, _sy, _size, _size);
			
			if(ind == 4) {
				if(_side[ind]) draw_sprite_stretched_ext(THEME.color_picker_box, 1, _sx + ui(2), _sy + ui(2), _size - ui(4), _size - ui(4), COLORS._main_accent, 1);
			} else {
				switch(_side[ind]) {
					case  1 : draw_sprite_stretched_ext(THEME.color_picker_box, 1, _sx + ui(2), _sy + ui(2), _size - ui(4), _size - ui(4), c_white, 1); break;
					case -1 : draw_sprite_stretched_ext(THEME.color_picker_box, 1, _sx + ui(2), _sy + ui(2), _size - ui(4), _size - ui(4), c_black, 1); break;
				}
			}
		}
		
		return hh;
	});
	
	input_display_list = [ 0, 
		["Effect",		false], side_renderer, 2, 3, 
		["Roughness",	false], 4, 5, 6, 
	];
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _pbox = _data[0];
		if(_pbox == noone) return _pbox;
		if(!is_surface(_pbox.content)) return _pbox;
		
		var _nbox = _pbox.clone();
		
		var _high = _data[1];
		var _chig = _data[2];
		var _csha = _data[3];
		var _roug = _data[4];
		var _rSca = _data[5];
		var _seed = _data[6];
		
		surface_set_shader(_nbox.content, sh_pb_highlight);
			shader_set_dim(, _pbox.content);
			shader_set_i("sides", _high);
			
			shader_set_color("highlightColor", _chig);
			shader_set_color("shadowColor", _csha);
			shader_set_f("roughness", _roug);
			shader_set_f("roughScale", _rSca);
			shader_set_f("seed", _seed);
			DRAW_CLEAR
			
			draw_surface_safe(_pbox.content);
		surface_reset_shader();
		
		return _nbox;
	}
}