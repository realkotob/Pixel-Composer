function Node_3DSurf(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name	= "3DSurf";
	cached_object = [];
	object_class  = dynaSurf_3d;
	
	newInput(0, nodeValue_D3Scene("Scene", self, noone))
		.setVisible(true, true);
	
	newInput(1, nodeValue_Vec2("Base Dimension", self, DEF_SURF));
	
	newInput(2, nodeValue_Float("Vertical Angle", self, 45 ))
		.setDisplay(VALUE_DISPLAY.slider, { range: [0, 90, 0.1] });
	
	newInput(3, nodeValue_Float("Distance", self, 4 ));
	
	newOutput(0, nodeValue_Output("3DSurf", self, VALUE_TYPE.dynaSurface, noone));
	
	input_display_list = [ 0,
		["Camera", false], 1, 2, 3, 
	];
	
	static getObject = function(index, class = object_class) { #region
		var _obj = array_safe_get_fast(cached_object, index, noone);
		if(_obj == noone) {
			_obj = new class();
		} else if(!is_instanceof(_obj, class)) {
			_obj.destroy();
			_obj = new class();
		}
		
		cached_object[index] = _obj;
		return _obj;
	} #endregion
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _sobj = _data[0];
		var _dim  = _data[1];
		var _vang = _data[2];
		var _dist = _data[3];
		
		if(_sobj == noone) return noone;
		
		var _scn  = getObject(_array_index);
		_scn.object = _sobj;
		_scn.w      = _dim[0];
		_scn.h      = _dim[1];
		
		_scn.camera_ay         = _vang;
		_scn.camera.focus_dist = _dist;
		
		return _scn;
	}
}