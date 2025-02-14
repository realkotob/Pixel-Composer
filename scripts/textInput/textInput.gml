function textInput(_input, _onModify) : widget() constructor {
	input		  = _input;
	onModify	  = _onModify;
	onModifyParam = noone;
	selecting     = false;
	auto_update   = false;
	
	typing = false;
	
	select_on_click = true;
	parser_server   = noone;
	globalParams    = [];
	localParams     = [];
	
	autocomplete_delay   = 0;
	autocomplete_modi    = false;	
	use_autocomplete	 = true;
	autocomplete_server	 = noone;
	autocomplete_object	 = noone;
	autocomplete_context = {};
	
	function_guide_server	   = noone;
	
	static _resetFocus = function() { resetFocus();	}
	
	static onKey = function(key) {}
	
	static setAutoUpdate = function( ) /*=>*/ { auto_update = true; 	return self; } 
	static setSideButton = function(b) /*=>*/ { self.side_button = b;	return self; } 
	
	static breakCharacter = function(ch) /*=>*/ { return ch == " " || ch == "\n"; }
}