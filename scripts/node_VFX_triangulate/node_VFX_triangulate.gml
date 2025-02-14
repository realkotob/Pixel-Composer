function Node_VFX_Triangulate(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "VFX Triangulate";
	color = COLORS.node_blend_vfx;
	icon  = THEME.vfx;
	use_cache = CACHE_USE.auto;
	
	function _Point(part) constructor {
		self.part = part;
		x  = part.x;
		y  = part.y;
		
		static equal = function(point) { INLINE return x == point.x && y == point.y; }
	}
	
	manual_ungroupable	 = false;
	
	newInput(0, nodeValue_Vec2("Output dimension", self, DEF_SURF ));
		
	newInput(1, nodeValue_Particle("Particles", self, -1 ))
		.setVisible(true, true);
		
	newInput(2, nodeValue_Float("Thickness", self, 1 ));
		
	newInput(3, nodeValue_Color("Color", self, cola(c_white) ));
		
	newInput(4, nodeValue_Bool("Inherit Thickness", self, false ));
		
	newInput(5, nodeValue_Bool("Inherit Color", self, false ));
	
	newOutput(0, nodeValue_Output("Triangles", self, VALUE_TYPE.surface, noone));
	
	input_display_list = [ 0, 
		[ "Particles", false], 1, 
		[ "Rendering", false], 4, 2, 5, 3,
	]
	
	setTrigger(2, "Clear cache", [ THEME.cache, 0, COLORS._main_icon ]);
	
	static onInspector2Update = function() { clearCache(); }
	
	static step = function() {
		var _ith = getInputData(4);
		var _icl = getInputData(5);
		
		inputs[2].setVisible(!_ith);
		inputs[3].setVisible(!_icl);
	}
	
	static update = function() {
		var _dim = getInputData(0);
		var _par = getInputData(1);
		
		var _th  = getInputData(2);
		var _cl  = getInputData(3);
		var _ith = getInputData(4);
		var _icl = getInputData(5);
		
		var _surf = outputs[0].getValue();
		    _surf = surface_verify(_surf, _dim[0], _dim[1]);
			outputs[0].setValue(_surf);
		
		var _vrx = array_create(array_length(_par));
		var _ind = 0;
		
		for( var i = 0, n = array_length(_par); i < n; i++ ) {
			var p = _par[i];
			
			if(!p.active) continue;
			_vrx[_ind++] = new _Point(p);
		}
		
		array_resize(_vrx, _ind);
		
		var tri = delaunay_triangulation(_vrx);
		var c0, c1, c2;
		
		surface_set_shader(_surf, noone);
			draw_set_color(c_white);
			
			for( var i = 0, n = array_length(tri); i < n; i++ ) {
				var t  = tri[i];
				var p0 = t[0].part;
				var p1 = t[1].part;
				var p2 = t[2].part;
				
				if(_ith) {
					if(_icl) {
						draw_line_width2(p0.x, p0.y, p1.x, p1.y, min(p0.scx, p0.scy), min(p1.scx, p1.scy), false, p0.currColor, p1.currColor);
						draw_line_width2(p0.x, p0.y, p2.x, p2.y, min(p0.scx, p0.scy), min(p2.scx, p2.scy), false, p0.currColor, p2.currColor);
						draw_line_width2(p1.x, p1.y, p2.x, p2.y, min(p1.scx, p1.scy), min(p2.scx, p2.scy), false, p1.currColor, p2.currColor);
					} else {
						draw_set_color(_cl);
						draw_line_width2(p0.x, p0.y, p1.x, p1.y, min(p0.scx, p0.scy), min(p1.scx, p1.scy));
						draw_line_width2(p0.x, p0.y, p2.x, p2.y, min(p0.scx, p0.scy), min(p2.scx, p2.scy));
						draw_line_width2(p1.x, p1.y, p2.x, p2.y, min(p1.scx, p1.scy), min(p2.scx, p2.scy));
					}
					
				} else if(_th == 1) {
					if(_icl) {
						draw_line_color(p0.x, p0.y, p1.x, p1.y, p0.currColor, p1.currColor);
						draw_line_color(p0.x, p0.y, p2.x, p2.y, p0.currColor, p2.currColor);
						draw_line_color(p1.x, p1.y, p2.x, p2.y, p1.currColor, p2.currColor);
						
					} else {
						draw_set_color(_cl);
						draw_line(p0.x, p0.y, p1.x, p1.y);
						draw_line(p0.x, p0.y, p2.x, p2.y);
						draw_line(p1.x, p1.y, p2.x, p2.y);
					}
				} else {
					if(_icl) {
						draw_line_width_color(p0.x, p0.y, p1.x, p1.y, _th, p0.currColor, p1.currColor);
						draw_line_width_color(p0.x, p0.y, p2.x, p2.y, _th, p0.currColor, p2.currColor);
						draw_line_width_color(p1.x, p1.y, p2.x, p2.y, _th, p1.currColor, p2.currColor);
						
					} else {
						draw_set_color(_cl);
						draw_line_width(p0.x, p0.y, p1.x, p1.y, _th);
						draw_line_width(p0.x, p0.y, p2.x, p2.y, _th);
						draw_line_width(p1.x, p1.y, p2.x, p2.y, _th);
					}
				}
			}
		surface_reset_shader();
		
		cacheCurrentFrame(_surf);
	}
	
	static getPreviewingNode = function() { return is(inline_context, Node_VFX_Group_Inline)? inline_context.getPreviewingNode() : self; }
	static getPreviewValues  = function() { return is(inline_context, Node_VFX_Group_Inline)? inline_context.getPreviewValues()  : self; }
}