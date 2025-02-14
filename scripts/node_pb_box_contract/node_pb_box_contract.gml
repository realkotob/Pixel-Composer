function Node_PB_Box_Contract(_x, _y, _group = noone) : Node_PB_Box(_x, _y, _group) constructor {
	name = "Split";
	batch_output = false;
	
	newInput(1, nodeValue("pBox", self, CONNECT_TYPE.input, VALUE_TYPE.pbBox, noone ))
		.setVisible(true, true);
		
	newInput(2, nodeValue_Enum_Scroll("Type", self,  0 , [ "Ratio", "Fix" ]));
	
	newInput(3, nodeValue_Float("Ratio", self, 0.5 ))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(4, nodeValue_Int("Fix Width", self, 8 ))
	
	newInput(5, nodeValue_Enum_Button("Axis", self,  0 , [ "X", "Y" ]));
	
	newOutput(0, nodeValue_Output("pBox Center", self, VALUE_TYPE.pbBox, noone ));
	
	newOutput(1, nodeValue_Output("pBox Side", self, VALUE_TYPE.pbBox, noone ));
	
	input_display_list = [ 0, 1,
		["Split",	false], 5, 2, 3, 4,
	]
	
	static step = function() {
		if(array_empty(current_data)) return;
		
		var _typ = current_data[2];
		var _axs = current_data[5];
		
		inputs[3].setVisible(_typ == 0);
		inputs[4].setVisible(_typ != 0);
		
		if(_axs == 0)	inputs[4].name = "Fix Width";
		else			inputs[4].name = "Fix Height";
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _layr = _data[0];
		var _pbox = _data[1];
		var _type = _data[2];
		var _rati = _data[3];
		var _fixx = _data[4];
		var _axis = _data[5];
		
		if(_pbox == noone) return noone;
		
		if(_axis == 0) {
			var _w;
			
			switch(_type) {
				case 0 : _w = round(_pbox.w * _rati);	break;
				case 1 : _w = _fixx;					break;
			}
				
			if(_output_index == 0) {
				var _nbox = _pbox.clone();
				_nbox.layer += _layr;
				
				_nbox.x += (_nbox.w - _w) / 2;
				_nbox.w  = _w;
				
				_nbox.content = surface_stretch(_nbox.content, _nbox.w, _nbox.h);
			} else if(_output_index == 1) {
				_pbox = [ _pbox.clone(), _pbox.clone() ];
				
				_pbox[0].content = noone;
				_pbox[1].content = noone;
				
				_pbox[0].layer += _layr;
				_pbox[1].layer += _layr;
				
				_pbox[1].x += _w + (_pbox[0].w - _w) / 2;
				
				_pbox[0].w = (_pbox[0].w - _w) / 2;
				_pbox[1].w = (_pbox[1].w - _w) / 2;
				
				_pbox[1].mirror_h = !_pbox[1].mirror_h;
			}
		} else {
			var _h;
			
			switch(_type) {
				case 0 : _h = round(_pbox.h * _rati);	break;
				case 1 : _h = _fixx;					break;
			}
			
			if(_output_index == 0) {
				var _nbox = _pbox.clone();
				_nbox.layer += _layr;
			
				_nbox.y += (_nbox.h - _h) / 2;
				_nbox.h = _h;
				
				_nbox.content = surface_stretch(_nbox.content, _nbox.w, _nbox.h);
			} else if(_output_index == 1) {
				_pbox = [ _pbox.clone(), _pbox.clone() ];
				
				_pbox[0].content = noone;
				_pbox[1].content = noone;
				
				_pbox[0].layer += _layr;
				_pbox[1].layer += _layr;
				
				_pbox[1].y += _h + (_pbox[0].h - _h) / 2;
				
				_pbox[0].h = (_pbox[0].h - _h) / 2;
				_pbox[1].h = (_pbox[1].h - _h) / 2;
				
				_pbox[1].mirror_v = !_pbox[1].mirror_v;
			}
		}
		
		return _pbox;
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var _axs = current_data[5];
		var bbox = drawGetBbox(xx, yy, _s)
			.toSquare()
			.pad(8);
		
		draw_set_color(c_white);
		draw_rectangle_border(bbox.x0, bbox.y0, bbox.x1, bbox.y1, 2);
		
		if(_axs == 0) {
			draw_line(bbox.x0 + 16, bbox.y0, bbox.x0 + 16, bbox.y1);
			draw_line(bbox.x1 - 16, bbox.y0, bbox.x1 - 16, bbox.y1);
		} else {
			draw_line(bbox.x0, bbox.y0 + 16, bbox.x1, bbox.y0 + 16);
			draw_line(bbox.x0, bbox.y1 - 16, bbox.x1, bbox.y1 - 16);
		}
	}
}