function Panel_Graph_Export_Image(_panel) : PanelContent() constructor {
	title   = __txtx("panel_export_graph", "Export Graph");
	padding = ui(8);
	
	w       = min(WIN_W, ui(800));
	h       = ui(400);
	
	min_w   = ui(640);
	min_h   = ui(320);
	
	set_w   = min(w / 2, ui(320));
	set_h   = h - padding * 2 - ui(32) - padding;
	
	surf_w  = w - set_w - padding * 2 - ui(16);
	surf_h  = h - padding * 2;
	
	targetPanel = _panel;
	nodeList    = targetPanel.nodes_list;
	surface     = noone;
	bg_surface  = noone;
	
	settings = {
		scale		: 1,
		padding		: 64,
		
		bgEnable	: false,
		bgColor		: cola(COLORS.panel_bg_clear),
		
		gridEnable  : false,
		gridColor   : cola(targetPanel.project.graphGrid.color),
		gridAlpha   : targetPanel.project.graphGrid.opacity,
		
		borderPad	: 0,
		borderColor	: cola(c_white),
		borderAlpha	: 0.05,
	};
	
	sel          = 0;
	nodes_select = [ "All nodes", "Selected" ];
	widgets      = [];
	
	widgets[0] = [ "Nodes", new scrollBox(nodes_select, 
		function(val) /*=>*/ { 
			sel      = val; 
			nodeList = val? targetPanel.nodes_selecting : targetPanel.nodes_list; 
			refresh(); 
		}, false),
		function() /*=>*/ {return nodes_select[sel]}  
	];
	
	widgets[1]  = [ "Scale",			new textBox(TEXTBOX_INPUT.number, function(val) /*=>*/ { settings.scale       = val; refresh(); }),                  function() /*=>*/ {return settings.scale}       ];
	widgets[2]  = [ "Padding",			new textBox(TEXTBOX_INPUT.number, function(val) /*=>*/ { settings.padding     = val; refresh(); }),                  function() /*=>*/ {return settings.padding}     ];
	widgets[3]  = [ "Solid Background",	new checkBox(                     function()    /*=>*/ { settings.bgEnable    = !settings.bgEnable; refresh(); }),   function() /*=>*/ {return settings.bgEnable}    ];
	widgets[4]  = [ "Background Color",	new buttonColor(                  function(val) /*=>*/ { settings.bgColor     = val; refresh(); }),                  function() /*=>*/ {return settings.bgColor}     ];
	widgets[5]  = [ "Render Grid",		new checkBox(                     function()    /*=>*/ { settings.gridEnable  = !settings.gridEnable; refresh(); }), function() /*=>*/ {return settings.gridEnable}  ];
	widgets[6]  = [ "Grid Color",		new buttonColor(                  function(val) /*=>*/ { settings.gridColor   = val; refresh(); }),                  function() /*=>*/ {return settings.gridColor}   ];
	widgets[7]  = [ "Grid Opacity",		new textBox(TEXTBOX_INPUT.number, function(val) /*=>*/ { settings.gridAlpha   = val; refresh(); }),                  function() /*=>*/ {return settings.gridAlpha}   ];
	widgets[8]  = [ "Border",			new textBox(TEXTBOX_INPUT.number, function(val) /*=>*/ { settings.borderPad   = val; refresh(); }),                  function() /*=>*/ {return settings.borderPad}   ];
	widgets[9]  = [ "Border Color",		new buttonColor(                  function(val) /*=>*/ { settings.borderColor = val; refresh(); }),                  function() /*=>*/ {return settings.borderColor} ];
	widgets[10] = [ "Border Opacity",	new textBox(TEXTBOX_INPUT.number, function(val) /*=>*/ { settings.borderAlpha = val; refresh(); }),                  function() /*=>*/ {return settings.borderAlpha} ];
	
	b_export = button(function() /*=>*/ {
		if(!is_surface(surface)) return;
		
		var path = get_save_filename_pxc("image|*.png;*.jpg", "Screenshot");
		if(path == -1) return;
		
		if(filename_ext(path) != ".png") path += ".png";
		surface_save(surface, path);
		noti_status($"Graph image exported at {path}");
	});
	
	b_export.text = __txt("Export") + "...";
	
	sc_settings = new scrollPane(set_w, set_h, function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear_inner, 1);
		
		var _ww = max(set_w * 0.5, ui(160));
		var _hh = ui(24);
		var _ss = ui(28);
		var _ty = _y + _hh / 2;
		var _tx = sc_settings.surface_w - ui(8);
		var  wh = _hh + ui(8);
		
		for( var i = 0, n = array_length(widgets); i < n; i++ ) {
			var _tyy = _ty + wh * i;
			
			draw_set_text(f_p3, fa_left, fa_center, COLORS._main_text);
			draw_text_add(ui(8), _tyy, __txt(widgets[i][0], "graph_export_"));
			
			var _wid = widgets[i][1];
			var _dat = widgets[i][2]();
			
			var _param = new widgetParam(_tx - _ww, _tyy - _hh / 2, _ww, _hh, _dat, {}, _m, sc_settings.x + x, sc_settings.y + y).setFont(f_p3);
			if(is(_wid, checkBox)) _param.x += _ww / 2 - _param.s / 2;
			
			_wid.setFocusHover(pFOCUS, pHOVER);
			_wid.drawParam(_param);
			
			if(_wid.inBBOX(_m)) 
				sc_settings.hover_content = true;
		}
		
		var _h = wh * array_length(widgets) + _hh;
		return _h;
	});
	
	function onResize() {
		set_w  = min(w / 2, ui(320));
		set_h  = h - padding * 2 - ui(32) - padding;
		
		surf_w = w - set_w - padding * 2 - ui(16);
		surf_h = h - padding * 2;
	}
	
	function refresh() {
		surface_free_safe(surface);
		surface = noone;
		if(nodeList == noone) return;
			
		surface = graph_export_image(targetPanel.nodes_list, nodeList, settings);
	} refresh();
	
	function drawContent(panel) {
		draw_clear(COLORS.panel_bg_clear);
		
		var tx = padding;
		var ty = padding;
		var sh = 160;
		
		var _sx0 = tx, _sx1 = _sx0 + surf_w;
		var _sy0 = h / 2 - surf_h / 2;
		var _sy1 = h / 2 + surf_h / 2;
		
		var _m = [ mx, my ];
		
		if(is_surface(surface)) {
			var _sw = surface_get_width_safe(surface);
			var _sh = surface_get_height_safe(surface);
			var  ss = min(surf_w / _sw, surf_h / _sh);
			
			bg_surface = surface_verify(bg_surface, _sw * ss, _sh * ss);
			surface_set_target(bg_surface);
				draw_sprite_tiled_ext(s_transparent, 0, 0, 0, 1, 1, COLORS.panel_preview_transparent, 1);
			surface_reset_target();
			
			var _sx = _sx0 + surf_w / 2 - _sw * ss / 2;
			var _sy = _sy0 + surf_h / 2 - _sh * ss / 2;
			
			draw_surface(bg_surface, _sx, _sy);
			draw_surface_ext_safe(surface, _sx, _sy, ss, ss, 0, c_white, 1);
			
			draw_set_text(f_p2, fa_center, fa_bottom, COLORS._main_text_sub);
			draw_text_add(_sx0 + surf_w / 2, _sy + _sh * ss - ui(2), $"{_sw} x {_sh} px");
			
			draw_set_color(COLORS._main_icon);
			draw_set_alpha(.5);
			draw_rectangle(_sx, _sy, _sx + _sw * ss, _sy + _sh * ss, 1);
			draw_set_alpha(1);
			
			var bx = _sx + _sw * ss - ui(24) - ui(4);
			var by = _sy            + ui(1)  + ui(4);
			
			if(buttonInstant(THEME.button_hide_fill, bx, by, ui(24), ui(24), _m, pHOVER, pFOCUS) == 2)
				refresh();
			draw_sprite_ui(THEME.refresh_16, 0, bx + ui(12), by + ui(12),,,, COLORS._main_icon, 1);
			
		} else {
			draw_set_color(COLORS._main_icon);
			draw_set_alpha(.5);
			draw_rectangle(_sx0, _sy0, _sx1, _sy1, 1);
			draw_set_alpha(1);
		}
		
		
		var sx = w - padding - set_w;
		var sy = ty;
		
		draw_sprite_stretched(THEME.ui_panel_bg, 1, sx - ui(8), sy, set_w + ui(8), h - padding * 2);
		
		sc_settings.verify(set_w - ui(8), set_h - ui(16));
		sc_settings.setFocusHover(pFOCUS, pHOVER);
		sc_settings.drawOffset(sx, sy + ui(8), mx, my);
		
		draw_set_text(f_p1, fa_left, fa_top, COLORS._main_text);
		var _bw = ui(96);
		var _bh = ui(32);
		bx = w - padding - ui(8) - _bw;
		by = h - padding - ui(8) - _bh;
		
		b_export.setInteract(is_surface(surface));
		b_export.setFocusHover(pFOCUS, pHOVER);
		b_export.draw(bx, by, _bw, _bh, _m);
	}
}