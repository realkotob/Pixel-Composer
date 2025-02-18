function Node_Feedback(_x, _y, _group = -1) : Node_Collection(_x, _y, _group) constructor {
	name  = "Feedback";
	color = COLORS.node_blend_feedback;
	
	if(!LOADING && !APPENDING) {
		var input  = nodeBuild("Node_Feedback_Input", -256, -32, self);
		var output = nodeBuild("Node_Feedback_Output", 256, -32, self);
		
		input.inputs[| 2].setValue(4);
		output.inputs[| 0].setFrom(input.outputs[| 0]);
		output.inputs[| 2].setFrom(input.outputs[| 1]);
	}
	
	static doStepBegin = function() {
		if(!ANIMATOR.frame_progress) return;
		setRenderStatus(false);
		UPDATE |= RENDER_TYPE.full;
	}
	
	static getNextNodes = function() {
		var allReady = true;
		for(var i = custom_input_index; i < ds_list_size(inputs); i++) {
			var _in = inputs[| i].from;
			allReady &= _in.isUpdateReady()
		}
			
		if(!allReady) return;
		
		__nodeLeafList(nodes, RENDER_STACK);
	}
}