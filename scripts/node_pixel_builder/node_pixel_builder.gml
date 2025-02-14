function Node_Pixel_Builder(_x, _y, _group = noone) : Node_Collection(_x, _y, _group) constructor {
	name  = "Pixel Builder";
	color = COLORS.node_blend_feedback;
	icon  = THEME.pixel_builder;
	
	reset_all_child = true;
	
	newInput(0, nodeValue_Dimension(self));
	
	newOutput(0, nodeValue_Output("Surface Out", self, VALUE_TYPE.surface, noone));
	
	custom_input_index  = array_length(inputs);
	custom_output_index = array_length(outputs);
	
	if(NODE_NEW_MANUAL) {
		var input  = nodeBuild("Node_PB_Layer", -256, -32, self);
		RENDER_ALL 
	}
	
	static getNextNodes = function(checkLoop = false) { #region
		var allReady = true;
		for(var i = custom_input_index; i < array_length(inputs); i++) {
			var _in = inputs[i].from;
			if(!_in.isRenderActive()) continue;
			
			allReady &= _in.isRenderable()
		}
		
		if(!allReady) return [];
		
		return __nodeLeafList(getNodeList());
	} #endregion
	
	static checkComplete = function() { #region
		for( var i = 0; i < array_length(nodes); i++ )
			if(!nodes[i].rendered) return [];
		
		buildPixel();
		
		var _nodes = [];
		var _tos  = outputs[0].getJunctionTo();
			
		for( var j = 0; j < array_length(_tos); j++ ) {
			var _to = _tos[j];
			array_push(_nodes, _to.node);
		}
		
		return _nodes;
	} #endregion
	
	static buildPixel = function() { #region
		LOG_BLOCK_START();
		LOG_IF(global.FLAG.render == 1, $"================== BUILD PIXEL ==================");
		
		var _dim     = getInputData(0);
		var _surfs   = ds_map_create();
		
		for( var i = 0; i < array_length(nodes); i++ ) {
			var _n = nodes[i];
			
			for( var j = 0; j < array_length(_n.outputs); j++ ) {
				var _out = _n.outputs[j];
				
				if(_out.type != VALUE_TYPE.pbBox) continue;
				var _to  = _out.getJunctionTo();
				if(array_length(_to)) continue;
				
				var _pbox = _n.outputs[j].getValue();
				
				if(!is_array(_pbox)) 
					_pbox = [ _pbox ];
			
				for( var k = 0; k < array_length(_pbox); k++ ) {
					var _box = _pbox[k];
					if(!is_instanceof(_box, __pbBox)) continue;
					if(!is_surface(_box.content)) continue;
					
					var _layer = _box.layer;
					if(!ds_map_exists(_surfs, _layer))
						_surfs[? _layer] = [];
					array_push(_surfs[? _layer], _box);
				} 
			}
		}
		
		var _outSurf = outputs[0].getValue();
		surface_array_free(_outSurf);
		
		if(ds_map_empty(_surfs)) {
			ds_map_destroy(_surfs);
			outputs[0].setValue(surface_create(_dim[0], _dim[1]));
			LOG_BLOCK_END();
			return;
		}
		
		var _layers = ds_map_keys_to_array(_surfs);
		array_sort(_layers, true);
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1]);
		
		surface_set_target(_outSurf);
		DRAW_CLEAR
			for( var k = 0; k < array_length(_layers); k++ ) {
				var _s = _surfs[? _layers[k]];
				
				for( var j = 0; j < array_length(_s); j++ ) {
					var _box = _s[j];
					draw_surface_safe(_box.content, _box.x, _box.y);
				}
			}	
		surface_reset_target();
		
		ds_map_destroy(_surfs);
		
		outputs[0].setValue(_outSurf);
		LOG_BLOCK_END();
	} #endregion
}