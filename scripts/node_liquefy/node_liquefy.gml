enum LIQUEFY_TYPE {
	push,
	twirl,
	pinch,
	bloat,
}

function Node_Liquefy(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Liquefy";
	
	newInput(0, nodeValue_Surface("Surface In", self));
	
	newInput(1, nodeValue_Bool("Active", self, true));
	active_index = 1;
	
	newInput(2, nodeValue_Surface("Mask", self));
	
	newInput(3, nodeValue_Float("Mix", self, 1))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(4, nodeValue_Toggle("Channel", self, 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	__init_mask_modifier(2); // inputs 5, 6, 
	
	newOutput(0, nodeValue_Output("Surface Out", self, VALUE_TYPE.surface, noone));
	
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	typeList = [ 
		new scrollItem("Push",  s_node_liquefy_type, 0), 
		new scrollItem("Twirl", s_node_liquefy_type, 1), 
		new scrollItem("Pinch", s_node_liquefy_type, 2), 
		new scrollItem("Bloat", s_node_liquefy_type, 3), 
	];
	typeListStr = array_create_ext(array_length(typeList), function(i) /*=>*/ {return typeList[i].name});
	
	static createNewInput = function() {
		var _index = array_length(inputs);
		dynamic_input_inspecting = getInputAmount();
		
		newInput(_index + 0, nodeValue_Enum_Scroll("Type", self, 0, typeList));
		
		newInput(_index + 1, nodeValue_Vec2("Position", self, [ 0, 0 ]))
			.setUnitRef(function(index) /*=>*/ {return getDimension(index)}, VALUE_UNIT.reference);
		
		newInput(_index + 2, nodeValue_Vec2("Position 2", self, [ 1, 0 ])) // push
			.setUnitRef(function(index) /*=>*/ {return getDimension(index)}, VALUE_UNIT.reference);
		
		newInput(_index + 3, nodeValue_Float("Radius", self, 8));
		inputs[_index + 3].overlay_text_valign = fa_bottom;
		
		newInput(_index + 4, nodeValue_Float("Intensity", self, 0.1))
			.setDisplay(VALUE_DISPLAY.slider, { range: [ 0, 4, 0.01] });
		
		newInput(_index + 5, nodeValue_Float("Falloff", self, 0));
		
		newInput(_index + 6, nodeValue_Curve("Falloff Curve", self, CURVE_DEF_10));
		
		newInput(_index + 7, nodeValue_Float("Push", self, 0.1))
			.setDisplay(VALUE_DISPLAY.slider, { range: [ 0, 4, 0.01] });
		
		newInput(_index + 8, nodeValue_PathNode("Push path", self, noone))
		
		newInput(_index + 9, nodeValue_Int("Push resolution", self, 16));
		
		newInput(_index + 10, nodeValue_Float("Radius 2", self, 8));
		inputs[_index + 10].overlay_text_valign = fa_bottom;
		
		refreshDynamicDisplay();
		return inputs[_index];
	} 
	
	effect_renderer = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus) {
		
		var bs = ui(24);
		var bx = _x + ui(20);
		var by = _y;
		if(buttonInstant(THEME.button_hide_fill, bx, by, bs, bs, _m, _hover, _focus, "", THEME.add_16, 0, COLORS._main_value_positive) == 2) {
			createNewInput();
			triggerRender();
		}
			
		var amo = getInputAmount();
		var lh  = ui(28);
		var _h  = ui(12) + lh * amo;
		var yy  = _y + bs + ui(4);
		
		var del_light = -1;
		draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _x, yy, _w, _h, COLORS.node_composite_bg_blend, 1);
		
		for(var i = 0; i < amo; i++) {
			var _x0 = _x + ui(24);
			var _x1 = _x + _w - ui(16);
			var _yy = ui(6) + yy + i * lh + lh / 2;
			
			var _ind = input_fix_len + i * data_length;
			var _typ = current_data[_ind + 0];
			var _col = COLORS._main_icon;
			
			var tc   = i == dynamic_input_inspecting? COLORS._main_text_accent : COLORS._main_icon;
			var hov  = _hover && point_in_rectangle(_m[0], _m[1], _x0, _yy - lh / 2, _x1, _yy + lh / 2 - 1);
			
			if(hov && _m[0] < _x1 - ui(32)) {
				tc = COLORS._main_text;
				
				if(mouse_press(mb_left, _focus)) {
					dynamic_input_inspecting = i;
					refreshDynamicDisplay();
				}
			}
			
			draw_sprite_ext(s_node_liquefy_type, _typ, _x0 + ui(8), _yy, 1, 1, 0, _col, .5 + .5 * (i == dynamic_input_inspecting));
			
			draw_set_text(f_p2, fa_left, fa_center, tc);
			draw_text_add(_x0 + ui(28), _yy, typeListStr[_typ]);
			
			if(amo > 1) {
				var bs = ui(24);
				var bx = _x1 - bs;
				var by = _yy - bs / 2;
				if(buttonInstant(THEME.button_hide_fill, bx, by, bs, bs, _m, _hover, _focus, "", THEME.minus_16, 0, hov? COLORS._main_value_negative : COLORS._main_icon) == 2) 
					del_light = i;	
			}
		}
		
		if(del_light > -1) 
			deleteDynamicInput(del_light);
		
		return ui(32) + _h;
	});
	
	input_display_dynamic = [ 0, 
		["Regions", false], 1, 2, 8, 9, 3, 10, 5, 
		["Effect",  false], 4, 7, 
	];
	
	input_display_list = [ 1, 4, 
		["Surfaces",  true], 0, 2, 3, 5, 6, 
		new Inspector_Spacer(8, true),
		new Inspector_Spacer(2, false, false),
		effect_renderer, 
	]
	
	setDynamicInput(11, false);
	if(!LOADING && !APPENDING) createNewInput();
	
	attribute_surface_depth();
	attribute_oversample();
	attribute_interpolation();
	
	temp_surface = [ 0, 0 ];
	disp_path = [];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		PROCESSOR_OVERLAY_CHECK
		
		if(getInputAmount() == 0) return;
		
		dynamic_input_inspecting = clamp(dynamic_input_inspecting, 0, getInputAmount() - 1);
		var _ind  = input_fix_len + dynamic_input_inspecting * data_length;
		var _type = current_data[_ind + 0];
		var _hov  = false;
		
		draw_set_circle_precision(64);
		
		var pos = current_data[_ind + 1];
		var rad = current_data[_ind + 3] * _s;
		var px  = _x + pos[0] * _s;
		var py  = _y + pos[1] * _s;
		
		switch(_type) {
			case LIQUEFY_TYPE.push :
				var _path = current_data[_ind + 8];
				var rad2  = current_data[_ind + 10] * _s;
				
				if(_path == noone) {
					var pos2 = current_data[_ind + 2];
					var qx  = _x + pos2[0] * _s;
					var qy  = _y + pos2[1] * _s;
					
					draw_set_color(COLORS._main_accent);
					draw_circle(px, py, rad,  true);
					draw_circle(qx, qy, rad2, true);
					
					var hv = inputs[_ind + 2].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny); _hov |= bool(hv); hover &= !hv;
					var hv = inputs[_ind + 1].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny); _hov |= bool(hv); hover &= !hv;
					
					var hv = inputs[_ind + 10].drawOverlay(hover, active, qx, qy, _s, _mx, _my, _snx, _sny); _hov |= bool(hv); hover &= !hv;
					
				} else if(!array_empty(disp_path)) {
					var ox, oy, nx, ny;
					
					ox = _x + disp_path[0] * _s;
					oy = _y + disp_path[1] * _s;
					
					px = ox;
					py = oy;
					
					draw_set_color(COLORS._main_accent);
					draw_circle(px, py, rad, true);
					
					for( var i = 2, n = array_length(disp_path); i < n; i += 2 ) {
						nx = _x + disp_path[i + 0] * _s;
						ny = _y + disp_path[i + 1] * _s;
						
						draw_line(ox, oy, nx, ny);
						
						ox = nx;
						oy = ny;
					}
					
					draw_circle(ox, oy, rad2, true);
					
					var hv = inputs[_ind + 10].drawOverlay(hover, active, ox, oy, _s, _mx, _my, _snx, _sny); _hov |= bool(hv); hover &= !hv;
				}
				break;
			
			default:
				var hv  = inputs[_ind + 1].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny); _hov |= bool(hv); hover &= !hv;
				break;
		}
		
		var hv  = inputs[_ind + 3].drawOverlay(hover, active, px, py, _s, _mx, _my, _snx, _sny); _hov |= bool(hv); hover &= !hv;
		return _hov;
	}
	
	static step = function() {
		__step_mask_modifier();
	}
	
	static applyLiquefy = function(_data, _i) {
		var _ind  = input_fix_len + _i * data_length;
		var _surf = _data[0];
		var _type = _data[_ind + 0];
		var _pos1 = _data[_ind + 1];
		var _pos2 = _data[_ind + 2];
		var _rad  = _data[_ind + 3];
		var _int  = _data[_ind + 4];
		var _fall = _data[_ind + 5];
		var _push = _data[_ind + 7];
		var _path = _data[_ind + 8];
		var _pthR = min(1024, _data[_ind + 9]);
		var _rad2 = _data[_ind + 10];
		
		var _shader = sh_liquefy_push;
		
		switch(_type) {
			case LIQUEFY_TYPE.push  : _shader = sh_liquefy_push;  break;
			case LIQUEFY_TYPE.twirl : _shader = sh_liquefy_twirl; break;
			case LIQUEFY_TYPE.pinch : _shader = sh_liquefy_pinch; break;
			case LIQUEFY_TYPE.bloat : _shader = sh_liquefy_bloat; break;
		}
		
		surface_set_shader(temp_surface[0], _shader, true, BLEND.over);
		shader_set_interpolation(_surf);
			shader_set_dim("dimension", _surf);
			shader_set_2("pos1",        _pos1);
			shader_set_2("pos2",        _pos2);
			shader_set_f("radius",      _rad);
			shader_set_f("radius2",     _rad2);
			shader_set_f("intensity",   _int);
			shader_set_f("falloff",     _fall);
			shader_set_f("pushIntens",  _push);
			
			if(_type == LIQUEFY_TYPE.push) {
				var _usePath = _path != noone;
				var _pthList = array_create(_pthR * 2);
				var _p = new __vec2P();
				
				if(_usePath) {
					for( var i = 0; i < _pthR; i++ ) {
						_p = _path.getPointRatio(i / (_pthR - 1) ,0, _p);
						_pthList[i * 2 + 0] = _p.x;
						_pthList[i * 2 + 1] = _p.y;
					}
					
					if(_i == dynamic_input_inspecting) 
						disp_path = _pthList;
				}
				
				shader_set_i("usePath",        _usePath);
				shader_set_i("pathResolution", _pthR);
				shader_set_f("pathList",       _pthList);
			}
			
			draw_surface_safe(temp_surface[1]);
		surface_reset_shader();
		
		surface_set_shader(temp_surface[1], noone, true, BLEND.over);
			draw_surface_safe(temp_surface[0]);
		surface_reset_shader();
		
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _amo = getInputAmount();
		if(_amo == 0) return _outSurf;
		
		var  sam  = getAttribute("oversample");
		var _surf = _data[0];
		
		if(!is_surface(_surf)) return _outSurf;
		
		#region visibility
			dynamic_input_inspecting = clamp(dynamic_input_inspecting, 0, _amo - 1);
			var _ind  = input_fix_len + dynamic_input_inspecting * data_length;
			var _type = _data[_ind +  0];
			
			inputs[_ind +  2].setVisible(_type == 0);
			inputs[_ind +  7].setVisible(_type == 0);
			inputs[_ind +  8].setVisible(_type == 0, _type == 0);
			inputs[_ind +  9].setVisible(_type == 0);
			inputs[_ind + 10].setVisible(_type == 0);
			
			if(_type == LIQUEFY_TYPE.push) {
				var _path = _data[_ind + 8];
				var _usePath = _path != noone;
				
				inputs[_ind + 1].setVisible(!_usePath);
				inputs[_ind + 2].setVisible(!_usePath);
				inputs[_ind + 9].setVisible( _usePath);
			}
		#endregion
		
		var _dim = surface_get_dimension(_surf);
		for( var i = 0, n = array_length(temp_surface); i < n; i++ ) 
			temp_surface[i] = surface_verify(temp_surface[i], _dim[0], _dim[1]);
		
		surface_set_shader(temp_surface[1], noone, true, BLEND.over);
			draw_surface_safe(_surf);
		surface_reset_shader();
		
		for(var i = 0; i < _amo; i++)
			applyLiquefy(_data, i);
		
		surface_set_shader(_outSurf, noone, true, BLEND.over);
			draw_surface_safe(temp_surface[1]);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_surf, _outSurf, _data[2], _data[3]);
		_outSurf = channel_apply(_surf, _outSurf, _data[4]);
		
		return _outSurf;
	}
}