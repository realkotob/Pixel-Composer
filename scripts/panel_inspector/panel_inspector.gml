#region funtion calls
    
    function panel_inspector_copy_prop()                 { CALL("inspector_copy_property");          PANEL_INSPECTOR.propSelectCopy();                                                           }
    function panel_inspector_paste_prop()                { CALL("inspector_paste_property");         PANEL_INSPECTOR.propSelectPaste();                                                          }
    function panel_inspector_toggle_animation()          { CALL("inspector_toggle_animation");       PANEL_INSPECTOR.anim_toggling = true;                                                       }
    
    function panel_inspector_color_pick()                { CALL("color_picker");                     if(!PREFERENCES.alt_picker&& !MOUSE_BLOCK) return; PANEL_INSPECTOR.color_picking = true;    }
    
    function panel_inspector_section_expand_all()        { CALL("inspector_section_expand_all");     PANEL_INSPECTOR.section_expand_all();                                                       }
    function panel_inspector_section_collapse_all()      { CALL("inspector_section_collapse_all");   PANEL_INSPECTOR.section_collapse_all();                                                     }
    
    function panel_inspector_reset()                     { CALL("inspector_reset");                  PANEL_INSPECTOR.junction_reset();                                                           }
    function panel_inspector_add()                       { CALL("inspector_add");                    PANEL_INSPECTOR.junction_add();                                                             }
    function panel_inspector_remove()                    { CALL("inspector_remove");                 PANEL_INSPECTOR.junction_remove();                                                          }
    function panel_inspector_axis_combine()              { CALL("inspector_axis_combine");           PANEL_INSPECTOR.junction_axis_combine();                                                    }
    function panel_inspector_axis_separate()             { CALL("inspector_axis_separate");          PANEL_INSPECTOR.junction_axis_separate();                                                   }
    function panel_inspector_use_expression()            { CALL("inspector_use_expression");         PANEL_INSPECTOR.junction_use_expression();                                                  }
    function panel_inspector_disable_expression()        { CALL("inspector_disable_expression");     PANEL_INSPECTOR.junction_disable_expression();                                              }
    function panel_inspector_extract_global()            { CALL("inspector_extract_global");         PANEL_INSPECTOR.junction_extract_global();                                                  }
    function panel_inspector_extract_single()            { CALL("inspector_extract_single");         PANEL_INSPECTOR.junction_extract_single();                                                  }
    function panel_inspector_junction_bypass_toggle()    { CALL("inspector_junc_bypass");            PANEL_INSPECTOR.junction_bypass_toggle();                                                   }
    
    function __fnInit_Inspector() {
        registerFunction("", "Color Picker",                   "",    MOD_KEY.alt,     panel_inspector_color_pick           ).setMenu("color_picker")
        
        registerFunction("Inspector", "Copy Value",            "C",   MOD_KEY.ctrl,    panel_inspector_copy_prop            ).setMenu("inspector_copy_property",  THEME.copy)
        registerFunction("Inspector", "Paste Value",           "V",   MOD_KEY.ctrl,    panel_inspector_paste_prop           ).setMenu("inspector_paste_property", THEME.paste)
        registerFunction("Inspector", "Toggle Animation",      "I",   MOD_KEY.none,    panel_inspector_toggle_animation     ).setMenu("inspector_toggle_animation")
        
        registerFunction("Inspector", "Expand All Sections",   "",    MOD_KEY.none,    panel_inspector_section_expand_all   ).setMenu("inspector_expand_all_sections")
        registerFunction("Inspector", "Collapse All Sections", "",    MOD_KEY.none,    panel_inspector_section_collapse_all ).setMenu("inspector_collapse_all_sections")
        
        registerFunction("Inspector", "Reset",                 "",    MOD_KEY.none,    panel_inspector_reset                  ).setMenu("inspector_reset")
        registerFunction("Inspector", "Animate",               "",    MOD_KEY.none,    panel_inspector_add                    ).setMenu("inspector_animate")
        registerFunction("Inspector", "Reset Animation",       "",    MOD_KEY.none,    panel_inspector_remove                 ).setMenu("inspector_remove_animate")
        registerFunction("Inspector", "Combine Axis",          "",    MOD_KEY.none,    panel_inspector_axis_combine           ).setMenu("inspector_combine_axis")
        registerFunction("Inspector", "Separate Axis",         "",    MOD_KEY.none,    panel_inspector_axis_separate          ).setMenu("inspector_separate_axis")
        registerFunction("Inspector", "Use Expression",        "",    MOD_KEY.none,    panel_inspector_use_expression         ).setMenu("inspector_use_expression")
        registerFunction("Inspector", "Disable Expression",    "",    MOD_KEY.none,    panel_inspector_disable_expression     ).setMenu("inspector_disable_expression")
        registerFunction("Inspector", "Extract to Globalvar",  "",    MOD_KEY.none,    panel_inspector_extract_global         ).setMenu("inspector_extract_global")
        registerFunction("Inspector", "Extract Value",         "",    MOD_KEY.none,    panel_inspector_extract_single         ).setMenu("inspector_extract_value")
        registerFunction("Inspector", "Toggle Bypass",         "",    MOD_KEY.none,    panel_inspector_junction_bypass_toggle ).setMenu("inspector_bypass_toggle")
        
        __fnGroupInit_Inspector();
    }
    
    function __fnGroupInit_Inspector() {
        var _clrs = COLORS.labels;
        var _item = array_create(array_length(_clrs));
    
        for( var i = 0, n = array_length(_clrs); i < n; i++ ) {
            _item[i] = [ 
                [ THEME.timeline_color, i > 0, _clrs[i] ], 
                function(_data) { PANEL_INSPECTOR.setSelectingItemColor(_data.color); }, "", { color: i == 0? -1 : _clrs[i] }
            ];
        }
        
        array_push(_item, [ 
            [ THEME.timeline_color, 2 ], 
            function(_data) { colorSelectorCall(PANEL_INSPECTOR.__dialog_junction? PANEL_INSPECTOR.__dialog_junction.color : c_white, PANEL_INSPECTOR.setSelectingItemColor); }
        ]);
        
        MENU_ITEMS.inspector_group_set_color = menuItemGroup(__txt("Color"), _item, ["Inspector", "Set Color"]).setSpacing(ui(24));
        registerFunction("Inspector", "Set Color", "", MOD_KEY.none, function() /*=>*/ { menuCall("", [ MENU_ITEMS.inspector_group_set_color ]); });
        
        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
    }
#endregion

function Inspector_Custom_Renderer(drawFn, registerFn = noone) : widget() constructor {
    self.draw = drawFn;
    node  = noone;
    panel = noone;
    name  = "";
    
    popupPanel  = noone;
    popupDialog = noone;
    
    h = 64;
    fixHeight = -1;
    
    if(registerFn != noone) register = registerFn;
    else {
        register = function(parent = noone) { 
            if(!interactable) return;
            self.parent = parent;
        }
    }
    
    b_toggle = button(function() /*=>*/ { togglePopup(name); }).setIcon(THEME.node_goto, 0, COLORS._main_icon, .75);
    
    static setName  = function(name) { self.name = name; return self; }
    static setNode  = function(node) { self.node = node; return self; }
    static toString = function()     { return $"Custon renderer: {name}"; }
    
    static step = function() {
        b_toggle.icon_blend = popupPanel == noone? COLORS._main_icon : COLORS._main_accent;
    }
    
    static togglePopup = function(_title) { 
        if(popupPanel == noone) {
            popupPanel  = new Panel_Custom_Inspector(_title, self);
            popupDialog = dialogPanelCall(popupPanel);
            return;
        }
        
        if(instance_exists(popupDialog))
            instance_destroy(popupDialog);
            
        if(is(popupPanel, PanelContent))
            popupPanel.close();
        
        popupPanel = noone;
    }
    
    static clone    = function() { 
        var _n = new Inspector_Custom_Renderer(draw, register);
        var _key = variable_instance_get_names(self);
        
        for( var i = 0, n = array_length(_key); i < n; i++ ) 
            _n[$ _key[i]] = self[$ _key[i]];
        
        return _n;
    }
}

function Inspector_Sprite(spr) constructor { self.spr = spr; }

function Inspector_Label( text, font = f_p3) constructor { 
    self.text = text; 
    self.font = font; 
    
    open = true;
}

function Inspector_Spacer(height, line = false, coll = true) constructor { 
    self.h = height;  
    self.line = line; 
    self.coll = coll; 
}

function Panel_Inspector() : PanelContent() constructor {
    #region ---- main ----
        context_str = "Inspector";
        title       = __txt("Inspector");
        icon        = THEME.panel_inspector_icon;
    
        w     = ui(400);
        h     = ui(640);
        min_w = ui(160);
        
        locked       = false;
        focusable    = true;
        
        inspecting   = noone;
        inspectings  = [];
        inspectGroup = false;
        top_bar_h    = ui(100);
        
        static initSize = function() {
            content_w = w - ui(32);
            content_h = h - top_bar_h - ui(12);
        }
        initSize();
        
        view_mode_tooltip = new tooltipSelector("View", [ "Compact", "Spacious" ])
    #endregion
    
    #region ---- properties ----
        prop_hover      = noone;
        prop_selecting  = noone;
        
        prop_highlight      = noone;
        prop_highlight_time = 0;
    
        prop_dragging       = noone;
        prop_sel_drag_x     = 0;
        prop_sel_drag_y     = 0;
    
        color_picking = false;
        picker_index  = 0;
        picker_change = false;
        
        attribute_hovering = noone;
    #endregion
    
    drawWidgetInit();
    
    #region ---- header labels ----
        tb_node_name        = new textBox(TEXTBOX_INPUT.text, function(txt) /*=>*/ { if(inspecting) inspecting.setDisplayName(txt); });
        tb_node_name.format = TEXT_AREA_FORMAT.node_title;
        tb_node_name.font   = f_h5;
        tb_node_name.align  = fa_center;
        tb_node_name.hide   = true;
        
        tb_prop_filter             = new textBox(TEXTBOX_INPUT.text, function(txt) /*=>*/ { filter_text = txt; });
        tb_prop_filter.no_empty    = false;
        tb_prop_filter.auto_update = true;
        tb_prop_filter.font        = f_p0;
        tb_prop_filter.color       = COLORS._main_text_sub;
        tb_prop_filter.align       = fa_center;
        tb_prop_filter.hide        = true;
        filter_text = "";
    	
        prop_page   = 0;
        prop_page_b = new buttonGroup([ "Properties", "Settings", THEME.message_16 ], function(val) /*=>*/ { prop_page = val; })
   							.setButton([ THEME.button_hide_left, THEME.button_hide_middle, THEME.button_hide_right ])
   							.setFont(f_p2, COLORS._main_text_sub)
        
        proj_prop_page   = 0;
        proj_prop_page_b = new buttonGroup([ "PXC", "GM" ], function(val) /*=>*/ { proj_prop_page = val; })
        					.setButton([ THEME.button_hide_left, THEME.button_hide_middle, THEME.button_hide_right ])
        					.setFont(f_p2, COLORS._main_text_sub)
    #endregion
    
    #region ---- metadata ----
        current_meta = -1;
        meta_tb[0] = new textArea(TEXTBOX_INPUT.text, function(str) { current_meta.description = str; });    
        meta_tb[1] = new textArea(TEXTBOX_INPUT.text, function(str) { current_meta.author      = str; });
        meta_tb[2] = new textArea(TEXTBOX_INPUT.text, function(str) { current_meta.contact     = str; });
        meta_tb[3] = new textArea(TEXTBOX_INPUT.text, function(str) { current_meta.alias       = str; });
        meta_tb[4] = new textArrayBox(noone, META_TAGS);
        for( var i = 0, n = array_length(meta_tb); i < n; i++ )
            meta_tb[i].hide = true;
        
        meta_display = [ 
            [ __txt("Project Settings"),    false, "settings"   ], 
            [ __txt("Metadata"),            true , "metadata"   ], 
            [ __txt("Global variables"),    false, "globalvar"  ], 
            [ __txt("Group Properties"),    false, "group prop" ], 
        ];
        
        meta_steam_avatar = new checkBox(function() { STEAM_UGC_ITEM_AVATAR = !STEAM_UGC_ITEM_AVATAR; });
        
        global_button_edit = button(function() /*=>*/ { meta_display[2][1] = false; global_drawer.editing = !global_drawer.editing; }).setIcon(THEME.gear_16, 0, COLORS._main_icon_light);
        global_button_new  = button(function() /*=>*/ { meta_display[2][1] = false; PROJECT.globalNode.createValue(); }).setIcon(THEME.add_16,  0, COLORS._main_value_positive);
        global_buttons         = [ global_button_edit ];
        global_buttons_editing = [ global_button_edit, global_button_new ];
        
        global_drawer = new GlobalVarDrawer();
        
        GM_Explore_draw_init();
        
        metadata_default_button = button(function() /*=>*/ { json_save_struct(DIRECTORY + "meta.json", PROJECT.meta.serialize()); })
        	.setIcon(THEME.save,  0, COLORS._main_icon_light, .75)
        	.setTooltip(__txtx("panel_inspector_set_default", "Set as default"));
        	
        metadata_buttons = [ metadata_default_button ];
    #endregion
    
    #region ---- workshop ----
        workshop_uploading = false;
    #endregion
    
    #region ++++ menus ++++
        static nodeExpandAll = function(node) {
            if(node.input_display_list == -1) return;
            
            var dlist = node.input_display_list;
            for( var i = 0, n = array_length(dlist); i < n; i++ ) {
                if(!is_array(dlist[i])) continue;
                dlist[i][@ 1] = false;
            }
        }
        
        static nodeCollapseAll = function(node) {
            if(node.input_display_list == -1) return;
            
            var dlist = node.input_display_list;
            for( var i = 0, n = array_length(dlist); i < n; i++ ) {
                if(!is_array(dlist[i])) continue;
                dlist[i][@ 1] = true;
            }
        }
        
        function section_expand_all() {
            if(inspecting != noone) nodeExpandAll(inspecting);
            for( var i = 0, n = array_length(inspectings); i < n; i++ ) 
                nodeExpandAll(inspectings[i]);
        }
        
        function section_collapse_all() {
            if(inspecting != noone) nodeCollapseAll(inspecting);
            for( var i = 0, n = array_length(inspectings); i < n; i++ ) 
                nodeCollapseAll(inspectings[i]);
        }
        
        function junction_reset()              { if(__dialog_junction == noone) return; __dialog_junction.resetValue();            }
        function junction_add()                { if(__dialog_junction == noone) return; __dialog_junction.setAnim(true, true);     }
        function junction_remove()             { if(__dialog_junction == noone) return; __dialog_junction.setAnim(false, true);    }
        function junction_axis_combine()       { if(__dialog_junction == noone) return; __dialog_junction.sep_axis = false;        }
        function junction_axis_separate()      { if(__dialog_junction == noone) return; __dialog_junction.sep_axis = true;         }
        function junction_use_expression()     { if(__dialog_junction == noone) return; __dialog_junction.expUse = true;           }
        function junction_disable_expression() { if(__dialog_junction == noone) return; __dialog_junction.expUse = false;          }
        function junction_extract_global()     { if(__dialog_junction == noone) return; __dialog_junction.extractGlobal();         }
        function junction_extract_single()     { if(__dialog_junction == noone) return; __dialog_junction.extractNode();           }
        function junction_bypass_toggle()      { 
            if(__dialog_junction == noone || __dialog_junction.bypass_junc == noone) return; 
            __dialog_junction.bypass_junc.visible = !__dialog_junction.bypass_junc.visible;
            __dialog_junction.node.refreshNodeDisplay();
        }
        
        group_menu = [
            MENU_ITEMS.inspector_expand_all_sections,
            MENU_ITEMS.inspector_collapse_all_sections,
        ]
        
        __dialog_junction = noone;
        menu_junc_reset_value      = MENU_ITEMS.inspector_reset;
        menu_junc_add_anim         = MENU_ITEMS.inspector_animate;
        menu_junc_rem_anim         = MENU_ITEMS.inspector_remove_animate;
        menu_junc_combine_axis     = MENU_ITEMS.inspector_combine_axis;
        menu_junc_separate_axis    = MENU_ITEMS.inspector_separate_axis;
        menu_junc_expression_ena   = MENU_ITEMS.inspector_use_expression;
        menu_junc_expression_dis   = MENU_ITEMS.inspector_disable_expression;
        menu_junc_extract_global   = MENU_ITEMS.inspector_extract_global;
        menu_junc_extract          = MENU_ITEMS.inspector_extract_value;
        menu_junc_bypass_toggle    = MENU_ITEMS.inspector_bypass_toggle;
        
        menu_junc_copy             = MENU_ITEMS.inspector_copy_property;
        menu_junc_paste            = MENU_ITEMS.inspector_paste_property;
        
        function setSelectingItemColor(color) { 
            if(__dialog_junction == noone) return; 
            
            __dialog_junction.setColor(color);
            
            var _val_to = __dialog_junction.getJunctionTo();
            for( var i = 0, n = array_length(_val_to); i < n; i++ ) 
                _val_to[i].setColor(color);
        }
        
        menu_junc_color = MENU_ITEMS.inspector_group_set_color;
    #endregion
    
    function setInspecting(inspecting, _lock = false, _focus = true) {
        if(locked) return;
        
        self.inspecting = inspecting;
        if(_lock) locked = true;
        focusable = _focus;
        
        if(inspecting != noone)
            inspecting.onInspect();
        contentPane.scroll_y    = 0;
        contentPane.scroll_y_to = 0;
            
        picker_index = 0;
    }
    
    function getInspecting() {
        if(inspecting == noone) return noone;
        return inspecting.active? inspecting : noone;
    }
    
    function onFocusBegin() { if(!focusable) return; PANEL_INSPECTOR = self; }
    
    function onResize() {
        initSize();
        contentPane.resize(content_w, content_h);
    }
    
    ////- Property actions
    
    static highlightProp = function(prop) {
        prop_highlight      = prop;
        prop_highlight_time = 60;
    }
    
    function propSelectCopy()  { 
    	if(!prop_selecting) return; 
    	clipboard_set_text(prop_selecting.getString()); 
    }
    
    function propSelectPaste() { 
    	if(!prop_selecting) return; 
    	prop_selecting.setString(clipboard_get_text()); 
    }
    
    ////- DRAW
    
    contentPane = new scrollPane(content_w, content_h, function(_y, _m) { 
        draw_clear_alpha(COLORS.panel_bg_clear_inner, 1);
        
        if(inspecting == noone) 
        	return drawContentMeta(_y, _m);
        return drawContentNode(_y, _m);
    });
    
    static drawContentGM = function(_y, _m) {
    	var ww = contentPane.surface_w;
    	var hh = ui(40);
        var yy = _y + hh;
        var rx = x + ui(16);
        var ry = y + top_bar_h;
        
        var _hover = pHOVER && contentPane.hover;
        var  spac  = viewMode == INSP_VIEW_MODE.spacious;
    	var _font  = spac? f_p1 : f_p2;
        
        #region properties
	        var _wdx = 0;
	        var _wdy = yy;
	        var _wdw = ww;
	        var _wdh = TEXTBOX_HEIGHT;
	        
	        var _data  = PROJECT.attributes.bind_gamemaker_path;
	    	var _param = new widgetParam(_wdx, _wdy, _wdw, _wdh, _data, {}, _m, rx, ry)
	    					.setFont(_font)
	    					.setFocusHover(pFOCUS, _hover)
	    					.setScrollpane(contentPane);
            
	        var wh = PROJECT.gamemaker_editWidget.drawParam(_param);
	    	
	    	var _wdhh = wh + ui(8);
        	yy += _wdhh; 
        	hh += _wdhh;
		#endregion
		
		var gmBinder = PROJECT.bind_gamemaker;
		if(gmBinder == noone) return hh;
		
		var _wdh = GM_Explore_draw(gmBinder, 0, yy, contentPane.surface_w, contentPane.surface_h, _m, _hover, pFOCUS);
		hh += _wdh;
		
		return hh;
    }
    
    static drawContentMeta = function(_y, _m) {
        proj_prop_page_b.setFocusHover(pFOCUS, pHOVER);
        proj_prop_page_b.draw(ui(32), _y + ui(4), contentPane.w - ui(76), ui(24), proj_prop_page, _m, x + contentPane.x, y + contentPane.y);
        
        if(proj_prop_page == 1) return drawContentGM(_y, _m);
        
        var context = PANEL_GRAPH.getCurrentContext();
        var meta    = context == noone? PROJECT.meta : context.metadata;
        if(meta == noone) return 0;
        current_meta = meta;
        
        var  con_w = contentPane.surface_w - ui(4);
        var _hover = pHOVER && contentPane.hover;
        var  spac  = viewMode == INSP_VIEW_MODE.spacious;
        
        var hh  = ui(40);
        var yy  = _y + hh;
        var rx  = x + ui(16);
        var ry  = y + top_bar_h;
        var lbh = viewMode? ui(32) : ui(26);
        var _cAll = 0;
        var _font = spac? f_p1 : f_p2;
        
        attribute_hovering = noone;
        
        for( var i = 0, n = array_length(meta_display); i < n; i++ ) {
            if(i == 3 && PANEL_GRAPH.getCurrentContext() == noone) continue;
            
            var _meta  = meta_display[i];
            var _txt   = array_safe_get_fast(_meta, 0);
            var _tag   = array_safe_get_fast(_meta, 2);
            var _butts = noone;
            
            switch(_tag) { // header
            	case "metadata"  : _butts = metadata_buttons; break;
                case "globalvar" : _butts = global_drawer.editing? global_buttons_editing : global_buttons; break;
            }
            
            var _x1 = con_w;
            var _y1 = yy + ui(2);
                
            if(is_array(_butts)) {
            	var _bw = ui(28);
                var _bh = lbh - ui(4);
                
                var _amo = array_length(_butts);
                var _tw  = (_bw + ui(4)) * _amo;
                draw_sprite_stretched_ext(THEME.box_r5_clr, 0, con_w - _tw, yy, _tw, lbh, COLORS.panel_inspector_group_bg, 1);
                
                global_button_edit.icon       = global_drawer.editing? THEME.accept_16 : THEME.gear_16;
                global_button_edit.icon_blend = global_drawer.editing? COLORS._main_value_positive : COLORS._main_icon_light;
                
                for (var j = 0, m = array_length(_butts); j < m; j++) {
                    _x1 -= _bw + ui(4);
                    
                    var _b = _butts[j];
                        _b.setFocusHover(pFOCUS, _hover);
                        _b.draw(_x1 + ui(2), _y1, _bw, _bh, _m, THEME.button_hide_fill);
                    if(_b.inBBOX(_m)) contentPane.hover_content = true;
                }
                
                _x1 -= ui(4);
            }
            
            var cc = COLORS.panel_inspector_group_bg;
            
            if(_hover && point_in_rectangle(_m[0], _m[1], 0, yy, _x1, yy + lbh)) {
            	cc = COLORS.panel_inspector_group_hover;
                
                if(pFOCUS) {
                    	 if(DOUBLE_CLICK) _cAll = _meta[1]? -1 : 1;
                    else if(mouse_press(mb_left)) _meta[1] = !_meta[1];
                }
            }
            
            draw_sprite_stretched_ext(THEME.box_r5_clr, 0, 0, yy, _x1, lbh, cc, 1);
            
            draw_sprite_ui(THEME.arrow, _meta[1]? 0 : 3, ui(16), yy + lbh / 2, 1, 1, 0, COLORS.panel_inspector_group_bg, 1);    
            
            draw_set_text(viewMode? f_p0 : f_p1, fa_left, fa_center, COLORS._main_text_inner);
            draw_text_add(ui(32), yy + lbh / 2, _txt);
            
            yy += lbh + ui(viewMode? 8 : 6);
            hh += lbh + ui(viewMode? 8 : 6);
            
            if(_meta[1]) continue;
            
            switch(_tag) {
                case "settings" :
                    var _edt = PROJECT.attributeEditor;
                    var _lh, wh;
                    
                    for( var j = 0; j < array_length(_edt); j++ ) {
                        var title = array_safe_get(_edt[j], 0, noone);
                        var param = array_safe_get(_edt[j], 1, noone);
                        var editW = array_safe_get(_edt[j], 2, noone);
                        var drpFn = array_safe_get(_edt[j], 3, noone);
                        
                        var widx = ui(8);
                        var widy = yy;
                        
                        draw_set_text(_font, fa_left, fa_top, COLORS._main_text_inner);
                        draw_text_add(ui(16), spac? yy : yy + ui(3), __txt(title));
                        
                        if(spac) {
                            _lh = line_get_height();
                            yy += _lh + ui(6);
                            hh += _lh + ui(6);
                            
                        } else if(viewMode == INSP_VIEW_MODE.compact) {
                            _lh = line_get_height() + ui(6);
                        }
                        
                        var wh = 0;
                        var _data = PROJECT.attributes[$ param];
                        var _wdx  = spac? ui(16) : ui(140);
                        var _wdy  = yy;
                        var _wdw  = w - ui(48) - _wdx;
                        var _wdh  = spac? TEXTBOX_HEIGHT  : _lh;
                        
                        var _param = new widgetParam(_wdx, _wdy, _wdw, _wdh, _data, {}, _m, rx, ry)
                        					.setFont(_font)
					    					.setScrollpane(contentPane);
					    					
                        editW.setFocusHover(pFOCUS, _hover);
                        wh = editW.drawParam(_param);
                        
                        var jun  = PANEL_GRAPH.value_dragging;
                        var widw = con_w - ui(16);
                        var widh = spac? _lh + ui(6) + wh + ui(4) : max(wh, _lh);
                        
                        if(jun != noone && drpFn != noone && _hover && point_in_rectangle(_m[0], _m[1], widx, widy, widx + widw, widy + widh)) {
                            draw_sprite_stretched_ext(THEME.ui_panel, 1, widx, widy, widw, widh, COLORS._main_value_positive, 1);
                            attribute_hovering = drpFn;
                        }
                        
				    	var _wdhh = spac? wh + ui(8) : max(wh, _lh) + ui(6);
			        	yy += _wdhh; 
			        	hh += _wdhh;
                    }
                    
                    break;
                    
                case "metadata" :
                    var _wdx = spac? ui(16) : ui(140);
                    var _wdw = w - ui(48) - _wdx;
                    var _whh = line_get_height(_font);
                    var _edt = PROJECT.meta.steam == FILE_STEAM_TYPE.local || PROJECT.meta.author_steam_id == STEAM_USER_ID;
                        
                    for( var j = 0; j < array_length(meta.displays); j++ ) {
                        var display = meta.displays[j];
                        var _wdgt   = meta_tb[j];
                        
                        draw_set_text(_font, fa_left, fa_top, COLORS._main_text_inner);
                        draw_text_add(ui(16), spac? yy : yy + ui(3), __txt(display[0]));
                        
                        if(spac) {
                            _lh = line_get_height();
                            yy += _lh + ui(6);
                            hh += _lh + ui(6);
                            
                        } else if(viewMode == INSP_VIEW_MODE.compact) {
                            _lh = line_get_height() + ui(6);
                        }
                        
                        var _dataFunc = display[1];
                        var _data = _dataFunc(meta);
                        var _wdy  = yy;
                        var _wdh  = _whh * display[2];
                        
                        var _param = new widgetParam(_wdx, _wdy, _wdw, _wdh, _data, {}, _m, rx, ry)
                        					.setFont(_font)
					    					.setFocusHover(pFOCUS, _hover, _edt)
					    					.setScrollpane(contentPane);
                        
                        if(is(_wdgt, textArrayBox)) _wdgt.arraySet = current_meta.tags;
                        wh = _wdgt.drawParam(_param);
                        
				    	var _wdhh = spac? wh + ui(8) : max(wh, _lh) + ui(6);
			        	yy += _wdhh; 
			        	hh += _wdhh;
                    }
                    
                    if(STEAM_ENABLED && _edt) {
                        draw_set_text(_font, fa_left, fa_top, COLORS._main_text_inner);
                        draw_text_over(ui(16), spac? yy : yy + ui(3), __txt("Show Avatar"));
                        
                        if(spac) {
                            _lh = line_get_height();
                            yy += _lh + ui(6);
                            hh += _lh + ui(6);
                        }
                        
                        var _param = new widgetParam(_wdx, yy, _wdw, TEXTBOX_HEIGHT, STEAM_UGC_ITEM_AVATAR, {}, _m, rx, ry)
                        					.setFont(_font)
					    					.setFocusHover(pFOCUS, _hover)
					    					.setScrollpane(contentPane);
                        
                        wh = meta_steam_avatar.drawParam(_param);
                        
				    	var _wdhh = spac? wh + ui(8) : wh + ui(6);
			        	yy += _wdhh; 
			        	hh += _wdhh;
                    }
                    
                    break;
                    
                case "globalvar" : 
                    // if(findPanel("Panel_Globalvar")) { yy += ui(4); hh += ui(4); continue; }
                    if(_m[1] > yy) contentPane.hover_content = true;
                    
                    global_drawer.viewMode = viewMode;
                    var glPar = global_drawer.draw(ui(16), yy, contentPane.surface_w - ui(24), _m, pFOCUS, _hover, contentPane, ui(16) + x, top_bar_h + y);
                    var gvh   = glPar[0];
                    
                    yy += gvh + ui(8);
                    hh += gvh + ui(8);
                    break;
                    
                case "group prop" :
                    var context = PANEL_GRAPH.getCurrentContext();
                    var _h = drawNodeProperties(yy, _m, context);
                    
                    yy += _h;
                    hh += _h;
                    break;
            }
            
            yy += ui(viewMode? 4 : 2);
            hh += ui(viewMode? 4 : 2);
        }
        
        	 if(_cAll ==  1) { for( var i = 0, n = array_length(meta_display); i < n; i++ ) meta_display[i][1] = false; }
		else if(_cAll == -1) { for( var i = 0, n = array_length(meta_display); i < n; i++ ) meta_display[i][1] =  true; }
		
        return hh;
    }
    
    static drawContentNode = function(_y, _m) {
        var con_w  = contentPane.surface_w - ui(4);
        if(point_in_rectangle(_m[0], _m[1], 0, 0, con_w, content_h) && mouse_press(mb_left, pFOCUS))
            prop_selecting = noone;
        
        prop_page_b.data[2] = inspecting.messages_bub? THEME.message_16_grey_bubble : THEME.message_16_grey;
        prop_page_b.setFocusHover(pFOCUS, pHOVER);
        prop_page_b.draw(ui(32), _y + ui(4), contentPane.w - ui(76), ui(24), prop_page, _m, x + contentPane.x, y + contentPane.y);
        
        var _hh = ui(40);
        _y += _hh;
        
        if(is(inspecting, Node_Canvas) && inspecting.nodeTool != noone && is(inspecting.nodeTool.nodeObject, Node))
            return _hh + drawNodeProperties(_y, _m, inspecting.nodeTool.nodeObject);
        
        if(inspectGroup >= 0)           return _hh + drawNodeProperties(_y, _m, inspecting);
        if(is(inspecting, Node_Frame))  return _hh + drawNodeProperties(_y, _m, inspecting);
        
        for( var i = 0, n = min(10, array_length(inspectings)); i < n; i++ ) {
            if(i) {
                _y  += ui(8);
                _hh += ui(8);
            }
            
            if(n > 1) {
                draw_sprite_stretched_ext(THEME.box_r5_clr, 0, 0, _y, con_w, ui(32), COLORS.panel_inspector_output_label, 0.9);
                draw_set_text(f_p0b, fa_center, fa_center, COLORS._main_text_sub);
                
                var _tx = inspectings[i].getFullName();
                draw_text_add(con_w / 2, _y + ui(16), _tx);
                
                _y  += ui(32 + 8);
                _hh += ui(32 + 8);
            }
            
            var _h = drawNodeProperties(_y, _m, inspectings[i]);
            _y  += _h;
            _hh += _h;
        }
        
        return _hh + ui(64);
    }
    
    static drawNodeProperties = function(_y, _m, _inspecting = inspecting) {
        var con_w  = contentPane.surface_w - ui(4); 
        var _hover = pHOVER && contentPane.hover;
        
        _inspecting.inspecting = true;
        
        //tb_prop_filter.register(contentPane);
        //tb_prop_filter.setFocusHover(pHOVER, pFOCUS);
        //tb_prop_filter.draw(ui(32), _y + ui(4), con_w - ui(64), ui(28), filter_text, _m);
        //draw_sprite_ui(THEME.search, 0, ui(32 + 16), _y + ui(4 + 14), 1, 1, 0, COLORS._main_icon, 1);
        
        var hh = 0;
        var xc = con_w / 2;
        
        if(prop_page == 1) { // attribute/settings editor
            hh += ui(8);
            var hg  = ui(32);
            var yy  = _y + hh;
            var wx1 = con_w - ui(8);
            var ww  = max(ui(180), con_w / 3);
            var wx0 = wx1 - ww;
            var font  = viewMode == INSP_VIEW_MODE.spacious? f_p1 : f_p2;
            
            for( var i = 0, n = array_length(_inspecting.attributeEditors); i < n; i++ ) {
                var edt = _inspecting.attributeEditors[i];
                
                if(is_string(edt)) { // label
                    var lby = yy + ui(12);
                    draw_set_alpha(0.5);
                    draw_set_text(f_p1, fa_center, fa_center, COLORS._main_text_sub);
                    draw_text_add(xc, lby, edt);
                    
                    var lbw = string_width(edt) / 2;
                    draw_set_color(COLORS._main_text_sub);
                    draw_line_round(xc + lbw + ui(16), lby,   wx1, lby, 2);
                    draw_line_round(xc - lbw - ui(16), lby, ui(8), lby, 2);
                    draw_set_alpha(1.0);
                    
                    yy += ui(32);
                    hh += ui(32);
                    continue;
                }
                
                var _att_name = edt[0];
                var _att_val  = edt[1]();
                var _att_wid  = edt[2];
                var _att_h    = viewMode == INSP_VIEW_MODE.spacious? hg : line_get_height(font, 8);
                
                _att_wid.font = font;
                _att_wid.setFocusHover(pFOCUS, pHOVER);
                
                if(instanceof(_att_wid) == "buttonClass") {
                    _att_wid.text = _att_name;
                    _att_wid.draw(ui(8), yy, con_w - ui(16), _att_h, _m); 
                    
                    if(_att_wid.inBBOX(_m)) contentPane.hover_content = true;
                    yy += _att_h + ui(8);
                    hh += _att_h + ui(8);
                    continue;
                } 
                
                draw_set_text(font, fa_left, fa_center, COLORS._main_text);
                draw_text_add(ui(8), yy + _att_h / 2, _att_name);
                
                var _param = new widgetParam(wx0, yy, ww, _att_h, _att_val, {}, _m, x + contentPane.x, y + contentPane.y);
                    _param.s    = _att_h;
                    _param.font = font;
                    
                var _wh = _att_wid.drawParam(_param);
                
                if(_att_wid.inBBOX(_m)) contentPane.hover_content = true;
                
                var _hg = max(_att_h, _wh);
                yy += _hg + ui(8);
                hh += _hg + ui(8);
            }
            return hh;
            
        } 
        
        if(prop_page == 2) { 
            var _logs = _inspecting.messages;
            _inspecting.messages_bub = false;
            var _tmw  = ui(64);
            var yy = _y;
            var hh = ui(64);
            
            var con_w = contentPane.surface_w;
            var con_h = contentPane.surface_h - yy;
            
            draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, 0, yy, con_w, con_h, merge_color(CDEF.main_ltgrey, CDEF.main_white, 0.5));
            yy += ui(8);
            
            for (var i = array_length(_logs) - 1; i >= 0; i--) {
                var _log = _logs[i];
                
                var _time = _log[0];
                var _text = _log[1];
                
                draw_set_text(f_p3, fa_left, fa_top, COLORS._main_text_sub);
                var _hg = string_height_ext(_text, -1, con_w - _tmw - ui(10 + 8)) + ui(4);
                if(i % 2) draw_sprite_stretched_ext(THEME.ui_panel_bg, 4, ui(4), yy, con_w - ui(8), _hg, CDEF.main_dkblack, 0.25);
                
                draw_text_add(ui(10), yy + ui(2), _time);
                
                draw_set_color(COLORS._main_text);
                draw_text_ext_add(_tmw + ui(10), yy + ui(2), _text, -1, con_w - _tmw - ui(10 + 8));
                
                yy += _hg;
                hh += _hg;
            }
            
            return hh;
        }
        
        prop_hover  = noone;
        var jun     = noone;
        var amoIn   = is_array(_inspecting.input_display_list)?  array_length(_inspecting.input_display_list)  : array_length(_inspecting.inputs);
        var amoOut  = is_array(_inspecting.output_display_list)? array_length(_inspecting.output_display_list) : array_length(_inspecting.outputs);
        var amoMeta = _inspecting.attributes.outp_meta? array_length(_inspecting.junc_meta) : 0;
        
        var amo     = inspectGroup == 0? amoIn + 1 + amoOut + amoMeta : amoIn;
        
        var color_picker_index = 0;
        var pickers            = [];
        var _colsp             = false;
        var _cAll = 0;
        
        for(var i = 0; i < amo; i++) {
            var yy = hh + _y;
            
            if(i < amoIn) { // inputs
                var _dsl = _inspecting.input_display_list;
                var _dsp = array_safe_get_fast(_dsl, i);
                
                     if(!is_array(_dsl))  jun = array_safe_get_fast(_inspecting.inputs, i);
                else if(is_real(_dsp))    jun = array_safe_get_fast(_inspecting.inputs, _dsp);
                else                      jun = _dsp;
                
            } else if(i == amoIn) { // output label
                hh += ui(8 + 32 + 8);
                
                draw_sprite_stretched_ext(THEME.box_r5_clr, 0, 0, yy + ui(8), con_w, ui(32), COLORS.panel_inspector_output_label, 0.8);
                draw_set_text(f_p0b, fa_center, fa_center, COLORS._main_text_sub);
                draw_text_add(xc, yy + ui(8 + 16), __txt("Outputs"));
                continue;
            
            } else if(i < amoIn + 1 + amoOut) { // outputs
                var _oi = i - amoIn - 1;
                var _dsl = _inspecting.output_display_list;
                var _dsp = array_safe_get_fast(_dsl, _oi);
                
                     if(!is_array(_dsl)) jun = array_safe_get_fast(_inspecting.outputs, _oi);
                else if(is_real(_dsp))   jun = array_safe_get_fast(_inspecting.outputs, _dsp);
                else                     jun = _dsp;
                
            } else { // metadata
                jun = _inspecting.junc_meta[i - (amoIn + 1 + amoOut)];
                
            }
            
            if(is(jun, Inspector_Spacer)) {                    // SPACER
                var _hh = ui(jun.h);
                var _yy = yy + _hh / 2 - ui(2);
                
                if(jun.line) {
                    draw_set_color(COLORS.panel_inspector_key_separator);
                    draw_line(ui(8), _yy, con_w - ui(8), _yy);
                }
                
                hh += _hh;
                continue;
                
            } else if(is(jun, Inspector_Sprite)) {            // SPRITE
                var _spr = jun.spr;
                var _sh  = sprite_get_height(_spr);
                
                draw_sprite(_spr, 0, xc, yy);
                
                hh += _sh + ui(8);
                continue;
                
            } else if(is(jun, Inspector_Label)) {            // TEXT
                var _txt = jun.text;
                if(_txt == "") continue;
                
                draw_set_text(jun.font, fa_left, fa_top, COLORS._main_text_sub);
                var _sh = string_height_ext(_txt, -1, con_w - ui(16)) + ui(16);
                draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, 0, yy, con_w, _sh, COLORS._main_icon_light);
                draw_text_ext_add(ui(8), yy + ui(8), _txt, -1, con_w - ui(16));
                
                hh += _sh + ui(8);
                continue;
                
            } else if(is(jun, Inspector_Custom_Renderer)) {
                if(jun.popupPanel != noone) {
        			draw_set_text(f_p2, fa_center, fa_center, COLORS._main_icon, .5);
        			draw_text_add(con_w / 2, yy + ui(24) / 2 - ui(2), __txt("Pop-up content"));
        			draw_set_alpha(1);
        			
        			hh += ui(24 + 2);
                    continue;
                }
                
                jun.step();
                jun.fixHeight = -1;
                jun.panel     = self;
                jun.rx        = ui(16) + x;
                jun.ry        = top_bar_h + y;
                jun.register(contentPane);
                
                var _wdh = jun.draw(ui(6), yy, con_w - ui(12), _m, _hover, pFOCUS, self) + ui(8);
                if(!is_undefined(_wdh)) hh += _wdh;
                continue;
                
            } else if(is(jun, widget)) {
                jun.setFocusHover(pFOCUS, pHOVER);
                var param = new widgetParam(ui(6), yy, con_w - ui(12), TEXTBOX_HEIGHT, noone, {}, _m, x, y);
                var _wdh = jun.drawParam(param);
                if(!is_undefined(_wdh)) hh += _wdh + ui(4);
                continue;
                
            } else if(is_array(jun)) {                                    // LABEL
                var pad = i && _colsp == false? ui(4) : 0
                _colsp  = false;
                yy += pad;
                
                // draw_set_color(COLORS.panel_bg_clear_inner); // clear content below before drawing, animated section collapse, maybe?
                // draw_rectangle(0, yy, w, h, false);
                
                var txt  = __txt(jun[0]);
                var coll = jun[1] && filter_text == "";
                
                var lbx = 0;
                var lbh = viewMode? ui(32) : ui(26);
                var lbw = con_w;
                
                var togl   = array_safe_get_fast(jun, 2, noone);
                var toging = false;
                
                if(togl != noone) {
                    lbx += ui(40);
                    lbw -= ui(40);
                    toging = _inspecting.getInputData(togl);
                    if(is_array(toging)) toging = false;
                }
                
                var righ = array_safe_get_fast(jun, 3, noone);
                if(righ != noone)
                    lbw -= ui(32);
                
                if(_hover && point_in_rectangle(_m[0], _m[1], lbx, yy, lbx + lbw, yy + lbh)) {
                    contentPane.hover_content = true;
                    draw_sprite_stretched_ext(THEME.box_r5_clr, 0, lbx, yy, con_w - lbx, lbh, COLORS.panel_inspector_group_hover, 1);
                	
                	if(pFOCUS) {
	                		if(DOUBLE_CLICK) _cAll = jun[@ 1]? -1 : 1;
                       else if(mouse_press(mb_left)) jun[@ 1] = !coll;
		               else if(mouse_press(mb_right, pFOCUS)) menuCall("inspector_group_menu", group_menu, 0, 0, fa_left);
                	}
                } else
                    draw_sprite_stretched_ext(THEME.box_r5_clr, 0, lbx, yy, con_w - lbx, lbh, COLORS.panel_inspector_group_bg, 1);
            
                if(righ != noone) {
                    var _bx = lbx + lbw;
                    var _by = yy;
                    var _bw = ui(32);
                    var _bh = lbh;
                    
                    // draw_sprite_stretched_ext(THEME.box_r5_clr, 0, _bx, _by, _bw, _bh, COLORS.panel_inspector_group_bg, 1);
                    righ.setFocusHover(pFOCUS, pHOVER);
                    righ.draw(_bx + ui(2), _by + ui(2), _bw - ui(4), _bh - ui(4), _m, THEME.button_hide_fill);
                }
                
                if(filter_text == "") 
                    draw_sprite_ui(THEME.arrow, 0, lbx + ui(16), yy + lbh / 2, 1, 1, -90 + coll * 90, COLORS.panel_inspector_group_bg, 1);
                
                var cc, aa = 1;
                
                if(togl != noone) {
                    if(_hover && point_in_rectangle(_m[0], _m[1], 0, yy, ui(32), yy + lbh)) {
                        contentPane.hover_content = true;
                        draw_sprite_stretched_ext(THEME.box_r5_clr, 0, 0, yy, ui(32), lbh, COLORS.panel_inspector_group_hover, 1);
                        
                        if(mouse_press(mb_left, pFOCUS))
                            _inspecting.inputs[togl].setValue(!toging);
                    } else 
                        draw_sprite_stretched_ext(THEME.box_r5_clr, 0, 0, yy, ui(32), lbh, COLORS.panel_inspector_group_bg, 1);
                    
                    cc = toging? COLORS._main_accent : COLORS.panel_inspector_group_bg;
                    aa = 0.5 + toging * 0.5;
                    
                    draw_sprite_ui(THEME.inspector_checkbox, 0, ui(16), yy + lbh / 2, 1, 1, 0, cc, 1);
                    if(toging) 
                        draw_sprite_ui(THEME.inspector_checkbox, 1, ui(16), yy + lbh / 2, 1, 1, 0, cc, 1);
                }
                
                var ltx = lbx + ui(32);
                
                draw_set_text(viewMode? f_p0 : f_p1, fa_left, fa_center, COLORS._main_text, aa);
                draw_text_add(ltx, yy + lbh / 2, txt);
                draw_set_alpha(1);
                
                hh += lbh + ui(viewMode? 8 : 6) + pad;
                
                if(coll) { // skip 
                    _colsp   = true;
                    var j    = i + 1;
                    var _len = array_length(_inspecting.input_display_list);
                    
                    while(j < _len) {
                        var j_jun = _inspecting.input_display_list[j];
                        if(is_array(j_jun)) break;
                        if(is(j_jun, Inspector_Spacer) && !j_jun.coll) break;
                        
                        j++;
                    }
                    
                    i = j - 1;
                }
                
                continue;
                
            }
        
            if(!is(jun, NodeValue)) continue;
            
            if(!jun.show_in_inspector) continue;
            if(filter_text != "") {
                var pos = string_pos(filter_text, string_lower(jun.getName()));
                if(pos == 0) continue;
            }
            
            #region ++++ draw widget ++++
                var _font = viewMode == INSP_VIEW_MODE.spacious? f_p1 : f_p2;
                
                var lb_h = line_get_height(_font) + ui(8);
                var lb_w = line_get_width(jun.getName(), _font) + ui(16);
                var lb_x = ui(48) + (ui(24) * (jun.color != -1));
                var padd = ui(8);
            
                var _selY = yy;
                
                var lbHov = point_in_rectangle(_m[0], _m[1], lb_x, _selY + ui(2), lb_x + lb_w, _selY + lb_h - ui(4));
                if(lbHov) {
                    contentPane.hover_content = true;
                    draw_sprite_stretched_ext(THEME.box_r2_clr, 0, lb_x, _selY + ui(2), lb_w, lb_h - ui(4), c_white, 1);
                }
                
                var widg    = drawWidget(ui(16), yy, contentPane.surface_w - ui(24), _m, jun, false, pHOVER && contentPane.hover, pFOCUS, contentPane, ui(16) + x, top_bar_h + y);
                var widH    = widg[0];
                var mbRight = widg[1];
                var widHov  = widg[2];
                
                if(widHov) contentPane.hover_content = true;
                
                hh += lb_h + widH + padd;
            
                var _selY1 = yy + lb_h + widH + ui(2);
                var _selH  = _selY1 - _selY + (viewMode * ui(4));
                
                if(jun == prop_highlight && prop_highlight_time) {
                    if(prop_highlight_time == 60)
                        contentPane.setScroll(_y - yy);
                    var aa = min(1, prop_highlight_time / 30);
                    draw_sprite_stretched_ext(THEME.ui_panel, 1, ui(4), yy, contentPane.surface_w - ui(4), _selH, COLORS._main_accent, aa);
                }
                
                if(_hover && lbHov && prop_dragging == noone && mouse_press(mb_left, pFOCUS)) {
                    prop_dragging = jun;
                        
                    prop_sel_drag_x = mouse_mx;
                      prop_sel_drag_y = mouse_my;
                }
            #endregion
            
            if(jun.connect_type == CONNECT_TYPE.input && jun.type == VALUE_TYPE.color && jun.display_type == VALUE_DISPLAY._default) { // color picker
                pickers[color_picker_index] = jun;
                color_picker_index++;
            }
            
            if(jun.editWidget && jun.editWidget.temp_hovering) {
            	draw_sprite_stretched_ext(THEME.prop_selecting, 0, ui(4), _selY, contentPane.surface_w - ui(8), _selH, COLORS._main_accent, 1);
            	jun.editWidget.temp_hovering = false;
            }
            
            if(_hover && point_in_rectangle(_m[0], _m[1], ui(4), _selY, contentPane.surface_w - ui(4), _selY + _selH)) { // mouse in widget
                _HOVERING_ELEMENT = jun;
                
                var hov = PANEL_GRAPH.value_dragging != noone || (NODE_DROPPER_TARGET != noone && NODE_DROPPER_TARGET != jun);
                
                if(hov) {
                    draw_sprite_stretched_ext(THEME.ui_panel, 1, ui(4), _selY, contentPane.surface_w - ui(8), _selH, COLORS._main_value_positive, 1);
                    if(mouse_press(mb_left, NODE_DROPPER_TARGET_CAN)) {
                        NODE_DROPPER_TARGET.expression += $"{jun.node.internalName}.{jun.connect_type == CONNECT_TYPE.input? "inputs" : "outputs"}.{jun.internalName}";
                        NODE_DROPPER_TARGET.expressionUpdate(); 
                    }
                } else 
                    draw_sprite_stretched_ext(THEME.prop_selecting, 0, ui(4), _selY, contentPane.surface_w - ui(8), _selH, COLORS._main_accent, 1);
                
                if(anim_toggling) {
                    jun.setAnim(!jun.is_anim, true);
                    anim_toggling = false;
                }
                
                prop_hover = jun;
                    
                if(mouse_press(mb_left, pFOCUS))
                    prop_selecting = jun;
                        
                if(mouse_press(mb_right, pFOCUS && mbRight)) { // right click menu
                    prop_selecting = jun;
                    
                    var _menuItem = [ menu_junc_color, -1 ];
                    var _inp = jun.connect_type == CONNECT_TYPE.input;
                    
                    if(i < amoIn) {
                        array_push(_menuItem, menu_junc_reset_value, jun.is_anim? menu_junc_rem_anim : menu_junc_add_anim);
                        if(jun.sepable) array_push(_menuItem, jun.sep_axis? menu_junc_combine_axis : menu_junc_separate_axis);
                        array_push(_menuItem, -1);
                    }
                    
                    if(_inp) array_push(_menuItem, menu_junc_bypass_toggle);
                    
                    array_push(_menuItem, jun.expUse? menu_junc_expression_dis : menu_junc_expression_ena);
                    if(jun.globalExtractable()) {
                    	
                		array_push(_menuItem, menuItemShelf(__txtx("panel_inspector_use_global", "Use Globalvar"), function(_dat) /*=>*/ { 
                			var arr = [];
                            for( var i = 0, n = array_length(PROJECT.globalNode.inputs); i < n; i++ ) {
	                    		var _glInp = PROJECT.globalNode.inputs[i];
	                    		if(!typeCompatible(_glInp.type, __dialog_junction.type)) continue;
	                    		array_push(arr, menuItem(_glInp.name, function(d) /*=>*/ { __dialog_junction.setExpression(d.name); }, noone, noone, noone, { name : _glInp.name }));
	                    	}
                            return submenuCall(_dat, arr);
                        }));
                    	
                    	array_push(_menuItem, menu_junc_extract_global);
                    }
                    
                    array_push(_menuItem, -1, menu_junc_copy);
                    if(_inp) array_push(_menuItem, menu_junc_paste);
                    
                    if(_inp && jun.extract_node != "") {
                        if(is_array(jun.extract_node)) {
                            array_push(_menuItem, menuItemShelf(__txtx("panel_inspector_extract_multiple", "Extract to..."), function(_dat) /*=>*/ { 
                                var arr = [];
                                for(var i = 0; i < array_length(__dialog_junction.extract_node); i++)  {
                                    var _rec = __dialog_junction.extract_node[i];
                                    array_push(arr, menuItem(ALL_NODES[$ _rec].name, 
                                    	function(d) /*=>*/ { __dialog_junction.extractNode(d.name); }, noone, noone, noone, { name : _rec }));
                                }
                                    
                                return submenuCall(_dat, arr);
                            }));
                            
                        } else array_push(_menuItem, menu_junc_extract);
                    }
                    
                    var dia = menuCall("inspector_value_menu", _menuItem);
                    __dialog_junction = jun;
                }
            } 
        }
        
        	 if(_cAll ==  1) { section_expand_all();   }
		else if(_cAll == -1) { section_collapse_all(); }
		
        
        if(MESSAGE != noone && MESSAGE.type == "Color") {
            var inp = array_safe_get_fast(pickers, picker_index, 0);
            if(is_struct(inp)) {
                inp.setValue(MESSAGE.data);
                MESSAGE = noone;
            }
        }
        
        color_picking = false;
        
        if(prop_dragging) { //drag
            if(DRAGGING == noone && point_distance(prop_sel_drag_x, prop_sel_drag_y, mouse_mx, mouse_my) > 16) {
                prop_dragging.dragValue();
                prop_dragging = noone;
            }
            
            if(mouse_release(mb_left))
                prop_dragging = noone;
        }
        
        if(prop_highlight_time) {
            prop_highlight_time--;
            if(prop_highlight_time == 0)
                prop_highlight = noone;
        }
        
        return hh;
    }
    
    static drawInspectingNode = function() {
        
        var txt = inspecting.renamed? inspecting.display_name : inspecting.name;
             if(inspectGroup ==  1) txt = $"[{array_length(PANEL_GRAPH.nodes_selecting)}] {txt}"; 
        else if(inspectGroup == -1) txt = $"[{array_length(PANEL_GRAPH.nodes_selecting)}] Multiple nodes"; 
        
        var tb_x = ui(64);
        var tb_y = ui(14);
        var tb_w = w - ui(128);
        var tb_h = ui(32);
        
        tb_node_name.setFocusHover(pFOCUS, pHOVER);
        tb_node_name.draw(tb_x, tb_y, tb_w, tb_h, txt, [ mx, my ]);
        
        if(inspectGroup >= 0) {
            draw_set_text(f_p1, fa_center, fa_center, COLORS._main_text_sub);
            draw_text_add(w / 2 + ui(8), ui(56), inspecting.name);
        
            draw_set_text(f_p3, fa_center, fa_center, COLORS._main_text_sub);
            draw_set_alpha(0.65);
            draw_text_add(w / 2, ui(76), inspecting.internalName);
            draw_set_alpha(1);
        }
        
        var bx = ui(8);
        var by = ui(12);
            
        if(inspectGroup == 0) {
            draw_set_font(f_p1);
            var lx = w / 2 - string_width(inspecting.name) / 2 - ui(10);
            var ly = ui(56 - 8);
            if(buttonInstant(THEME.button_hide_fill, lx, ly, ui(16), ui(16), [mx, my], pHOVER, pFOCUS, __txt("Lock"), THEME.lock_12, !locked, locked? COLORS._main_icon_light : COLORS._main_icon) == 2)
                locked = !locked;
            
            if(buttonInstant(THEME.button_hide_fill, bx, by, ui(32), ui(32), [mx, my], pHOVER, pFOCUS, __txt("Presets"), THEME.preset, 1) == 2)
                dialogPanelCall(new Panel_Presets(inspecting), x + bx, y + by + ui(36));
        } else {
            draw_sprite_ui_uniform(THEME.preset, 1, bx + ui(32) / 2, by + ui(32) / 2, 1, COLORS._main_icon_dark);
        }
        
        ////- INSPECTOR ACTIONS
        
        var bx = w - ui(44);
        var by = ui(12);
        
        if(inspecting.hasInspector1Update(true)) {
            var icon = inspecting.insp1UpdateIcon;
            var ac = inspecting.insp1UpdateActive;
            var cc = ac? icon[2] : COLORS._main_icon_dark;
            var tt = inspecting.insp1UpdateTooltip;
            if(inspectGroup) tt += " [All]";
            
            if(buttonInstant(THEME.button_hide_fill, bx, by, ui(32), ui(32), [mx, my], pHOVER && ac, pFOCUS && ac, tt, icon[0], icon[1], cc) == 2) {
                if(inspectGroup == 1) {
                    for( var i = 0, n = array_length(inspectings); i < n; i++ ) inspectings[i].inspector1Update();
                } else 
                    inspecting.inspector1Update();
            }
        } else 
            draw_sprite_ui(THEME.sequence_control, 1, bx + ui(16), by + ui(16),,,, COLORS._main_icon_dark);
        
        if(inspecting.hasInspector2Update()) {
            by += ui(36);
            var icon = inspecting.insp2UpdateIcon;
            var ac = inspecting.insp2UpdateActive;
            var cc = ac? icon[2] : COLORS._main_icon_dark;
            var tt = inspecting.insp2UpdateTooltip;
            if(inspectGroup) tt += " [All]";
            
            if(buttonInstant(THEME.button_hide_fill, bx, by, ui(32), ui(32), [mx, my], pHOVER && ac, pFOCUS && ac, tt, icon[0], icon[1], cc) = 2) {
                if(inspectGroup) {
                    for( var i = 0, n = array_length(inspectings); i < n; i++ ) inspectings[i].inspector2Update();
                } else 
                    inspecting.inspector2Update();
            }
        }
    }
    
    function drawContent(panel) { 
        draw_clear_alpha(COLORS.panel_bg_clear, 1);
        draw_sprite_stretched(THEME.ui_panel_bg, 1, ui(8), top_bar_h - ui(8), w - ui(16), h - top_bar_h);
        
        if(inspecting && !inspecting.active) inspecting = noone;
        
        view_mode_tooltip.index = viewMode;
        var b = buttonInstant(THEME.button_hide_fill,  ui(8), ui(48), ui(32), ui(32), [mx, my], pHOVER, pFOCUS, view_mode_tooltip, THEME.inspector_view, viewMode);
        if(b == 1) {
			if(key_mod_press(SHIFT) && mouse_wheel_up())   { viewMode = !viewMode; PREFERENCES.inspector_view_default = viewMode; }
			if(key_mod_press(SHIFT) && mouse_wheel_down()) { viewMode = !viewMode; PREFERENCES.inspector_view_default = viewMode; }
		}
        if(b == 2) { viewMode = !viewMode; PREFERENCES.inspector_view_default = viewMode; }
        
        if(inspecting) {
            var _nodes = PANEL_GRAPH.nodes_selecting;
            
            inspectGroup = array_length(_nodes) > 1;
            inspectings  = array_empty(_nodes)? [ inspecting ] : _nodes;
            
            for( var i = 1, n = array_length(_nodes); i < n; i++ ) {
            	if(instanceof(_nodes[i]) == instanceof(_nodes[0])) continue;
            	
                inspectGroup = -1; 
                break; 
            }
            
            if(is(inspecting, Node_Frame)) inspectGroup = 0;
            
            title = inspecting.getDisplayName();
            inspecting.inspectorStep();
            drawInspectingNode();
            
        } else {
            title = __txt("Inspector");
            
            var txt = "Untitled";
            var context = PANEL_GRAPH.getCurrentContext();
            
            if(context == noone && file_exists_empty(PROJECT.path))
                txt = filename_name_only(PROJECT.path);
                
            else if(is(context, Node))
                txt = context.getDisplayName();
            
            draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
            var ss = min(.5, (w - ui(96)) / string_width(txt));
            draw_text_add(w / 2, ui(30), txt, ss);
            
            if(PROJECT.meta.steam == FILE_STEAM_TYPE.steamOpen) {
                var _tw = string_width(txt) / 2;
                BLEND_ADD
                draw_sprite_ui(THEME.steam, 0, w / 2 - _tw + ui(8), ui(29), 1, 1, 0, COLORS._main_icon);
                BLEND_NORMAL
            }
            
            var bx = w - ui(44);
            var by = ui(12);
            
            by += ui(36);
            if(STEAM_ENABLED && !workshop_uploading) {
                if(PROJECT.path == "") {
                    buttonInstant(noone, bx, by, ui(32), ui(32), [mx, my], pHOVER, pFOCUS, __txtx("panel_inspector_workshop_save", "Save file before upload"), THEME.workshop_upload, 0, COLORS._main_icon, 0.5);
                } else {
                    if(PROJECT.meta.steam == FILE_STEAM_TYPE.local) { //project made locally
                        if(buttonInstant(THEME.button_hide_fill, bx, by, ui(32), ui(32), [mx, my], pHOVER, pFOCUS, __txtx("panel_inspector_workshop_upload", "Upload to Steam Workshop"), THEME.workshop_upload, 0, COLORS._main_icon) == 2) {
                            var s = PANEL_PREVIEW.getNodePreviewSurface();
                            if(is_surface(s)) {
                                PROJECT.meta.author_steam_id = STEAM_USER_ID;
                                PROJECT.meta.steam = FILE_STEAM_TYPE.steamUpload;
                                SAVE_AT(PROJECT, PROJECT.path);
                                
                                steam_ugc_create_project();
                                workshop_uploading = true;
                            } else 
                                noti_warning("Please send any node to preview panel to use as a thumbnail.")
                        }
                    }
                    
                    if(PROJECT.meta.steam && PROJECT.meta.author_steam_id == STEAM_USER_ID) {
                        if(PROJECT.meta.steam == FILE_STEAM_TYPE.steamUpload) {
                            buttonInstant(THEME.button_hide_fill, bx, by, ui(32), ui(32), [mx, my], false, pHOVER, __txtx("panel_inspector_workshop_restart", "Open project from the workshop tab to update."), THEME.workshop_update, 0, COLORS._main_icon);
                        } else if(buttonInstant(THEME.button_hide_fill, bx, by, ui(32), ui(32), [mx, my], pHOVER, pFOCUS, __txtx("panel_inspector_workshop_update", "Update Steam Workshop content"), THEME.workshop_update, 0, COLORS._main_icon) == 2) {
                            SAVE_AT(PROJECT, PROJECT.path);
                            steam_ugc_update_project();
                            workshop_uploading = true;
                        }
                    }
                }
            }
            
            if(workshop_uploading) {
                draw_sprite_ui(THEME.loading_s, 0, bx + ui(16), by + ui(16),,, current_time / 5, COLORS._main_icon);
                if(STEAM_UGC_ITEM_UPLOADING == false)
                    workshop_uploading = false;
            }
        }
        
        contentPane.setFocusHover(pFOCUS, pHOVER);
        contentPane.draw(ui(16), top_bar_h, mx - ui(16), my - top_bar_h);
        
        if(!locked && PANEL_GRAPH.getFocusingNode() && inspecting != PANEL_GRAPH.getFocusingNode())
            setInspecting(PANEL_GRAPH.getFocusingNode());
            
    }
    
    ////- Serialize
    
    static serialize   = function() { 
        return { 
            name: instanceof(self), 
            inspecting  : node_get_id(inspecting), 
            inspectings : array_map(inspectings, function(n) { return node_get_id(n) }),
            
            locked,
        }; 
    }
    
    static deserialize = function(data) { 
        inspecting  = node_from_id(data.inspecting);
        inspectings = array_map(data.inspectings, function(n) { return node_from_id(n); });
        
        locked      = struct_try_get(data, "locked", locked);
        
        return self; 
    }
    
    ////- Actions
    
}

function New_Inspect_Node_Panel(node, pin = true) {
    panel = panelAdd("Panel_Inspector", true, false);
	panel.content.setInspecting(node, true, false);
	panel.destroy_on_click_out = !pin;
	
	return panel;
}