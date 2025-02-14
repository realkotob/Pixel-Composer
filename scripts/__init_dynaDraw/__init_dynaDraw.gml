globalvar DYNADRAW_FOLDER, DYNADRAW_DEFAULT;

function __init_dynaDraw() {
    DYNADRAW_DEFAULT = new dynaDraw_circle_fill();
    DYNADRAW_FOLDER  = new DirectoryObject("DynaDraw");
    DYNADRAW_FOLDER.icon       = THEME.dynadraw;
    DYNADRAW_FOLDER.icon_blend = c_white;
    
    ds_list_add(DYNADRAW_FOLDER.content, new dynaDraw_line());
    ds_list_add(DYNADRAW_FOLDER.content, new dynaDraw_circle_fill());
    ds_list_add(DYNADRAW_FOLDER.content, new dynaDraw_circle_fill_gradient());
    ds_list_add(DYNADRAW_FOLDER.content, new dynaDraw_circle_outline());
    ds_list_add(DYNADRAW_FOLDER.content, new dynaDraw_square_fill());
    ds_list_add(DYNADRAW_FOLDER.content, new dynaDraw_square_fill_gradient());
    ds_list_add(DYNADRAW_FOLDER.content, new dynaDraw_square_outline());
    ds_list_add(DYNADRAW_FOLDER.content, new dynaDraw_polygon_fill());
    ds_list_add(DYNADRAW_FOLDER.content, new dynaDraw_polygon_fill_gradient());
    ds_list_add(DYNADRAW_FOLDER.content, new dynaDraw_polygon_outline());
}

function dynaDraw() : dynaSurf() constructor {
	
	node    = noone;
	editors = [];
	
	static getWidth  = function() /*=>*/ {return 1};
	static getHeight = function() /*=>*/ {return 1};
	static getFormat = function() /*=>*/ {return surface_rgba8unorm};

	static updateNode = function() {
	    if(node == noone) return;
	    node.clearCache();
	    node.triggerRender();
	}
	
	static doSerialize = function(m) {}
	static serialize = function()  { 
	    var _m  = {};
	    _m.type = instanceof(self);
	    doSerialize(_m);
	    
	    return _m;
	}
	
	static deserialize = function(m) { 
	    var _c = asset_get_index(m.type);
	    return _c == -1? noone : new _c().deserialize(m);
	}
	
	static clone = function() /*=>*/ {return variable_clone(self)};
}