enum ARRAY_PROCESS {
	loop,
	hold,
	expand,
	expand_inv,
}

#macro PROCESSOR_OVERLAY_CHECK if(array_length(current_data) != array_length(inputs)) return 0;

function Node_Processor(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	attributes.array_process = ARRAY_PROCESS.loop;
	current_data	= [];
	inputs_is_array = [];
	inputs_index    = [];
	
	dimension_index = 0;
	process_amount	= 0;
	process_length  = [];
	process_running = [];
	
	manage_atlas = true;
	atlas_index  = 0;
	
	batch_output = true;	//Run processData once with all outputs as array.
	
	icon = THEME.node_processor_icon;
	
	array_push(attributeEditors, "Array processor");
	array_push(attributeEditors, [ "Array process type", function() /*=>*/ {return attributes.array_process}, 
		new scrollBox([ "Loop", "Hold", "Expand", "Expand inverse" ], function(val) /*=>*/ { attributes.array_process = val; triggerRender(); }, false) ]);
	
	static getInputData = function(index, def = 0) { INLINE return array_safe_get_fast(inputs_data, index, def); }
	
	static processData_prebatch  = function() {}
	static processData_postbatch = function() {}
	
	static processData = function(_outSurf, _data, _output_index, _array_index = 0) { return _outSurf; }
	
	static getSingleValue = function(_index, _arr = preview_index, output = false) { 
		var _l = output? outputs : inputs;
		if(_index < 0 || _index >= array_length(_l)) return 0;
		
		var _n  = _l[_index];
		var _in = output? _n.getValue() : getInputData(_index);
		
		if(!_n.isArray(_in)) return _in;
		if(!is_array(_in))   return 0;
		
		var _aIndex = _arr;
		
		switch(attributes.array_process) {
			case ARRAY_PROCESS.loop :		_aIndex = safe_mod(_arr, process_length[_index]);													break;
			case ARRAY_PROCESS.hold :		_aIndex = min(_arr, process_length[_index] - 1	); 													break;
			case ARRAY_PROCESS.expand :		_aIndex = floor(_arr / process_running[_index]) % process_length[_index];							break;
			case ARRAY_PROCESS.expand_inv : _aIndex = floor(_arr / process_running[array_length(_l) - 1 - _index]) % process_length[_index];	break;
		}
		
		return array_safe_get_fast(_in, _aIndex);
	} 
	
	static getDimension = function(arr = 0) { 
		if(dimension_index == -1) return [ 1, 1 ];
		
		var _ip = array_safe_get(inputs, dimension_index, noone);
		if(_ip == noone) return [ 1, 1 ];
		
		var _in = getSingleValue(dimension_index, arr);
		
		if(_ip.type == VALUE_TYPE.surface && is_surface(_in)) {
			var ww = surface_get_width_safe(_in);
			var hh = surface_get_height_safe(_in);
			return [ww, hh];
		}
		
		if(is_array(_in) && array_length(_in) == 2)
			return _in;
			
		return [1, 1];
	} 
	
	static processDataArray = function(outIndex) { 
		var _output = outputs[outIndex];
		var _out    = _output.getValue();
		var _atlas  = false;
		var _pAtl   = noone;
		var _data   = [];
		var _dep    = attrDepth();
		
		if(process_amount == 1) { // render single data
			if(_output.type == VALUE_TYPE.d3object) //passing 3D vertex call
				return _out;
			
			_data = array_map(inputs, function(_in, i) /*=>*/ {return inputs_data[i]});
			
			if(_output.type == VALUE_TYPE.surface) {								// Surface preparation
				if(manage_atlas) {
					_pAtl  = _data[atlas_index];
					_atlas = is_instanceof(_pAtl, SurfaceAtlas);
					
					if(_atlas) _data[atlas_index] = _pAtl.getSurface();
				}
				
				if(dimension_index > -1) {
					var surf = _data[dimension_index];
					var _sw = 1, _sh = 1;
					if(inputs[dimension_index].type == VALUE_TYPE.surface) {
						if(is_surface(surf)) {
							_sw = surface_get_width_safe(surf);
							_sh = surface_get_height_safe(surf);
						} else 
							return noone;
							
					} else if(is_array(surf)) {
						_sw = array_safe_get_fast(surf, 0, 1);
						_sh = array_safe_get_fast(surf, 1, 1);
					}
					
					if(is_instanceof(_out, SurfaceAtlas)) {
						if(manage_atlas) {
							surface_free_safe(_out.getSurface())
							_out = surface_verify(_out.getSurface(), _sw, _sh, _dep);
						}
					} else
						_out = surface_verify(_out, _sw, _sh, _dep);
				}
			}
			
			current_data = _data;
			
			if(active_index > -1 && !_data[active_index]) // skip
				return inputs[0].type == VALUE_TYPE.surface? surface_clone(_data[0], _out) : _data[0];
			
			var data = processData(_out, _data, outIndex, 0);					// Process data
			
			if(_output.type == VALUE_TYPE.surface) {
				if(manage_atlas && _atlas && is_surface(data)) {				// Convert back to atlas
					var _atl = _pAtl.clone();
					_atl.setSurface(data);
					return _atl;
				}
				
				//data = surface_project_posterize(data);
			}
			
			return data;
		} 
		
		#region ++++ array preparation ++++
			if(!is_array(_out))
				_out = array_create(process_amount);
			else if(array_length(_out) != process_amount) 
				array_resize(_out, process_amount);
		#endregion
		
		for(var l = 0; l < process_amount; l++) {
			
			for(var i = array_length(inputs) - 1; i >= 0; i--)
				_data[i] = inputs_index[i][l] == -1? inputs_data[i] : inputs_data[i][inputs_index[i][l]];
				
			if(_output.type == VALUE_TYPE.surface) { #region						// Output surface verification
				if(manage_atlas) {
					_pAtl  = _data[atlas_index];
					_atlas = is_instanceof(_pAtl, SurfaceAtlas);
					
					if(_atlas) _data[atlas_index] = _pAtl.getSurface();
				}
				
				if(dimension_index > -1) {
					var surf = _data[dimension_index];
					var _sw = 1, _sh = 1;
					if(inputs[dimension_index].type == VALUE_TYPE.surface) {
						if(is_surface(surf)) {
							_sw = surface_get_width_safe(surf);
							_sh = surface_get_height_safe(surf);
						} else 
							return noone;
					} else if(is_array(surf)) {
						_sw = surf[0];
						_sh = surf[1];
					}
					
					if(is_instanceof(_out[l], SurfaceAtlas)) {
						if(manage_atlas) {
							surface_free_safe(_out[l].surface.surface)
							_out[l] = surface_verify(_out[l].getSurface(), _sw, _sh, _dep);
						}
						
					} else
						_out[l] = surface_verify(_out[l], _sw, _sh, _dep);
				}
			} #endregion
			
			if(l == 0 || l == preview_index) 
				current_data = _data;
			
			if(active_index > -1 && !_data[active_index]) { // skip
				if(!_atlas && inputs[0].type == VALUE_TYPE.surface)
					_out[l] = surface_clone(_data[0], _out[l]);
				else 
					_out[l] = _data[0];
					
			} else {
				_out[l] = processData(_out[l], _data, outIndex, l);					// Process data
				
				if(_output.type == VALUE_TYPE.surface) {
					if(manage_atlas && _atlas && is_surface(_out[l])) {				// Convert back to atlas
						var _atl = _pAtl.clone();
						_atl.setSurface(_out[l]);
						_out[l] = _atl;
					}
					
					//data = surface_project_posterize(data);
				}
			}
		}
		
		return _out;
	}
	
	static processBatchOutput = function() { 
		var _is  = array_length(inputs);
		var _os  = array_length(outputs);
		
		var data;
		var _out = array_create(_os);
		for(var i = 0; i < _os; i++) _out[i] = outputs[i].getValue();
		
		var _surfOut = outputs[0];
		var _skip = active_index != -1 && !inputs_data[active_index];
		
		if(process_amount == 1) {
			current_data = inputs_data;
			
			if(_skip) { // skip
				var _skp = inputs[0].type == VALUE_TYPE.surface? surface_clone(inputs_data[0], _out[0]) : inputs_data[0];
				_surfOut.setValue(_skp);
				return;
			}
			
			if(dimension_index > -1) {
				var _dim = getDimension();
				for(var i = 0; i < _os; i++) {
					if(outputs[i].type != VALUE_TYPE.surface) continue;
					
					_out[i] = surface_verify(_out[i], _dim[0], _dim[1], attrDepth());
				}
			}
			
			if(_os == 1) {
				data = processData(_out[0], inputs_data, 0, 0);
				if(data == noone) return;
				
				outputs[0].setValue(data);
				
			} else {
				data = processData(_out, inputs_data, 0, 0);
				if(data == noone) return;
				
				for(var i = 0; i < _os; i++) outputs[i].setValue(data[i]);
			}
			
			return;
		}
		
		if(_skip) {
			
			var _skp = inputs[0].type == VALUE_TYPE.surface? surface_array_clone(inputs_data[0]) : inputs_data[0];
			_surfOut.setValue(_skp);
			
		} else {
			
			var _inputs  = array_create(_is);
			var _outputs = array_create(_os);
		
			for( var l = 0; l < process_amount; l++ ) {
				for(var i = 0; i < _is; i++) 
					_inputs[i] = inputs_index[i][l] == -1? inputs_data[i] : inputs_data[i][inputs_index[i][l]];
					
				if(l == 0 || l == preview_index) current_data = _inputs;
				
				var _outa = array_create(_os);
					
				if(dimension_index > -1) {
					var _dim  = getDimension(l);
					for(var i = 0; i < _os; i++) {
						_outa[i] = array_safe_get(_out[i], l);
						
						if(outputs[i].type != VALUE_TYPE.surface) continue;
						
						_outa[i] = surface_verify(_outa[i], _dim[0], _dim[1], attrDepth());
					}
				}
				
				if(_os == 1) {
					data = processData(_outa[0], _inputs, 0, l);
					_outputs[0][l] = data;
					
				} else {
					data = processData(_outa, _inputs, 0, l);
					for(var i = 0; i < _os; i++) _outputs[i][l] = data[i];
				}
			}
			
			for( var i = 0, n = _os; i < n; i++ )
				outputs[i].setValue(_outputs[i]);
		}
		
	} 
	
	static processOutput = function() { 
		for(var i = 0; i < array_length(outputs); i++) {
			var val = outputs[i].process_array? processDataArray(i) : processData(outputs[i].getValue(), noone, i);
			if(val != undefined)
				outputs[i].setValue(val);
		}
	} 
	
	static preGetInputs = function() {}
	
	static getInputs = function() {
		preGetInputs();
		
		var _len = array_length(inputs);
		
		process_amount	= 1;
		inputs_data		= array_verify(inputs_data,		_len);
		inputs_is_array	= array_verify(inputs_is_array, _len);
		inputs_index    = array_verify(inputs_index,	_len);
		process_length  = array_verify(process_length,	_len);
		process_running = array_verify(process_running,	_len);
		
		array_foreach(inputs, function(_in, i) /*=>*/ {
			var raw = _in.getValue();
			var amo = _in.arrayLength(raw);
			var val = raw;
			
			_in.bypass_junc.setValue(val);
				 if(amo == 0) val = noone;		//empty array
			else if(amo == 1) val = raw[0];		//spread single array
			inputs_is_array[i] = amo > 1;
			
			amo = max(1, amo);
			
			input_value_map[$ _in.internalName] = val;
			inputs_data[i] = val;				//setInputData(i, val);
			
			switch(attributes.array_process) {
				case ARRAY_PROCESS.loop : 
				case ARRAY_PROCESS.hold :   
					process_amount = max(process_amount, amo);	
					break;
					
				case ARRAY_PROCESS.expand : 
				case ARRAY_PROCESS.expand_inv : 
					process_amount *= amo;
					break;
			}
			
			process_length[i]  = amo;
			process_running[i] = process_amount;
		});
		
		var amoMax = process_amount;
		for( var i = 0; i < _len; i++ ) {
			amoMax /= process_length[i];
			process_running[i] = amoMax;
			
			inputs_index[i] = array_verify(inputs_index[i], process_amount);
		}
		
		for(var l = 0; l < process_amount; l++) // input preparation
		for(var i = 0; i < _len; i++) { 
			inputs_index[i][l] = -1;
			if(!inputs_is_array[i]) continue;
			
			var _index = 0;
			switch(attributes.array_process) {
				case ARRAY_PROCESS.loop :		_index = safe_mod(l, process_length[i]); break;
				case ARRAY_PROCESS.hold :		_index = min(l, process_length[i] - 1);  break;
				case ARRAY_PROCESS.expand :		_index = floor(l / process_running[i]) % process_length[i]; break;
				case ARRAY_PROCESS.expand_inv : _index = floor(l / process_running[array_length(inputs) - 1 - i]) % process_length[i]; break;
			}
			
			inputs_index[i][l] = _index;
		}
		
		// print($"{name}: {process_amount}");
	}
	
	static update = function(frame = CURRENT_FRAME) {
		processData_prebatch();
		
		if(batch_output) processBatchOutput();
		else			 processOutput();
		
		processData_postbatch();
		
		postProcess();
		postPostProcess();
	}
	
	static postProcess = function() {}
	
	static postPostProcess = function() {}
	
	///////////////////// CACHE /////////////////////
	
	static cacheCurrentFrameIndex = function(_aindex, _surface) {
		cacheArrayCheck();
		var _frame = CURRENT_FRAME;
		if(_frame < 0) return;
		if(_frame >= array_length(cached_output)) return;
		
		var _surfs = cached_output[_frame];
		var _cache = array_safe_get_fast(_surfs, _aindex);
		
		if(is_array(_surface)) {
			surface_array_free(_cache);
			_surfs[_aindex] = surface_array_clone(_surface);
			
		} else if(surface_exists(_surface)) {
			var _sw = surface_get_width(_surface);
			var _sh = surface_get_height(_surface);
			
			_cache = surface_verify(_cache, _sw, _sh);
			surface_set_target(_cache);
				DRAW_CLEAR BLEND_OVERRIDE
				draw_surface(_surface, 0, 0);
			surface_reset_target();
			
			_surfs[_aindex] = _cache;
		}
		
		cached_output[_frame] = _surfs;
		array_safe_set(cache_result, _frame, true);
		
		return cached_output[_frame];
	}
	
	static getCacheFrameIndex = function(_aindex = 0, _frame = CURRENT_FRAME) {
		if(_frame < 0) return false;
		if(!cacheExist(_frame)) return noone;
		
		var surf = array_safe_get_fast(cached_output, _frame);
		return array_safe_get_fast(surf, _aindex, noone);
	}
}