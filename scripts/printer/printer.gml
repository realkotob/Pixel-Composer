function printBool(val) {
	if(!is_array(val)) return val? __txt("True") : __txt("False");
		
	var ss = "[";
	for( var i = 0, n = array_length(val); i < n; i++ ) {
		ss += (i? ", " : "") + printBool(val[i]);
	}
	
	ss += "]";
	return ss;
}