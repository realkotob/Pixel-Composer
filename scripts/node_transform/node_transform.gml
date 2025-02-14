#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Transform", "Rotation > Rotate CCW", "R", MOD_KEY.none, function() /*=>*/ { PANEL_GRAPH_FOCUS_STR _n.inputs[5].setValue((_n.inputs[5].getValue() + 90) % 360); });
		addHotkey("Node_Transform", "Render Mode > Toggle",  "M", MOD_KEY.none, function() /*=>*/ { PANEL_GRAPH_FOCUS_STR _n.inputs[7].setValue((_n.inputs[7].getValue() + 1) % 3); });
		addHotkey("Node_Transform", "Output Dimension Type > Toggle",  "D", MOD_KEY.none, function() /*=>*/ { PANEL_GRAPH_FOCUS_STR _n.inputs[9].setValue((_n.inputs[9].getValue() + 1) % 4); });
	});

	enum OUTPUT_SCALING {
		same_as_input,
		constant,
		relative,
		scale
	}
#endregion

function Node_Transform(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Transform";
	dimension_index = -1;
	
	newInput(0, nodeValue_Surface("Surface In", self));
	
	newInput(1, nodeValue_Vec2("Output Dimension", self, [ 1, 1 ]))
		.setVisible(false);
	
	newInput(2, nodeValue_Vec2("Position", self, [ 0.5, 0.5 ]))
		.setUnitRef(function(index) { return getDimension(index); }, VALUE_UNIT.reference);
	
	newInput(3, nodeValue_Vec2("Anchor", self, [ 0.5, 0.5 ]));
		inputs[3].setDisplay(VALUE_DISPLAY.vector, { side_button : new buttonAnchor(inputs[3]) });
	
	newInput(4, nodeValue_Bool("Relative Anchor", self, true));
	
	newInput(5, nodeValue_Rotation("Rotation", self, 0));
	
	newInput(6, nodeValue_Vec2("Scale", self, [ 1, 1 ]));
	
	newInput(7, nodeValue_Enum_Button("Render Mode", self, 0, [ "Normal", "Tile", "Wrap" ]));
	
	newInput(8, nodeValue_Float("Rotate by Velocity", self, 0, "Make the surface rotates to follow its movement."))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(9, nodeValue_Enum_Scroll("Output Dimension Type", self, OUTPUT_SCALING.same_as_input, [
																			new scrollItem("Same as input"),
																			new scrollItem("Constant"),
																			new scrollItem("Relative to input").setTooltip("Set dimension as a multiple of input surface."),
																			new scrollItem("Fit content").setTooltip("Automatically set dimension to fit content."),
																		]));
	
	newInput(10, nodeValue_Bool("Round Position", self, false, "Round position to the nearest integer value to avoid jittering."));
	
	newInput(11, nodeValue_Bool("Active", self, true));
		active_index = 11;
	
	newInput(12, nodeValue_Bool("Echo", self, false));
	
	newInput(13, nodeValue_Int("Echo Amount", self, 8));
	
	newInput(14, nodeValue_Float("Alpha", self, 1))
		.setDisplay(VALUE_DISPLAY.slider);
		
	input_display_list = [ 11, 0,  
		["Output",		 true],	9, 1, 7,
		["Position",	false], 2, 10, 
		["Rotation",	false], 3, 5, 8, 
		["Scale",		false], 6, 
		["Render",		false], 14, 
		["Echo",		 true, 12], 13, 
	];
	
	newOutput(0, nodeValue_Output("Surface Out", self, VALUE_TYPE.surface, noone));
	
	newOutput(1, nodeValue_Output("Dimension", self, VALUE_TYPE.integer, [ 1, 1 ]))
		.setDisplay(VALUE_DISPLAY.vector)
		.setVisible(false);
	
	attribute_surface_depth();
	attribute_interpolation();
	
	vel        = 0;
	prev_pos   = [ 0, 0 ];
	prev_data  = noone;
	
	static getDimension = function(arr = 0) {
		var _surf		= getSingleValue(0, arr);
		var _out_type	= getSingleValue(9, arr);
		var _out		= getSingleValue(1, arr);
		var _rotate		= getSingleValue(5, arr);
		var _scale		= getSingleValue(6, arr);
		var ww, hh;
		
		var sw  = surface_get_width_safe(_surf);
		var sh  = surface_get_height_safe(_surf);
		
		switch(_out_type) {
			case OUTPUT_SCALING.same_as_input :
				ww = sw;
				hh = sh;
				break;
			case OUTPUT_SCALING.relative : 
				ww = sw * _out[0];
				hh = sh * _out[1];
				break;
			case OUTPUT_SCALING.constant :	
				ww = _out[0];
				hh = _out[1];
				break;
			case OUTPUT_SCALING.scale :	
				ww = sw * _scale[0];
				hh = sh * _scale[1];
				
				var p0 = point_rotate( 0,  0, ww / 2, hh / 2, _rotate);
				var p1 = point_rotate(ww,  0, ww / 2, hh / 2, _rotate);
				var p2 = point_rotate( 0, hh, ww / 2, hh / 2, _rotate);
				var p3 = point_rotate(ww, hh, ww / 2, hh / 2, _rotate);
				
				var minx = min(p0[0], p1[0], p2[0], p3[0]);
				var maxx = max(p0[0], p1[0], p2[0], p3[0]);
				var miny = min(p0[1], p1[1], p2[1], p3[1]);
				var maxy = max(p0[1], p1[1], p2[1], p3[1]);
				
				ww = maxx - minx;
				hh = maxy - miny;
				break;
		}
		
		return [ ww, hh ];
	}
	
	static centerAnchor = function() {
		var _surf = getInputData(0);
		
		var _out_type = getInputData(9);
		var _out = getInputData(1);
		var _sca = getInputData(6);
		
		if(is_array(_surf)) {
			if(array_length(_surf) == 0) return;
			_surf = _surf[preview_index];
		}
		
		inputs[3].setValue([ 0.5, 0.5 ]);
		inputs[2].setValue([ surface_get_width_safe(_surf) / 2, surface_get_height_safe(_surf) / 2 ]);
	}
	
	static step = function() {
		if(!PROJECT.animator.frame_progress) return;
		var pos = getSingleValue(2);
		
		if(IS_FIRST_FRAME) {
			vel = 0;
			prev_pos[0] = pos[0];
			prev_pos[1] = pos[1];
			
		} else {
			vel = point_direction(prev_pos[0], prev_pos[1], pos[0], pos[1]);
				
			prev_pos[0] = pos[0];
			prev_pos[1] = pos[1];
		}
	}
	
	static processData = function(_outData, _data, _output_index, _array_index) {
		var ins = _data[0];
		
		var out_type  = _data[9];
		var out		  = _data[1];
		var pos		  = [ _data[2][0], _data[2][1] ];
		var pos_exact = _data[10];
		var anc       = [ _data[3][0], _data[3][1] ];
		var rot_vel   = vel * _data[8];
		var rot		  = _data[5] + rot_vel;
		var sca       = _data[6];
		var mode      = _data[7];
		
		var echo      = _data[12];
		var echo_amo  = _data[13];
		var alp       = _data[14];
		
		var _outSurf  = _outData[0];
		var _outRes   = array_create(array_length(outputs));
		
		var cDep = attrDepth();
		
		var ww  = surface_get_width_safe(ins);
		var hh  = surface_get_height_safe(ins);
		var _ww = ww;
		var _hh = hh;
		
		if(!is_surface(ins)) {
			surface_free(_outSurf);
			_outSurf = noone;
		}
		
		_outRes[0] = _outSurf;
		_outRes[1] = [ ww, hh ];
		
		if(_ww <= 1 && _hh <= 1) return _outRes;
		
		switch(out_type) { // output dimension
			case OUTPUT_SCALING.same_as_input :
				inputs[1].setVisible(false);
				break;
				
			case OUTPUT_SCALING.constant :	
				inputs[1].setVisible(true);
				_ww  = out[0];
				_hh  = out[1];
				break;
				
			case OUTPUT_SCALING.relative : 
				inputs[1].setVisible(true);
				_ww = ww * out[0];
				_hh = hh * out[1];
				break;
				
			case OUTPUT_SCALING.scale : 
				inputs[1].setVisible(false);
				_ww = ww * sca[0];
				_hh = hh * sca[1];
				
				var p0 = point_rotate(  0,   0, _ww / 2, _hh / 2, rot);
				var p1 = point_rotate(_ww,   0, _ww / 2, _hh / 2, rot);
				var p2 = point_rotate(  0, _hh, _ww / 2, _hh / 2, rot);
				var p3 = point_rotate(_ww, _hh, _ww / 2, _hh / 2, rot);
				
				var minx = min(p0[0], p1[0], p2[0], p3[0]);
				var maxx = max(p0[0], p1[0], p2[0], p3[0]);
				var miny = min(p0[1], p1[1], p2[1], p3[1]);
				var maxy = max(p0[1], p1[1], p2[1], p3[1]);
				
				_ww = maxx - minx;
				_hh = maxy - miny;
				break;
		}
		
		_outRes[1] = [ ww, hh ];
		
		if(_ww <= 0 || _hh <= 0) return _outRes;
		
		_outSurf = surface_verify(_outSurf, _ww, _hh, cDep);
		_outRes[0] = _outSurf;
		
		anc[0] *= ww * sca[0];
		anc[1] *= hh * sca[1];
		
		pos[0] -= anc[0];
		pos[1] -= anc[1];
		
		pos = point_rotate(pos[0], pos[1], pos[0] + anc[0], pos[1] + anc[1], rot);
		
		var draw_x, draw_y;
		draw_x = pos[0];
		draw_y = pos[1];
				
		if(pos_exact) {
			draw_x = round(draw_x);
			draw_y = round(draw_y);
		}
			
		if(mode == 1) { // Tile
			surface_set_shader(_outSurf);
			shader_set_interpolation(ins);
			
				draw_surface_tiled_ext_safe(ins, draw_x, draw_y, sca[0], sca[1], rot, c_white, alp);
				
			surface_reset_shader();
		
		} else { // Normal or wrap
			surface_set_shader(_outSurf);
			shader_set_interpolation(ins);
			
			if(echo && CURRENT_FRAME && prev_data != noone) {
				var _pre = prev_data[_array_index];
				
				for( var i = 0; i <= echo_amo; i++ ) {
					var rat = i / echo_amo;
					var _px = lerp(_pre[0][0], draw_x, rat);
					var _py = lerp(_pre[0][1], draw_y, rat);
					var _rt = lerp(_pre[1],    rot,    rat);
					var _sx = lerp(_pre[2][0], sca[0], rat);
					var _sy = lerp(_pre[2][1], sca[1], rat);
					
					if(pos_exact) {
						_px = round(_px);
						_py = round(_py);
					}
					
					draw_surface_ext_safe(ins, _px, _py, _sx, _sy, _rt, c_white, alp);
				}
			} else 
				draw_surface_ext_safe(ins, draw_x, draw_y, sca[0], sca[1], rot, c_white, alp);
			
			if(mode == 2) {
				draw_surface_ext_safe(ins, draw_x - _ww, draw_y - _hh, sca[0], sca[1], rot, c_white, alp);
				draw_surface_ext_safe(ins, draw_x,       draw_y - _hh, sca[0], sca[1], rot, c_white, alp);
				draw_surface_ext_safe(ins, draw_x + _ww, draw_y - _hh, sca[0], sca[1], rot, c_white, alp);
				
				draw_surface_ext_safe(ins, draw_x - _ww, draw_y, sca[0], sca[1], rot, c_white, alp);
				draw_surface_ext_safe(ins, draw_x + _ww, draw_y, sca[0], sca[1], rot, c_white, alp);
				
				draw_surface_ext_safe(ins, draw_x - _ww, draw_y + _hh, sca[0], sca[1], rot, c_white, alp);
				draw_surface_ext_safe(ins, draw_x,       draw_y + _hh, sca[0], sca[1], rot, c_white, alp);
				draw_surface_ext_safe(ins, draw_x + _ww, draw_y + _hh, sca[0], sca[1], rot, c_white, alp);
			}
			surface_reset_shader();
		
		}
		
		prev_data[_array_index] = [
			[ draw_x, draw_y ],
			rot,
			[ sca[0], sca[1] ],
		];
		
		return _outRes;
	}
	
	overlay_dragging = 0;
	corner_dragging  = 0;
	overlay_drag_mx  = 0;
	overlay_drag_my  = 0;
	overlay_drag_sx  = 0;
	overlay_drag_sy  = 0;
	overlay_drag_px  = 0;
	overlay_drag_py  = 0;
	overlay_drag_ma  = 0;
	overlay_drag_sa  = 0;
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		PROCESSOR_OVERLAY_CHECK
		
		var _surf = current_data[0];
		if(is_array(_surf)) {
			if(array_length(_surf) == 0) return;
			_surf = _surf[preview_index];
		}
		
		var _surf_out = outputs[0].getValue();
		if(is_array(_surf_out)) {
			if(array_length(_surf_out) == 0) return;
			_surf_out = _surf_out[preview_index];
		}
		
		var __pos = current_data[2];
		var pos   = [ __pos[0], __pos[1] ];
		var _pos  = [ __pos[0], __pos[1] ];
		
		var __anc = current_data[3];
		var anc   = [ __anc[0], __anc[1] ];
		var _anc  = [ __anc[0], __anc[1] ];
		
		var rot = current_data[5];
		var sca = current_data[6];
		
		var srw = surface_get_width_safe(_surf);
		var srh = surface_get_height_safe(_surf);
		
		var ow = surface_get_width_safe(_surf_out);
		var oh = surface_get_height_safe(_surf_out);
		
		var ww  = srw * sca[0];
		var hh  = srh * sca[1];
		
		anc[0] *= ww;
		anc[1] *= hh;
		
		pos[0] -= anc[0];
		pos[1] -= anc[1];
		
		#region bounding box
			var bx0 = _x + pos[0] * _s;
			var by0 = _y + pos[1] * _s;
			
			var bx1 = _x + (pos[0] + ww) * _s;
			var by1 = _y + (pos[1] + hh) * _s;
			
			var bx2 = _x + (pos[0] + ww) * _s + 18;
			var by2 = _y + (pos[1] + hh) * _s + 18;
			
			var bax = _x + (pos[0] + anc[0]) * _s;
			var bay = _y + (pos[1] + anc[1]) * _s;
			
			var tl = point_rotate(bx0, by0, bax, bay, rot);
			var tr = point_rotate(bx1, by0, bax, bay, rot);
			var bl = point_rotate(bx0, by1, bax, bay, rot);
			var br = point_rotate(bx1, by1, bax, bay, rot);
			var sz = point_rotate(bx2, by2, bax, bay, rot);
			
			var rth = point_rotate((bx0 + bx1) / 2, by0 - 16, bax, bay, rot);
			
			var a_index  = 0;
			var r_index  = 0;
			var tl_index = 0;
			var tr_index = 0;
			var bl_index = 0;
			var br_index = 0;
			var sz_index = 0;
			
			draw_set_color(COLORS._main_accent);
			draw_line(tl[0], tl[1], tr[0], tr[1]);
			draw_line(tl[0], tl[1], bl[0], bl[1]);
			draw_line(tr[0], tr[1], br[0], br[1]);
			draw_line(bl[0], bl[1], br[0], br[1]);
			
			     if(point_in_circle(_mx, _my, bax, bay, 8))		  a_index  = 1;
			else if(point_in_circle(_mx, _my, rth[0], rth[1], 8)) r_index  = 1;
			else if(point_in_circle(_mx, _my, tl[0], tl[1], 8))	  tl_index = 1;
			else if(point_in_circle(_mx, _my, tr[0], tr[1], 8))	  tr_index = 1;			
			else if(point_in_circle(_mx, _my, bl[0], bl[1], 8))	  bl_index = 1;			
			else if(point_in_circle(_mx, _my, br[0], br[1], 8))	  br_index = 1;
			else if(point_in_circle(_mx, _my, sz[0], sz[1], 8))	  sz_index = 1;
			
			draw_sprite_colored(THEME.anchor, a_index, bax, bay);
			draw_sprite_colored(THEME.anchor_selector, tl_index,  tl[0],  tl[1]);
			draw_sprite_colored(THEME.anchor_selector, tr_index,  tr[0],  tr[1]);
			draw_sprite_colored(THEME.anchor_selector, bl_index,  bl[0],  bl[1]);
			draw_sprite_colored(THEME.anchor_selector, br_index,  br[0],  br[1]);
			draw_sprite_colored(THEME.anchor_scale,    sz_index,  sz[0],  sz[1], 1, rot);
			draw_sprite_colored(THEME.anchor_rotate,   r_index,  rth[0], rth[1], 1, rot);
		#endregion
		
		if(overlay_dragging && overlay_dragging < 3) { //Transform
			var px = _mx - overlay_drag_mx;
			var py = _my - overlay_drag_my;
			var pos_x, pos_y;
			
			if(key_mod_press(SHIFT)) {
				var ang  = round(point_direction(overlay_drag_mx, overlay_drag_my, _mx, _my) / 45) * 45;
				var dist = point_distance(overlay_drag_mx, overlay_drag_my, _mx, _my) / _s;
				
				pos_x = overlay_drag_sx + lengthdir_x(dist, ang);
				pos_y = overlay_drag_sy + lengthdir_y(dist, ang);
			} else {
				pos_x = overlay_drag_sx + px / _s;
				pos_y = overlay_drag_sy + py / _s;
			}
			
			pos_x = value_snap(pos_x, _snx);
			pos_y = value_snap(pos_y, _sny);
			
			if(overlay_dragging == 1) { //Move
				if(inputs[2].setValue([ pos_x, pos_y ]))
					UNDO_HOLDING = true;
			} else if(overlay_dragging == 2) { //Move anchor
				var nanx = pos_x / ww;
				var nany = pos_y / hh;
				
				if(key_mod_press(ALT)) {
					var modi = false;
					modi |= inputs[3].setValue([ nanx, nany ]);
					modi |= inputs[2].setValue([ overlay_drag_px + pos_x, overlay_drag_py + pos_y ]);
					
					if(modi)
						UNDO_HOLDING = true;
				} else {
					if(inputs[3].setValue([ nanx, nany ]))
						UNDO_HOLDING = true;
				}
			}
			
			if(mouse_release(mb_left)) {
				overlay_dragging = 0;	
				UNDO_HOLDING = false;
			}
		} else if(overlay_dragging == 3) { //Angle
			var aa = point_direction(bax, bay, _mx, _my);
			var da = angle_difference(overlay_drag_ma, aa);
			var sa;
			
			if(key_mod_press(CTRL)) sa = round((overlay_drag_sa - da) / 15) * 15;
			else					sa = overlay_drag_sa - da;
			
			if(inputs[5].setValue(sa))
				UNDO_HOLDING = true;
			
			if(mouse_release(mb_left)) {
				overlay_dragging = 0;
				UNDO_HOLDING = false;
			}
		} else if(overlay_dragging == 4) { //Scale
			var ol_x = (overlay_drag_mx - _x) / _s;
			var ol_y = (overlay_drag_my - _y) / _s;
			var ml_x = (_mx - _x) / _s;
			var ml_y = (_my - _y) / _s;
			
			var os_x = value_snap(ol_x, _snx);
			var os_y = value_snap(ol_y, _sny);
			var ms_x = value_snap(ml_x, _snx);
			var ms_y = value_snap(ml_y, _sny);
			
			var _p   = point_rotate(ms_x - os_x, ms_y - os_y, 0, 0, -rot);
			
			var _sw = _p[0] / srw;
			var _sh = _p[1] / srh;
			var sw, sh;
			
			if(corner_dragging == 0) {
				sw = -_sw / _anc[0];
				sh = -_sh / _anc[1];
			} else if(corner_dragging == 1) {
				sw =  _sw / (1 - _anc[0]);
				sh = -_sh / _anc[1];
			} else if(corner_dragging == 2) {
				sw = -_sw / _anc[0];
				sh =  _sh / (1 - _anc[1]);
			} else if(corner_dragging == 3) {
				sw =  _sw / (1 - _anc[0]);
				sh =  _sh / (1 - _anc[1]);
			} else if(corner_dragging == 4) {
				sw =  _sw / (1 - _anc[0]);
				sh =  _sh / (1 - _anc[1]);
			}
			
			var _sw = overlay_drag_sx + sw;
			var _sh = overlay_drag_sy + sh;
			
			if(key_mod_press(SHIFT)) {
				_sw = max(_sw, _sh);
				_sh = _sw;
			}
			
			if(inputs[6].setValue([ _sw, _sh ]))
				UNDO_HOLDING = true;
			
			if(mouse_release(mb_left)) {
				overlay_dragging = 0;
				UNDO_HOLDING = false;
			}
		}
		
		if(overlay_dragging == 0 && mouse_press(mb_left, active)) {
			if(point_in_circle(_mx, _my, bax, bay, 8)) {
				overlay_dragging = 2;
				overlay_drag_mx  = _mx;
				overlay_drag_my  = _my;
				overlay_drag_sx  = anc[0];
				overlay_drag_sy  = anc[1];
				overlay_drag_px  = pos[0];
				overlay_drag_py  = pos[1];
				
			} else if(point_in_circle(_mx, _my, tl[0], tl[1], 8) || 
			          point_in_circle(_mx, _my, tr[0], tr[1], 8) || 
					  point_in_circle(_mx, _my, bl[0], bl[1], 8) || 
					  point_in_circle(_mx, _my, br[0], br[1], 8) || 
					  point_in_circle(_mx, _my, sz[0], sz[1], 8)) {
				overlay_dragging = 4;
				
				if(point_in_circle(_mx, _my, tl[0], tl[1], 8))		corner_dragging = 0;
				else if(point_in_circle(_mx, _my, tr[0], tr[1], 8)) corner_dragging = 1;
				else if(point_in_circle(_mx, _my, bl[0], bl[1], 8)) corner_dragging = 2;
				else if(point_in_circle(_mx, _my, br[0], br[1], 8)) corner_dragging = 3;
				else if(point_in_circle(_mx, _my, sz[0], sz[1], 8)) corner_dragging = 4;
				
				overlay_drag_mx  = _mx;
				overlay_drag_my  = _my;
				overlay_drag_sx  = sca[0];
				overlay_drag_sy  = sca[1];
				
			} else if(point_in_circle(_mx, _my, rth[0], rth[1], 8)) {
				overlay_dragging = 3;
				overlay_drag_ma  = point_direction(bax, bay, _mx, _my);
				overlay_drag_sa  = rot;
				
			} else if(point_in_triangle(_mx, _my, tl[0], tl[1], tr[0], tr[1], bl[0], bl[1]) || 
			          point_in_triangle(_mx, _my, tr[0], tr[1], bl[0], bl[1], br[0], br[1])) {
				overlay_dragging = 1;
				overlay_drag_mx  = _mx;
				overlay_drag_my  = _my;
				overlay_drag_sx  = _pos[0];
				overlay_drag_sy  = _pos[1];
			}
		}
	
		if(inputs[2].is_anim && inputs[2].value_from == noone && !inputs[2].sep_axis) { // draw path
			var posInp = inputs[2];
			var allPos = posInp.animator.values;
			var ox, oy, nx, ny;
			var _val, _px, _py;
			
			draw_set_color(COLORS._main_accent);
			
			for( var i = 0, n = array_length(allPos); i < n; i++ ) {
				_val = allPos[i].value;
				_px  = _val[0];
				_py  = _val[1];
				
				if(posInp.unit.mode == VALUE_UNIT.reference) {
					_px *= ow;
					_py *= oh;
				}
			
				nx = _x + _px * _s;
				ny = _y + _py * _s;
				
				draw_set_alpha(1);
				draw_circle_prec(nx, ny, 4, false);
				
				if(i) {
					draw_set_alpha(0.5);
					draw_line_dashed(ox, oy, nx, ny);
				}
			
				ox = nx;
				oy = ny;
			}
		
			draw_set_alpha(1);
		}
	}

	static drawOverlayTransform = function(_node) { 
		if(_node != inputs[0].getNodeFrom()) return noone;
		
		var _tr = array_safe_get(prev_data, preview_index, noone);
		return _tr == noone? noone : [ _tr[0][0], _tr[0][1], _tr[2][0], _tr[2][1], _tr[1] ];
	}
	
}