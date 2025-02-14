function __Node_Cache(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Cache";
	clearCacheOnChange = false;
	update_on_frame    = true;
	
	attributes.cache_group = [];
	cache_group_members    = [];
	group_vertex   = [];
	group_dragging = false;
	group_adding   = false;
	group_alpha    = 0;
	vertex_hash    = "";
	
	setTrigger(1, "Generate cache group", [ THEME.cache_group, 0, COLORS._main_icon ]);
	
	if(NOT_LOAD) run_in(1, function() { onInspector1Update(); });
	
	static removeNode = function(node) {
		if(node.cache_group != self) return;
		
		array_remove(attributes.cache_group, node.node_id);
		array_remove(cache_group_members, node);
		
		node.cache_group = noone;
	}
	
	static addNode = function(node) {
		if(node.cache_group == self) return;
		if(node.cache_group != noone)
			node.cache_group.removeNode(node);
		
		array_push(attributes.cache_group, node.node_id);
		array_push(cache_group_members, node);
		
		node.cache_group = self;
	}
	
	static enableNodeGroup = function() {
		if(LOADING || APPENDING) return; 
		
		for( var i = 0, n = array_length(cache_group_members); i < n; i++ )
			cache_group_members[i].renderActive = true;
		clearCache(true);
	}
	
	static disableNodeGroup = function() {
		if(LOADING || APPENDING) return;
		
		if(IS_PLAYING && IS_LAST_FRAME)
		for( var i = 0, n = array_length(cache_group_members); i < n; i++ )
			cache_group_members[i].renderActive = false;
	}
	
	static refreshCacheGroup = function() {
		cache_group_members = [];
		
		for( var i = 0, n = array_length(attributes.cache_group); i < n; i++ ) {
			if(!ds_map_exists(PROJECT.nodeMap, attributes.cache_group[i])) {
				print($"Node not found {attributes.cache_group[i]}");
				continue;
			}
			
			var _node = PROJECT.nodeMap[? attributes.cache_group[i]];
			array_push(cache_group_members, _node);
			_node.cache_group = self;
		}
	}
	
	static getCacheGroup = function(node) {
		if(node != self) addNode(node);
		
		for( var i = 0, n = array_length(node.inputs); i < n; i++ ) {
			var _from = node.inputs[i].value_from;
			
			if(_from == noone) continue;
			if(_from.node == self) continue;
			if(array_exists(attributes.cache_group, _from.node.node_id)) continue;
			getCacheGroup(_from.node);
		}
	}
	
	setTrigger(1,,, function() /*=>*/ {
		attributes.cache_group = [];
		cache_group_members    = [];
		
		getCacheGroup(self);
		refreshCacheGroup();
	});
	
	static ccw = function(a, b, c) { return (b[0] - a[0]) * (c[1] - a[1]) - (c[0] - a[0]) * (b[1] - a[1]); }
	
	static getNodeBorder = function(_i, _vertex, _node) {
		var _rad = 4;
		var _stp = 15;
		
		var _nx0 = _node.x - 32 + _rad;
		var _ny0 = _node.y - 32 + _rad;
		var _nx1 = _node.x + (_node == self? _node.w / 2 : _node.w + 32 - _rad);
		var _ny1 = _node.y + _node.h + 32 - _rad;
		
		var _ind = 0;
		for( var i =   0; i <=  90; i += _stp ) _vertex[_i * 7 * 4 + _ind++] = [ _nx1 + lengthdir_x(_rad, i), _ny0 + lengthdir_y(_rad, i) ];
		for( var i =  90; i <= 180; i += _stp ) _vertex[_i * 7 * 4 + _ind++] = [ _nx0 + lengthdir_x(_rad, i), _ny0 + lengthdir_y(_rad, i) ];
		for( var i = 180; i <= 270; i += _stp ) _vertex[_i * 7 * 4 + _ind++] = [ _nx0 + lengthdir_x(_rad, i), _ny1 + lengthdir_y(_rad, i) ];
		for( var i = 270; i <= 360; i += _stp ) _vertex[_i * 7 * 4 + _ind++] = [ _nx1 + lengthdir_x(_rad, i), _ny1 + lengthdir_y(_rad, i) ];
	}
	
	static refreshGroupBG = function() {
		var _hash = "";
		for( var i = -1, n = array_length(cache_group_members); i < n; i++ ) {
			var _node = i == -1? self : cache_group_members[i];
			_hash += $"{_node.x},{_node.y},{_node.w},{_node.h}|";
		}
		_hash = md5_string_utf8(_hash);
		
		if(vertex_hash == _hash) return;
		vertex_hash = _hash;
		
		group_vertex = [];
		
		if(array_empty(cache_group_members)) return;
		var _vtrx   = array_create((array_length(cache_group_members) + 1) * 4 * 7);
		
		for( var i = -1, n = array_length(cache_group_members); i < n; i++ ) {
			var _node = i == -1? self : cache_group_members[i];
			getNodeBorder(i + 1, _vtrx, _node);
		}
		
		__temp_minP = [ x, y ];
		__temp_minI = 0;
		
		for( var i = 0, n = array_length(_vtrx); i < n; i++ ) {
			var _v = _vtrx[i];
			
			if(_v[1] > __temp_minP[1] || (_v[1] == __temp_minP[1] && _v[0] < __temp_minP[0])) {
				__temp_minP = _v;
				__temp_minI = i;
			}
		}
		
		_vtrx = array_map( _vtrx, function(a, i) { return [ a[0], a[1], i == __temp_minI? -999 : point_direction(__temp_minP[0], __temp_minP[1], a[0], a[1]) + 360 ] });
		array_sort(_vtrx, function(a0, a1) { return a0[2] == a1[2]? sign(a0[0] - a1[0]) : sign(a0[2] - a1[2]); });
		
		var _linS = 0;
		for( var i = 1, n = array_length(_vtrx); i < n; i++ ) {
			if(_vtrx[i][1] != _vtrx[0][1]) break;
			_linS = i;
		}
		
		array_delete(_vtrx, 1, _linS - 1);
		
		group_vertex = [ _vtrx[0], _vtrx[1] ];
		
		for( var i = 2, n = array_length(_vtrx); i < n; i++ ) {
			var _v = _vtrx[i];
			
			while( array_length(group_vertex) >= 2 && ccw( group_vertex[array_length(group_vertex) - 2], group_vertex[array_length(group_vertex) - 1], _v ) >= 0 )
				array_pop(group_vertex);
			array_push(group_vertex, _v);
		}
	}
	
	static groupCheck = function(_x, _y, _s, _mx, _my) {
		if(array_length(group_vertex) < 3) return;
		var _inGroup = true;
		var _m       = [ _mx / _s - _x, _my / _s - _y ];
		
		group_adding = false;
		
		if(PANEL_GRAPH.node_dragging && key_mod_press(SHIFT)) {
			var side = undefined;
			for( var i = 1, n = array_length(group_vertex); i < n; i++ ) {
				var a = group_vertex[i - 1];
				var b = group_vertex[i - 0];
			
				var _side = sign(ccw(a, b, _m));
				if(side == undefined) side = _side;
				else if(side != _side) _inGroup = false;
			}
		
			var _list    = PANEL_GRAPH.nodes_selecting;
		
			if(_inGroup) {
				group_adding = true;
				for( var i = 0, n = array_length(_list); i < n; i++ )
					array_push_unique(attributes.cache_group, _list[i].node_id);
			} else {
				for( var i = 0, n = array_length(_list); i < n; i++ )
					array_remove(attributes.cache_group, _list[i].node_id);
			}
			
			if(!group_dragging) {
				for( var i = 0, n = array_length(_list); i < n; i++ )
					array_remove(attributes.cache_group, _list[i].node_id);
				refreshCacheGroup();
				refreshGroupBG();
			}
			group_dragging = true;
		}
		
		if(group_dragging && mouse_release(mb_left)) {
			refreshCacheGroup();
			refreshGroupBG();
			
			group_dragging = false;
		}
	}
	
	static drawNodeBG = function(_x, _y, _mx, _my, _s) {
		refreshGroupBG();
		if(array_length(group_vertex) < 3) return;
		
		var _color  = getColor();
		draw_set_color(_color);
		group_alpha = lerp_float(group_alpha, group_adding, 4);
		draw_set_alpha(0.025 + 0.025 * group_alpha);
		draw_primitive_begin(pr_trianglelist);
			var a = group_vertex[0];
			var b = group_vertex[1];
			var c;
			
			for( var i = 2, n = array_length(group_vertex); i < n; i++ ) {
				c = group_vertex[i];
				
				draw_vertex(_x + a[0] * _s, _y + a[1] * _s);
				draw_vertex(_x + b[0] * _s, _y + b[1] * _s);
				draw_vertex(_x + c[0] * _s, _y + c[1] * _s);
				
				b = group_vertex[i];
			}
		draw_primitive_end();
		
		draw_set_alpha(0.3);
		draw_primitive_begin(pr_linestrip);
			for( var i = 0, n = array_length(group_vertex); i < n; i++ ) {
				var a = group_vertex[i];
				draw_vertex(_x + a[0] * _s, _y + a[1] * _s);
			}
			
			a = group_vertex[0];
			draw_vertex(_x + a[0] * _s, _y + a[1] * _s);
		draw_primitive_end();
		
		draw_set_alpha(1);
	}
		
	static onDestroy = function() { enableNodeGroup(); }
}