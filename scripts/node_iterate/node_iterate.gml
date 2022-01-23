function Node_create_Iterate(_x, _y) {
	var node = new Node_Iterate(_x, _y);
	ds_list_add(PANEL_GRAPH.nodes_list, node);
	return node;
}

function Node_Iterate(_x, _y) : Node_Collection(_x, _y) constructor {
	name = "Iterate";
	color = c_ui_lime;
	icon  = s_group_16;
	previewable = false;
	
	w = 96;
	min_h = 0;
	
	iterated = 0;
	
	inputs[| 0] = nodeValue( 0, "Repeat", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1 );
	
	custom_input_index = 1;
	
	static setRenderStatus = function(result) {
		rendered = result;
		if(!rendered) iterated = 0;
	}
	
	static outputRendered = function() {
		var iter = true;
		for( var i = 0; i < ds_list_size(outputs); i++ ) {
			var _out = outputs[| i].node;
			iter &= _out.rendered;
		}
		
		if(iter) {
			iterated++;
			if(iterated >= inputs[| 0].getValue()) 
				return 2;
			
			for( var i = 0; i < ds_list_size(nodes); i++ ) {
				nodes[| i].setRenderStatus(false);
			}
			return 1;
		}
		
		return 0;
	}
}