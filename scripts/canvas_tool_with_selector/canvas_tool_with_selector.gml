function canvas_tool_with_selector(tool) : canvas_tool() constructor {
	self.tool = tool;
	
	function init(node) {
		node.selection_tool_after  = tool;
	}
	
	function getTool() { return node.tool_sel_magic; }
}