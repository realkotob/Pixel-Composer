enum MATH_OPERATOR {
	add,
	subtract,
	multiply,
	divide,
	power,
	root,
		
	sin,
	cos,
	tan,
		
	modulo,
		
	floor,
	ceiling,
	round,
}

function Node_create_Math(_x, _y, _group = -1, _param = "") {
	var node = new Node_Math(_x, _y, _group);
	
	switch(_param) {
		case "add" :		node.inputs[| 0].setValue(MATH_OPERATOR.add); break;
		case "subtract" :	node.inputs[| 0].setValue(MATH_OPERATOR.subtract); break;
		case "multiply" :	node.inputs[| 0].setValue(MATH_OPERATOR.multiply); break;
		case "divide" :		node.inputs[| 0].setValue(MATH_OPERATOR.divide); break;
		case "power" :		node.inputs[| 0].setValue(MATH_OPERATOR.power); break;
		case "root" :		node.inputs[| 0].setValue(MATH_OPERATOR.root); break;
		
		case "sin" :		node.inputs[| 0].setValue(MATH_OPERATOR.sin); break;
		case "cos" :		node.inputs[| 0].setValue(MATH_OPERATOR.cos); break;
		case "tan" :		node.inputs[| 0].setValue(MATH_OPERATOR.tan); break;
		
		case "modulo" :		node.inputs[| 0].setValue(MATH_OPERATOR.modulo); break;
		
		case "floor" :		node.inputs[| 0].setValue(MATH_OPERATOR.floor); break;
		case "ceiling" :	node.inputs[| 0].setValue(MATH_OPERATOR.ceiling); break;
		case "round" :		node.inputs[| 0].setValue(MATH_OPERATOR.round); break;
	}
	
	//ds_list_add(PANEL_GRAPH.nodes_list, node);
	return node;
}

function Node_Math(_x, _y, _group = -1) : Node(_x, _y, _group) constructor {
	name		= "Math";
	color		= COLORS.node_blend_number;
	previewable = false;
	
	w = 96;
	min_h = 0;
	
	inputs[| 0] = nodeValue(0, "Type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ 
			/* 0 -  9*/ "Add", "Subtract", "Multiply", "Divide", "Power", "Root", "Sin", "Cos", "Tan", "Modulo", 
			/*10 - 12*/ "Floor", "Ceil", "Round" ]);
	
	inputs[| 1] = nodeValue(1, "a", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setVisible(true, true);
	inputs[| 2] = nodeValue(2, "b", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setVisible(true, true);
	inputs[| 3] = nodeValue(3, "Degree angle", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
	
	outputs[| 0] = nodeValue(0, "Math", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, 0);
	
	static _eval = function(mode, a, b, deg = true) {
		switch(mode) {
			case MATH_OPERATOR.add :		
				if(is_real(a) && is_real(b))			return a + b;
				else if(is_string(a) || is_string(b))	return string(a) + string(b);
				
			case MATH_OPERATOR.subtract :	
				if(is_real(a) && is_real(b))			return a - b;
				else if(is_string(a) || is_string(b))	return string_replace(string(a), string(b), "");
				
			case MATH_OPERATOR.multiply :	
				if(is_real(a) && is_real(b))			return a * b;
				else if(is_string(a) || is_real(b))	{
					var s = "";
					repeat(b) s += a;
					return s;
				} else if(is_string(b) || is_real(a))	{
					var s = "";
					repeat(a) s += b;
					return s;
				}
				
			case MATH_OPERATOR.divide :	
				if(is_real(a) && is_real(b))			return b == 0? 0 : a / b;
				else if(is_string(a) || is_string(b))	return string_replace_all(string(a), string(b), "");
			
			case MATH_OPERATOR.power :		if(is_real(a) && is_real(b)) return power(a, b);
			case MATH_OPERATOR.root :		if(is_real(a) && is_real(b)) return b == 0? 0 : power(a, 1 / b);
			
			case MATH_OPERATOR.sin :		if(is_real(a) && is_real(b)) return sin(degtorad(a)) * b;
			case MATH_OPERATOR.cos :		if(is_real(a) && is_real(b)) return cos(degtorad(a)) * b;
			case MATH_OPERATOR.tan :		if(is_real(a) && is_real(b)) return tan(degtorad(a)) * b;
			case MATH_OPERATOR.modulo :		if(is_real(a) && is_real(b)) return safe_mod(a, b);
			
			case MATH_OPERATOR.floor :		if(is_real(a)) return floor(a);
			case MATH_OPERATOR.ceiling :	if(is_real(a)) return ceil(a);
			case MATH_OPERATOR.round :		if(is_real(a)) return round(a);
		}
		return 0;
	}
	
	static step = function() {
		var mode = inputs[| 0].getValue();
		
		switch(mode) {
			case MATH_OPERATOR.sin :
			case MATH_OPERATOR.cos :
			case MATH_OPERATOR.tan :
				inputs[| 3].setVisible(true);
				break;
			default:
				inputs[| 3].setVisible(false);
				break;
		}
	}
	
	function update() { 
		var mode = inputs[| 0].getValue();
		var a = inputs[| 1].getValue();
		var b = inputs[| 2].getValue();
		var deg = inputs[| 3].getValue();
		var as = is_array(a);
		var bs = is_array(b);
		var al = as? array_length(a) : 0;
		var bl = bs? array_length(b) : 0;
		
		switch(mode) {
			case MATH_OPERATOR.add :
			case MATH_OPERATOR.subtract :
			case MATH_OPERATOR.multiply :
			case MATH_OPERATOR.divide :
			case MATH_OPERATOR.power :
			case MATH_OPERATOR.root :	
			case MATH_OPERATOR.modulo :	
				inputs[| 2].setVisible(true);
				break;
			case MATH_OPERATOR.sin :
			case MATH_OPERATOR.cos :
			case MATH_OPERATOR.tan :
				inputs[| 2].setVisible(true);
				inputs[| 2].name = "Amplitude";
				break;
			case MATH_OPERATOR.floor :
			case MATH_OPERATOR.ceiling :
			case MATH_OPERATOR.round :
				inputs[| 2].setVisible(false);
				break;
			default: return;
		}
		
		var val = 0;
		if(!as && !bs)
			val = _eval(mode, a, b, deg);
		else if(!as && bs) {
			for( var i = 0; i < bl; i++ )
				val[i] = _eval(mode, a, b[i], deg);
		} else if(as && !bs) {
			for( var i = 0; i < al; i++ )
				val[i] = _eval(mode, a[i], b, deg);
		} else {
			for( var i = 0; i < max(al, bl); i++ ) 
				val[i] = _eval(mode, array_safe_get(a, i), array_safe_get(b, i), deg);
		}
		
		outputs[| 0].setValue(val);
	}
	
	function onDrawNode(xx, yy, _mx, _my, _s) {
		draw_set_text(f_h3, fa_center, fa_center, COLORS._main_text);
		var str = "";
		switch(inputs[| 0].getValue()) {
			case MATH_OPERATOR.add :		str = "+"; break;
			case MATH_OPERATOR.subtract :	str = "-"; break;
			case MATH_OPERATOR.multiply :	str = "*"; break;
			case MATH_OPERATOR.divide :		str = "/"; break;
			case MATH_OPERATOR.power :		str = "pow"; break;
			case MATH_OPERATOR.root :		str = "root"; break;
			
			case MATH_OPERATOR.sin :		str = "sin"; break;
			case MATH_OPERATOR.cos :		str = "cos"; break;
			case MATH_OPERATOR.tan :		str = "tan"; break;
			case MATH_OPERATOR.modulo :		str = "mod"; break;
			
			case MATH_OPERATOR.floor :		str = "floor"; break;
			case MATH_OPERATOR.ceiling :	str = "ceil"; break;
			case MATH_OPERATOR.round :		str = "round"; break;
			default: return;
		}
		
		var _ss = min((w - 16) * _s / string_width(str), (h - 18) * _s / string_height(str));
		
		if(_s * w > 48)
			draw_text_transformed(xx + w / 2 * _s, yy + 10 + h / 2 * _s, str, _ss, _ss, 0);
		else 
			draw_text_transformed(xx + w / 2 * _s, yy + h / 2 * _s, str, _ss, _ss, 0);
	}
}