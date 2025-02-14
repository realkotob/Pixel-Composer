function Node_HTTP_request(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "HTTP";
	setDimension(96, 72);
	
	newInput(0, nodeValue_Text("Address", self, ""));
	
	newInput(1, nodeValue_Enum_Scroll("Type", self,  0, [ "Get", "Post" ]));
	
	newInput(2, nodeValue_Text("Content", self, ""))
	
	newOutput(0, nodeValue_Output("Result", self, VALUE_TYPE.text, ""));
	
	address_domain  = "";
	downloaded_size = 0;
	
	setTrigger(1, "Trigger", [ THEME.sequence_control, 1, COLORS._main_value_positive ], function() /*=>*/ {return request()});
	
	attributes.max_file_size = 10000;
	array_push(attributeEditors, "HTTP");
	array_push(attributeEditors, ["Max request size", function() { return attributes.max_file_size; }, new textBox(TEXTBOX_INPUT.number, function(val) { attributes.max_file_size = val; }) ]);
	
	static request = function() {
		var _addr = getInputData(0);
		var _type = getInputData(1);
		var _post = getInputData(2);
		
		downloaded_size = 0;
		
		switch(_type) {
			case 0 :
				asyncCall(http_get(_addr), function(param, data) /*=>*/ {
					var sta = data[? "status"];
					var res = data[? "result"];
					
					if(sta == 0) {
						if(downloaded_size > attributes.max_file_size) {
							noti_warning($"HTTP request: Requesed file to large ({downloaded_size} B).");
							outputs[0].setValue("");
						} else
							outputs[0].setValue(res);
							
						triggerRender(true);
						
					} else if(sta == 1) {
						var _siz = data[? "contentLength"];
						var _dow = data[? "sizeDownloaded"];
						
						downloaded_size = _dow;
					}
				});
				break;
			
			case 1 :
				asyncCall(http_post_string(_addr, _post), function(param, data) /*=>*/ {
					var sta = data[? "status"];
					var res = data[? "result"];
					
					outputs[0].setValue(res);
					triggerRender(true);
				});
				break;
		}
	}
	
	static update = function() {
		var _addr = getInputData(0);
		var _type = getInputData(1);
		var _post = getInputData(2);
		
		inputs[2].setVisible(_type == 1, _type == 1);
		
		if(_addr == "") return;
		
		draw_set_font(f_p0);
		var _addrs = string_split(_addr, "/", true);
		address_domain = array_safe_get(_addrs, 1, "");
		address_domain = string_cut_line(address_domain, 128);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var addr = getInputData(0);
		var bbox = drawGetBbox(xx, yy, _s);
		
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		draw_text_bbox(bbox, address_domain);
	}
}