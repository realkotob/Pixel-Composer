function Node_3D_Mesh_Cone(_x, _y, _group = noone) : Node_3D_Mesh(_x, _y, _group) constructor {
	name = "3D Cone";
	
	object_class = __3dCone;
	
	newInput(in_mesh + 0, nodeValue_Int("Side", self, 8 ))
		.setValidator(VV_min(3));
	
	newInput(in_mesh + 1, nodeValue_D3Material("Material Bottom", self, new __d3dMaterial()))
		.setVisible(true, true);
	
	newInput(in_mesh + 2, nodeValue_D3Material("Material Side", self, new __d3dMaterial()))
		.setVisible(true, true);
	
	newInput(in_mesh + 3, nodeValue_Bool("Smooth Side", self, false ));
	
	input_display_list = [
		__d3d_input_list_mesh, in_mesh + 0, 
		__d3d_input_list_transform,
		["Material",	false], in_mesh + 3, in_mesh + 1, in_mesh + 2, 
	]
	
	static processData = function(_output, _data, _output_index, _array_index = 0) {
		var _side     = _data[in_mesh + 0];
		var _mat_bot  = _data[in_mesh + 1];
		var _mat_sid  = _data[in_mesh + 2];
		var _smt      = _data[in_mesh + 3];
		
		var object = getObject(_array_index);
		object.checkParameter({sides: _side, smooth: _smt});
		object.materials = [ _mat_bot, _mat_sid ];
		
		setTransform(object, _data);
		
		return object;
	}
	
	static getPreviewValues = function() { return getSingleValue(in_mesh + 1); }
}