#macro __3D_GROUP_PRESUB transform.submitMatrix(); for( var i = 0, n = array_length(objects); i < n; i++ )
#macro __3D_GROUP_POSSUB transform.clearMatrix();

function __3dGroup() constructor {
	objects = [];
	
	transform = new __transform();
	
	static getCenter = function() {
		var _v = new __vec3();
		var _i = 0;
		
		for( var i = 0, n = array_length(objects); i < n; i++ ) {
			if(!is_struct(objects[i])) continue;
			var _c = objects[i].getCenter();
			if(_c == noone) continue;
			_v._add(objects[i].getCenter());
			_i++;
		}
		
		if(_i) _v = _v.multiply(1 / _i);
		_v.add(transform.position);
		
		return _v;
	}
	
	static getBBOX   = function() {
		if(array_empty(objects)) return new __bbox3D(new __vec3(-0.5), new __vec3(0.5));
		var _m0 = noone;
		var _m1 = noone;
		var _cc = getCenter();
		
		for( var i = 0, n = array_length(objects); i < n; i++ ) {
			if(!is_struct(objects[i])) continue;
			var _c = objects[i].getCenter();
			var _b = objects[i].getBBOX();
			
			if(_c == noone || _b == noone) continue;
			
			_b.first.multiplyVec(transform.scale);
			_b.second.multiplyVec(transform.scale);
			
			var _n0 = _b.first.add(_c);
			var _n1 = _b.second.add(_c);
			
			_m0 = _m0 == noone? _n0 : _m0.minVal(_n0);
			_m1 = _m1 == noone? _n1 : _m1.maxVal(_n1);
		}
		
		if(_m0 == noone) return new __bbox3D(new __vec3(-0.5), new __vec3(0.5));
		
		_m0._subtract(_cc);
		_m1._subtract(_cc);
		
		return new __bbox3D(_m0, _m1); 
	}
	
	static addObject = function(_obj) { array_push(objects, _obj); }
	
	static submit       = function(_sc = {}, _sh = noone)    /*=>*/ { __3D_GROUP_PRESUB objects[i].submit(_sc, _sh);       __3D_GROUP_POSSUB }
	static submitUI     = function(_sc = {}, _sh = noone)    /*=>*/ { __3D_GROUP_PRESUB objects[i].submitUI(_sc, _sh);     __3D_GROUP_POSSUB }
	static submitSel    = function(_sc = {}, _sh = noone)    /*=>*/ { __3D_GROUP_PRESUB objects[i].submitSel(_sc, _sh);    __3D_GROUP_POSSUB }
	static submitShader = function(_sc = {}, _sh = noone)    /*=>*/ { __3D_GROUP_PRESUB objects[i].submitShader(_sc, _sh); __3D_GROUP_POSSUB }
	static submitShadow = function(_sc = {}, object = noone) /*=>*/ { for( var i = 0, n = array_length(objects); i < n; i++ ) objects[i].submitShadow(_sc, object); }
	static map = function(callback, _sc = {}) /*=>*/ { for( var i = 0, n = array_length(objects); i < n; i++ ) callback(objects[i], _sc); }
	
	static clone = function(vertex = true, cloneBuffer = false) {
		var _new = new __3dGroup();
		
		_new.transform = transform.clone();
		_new.objects   = array_create(array_length(objects));
		
		for( var i = 0, n = array_length(objects); i < n; i++ )
			_new.objects[i] = objects[i].clone(vertex, cloneBuffer);
		
		return _new;
	}
}