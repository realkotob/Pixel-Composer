function canvas_tool_node(canvas, node) : canvas_tool() constructor {
	
	self.canvas = canvas;
	self.node   = node;
	override    = true;
	panel       = noone;
	
	applySelection = false;
	
	static destroy = function() {
		if(applySelection) canvas.tool_selection.apply();
		cleanUp();
	}
	
	static cleanUp = function() {
		UNDO_HOLDING = true;
		surface_free_safe(targetSurface);
		surface_free_safe(maskedSurface);
		
		if(is_struct(nodeObject)) {
			if(is_instanceof(nodeObject, Node))
				nodeObject.destroy();
			
			else {
				var keys = struct_get_names(nodeObject);
				for (var i = 0, n = array_length(keys); i < n; i++) 
					if(is_instanceof(nodeObject[$ keys[i]], Node))
						nodeObject[$ keys[i]].destroy();
			}
		}
		
		if(panel) panel.remove();
		node.nodeTool = noone;
		UNDO_HOLDING = false;
	}
	
	function init() {
		
		applySelection = canvas.tool_selection.is_selected;
		destiSurface   = applySelection? canvas.tool_selection.selection_surface : canvas.getCanvasSurface();
		if(!is_surface(destiSurface))
			return noone;
		
		sw = surface_get_width(destiSurface);
		sh = surface_get_height(destiSurface);
		targetSurface = surface_create(sw, sh);
		maskedSurface = surface_create(sw, sh);
		
		surface_set_shader(targetSurface, noone);
			draw_surface_safe(destiSurface);
		surface_reset_shader();
		
		nodeObject = node.build(0, 0);
		
		if(nodeObject == noone || !is_instanceof(nodeObject, Node)) {
			noti_warning("Not tools only allows a single node.");
			destroy();
			return noone;
		}
		
		inputJunction  = noone;
		outputJunction = noone;
		
		setColor = true;
		
		for( var i = 0, n = array_length(nodeObject.inputs); i < n; i++ ) {
			var _in = nodeObject.inputs[i];
			if(_in.type == VALUE_TYPE.surface || _in.name == "Dimension")
				inputJunction = _in;
				
			if(_in.type == VALUE_TYPE.color && setColor) {
				_in.setValue(CURRENT_COLOR);
				setColor = false;
			}
				
		}
		
		for( var i = 0, n = array_length(nodeObject.outputs); i < n; i++ ) {
			var _in = nodeObject.outputs[i];
			if(_in.type == VALUE_TYPE.surface) {
				outputJunction = _in;
				break;
			}
		}
		
		if(outputJunction == noone) {
			noti_warning("Selected node has no surface output.");
			destroy();
			return noone;
		}
		
		New_Inspect_Node_Panel(nodeObject);
		
		return self;
	}
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	function apply() {
		var _surf = surface_create(sw, sh);
		var _repl = key_mod_press(SHIFT);
		
		if(applySelection) {
			var _fore = canvas.tool_selection.selection_surface;
			
			if(_repl) {
				surface_set_shader(_surf, noone);
					draw_surface_safe(maskedSurface);
				surface_reset_shader();
				
			} else {
				surface_set_shader(_surf, sh_blend_normal);
					shader_set_surface("fore",		maskedSurface);
					shader_set_f("dimension",		1, 1);
					shader_set_f("opacity",			1);
					
					draw_surface_safe(_fore);
				surface_reset_shader();
			}
			
			surface_free(_fore);
			canvas.tool_selection.selection_surface = _surf;
			canvas.tool_selection.apply();
			
		} else {
			var _fore = canvas.getCanvasSurface();
			canvas.storeAction();
			
			if(_repl) {
				surface_set_shader(_surf, noone);
					draw_surface_safe(maskedSurface);
				surface_reset_shader();
				
			} else {
				surface_set_shader(_surf, sh_blend_normal);
					shader_set_surface("fore",		maskedSurface);
					shader_set_f("dimension",		1, 1);
					shader_set_f("opacity",			1);
					
					draw_surface_safe(_fore);
				surface_reset_shader();
			}
			
			canvas.setCanvasSurface(_surf);
			canvas.surface_store_buffer();
		}
		
		PANEL_PREVIEW.tool_current = noone;
		
		cleanUp();
	}
	
	function step(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		
		var _px, _py, _pw, _ph;
		
		if(applySelection) {
			_px = canvas.tool_selection.selection_position[0];
			_py = canvas.tool_selection.selection_position[1];
			_pw = canvas.tool_selection.selection_size[0];
			_ph = canvas.tool_selection.selection_size[1];
			
		} else {
			_px = 0;
			_py = 0;
			_pw = canvas.attributes.dimension[0];
			_ph = canvas.attributes.dimension[1];
			
		}
		
		var _dx = _x + _px * _s;
		var _dy = _y + _py * _s;
		
		if(inputJunction) {
			if(inputJunction.type == VALUE_TYPE.surface)
				inputJunction.setValue(targetSurface);
			else if(inputJunction.name == "Dimension")
				inputJunction.setValue([ sw, sh ]);
		}
		if(is_instanceof(nodeObject, Node_Collection))
			RenderList(nodeObject.nodes);
		else 
			nodeObject.update();
		
		var _surf = outputJunction.getValue();
			
		if(applySelection) {
			maskedSurface = surface_verify(maskedSurface, sw, sh);
			surface_set_shader(maskedSurface);
				draw_surface_safe(_surf);
				BLEND_MULTIPLY
					draw_surface_safe(canvas.tool_selection.selection_mask);
				BLEND_NORMAL
			surface_reset_shader();
			
		} else
			maskedSurface = _surf;
		
		if(!key_mod_press(SHIFT))
			draw_surface_ext_safe(destiSurface,  _dx, _dy, _s, _s);
		draw_surface_ext_safe(maskedSurface, _dx, _dy, _s, _s);
		
		var hov = nodeObject.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
		
		if(is_undefined(hov) || !hov) {
			     if(mouse_press(mb_left, active))  { apply();	MOUSE_BLOCK = true; }
			else if(mouse_press(mb_right, active)) { destroy(); MOUSE_BLOCK = true; }
		}
	}
	
}