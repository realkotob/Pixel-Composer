function __3dCylinder(radius = 0.5, height = 1, sides = 8, smooth = false) : __3dObject() constructor {
	VF = global.VF_POS_NORM_TEX_COL;
	render_type = pr_trianglelist;
	
	self.radius = radius;
	self.height = height;
	self.sides  = sides;
	self.smooth = smooth;
	
	caps     = true;
	segment  = 1;
	profiles = [ 1, 1 ];
	
	static initModel = function() {
		var v0 = array_create(3 * sides);
		var v1 = array_create(3 * sides);
		var _h = height / 2;
		
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		for( var i = 0; i < sides; i++ ) { // caps
			var a0 = (i + 0) / sides * 360;
			var a1 = (i + 1) / sides * 360;
			
			var _r0 = radius * profiles[array_length(profiles) - 1];
			var _r1 = radius * profiles[0];
				
			var x0 = lengthdir_x(1, a0);
			var y0 = lengthdir_y(1, a0);
			var x1 = lengthdir_x(1, a1);
			var y1 = lengthdir_y(1, a1);
			
			var _u0 = 0.5 + lengthdir_x(0.5, a0);
			var _v0 = 0.5 + lengthdir_y(0.5, a0);
			var _u1 = 0.5 + lengthdir_x(0.5, a1);
			var _v1 = 0.5 + lengthdir_y(0.5, a1);
			
			v0[i * 3 + 0] = new __vertex(       0,        0,  _h).setNormal(0, 0,  1).setUV(0.5,  0.5);
			v0[i * 3 + 1] = new __vertex(x0 * _r0, y0 * _r0,  _h).setNormal(0, 0,  1).setUV(_u0,  _v0);
			v0[i * 3 + 2] = new __vertex(x1 * _r0, y1 * _r0,  _h).setNormal(0, 0,  1).setUV(_u1,  _v1);
			
			v1[i * 3 + 0] = new __vertex(       0,        0, -_h).setNormal(0, 0, -1).setUV(0.5,  0.5);
			v1[i * 3 + 1] = new __vertex(x1 * _r1, y1 * _r1, -_h).setNormal(0, 0, -1).setUV(_u1,  _v1);
			v1[i * 3 + 2] = new __vertex(x0 * _r1, y0 * _r1, -_h).setNormal(0, 0, -1).setUV(_u0,  _v0);
		}
		
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		var vs = array_create(3 * sides * 2 * segment);
		var _sg = 1 / segment;
		var _ix = 0;
		
		for( var i = 0; i < sides; i++ ) { // sides
			var a0 = (i + 0) / sides * 360;
			var a1 = (i + 1) / sides * 360;
			
			var _x0 = lengthdir_x(1, a0);
			var _y0 = lengthdir_y(1, a0);
			var _x1 = lengthdir_x(1, a1);
			var _y1 = lengthdir_y(1, a1);
			
			var nx0 = smooth? lengthdir_x(1, a0) : lengthdir_x(1, (a0 + a1) / 2);
			var ny0 = smooth? lengthdir_y(1, a0) : lengthdir_y(1, (a0 + a1) / 2);
			var nx1 = smooth? lengthdir_x(1, a1) : lengthdir_x(1, (a0 + a1) / 2);
			var ny1 = smooth? lengthdir_y(1, a1) : lengthdir_y(1, (a0 + a1) / 2);
			
			var ux0 = (i + 0) / sides;
			var ux1 = (i + 1) / sides;
			
			for( var j = 0; j < segment; j++ ) {
				var _j0 = j * _sg;
				var _j1 = _j0 + _sg;
				
				var _r0 = radius * profiles[j    ];
				var _r1 = radius * profiles[j + 1];
				
				var x0 = _x0 * _r0, y0 = _y0 * _r0;
				var x1 = _x1 * _r0, y1 = _y1 * _r0;
				var x2 = _x0 * _r1, y2 = _y0 * _r1;
				var x3 = _x1 * _r1, y3 = _y1 * _r1;
				
				var _h0 = -_h + _j0 * _h * 2;
				var _h1 = -_h + _j1 * _h * 2;
				
				vs[_ix++] = new __vertex(x2, y2, _h1).setNormal(nx0, ny0, 0).setUV(ux0, _j1);
				vs[_ix++] = new __vertex(x0, y0, _h0).setNormal(nx0, ny0, 0).setUV(ux0, _j0);
				vs[_ix++] = new __vertex(x3, y3, _h1).setNormal(nx1, ny1, 0).setUV(ux1, _j1);
															  					  
				vs[_ix++] = new __vertex(x0, y0, _h0).setNormal(nx0, ny0, 0).setUV(ux0, _j0);
				vs[_ix++] = new __vertex(x1, y1, _h0).setNormal(nx1, ny1, 0).setUV(ux1, _j0);
				vs[_ix++] = new __vertex(x3, y3, _h1).setNormal(nx1, ny1, 0).setUV(ux1, _j1);
			}
		}
		
		vertex = caps? [ vs, v0, v1 ] : [ vs ];
		object_counts = array_length(vertex);
		VB = build();
	} initModel();
	
	static onParameterUpdate = initModel;
}