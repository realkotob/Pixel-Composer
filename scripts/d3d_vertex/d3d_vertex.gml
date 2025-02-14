function __vertex(_x = 0, _y = _x, _z = _x, color = c_white, alpha = 1) constructor {
	x = _x;
	y = _y;
	z = _z;
	
	nx = 0;
	ny = 0;
	nz = 0;
	
	u = 0;
	v = 0;
	
	self.color    = color;
	self.alpha    = alpha;
	
	static set = function(_x, _y, _z, _nx, _ny, _nz, _u, _v) {
		INLINE
		x = _x;
		y = _y;
		z = _z;
		
		nx = _nx;
		ny = _ny;
		nz = _nz;
		
		u = _u;
		v = _v;
		return self;
	}
	
	static setNormal = function(_nx = 0, _ny = _nx, _nz = _nx) {
		INLINE
		nx = _nx;
		ny = _ny;
		nz = _nz;
		return self;
	}
	
	static setUV = function(_u = 0, _v = _u) {
		INLINE
		u = _u;
		v = _v;
		return self;
	}
	
	static toString = function() { return $"[__vertex] ( pos: ({x}, {y}, {z}), nor: ({nx}, {ny}, {nz}), uv: ({u}, {v}), {color}, {alpha} )"; }
	
	static clone = function() {
		INLINE
		var _v = new __vertex(x, y, z, color, alpha);
		
		_v.nx = nx;
		_v.ny = ny;
		_v.nz = nz;
		
		_v.u  = u;
		_v.v  = v;
		
		return _v;
	}
}