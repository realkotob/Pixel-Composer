enum __GM_FILE_DATATYPE {
    float,
    integer,
    bool,
    string,
}

function Binder_Gamemaker(path) {
    if(!file_exists_empty(path))     return noone;
    if(filename_ext(path) != ".yyp") return noone;
    
    return new __Binder_Gamemaker(path);
}

function GMAsset(_gm, _rpth, _rawData) constructor {
    static serialize_bool_keys = {};
    
    gmBinder  = _gm;
    path      = $"{_gm.dir}/{_rpth}";
    key       = _rpth;
    raw       = _rawData;
    name      = raw.name;
    type      = raw.resourceType;
    thumbnail = noone;
    
    static formatPrimitive = function(key, val) {
        if(is_undefined(val)) return "null";
        if(is_string(val))    return $"\"{val}\"";
        
        if(struct_has(serialize_bool_keys, key)) return bool(val)? "true" : "false";
        return string(val);
    }
    
    static simple_serialize = function(_k, _v, _depth = 1) {
	
    	var _newLine = false;
    	
        if(is_array(_v)) {
            if(array_empty(_v)) return "[]";
            
            switch(_k) {
	    		case "assets" :
	    		case "instances" :
	    		case "instanceCreationOrder" :
	    		case "layers" :
	    		case "parent" :
	    		case "physicsSettings" :
	    		case "properties" :
	    		case "roomSettings" :
	    		case "viewSettings" :
	    		case "views" :
	    			_newLine = true;
	    			break;
	    	}
		    	
            var _str  = _newLine? "[\n" : "[";
            var _nl   = _newLine? ",\n" : ",";
            var _padd = _newLine? string_multiply("  ", _depth + 1) : ""; 
            
            for( var i = 0, n = array_length(_v); i < n; i++ )
                _str += $"{_padd}{simple_serialize(_k, _v[i], _depth + 1)}{_nl}";
            
            _str += _newLine? string_multiply("  ", _depth) + "]" : "]";
            return _str;
            
        } 
        
        if(is_struct(_v)) {
        	switch(_k) {
	    		case "parent" :
	    		case "physicsSettings" :
	    		case "roomSettings" :
	    		case "viewSettings" :
	    			_newLine = true;
	    			break;
	    	}
		    	
            var _keys = struct_get_names(_v);
    	    array_sort(_keys, function(a, b) /*=>*/ {return string_compare(a, b)});
    	    
    	    var _str  = _newLine? "{\n" : "{";
    	    var _nl   = _newLine? "\n"  : "";
    	    var _padd = _newLine? string_multiply("  ", _depth + 1) : "";
    	    
    	    for( var i = 0, n = array_length(_keys); i < n; i++ ) {
    	    	var __k = _keys[i];
    	    	var __v = _v[$ __k];
    	    	
    	    	_str += $"{_padd}\"{__k}\":{simple_serialize(__k, __v, _depth + 1)},{_nl}";
    	    }
    	    
    	    _str += _newLine? string_multiply("  ", _depth) + "}" : "}";
    	    return _str;
        }
        
        return formatPrimitive(_k, _v);
    }
    
    static sync = function() { file_text_write_all(path, json_stringify(raw)); }
    
    static link = function() {}
}

function GMSprite(_gm, _rpth, _rawData) : GMAsset(_gm, _rpth, _rawData) constructor {
    var _dirr   = filename_dir(path);
    var _frame  = raw.frames;
    var _layers = raw.layers;
    
    thumbnailPath = "";
    if(array_empty(_frame) || array_empty(_layers)) return;
    
    thumbnailPath = $"{_dirr}/layers/{_frame[0].name}/{_layers[0].name}.png";
    if(file_exists(thumbnailPath))
        thumbnail = sprite_add(thumbnailPath, 0, 0, 0, 0, 0);
}

function GMTileset(_gm, _rpth, _rawData) : GMAsset(_gm, _rpth, _rawData) constructor {
	sprite = struct_try_get(raw.spriteId, "path", "");
    spriteObject = noone;
    
    static link = function() {
        spriteObject = gmBinder.getResourceFromPath(sprite);
    }
} 

function GMObject(_gm, _rpth, _rawData) : GMAsset(_gm, _rpth, _rawData) constructor {
    sprite = struct_try_get(raw.spriteId, "path", "");
    spriteObject = noone;
    
    static link = function() {
        spriteObject = gmBinder.getResourceFromPath(sprite);
    }
}

function __Binder_Gamemaker(path) constructor {
    self.path   = path;
    name        = filename_name_only(path);
    dir         = filename_dir(path);
    projectName = "";
    
    resourcesRaw = [];
    resourcesMap = {};
    resourceList = [];
    
    resources    = [
        { name: "sprites", data : [], closed : false, },
        { name: "tileset", data : [], closed : false, },
        { name: "rooms",   data : [], closed : false, },
    ];
    
    nodeMap = {};
    
    static getResourceFromPath = function(path) { return struct_try_get(resourcesMap, path, noone); }
    
    static getNodeFromPath = function(path, _x, _y) {
        if(struct_has(nodeMap, path)) return nodeMap[$ path];
        
        var _n = nodeBuild("Node_Tile_Tileset", _x, _y).skipDefault();
	    nodeMap[$ path] = _n;
	    
	    return _n;
    }
    
    static readYY = function(path) {
        var _res = file_read_all(path);
        var _map = json_try_parse(_res, noone);
        return _map;
    }
    
    static refreshResources = function() {
        if(!file_exists(path)) return;
        
        var _resMap = readYY(path);
        if(_resMap == noone) return;
        
        projectName  = _resMap.name;
        resourcesRaw = _resMap.resources;
        
        var resMap   = {};
        resourceList = [];
        
        var sprites = [];
        var objects = [];
        var tileset = [];
        var rooms   = [];
        var _asst;
        
        for( var i = 0, n = array_length(resourcesRaw); i < n; i++ ) {
            var _res  = resourcesRaw[i].id;
            var _name = _res.name;
            var _rpth = _res.path;
            
            var _rawData = readYY($"{dir}/{_rpth}");
            if(_rawData == noone) continue;
            
            switch(_rawData.resourceType) {
                case "GMSprite":  _asst = new GMSprite( self, _rpth, _rawData); array_push(sprites, _asst); break;
                case "GMObject":  _asst = new GMObject( self, _rpth, _rawData); array_push(objects, _asst); break;
                case "GMTileSet": _asst = new GMTileset(self, _rpth, _rawData); array_push(tileset, _asst); break;
                case "GMRoom":    _asst = new GMRoom(   self, _rpth, _rawData); array_push(rooms,   _asst); break;
                default :         _asst = noone;
            }
            
            if(_asst == noone) continue;
            
            if(struct_has(resourcesMap, _rpth)) {
            	struct_override(resourcesMap[$ _rpth], _asst);
            	_asst = resourcesMap[$ _rpth];
            }
            
            resMap[$ _rpth] = _asst;
            array_push(resourceList, _asst);
        }
        
        resourcesMap = resMap;
        for( var i = 0, n = array_length(resourceList); i < n; i++ )
            resourceList[i].link();
        
        resources[0].data = sprites;
        resources[1].data = tileset;
        resources[2].data = rooms;
    }
    
    refreshResources();
}