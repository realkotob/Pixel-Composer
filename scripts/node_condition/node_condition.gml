#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Condition", "Condition > Toggle", "C", MOD_KEY.none, function() /*=>*/ { PANEL_GRAPH_FOCUS_STR _n.inputs[1].setValue((_n.inputs[1].getValue() + 1) % 6); });
		addHotkey("Node_Condition", "Eval Mode > Toggle", "E", MOD_KEY.none, function() /*=>*/ { PANEL_GRAPH_FOCUS_STR _n.inputs[5].setValue((_n.inputs[5].getValue() + 1) % 3); });
	});
#endregion

function Node_Condition(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Condition";
	
	setDimension(96, 48);
	
	newInput(0, nodeValue_Float("Check value", self, 0 ))
		.setVisible(true, true)
		.rejectArray();
		
	newInput(1, nodeValue_Enum_Scroll("Condition", self,  0 , [ new scrollItem("Equal",             s_node_condition_type, 0), 
												                new scrollItem("Not equal",         s_node_condition_type, 1), 
												                new scrollItem("Less ",             s_node_condition_type, 2), 
												                new scrollItem("Less or equal ",	s_node_condition_type, 3), 
												                new scrollItem("Greater ",			s_node_condition_type, 4), 
												                new scrollItem("Greater or equal",  s_node_condition_type, 5), ]))
		.rejectArray();
		
	newInput(2, nodeValue_Float("Compare to", self, 0 ))
		.rejectArray();
	
	newInput(3, nodeValue("True", self, CONNECT_TYPE.input, VALUE_TYPE.any, -1 ))
		.setVisible(true, true);
		
	newInput(4, nodeValue("False", self, CONNECT_TYPE.input, VALUE_TYPE.any, -1 ))
		.setVisible(true, true);
	
	newInput(5, nodeValue_Enum_Scroll("Eval Mode", self,  0 , ["Boolean", "Number compare", "Text compare" ]))
		.rejectArray();
	
	newInput(6, nodeValue_Bool("Boolean", self, false ))
		.setVisible(true, true)
		.rejectArray();
	
	newInput(7, nodeValue_Text("Text 1", self, "" ));
	
	newInput(8, nodeValue_Text("Text 2", self, "" ));
		
	input_display_list = [ 5,
		["Condition", false], 0, 1, 2, 6, 7, 8, 
		["Result",	  true], 3, 4
	]
	
	newOutput(0, nodeValue_Output("Result", self, VALUE_TYPE.any, []));
	newOutput(1, nodeValue_Output("Bool", self, VALUE_TYPE.boolean, false));
	
	doUpdate = doUpdateLite;
	static update = function(frame = CURRENT_FRAME) {
		var _true = inputs[3].getValue();
		var _fals = inputs[4].getValue();
		
		var _mode = inputs[5].getValue();
		
		var _chck = inputs[0].getValue();
		var _cond = inputs[1].getValue();
		var _valu = inputs[2].getValue();
		var _bool = inputs[6].getValue();
		var _txt1 = inputs[7].getValue();
		var _txt2 = inputs[8].getValue();
		
		inputs[0].setVisible(_mode == 1, _mode == 1);
		inputs[1].setVisible(_mode == 1);
		inputs[2].setVisible(_mode == 1, _mode == 1);
		inputs[6].setVisible(_mode == 0, _mode == 0);
		inputs[7].setVisible(_mode == 2, _mode == 2);
		inputs[8].setVisible(_mode == 2, _mode == 2);
		
		inputs[3].setType(inputs[3].value_from == noone? VALUE_TYPE.any : inputs[3].value_from.type);
		inputs[4].setType(inputs[4].value_from == noone? VALUE_TYPE.any : inputs[4].value_from.type);
		
		var res = false;
		
		switch(_mode) {
			case 0 : res = _bool; break;
			case 1 :
				switch(_cond) {
					case 0 : res = _chck == _valu; break;
					case 1 : res = _chck != _valu; break;
					case 2 : res = _chck <  _valu; break;
					case 3 : res = _chck <= _valu; break;
					case 4 : res = _chck >  _valu; break;
					case 5 : res = _chck >= _valu; break;
				}
				break;
			case 2 : res = _txt1 == _txt2; break;
		}
		
		if(res) {
			outputs[0].setValue(_true);
			outputs[0].setType(inputs[3].type);
			outputs[0].display_type = inputs[3].display_type;
		} else {
			outputs[0].setValue(_fals);
			outputs[0].setType(inputs[4].type);	
			outputs[0].display_type = inputs[4].display_type;
		}
		
		outputs[1].setValue(res);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var val = outputs[1].getValue();
		var frm = val? inputs[3] : inputs[4];
		var to  = outputs[0];
		var c0 = value_color(frm.type);
		
		draw_set_color(c0);
		draw_set_alpha(0.5);
		draw_line_width(frm.x, frm.y, to.x, to.y, _s * 4);
		draw_set_alpha(1);
	}
}