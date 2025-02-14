#region function registers
    function global_fullscreen()        { CALL("fullscreen");        winMan_setFullscreen(!window_is_fullscreen);                                        }
    function global_project_close()     { CALL("close_project");     PANEL_GRAPH.close();                                                                }
    function global_project_close_all() { CALL("close_project_all"); for( var i = array_length(PROJECTS) - 1; i >= 0; i-- ) closeProject(PROJECTS[i]);   }
    function global_theme_reload()      { CALL("reload_theme");      loadGraphic(PREFERENCES.theme); resetPanel();                                       }
    
    function global_render_all()        { CALL("render_all");        RENDER_ALL_REORDER                                                                  }
    function global_export_all()        { 
        for (var i = 0, n = array_length(PROJECT.allNodes); i < n; i++) {
            var node = PROJECT.allNodes[i];
            
            if(!node.active) continue;
            if(instanceof(node) != "Node_Export") continue;
            
            node.doInspectorAction();
        }
    }
    
    function __fnInit_Global() {
        registerFunction("", "New file",            "N",    MOD_KEY.ctrl,                                 NEW                      ).setMenu("new_file",       THEME.new_file)
        
        if(!DEMO) {
            registerFunction("", "Save",            "S",    MOD_KEY.ctrl,                                 SAVE                     ).setMenu("save",           THEME.save)
            registerFunction("", "Save as",         "S",    MOD_KEY.ctrl | MOD_KEY.shift,                 SAVE_AS                  ).setMenu("save_as",        THEME.save)
            registerFunction("", "Save at",         "",     MOD_KEY.none,                                 SAVE_AT                  ).setMenu("save_at",        THEME.save)
                .setArg([ ARG("project", function() { return PROJECT; }, true), ARG("path", ""), ARG("log", "save at ") ])
            
            registerFunction("", "Save all",        "S",    MOD_KEY.ctrl | MOD_KEY.alt,                   SAVE_ALL                 ).setMenu("save_all",       THEME.icon_save_all)
            registerFunction("", "Open",            "O",    MOD_KEY.ctrl,                                 LOAD                     ).setMenu("open",           THEME.noti_icon_file_load)
            registerFunction("", "Open Safe",       "",     MOD_KEY.none,                                 LOAD_SAFE                ).setMenu("open_safe",      THEME.noti_icon_file_load)
            
            registerFunction("", "Open at",         "",     MOD_KEY.none,                                 LOAD_AT                  ).setMenu("open_at",        THEME.noti_icon_file_load)
                .setArg([ ARG("path", ""), ARG("readonly", false), ARG("override", false) ])
            
            registerFunction("", "Append",          "",     MOD_KEY.none,                                 APPEND                   ).setMenu("append",         )
                .setArg([ ARG("path", ""), ARG("context", function() { return PANEL_GRAPH.getCurrentContext() }, true) ])
            
            registerFunction("", "Recent Files",    "R",    MOD_KEY.ctrl | MOD_KEY.shift,
                function(_dat) { 
                    var arr = [];
                    var dat = [];
                    for(var i = 0; i < min(10, ds_list_size(RECENT_FILES)); i++)  {
                        var _rec = RECENT_FILES[| i];
                        array_push(arr, menuItem(_rec, function(_dat) { LOAD_PATH(_dat.path); }, noone, noone, noone, { path: _rec }));
                    }
                    
                    return submenuCall(_dat, arr);
                }).setMenu("recent_files",, true);
                
            registerFunction("", "Import .zip",     "",     MOD_KEY.none,                                 __IMPORT_ZIP             ).setMenu("import_zip",     )
            registerFunction("", "Export .zip",     "",     MOD_KEY.none,                                 __EXPORT_ZIP             ).setMenu("export_zip",     )
            
            registerFunction("", "Import",          "",     MOD_KEY.none, function(_dat) /*=>*/ {return submenuCall(_dat, [ MENU_ITEMS.import_zip ])}   ).setMenu("import_menu",, true);
            registerFunction("", "Export",          "",     MOD_KEY.none, function(_dat) /*=>*/ {return submenuCall(_dat, [ MENU_ITEMS.export_zip ])}   ).setMenu("export_menu",, true);
        }
        
        registerFunction("", "Undo",                "Z",    MOD_KEY.ctrl,                                 UNDO                     ).setMenu("undo",           )
        registerFunction("", "Redo",                "Z",    MOD_KEY.ctrl | MOD_KEY.shift,                 REDO                     ).setMenu("redo",           )
        
        registerFunction("", "Full panel",          "`",    MOD_KEY.none,                                 set_focus_fullscreen     ).setMenu("full_panel",     )
        registerFunction("", "Reset layout",        vk_f10, MOD_KEY.ctrl,                                 resetPanel               ).setMenu("reset_layout",   )
        
        registerFunction("", "Fullscreen",          vk_f11, MOD_KEY.none,                                 global_fullscreen        ).setMenu("fullscreen",     )
        registerFunction("", "Render all",          vk_f5,  MOD_KEY.none,                                 global_render_all        ).setMenu("render_all",     [ THEME.sequence_control, 1 ])
        registerFunction("", "Export all",          "",     MOD_KEY.none,                                 global_export_all        ).setMenu("export_all",     )
        
        registerFunction("", "Close file",          "Q",    MOD_KEY.ctrl,                                 global_project_close     ).setMenu("close_file",     )
        registerFunction("", "Close all files",     "",     MOD_KEY.none,                                 global_project_close_all ).setMenu("close_all_files",)
        registerFunction("", "Close program",       vk_f4,  MOD_KEY.alt,                                  window_close             ).setMenu("close_software", )
        registerFunction("", "Close project",       "",     MOD_KEY.none,                                 closeProject             ).setMenu("close_project",  )
            .setArg([ ARG("project", function() { return PROJECT; }, true) ])
            
        registerFunction("", "Reload theme",        vk_f10, MOD_KEY.ctrl | MOD_KEY.shift,                 global_theme_reload      ).setMenu("reload_theme",   )
        
        registerFunction("", "Addons",              "",     MOD_KEY.none, function(_dat) /*=>*/ {
            var arr = [
                MENU_ITEMS.addons,
                menuItem(__txtx("panel_menu_addons_key", "Key displayer"), function() /*=>*/ { if(instance_exists(addon_key_displayer)) return; instance_create_depth(0, 0, 0, addon_key_displayer); }),
                -1
            ];
            
            for( var i = 0, n = array_length(ADDONS); i < n; i++ )
                array_push(arr, menuItem(ADDONS[i].name, function(_dat) /*=>*/ { addonTrigger(_dat.name); } ));
            
            return submenuCall(_dat, arr);
        }).setMenu("addon_menu", THEME.addon_icon, true)
        
    }
    
#endregion

function Panel_Menu() : PanelContent() constructor {
    title     = __txt("Menu");
    auto_pin = true;
    
    noti_flash         = 0;
    noti_flash_color = COLORS._main_accent;
    noti_icon         = noone;
    noti_icon_show   = 0;
    noti_icon_time   = 0;
    
    vertical_break    = ui(240);
    version_name_copy = 0;
    
    var _right = PREFERENCES.panel_menu_right_control;
    if(_right) action_buttons = ["exit", "maximize", "minimize", "fullscreen"];
    else       action_buttons = ["exit", "minimize", "maximize", "fullscreen"];
    
    menu_file_nondemo = [
        MENU_ITEMS.new_file,
        MENU_ITEMS.open,
            
        MENU_ITEMS.save,
        MENU_ITEMS.save_as,
        MENU_ITEMS.save_all,
        MENU_ITEMS.recent_files,
        
        MENU_ITEMS.autosave_folder,
        MENU_ITEMS.import_menu,
        MENU_ITEMS.export_menu,
        -1,
    ];
    
    menu_file = [
        MENU_ITEMS.preference,
        MENU_ITEMS.splash_screen,
        MENU_ITEMS.command_palette,
        -1,
        MENU_ITEMS.addon_menu,
        -1,
        MENU_ITEMS.fullscreen,
        MENU_ITEMS.close_file,
        MENU_ITEMS.close_all_files,
        MENU_ITEMS.close_software,
    ]; 
    
    if(!DEMO) menu_file = array_append(menu_file_nondemo, menu_file);
    
    menu_help = [ 
        menuItem(__txtx("panel_menu_help_video", "Tutorial videos"),                       function() { url_open("https://www.youtube.com/@makhamdev"); }, THEME.youtube),
        menuItem(__txtx("panel_menu_help_wiki", "Community Wiki"),                         function() { url_open("https://pixel-composer.fandom.com/wiki/Pixel_Composer_Wiki"); }, THEME.wiki),
        -1, 
        menuItem(__txtx("panel_menu_local_directory", "Open local directory"),             function() { shellOpenExplorer(DIRECTORY); }, THEME.folder),
        menuItem(__txtx("panel_menu_autosave_directory", "Open autosave directory"),       function() { shellOpenExplorer(DIRECTORY + "autosave/"); }, THEME.folder),
        menuItem(__txtx("panel_menu_reset_default", "Reset default collection, assets"),   function() {
            zip_unzip("data/Collections.zip", DIRECTORY + "Collections");
            zip_unzip("data/Assets.zip", DIRECTORY + "Assets");
        }),
        -1,
        menuItem(__txtx("panel_menu_connect_patreon", "Connect to Patreon"),               function() { dialogCall(o_dialog_patreon);         }, THEME.patreon),
        menuItem(__txtx("panel_menu_connect_patreon", "Connect to Patreon (legacy)"),      function() { dialogPanelCall(new Panel_Patreon()); }, THEME.patreon),
    ];
    
    menuItem_undo = MENU_ITEMS.undo;
    menuItem_redo = MENU_ITEMS.redo;
    
    menus = [
        [ __txt("File"), menu_file ],
        
        [ __txt("Edit"), [
            menuItem_undo,
            menuItem_redo,
            MENU_ITEMS.history,
        ]],
        
        [ __txt("Preview"), [
            MENU_ITEMS.preview_focus_content, 
            MENU_ITEMS.preview_save_current_frame, 
            MENU_ITEMS.preview_group_preview_bg,
        ]], 
        
        [ __txt("Animation"), [
            MENU_ITEMS.animation_settings,
            MENU_ITEMS.animation_scaler,
        ]],
        
        [ __txt("Rendering"), [
            MENU_ITEMS.render_all,
            MENU_ITEMS.export_all,
            menuItem(__txtx("panel_menu_export_render_all", "Render disabled node when export"), 
                function() { PREFERENCES.render_all_export = !PREFERENCES.render_all_export; },,, 
                function() { return PREFERENCES.render_all_export; }),
        ]],
        
        [ __txt("Panels"), [
            menuItemShelf(__txt("Workspace"), function(_dat) { 
                var arr = [];
                var lay = [];
                
                var f   = file_find_first(DIRECTORY + "layouts/*", 0);
                while(f != "") {
                    array_push(lay, filename_name_only(f));
                    f = file_find_next();
                }
                
                array_push(arr, menuItem(__txtx("panel_menu_save_layout", "Save layout"), function() {
                    var dia = dialogCall(o_dialog_file_name, mouse_mx + ui(8), mouse_my + ui(8));
                    dia.name = PREFERENCES.panel_layout_file;
                    dia.onModify = function(name) { 
                        var cont = panelSerialize();
                        json_save_struct(DIRECTORY + "layouts/" + name + ".json", cont);
                    };
                }));
                
                array_push(arr, MENU_ITEMS.reset_layout);
                array_push(arr, -1);
                
                for(var i = 0; i < array_length(lay); i++)  {
                    array_push(arr, menuItem(lay[i], 
                        function(_dat) /*=>*/ { PREFERENCES.panel_layout_file = _dat.path; PREF_SAVE(); setPanel(); }, noone, noone, 
                        function(item) /*=>*/ {return item.name == PREFERENCES.panel_layout_file},
                        { path: lay[i] }));
                }
                
                return submenuCall(_dat, arr);
            }),
            -1,
            
            MENU_ITEMS.collections_panel,
            MENU_ITEMS.graph_panel,
            MENU_ITEMS.preview_panel,
            MENU_ITEMS.inspector_panel,
            MENU_ITEMS.workspace_panel,
            MENU_ITEMS.animation_panel,
            MENU_ITEMS.notification_panel,
            MENU_ITEMS.globalvar_panel,
            MENU_ITEMS.file_explorer_panel,
            
            menuItemShelf(__txt("Nodes"), function(_dat) { 
                return submenuCall(_dat, [
                    MENU_ITEMS.align_panel,
                    MENU_ITEMS.nodes_panel,
                    MENU_ITEMS.tunnels_panel,
                ]);
            }),
            
            menuItemShelf(__txt("Color"), function(_dat) { 
                return submenuCall(_dat, [
                    MENU_ITEMS.color_panel,
                    MENU_ITEMS.palettes_panel,
                    MENU_ITEMS.palettes_mixer_panel,
                    MENU_ITEMS.gradients_panel,
                ]);
            }),
            
            MENU_ITEMS.preview_histogram,
        ]],
        
        [ __txt("Help"), menu_help ],
    ]; 
    
    if(TESTING) {
        array_push(menus, [ __txt("Dev"), [
            MENU_ITEMS.console_panel,
            menuItem(__txtx("panel_debug_overlay", "Debug overlay"),                              function() /*=>*/ { show_debug_overlay(true);                      }),
            menuItem(__txtx("panel_menu_profile_render", "Render Profiler"),                      function() /*=>*/ { dialogPanelCall(new Panel_Profile_Render());   }),
            // menuItem(__txtx("panel_menu_resource_monitor", "Resource Monitor"),                   () => { dialogPanelCall(new Panel_Resource_Monitor()); }),
            -1, 
            
            menuItem(__txtx("panel_menu_tester", "Save frozen"),                                  function() /*=>*/ { PROJECT.freeze = true; SAVE();                 }),
            menuItem(__txtx("panel_menu_tester", "Tester"),                                       function() /*=>*/ { dialogPanelCall(new Panel_Test());             }),
            -1, 
            
            menuItem(__txt("Collection Manager"),                                                 function() /*=>*/ { dialogPanelCall(new Panel_Collection_Manager());}),
            menuItem(__txt("Nodes Manager"),                                                      function() /*=>*/ { dialogPanelCall(new Panel_Nodes_Manager());     }),
            // menuItem(__txtx("panel_menu_test_load_nodes", "Load all nodes"),                      () => { __test_load_all_nodes();                        }),
            // menuItem(__txtx("panel_menu_test_gen_guide", "Generate node guide"),                  () => { dialogPanelCall(new Panel_Node_Data_Gen());    }),
            // menuItem(__txtx("panel_menu_test_gen_theme", "Generate theme object"),                () => {  __test_generate_theme();                      }),
            -1,
            menuItem(__txtx("panel_menu_test_warning", "Display Warning"),                        function() /*=>*/ { noti_warning("Error message")                  }),
            menuItem(__txtx("panel_menu_test_error", "Display Error"),                            function() /*=>*/ { noti_error("Error message")                    }),
            menuItem(__txtx("panel_menu_test_crash", "Force crash"),                              function() /*=>*/ { print(1 + "a");                                }),
            -1,
            menuItemShelf(__txt("Misc."), function(_dat) { 
                return submenuCall(_dat, [ menuItem(__txtx("panel_menu_node_credit", "Node credit dialog"), function() /*=>*/ { dialogPanelCall(new Panel_Node_Cost()); }), ]);
            }),
        ]]);
    }
    
    menu_help_steam = array_clone(menu_help);
    array_push(menu_help_steam, -1, 
        menuItem(__txtx("panel_menu_steam_workshop", "Steam Workshop"), function() /*=>*/ { steam_activate_overlay_browser("https://steamcommunity.com/app/2299510/workshop/"); }, THEME.steam) );
    
    function onFocusBegin() { PANEL_MENU = self; }
    
    function setNotiIcon(icon) {
        noti_icon = icon;
        noti_icon_time = 90;
    }
    
    function undoUpdate() {
        var txt = __txt("Undo");
        if(!ds_stack_empty(UNDO_STACK)) {
            var act = ds_stack_top(UNDO_STACK);
            if(array_length(act) > 1) txt = $"{__txt("Undo")} {array_length(act)} {__txt("Actions")}";
            else                      txt = $"{__txt("Undo")} {act[0]}";
        }
        
        menuItem_undo.active = !ds_stack_empty(UNDO_STACK);
        menuItem_undo.name = txt;
        
        txt = __txt("Redo");
        if(!ds_stack_empty(REDO_STACK)) {
            var act = ds_stack_top(REDO_STACK);
            if(array_length(act) > 1) txt = $"{__txt("Redo")} {array_length(act)} {__txt("Actions")}";
            else                      txt = $"{__txt("Redo")} {act[0]}";
        }
        
        menuItem_redo.active = !ds_stack_empty(REDO_STACK);
        menuItem_redo.name = txt;
    }
    
    function drawContent(panel) {
        var _right     = PREFERENCES.panel_menu_right_control;
        var _draggable = pFOCUS;
        
        draw_clear_alpha(COLORS.panel_bg_clear, 1);
        menus[6][1] = STEAM_ENABLED? menu_help_steam : menu_help;
        var hori = w > h;
        var font = f_p2;
        var xx   = ui(40);
        var yy   = ui(8);
        
        #region about
            if(hori) {
                if(_right)
                    xx = ui(24);
                else {
                    xx = ui(140);
                    draw_set_color(COLORS._main_icon_dark);
                    draw_line_round(xx, ui(8), xx, h - ui(8), 3);
                }
        
                var bx = _right? xx : w - ui(24);
                draw_sprite_ui_uniform(THEME.icon_24, 0, bx, h / 2, 1, c_white);
                if(pHOVER && point_in_rectangle(mx, my, bx - ui(16), 0, bx + ui(16), ui(32))) {
                    _draggable = false;
                    if(mouse_press(mb_left, pFOCUS)) dialogCall(o_dialog_about);
                }
                
            } else {
                var bx = ui(20);
                var by = h - ui(20);
            
                draw_sprite_ui_uniform(THEME.icon_24, 0, bx, by, 1, c_white);
                if(pHOVER && point_in_rectangle(mx, my, bx - ui(16), by - ui(16), bx + ui(16), by + ui(16))) {
                    _draggable = false;
                    if(mouse_press(mb_left, pFOCUS)) dialogCall(o_dialog_about);
                }
            }
        #endregion
        
        #region menu
            if(hori) {
                xx += _right? ui(20) : ui(8);
                yy  = 0;
                
            } else {
                xx = ui(8);
                yy = w < vertical_break? ui(72) : ui(40);
            }
            
            var xc, x0, x1, yc, y0, y1;
            var  sx = xx;
            var _mx = xx;
            var row = 1;
            var maxRow = ceil(h / ui(40));
            var ww, _ww = 0;
            
            draw_set_text(font, fa_center, fa_center, COLORS._main_text);
            
            for(var i = 0; i < array_length(menus) - 1; i++) {
                 ww = string_width(menus[i][0]) + ui(16 + 8);
                _ww += ww;
                
                if(_ww > w * 0.4 - sx) {
                    row++;
                    _ww = 0;
                } 
            }
            
            row = min(row, maxRow);
            var _curRow = 0, currY;
            var _rowH   = (h - ui(12)) / row;
            var _ww     = 0;
        
            for(var i = 0; i < array_length(menus); i++) {
                var _menu = menus[i];
                var _name = _menu[0];
                
                draw_set_text(font, fa_center, fa_center, COLORS._main_text);
                var ww = string_width(_name) + ui(16);
                var hh = line_get_height() + ui(8);
            
                if(hori) {
                    xc = xx + ww / 2;
                    x0 = xx;
                    x1 = xx + ww;
                    y0 = ui(6) + _rowH * _curRow;
                    y1 = y0 + _rowH;
                
                    yc = (y0 + y1) / 2;
                    currY = yc;
                    
                } else {
                    xc = w / 2;
                    yc = yy + hh / 2;
                
                    x0 = ui(6);
                    x1 = w - ui(6);
                    y0 = yy;
                    y1 = yy + hh;
                }
            
                if(pHOVER && point_in_rectangle(mx, my, x0, y0, x1, y1)) {
                    _draggable = false;
                    draw_sprite_stretched(THEME.box_r2_clr, 0, x0, y0, x1 - x0, y1 - y0);
                    
                    if((mouse_press(mb_left, pFOCUS)) || instance_exists(o_dialog_menubox)) {
                        if(hori) menuCall($"main_{_name}_menu", _menu[1], x + x0, y + y1);
                        else     menuCall($"main_{_name}_menu", _menu[1], x + x1, y + y0);
                    }
                }
            
                draw_set_text(font, fa_center, fa_center, COLORS._main_text);
                draw_text_add(xc, yc, _name);
            
                if(hori) {
                    xx  += ww + 8;
                    _mx  = max(_mx, xx);
                    _ww += ww + 8;
                    if(_ww > w * 0.6 - sx) {
                        _curRow++;
                        _ww = 0;
                        xx  = sx;
                    }
                    
                } else
                    yy += hh + 8;
            }
        #endregion
        
        #region notification
            var warning_amo = ds_list_size(WARNING);
            var error_amo   = ds_list_size(ERRORS);
            var nx0, ny0;
            
            if(hori) {
                nx0 = _mx + ui(8);
                ny0 = h / 2;
                
            } else {
                nx0 = ui(8);
                ny0 = yy + ui(16);
            }
            
            draw_set_text(font, fa_left, fa_center);
            var wr_w = ui(20) + ui(8) + string_width(string(warning_amo));
            var er_w = ui(20) + ui(8) + string_width(string(error_amo));
            
            if(noti_icon_time > 0) {
                noti_icon_show = lerp_float(noti_icon_show, 1, 4);
                noti_icon_time--;
            } else 
                noti_icon_show = lerp_float(noti_icon_show, 0, 4);
            
            var nw = hori? ui(16) + wr_w + ui(16) + er_w + noti_icon_show * ui(32) : w - ui(16);
            var nh = ui(28);
            
            noti_flash = lerp_linear(noti_flash, 0, 0.02);
            var ev = animation_curve_eval(ac_flash, noti_flash);
            var cc = merge_color(c_white, noti_flash_color, ev);
            
            if(pHOVER && point_in_rectangle(mx, my, nx0, ny0 - nh / 2, nx0 + nw, ny0 + nh / 2)) {
                _draggable = false;
                draw_sprite_stretched_ext(THEME.box_r2_clr, 0, nx0, ny0 - nh / 2, nw, nh, cc, 1);
                if(mouse_press(mb_left, pFOCUS)) {
                    var dia = dialogPanelCall(new Panel_Notification(), nx0, ny0 + nh / 2 + ui(4));
                    dia.anchor = ANCHOR.left | ANCHOR.top;
                }
                
                TOOLTIP = $"{warning_amo} {__txt("Warnings")} {error_amo} {__txt("Errors")}";
            } else
                draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, nx0, ny0 - nh / 2, nw, nh, cc, 1);
            
            gpu_set_blendmode(bm_add);
            draw_sprite_stretched_ext(THEME.box_r2, 0, nx0, ny0 - nh / 2, nw, nh, cc, ev / 2);
            gpu_set_blendmode(bm_normal);
            
            var _prg = noone;
            for( var i = 0, n = array_length(STATS_PROGRESS); i < n; i++ ) _prg = max(_prg, STATS_PROGRESS[i].progress);
            if(_prg > noone) draw_sprite_stretched_ext(THEME.box_r2, 0, nx0, ny0 - nh / 2, nw * clamp(_prg, 0, 1), nh, COLORS._main_value_positive, .5);
            
            if(noti_icon_show > 0)
                draw_sprite_ui(noti_icon, 0, nx0 + nw - ui(16), ny0,,,,, noti_icon_show);
            
            draw_set_color(COLORS._main_text_inner);
            var wr_x = hori? nx0 + ui(8) : w / 2 - (wr_w + er_w + ui(16)) / 2;
            draw_sprite_ui_uniform(THEME.noti_icon_warning, warning_amo? 1 : 0, wr_x + ui(10), ny0);
            draw_text_add(wr_x + ui(28), ny0, warning_amo);
            
            wr_x += wr_w + ui(16);
            draw_sprite_ui_uniform(THEME.noti_icon_error, error_amo? 1 : 0, wr_x + ui(10), ny0);
            draw_text_add(wr_x + ui(28), ny0, error_amo);
            
            if(hori) nx0 += nw + ui(8);
            else     ny0 += nh + ui(8);
        #endregion
        
        #region addons 
            var wh = ui(28);
            if(!hori) nx0 = ui(8);
            
            if(instance_exists(addon)) {
                draw_set_text(font, fa_left, fa_center, COLORS._main_text);
                
                var name = string(instance_number(addon)) + " ";
                var ww = hori? string_width(name) + ui(40) : w - ui(16);
                
                if(pHOVER && point_in_rectangle(mx, my, nx0, ny0 - wh / 2, nx0 + ww, ny0 + wh / 2)) {
                    _draggable = false;
                    TOOLTIP = __txt("Addons");
                    draw_sprite_stretched(THEME.box_r2_clr, 0, nx0, ny0 - wh / 2, ww, wh);
                    if(mouse_press(mb_left, pFOCUS))
                        dialogPanelCall(new Panel_Addon());
                } else 
                    draw_sprite_stretched(THEME.ui_panel_bg, 1, nx0, ny0 - wh / 2, ww, wh);
                draw_text_add(nx0 + ui(8), ny0, name);
                draw_sprite_ui(THEME.addon_icon, 0, nx0 + ui(20) + string_width(name), ny0 + ui(1),,,, COLORS._main_icon);
                
                if(hori) nx0 += ww + ui(4);
                else     ny0 += hh + ui(4);
            }
        #endregion
        
        var x1 = _right? w - ui(6) : ui(8 + 28);
        
        #region actions
            var bs = ui(28);
            
            for( var i = 0, n = array_length(action_buttons); i < n; i++ ) {
                var action = action_buttons[i];
                
                switch(action) {
                    case "exit":
                        var b = buttonInstant(THEME.button_hide_fill, x1 - bs, ui(6), bs, bs, [mx, my], pHOVER, true,, THEME.window_exit_icon, 0, COLORS._main_accent);
                        if(b) _draggable = false;
                        if(b == 2) window_close();
                        break;
                        
                    case "maximize":
                        var win_max = window_is_maximized || window_is_fullscreen;
                        if(OS == os_macosx)
                            win_max = __win_is_maximized;
                        
                        var b = buttonInstant(THEME.button_hide_fill, x1 - bs, ui(6), bs, bs, [mx, my], pHOVER, true,, THEME.window_maximize_icon, win_max, [ COLORS._main_icon, CDEF.lime ]);
                        if(b) _draggable = false;
                        if(b == 2) {
                            if(OS == os_windows) {
                                if(window_is_fullscreen) {
                                    winMan_setFullscreen(false);
                                    winMan_Unmaximize();
                                    
                                } else if(window_is_maximized) {
                                    winMan_Unmaximize();
                                    DISPLAY_REFRESH
                                    
                                } else {
                                    winMan_Maximize();
                                    DISPLAY_REFRESH
                                }
                                
                            } else if(OS == os_macosx) {
                                if(__win_is_maximized)  mac_window_minimize();
                                else                    mac_window_maximize();
                            }
                        }
                        break;
                        
                    case "minimize":
                        var b = buttonInstant(THEME.button_hide_fill, x1 - bs, ui(6), bs, bs, [mx, my], pHOVER, true,, THEME.window_minimize_icon, 0, [ COLORS._main_icon, CDEF.yellow ]);
                        if(b) _draggable = false;
                        if(b == -2) {
                                 if(OS == os_windows) winMan_Minimize();
                            else if(OS == os_macosx)  mac_window_dock();
                        }
                        break;
                        
                    case "fullscreen":
                        var win_full = window_is_fullscreen;
                        var b = buttonInstant(THEME.button_hide_fill, x1 - bs, ui(6), bs, bs, [mx, my], pHOVER, true,, THEME.window_fullscreen_icon, win_full, [ COLORS._main_icon, CDEF.cyan ]);
                        if(b) _draggable = false;
                        if(b == 2) {
                            if(OS == os_windows)
                                winMan_setFullscreen(!win_full);
                                
                            else if(OS == os_macosx) {
                                if(win_full) {
                                    winMan_setFullscreen(false);
                                    mac_window_minimize();
                                } else
                                    winMan_setFullscreen(true);
                            }
                        }
                        break;
                }
                
                if(_right) x1 -= bs + ui(4);
                else       x1 += bs + ui(4);
            }
        #endregion
        
        #region version
            var _xx1 = _right? x1 : w - ui(40);
            
            var txt = $"v. {VERSION_STRING}";
            if(STEAM_ENABLED) txt += " Steam";
            
            version_name_copy = lerp_float(version_name_copy, 0, 10);
            var tc  = merge_color(COLORS._main_text_sub, COLORS._main_value_positive, min(1, version_name_copy));
            var sc  = merge_color(c_white, COLORS._main_value_positive, min(1, version_name_copy));
            var fnt = f_p2;
            
            if(hori) {
                if(w > 1500) {
                    draw_set_text(fnt, fa_right, fa_center, tc);
                    var  ww = string_width(txt) + ui(12) + ui(20) * NIGHTLY;
                    var  hh = string_height(txt) + ui(8);
                    var _x0 = _xx1 - ww;
                    var _x1 = _xx1;
                    
                    var _y0 = h / 2 - hh / 2;
                    var _y1 = h / 2 + hh / 2;
                    
                    if(pHOVER && point_in_rectangle(mx, my, _x0, _y0, _x1, _y1)) {
                        _draggable = false;
                        draw_sprite_stretched_ext(THEME.button_hide_fill, 1, _x0, _y0, _x1 - _x0, _y1 - _y0, sc, 1);
                        
                        if(mouse_press(mb_left, pFOCUS))
                            dialogCall(o_dialog_release_note); 
                            
                        if(mouse_press(mb_right, pFOCUS)) {
                            clipboard_set_text(VERSION_STRING);
                            version_name_copy = 3;
                        }
                    }
                    
                    var _ty = (_y0 + _y1) / 2;
                    draw_text(_x1 - ui(6), round(_ty), txt);
                    if(NIGHTLY) draw_sprite_ext(s_nightly, 0, _x0 + ui(16), _ty, 1, 1, 0, COLORS._main_icon);
                    _xx1 = _x0 - ui(8);
                }
                
            } else {
                var _xx1 = ui(40);
                var y1 = h - ui(20);
                
                draw_set_text(fnt, fa_left, fa_center, tc);
                var ww = string_width(txt) + ui(12);
                if(pHOVER && point_in_rectangle(mx, my, _xx1, y1 - ui(16), _xx1 + ww, y1 + ui(16))) {
                    _draggable = false;
                    draw_sprite_stretched_ext(THEME.button_hide_fill, 1, _xx1, y1 - ui(16), ww, ui(32), sc, 1);
                    
                    if(mouse_press(mb_left, pFOCUS))
                        dialogCall(o_dialog_release_note); 
                        
                    if(mouse_press(mb_right, pFOCUS)) {
                        clipboard_set_text(VERSION_STRING);
                        version_name_copy = 3;
                    }
                }
                
                draw_text_int(_xx1 + ui(6), y1, txt);
            }
        #endregion
        
        #region title
            
            var txt = PROJECT.path == ""? __txt("Untitled") : filename_name_only(PROJECT.path);
            if(PROJECT.modified) txt += "*";
            
            var tx0, tx1, tcx;
            var ty0, ty1;
            var tbx0, tby0;
            var maxW;
            
            if(hori) {
                tx0 = nx0;
                tx1 = _xx1;
                ty0 = 0;
                ty1 = h;
                tcx  = (tx0 + tx1) / 2;
                
            } else {
                tx0 = ui(8);
                tx1 = w < vertical_break? w - ui(16) : w - ui(144);
                ty0 = w < vertical_break? ui(36) : ui(6);
                
                tcx = tx0;
                if(!_right && w >= vertical_break) {
                    tx0 = x1 - bs;
                    tx1 = w - ui(16);
                }
            }
            
            maxW = abs(tx0 - tx1);
            
            draw_set_font(f_p0b);
            var full_name = string_width(txt + ".pxc") < maxW;
            var tc = string_cut(txt, maxW);
            var tw = string_width(tc) + ui(16);
            var th = ui(28);
            
            if(hori) {
                tbx0 = tcx - tw / 2;
                tby0 = ty1 / 2 - ui(14);
                
            } else {
                tbx0 = tx0;
                tby0 = ty0;
            }
            
            if(full_name) tw += string_width(".pxc");
            var _b   = buttonInstant(THEME.button_hide_fill, tbx0, tby0, tw, th, [mx, my], pHOVER, pFOCUS);
            var _hov = _b > 0;
            
            if(_b) _draggable = false;
            if(_b == 2) {
                _hov = true;
                var arr = [];
                var dat = [];
                var tip = [];
                
                for(var i = 0; i < min(10, ds_list_size(RECENT_FILES)); i++)  {
                    var _rec = RECENT_FILES[| i];
                    var _dat = RECENT_FILE_DATA[| i];
                    array_push(arr, menuItem(_rec, function(_dat) /*=>*/ {return LOAD_PATH(_dat.path)}, noone, noone, noone, { path: _dat.path }) );
                    array_push(tip, [ method(_dat, _dat.getThumbnail), VALUE_TYPE.surface ]);
                }
                
                var dia = hori? menuCall("title_recent_menu", arr, x + tcx, y + h, fa_center) : menuCall("title_recent_menu", arr, x + w, y + tby0);
                if(dia) dia.tooltips = tip;
            }
            
            
            draw_set_font(f_p0b);
            var _tcw = string_width(tc);
            
            if(hori) {
                var _tyc = (ty0 + ty1) / 2;
                
                draw_set_text(f_p0b, fa_left, fa_center, COLORS._main_text);
                draw_text_int(tcx - _tcw / 2, _tyc, tc);
                
                if(full_name) {
                    draw_set_color(COLORS._main_text_sub);
                    draw_text_int(tcx + _tcw / 2, _tyc, ".pxc");
                    
                    if(PROJECT.readonly) {
                        var _rd_lx = tcx - _tcw / 2 - ui(2);
                        var _rd_ly = _tyc;
                        var _rd_t  = "Read only";
                        
                        draw_set_font(f_p3);
                        var _rd_w = string_width(_rd_t)  + ui(8);
                        var _rd_h = string_height(_rd_t) + ui(4);
                        
                        var _rd_x0 = _rd_lx - _rd_w - ui(8);
                        var _rd_x1 = _rd_x0 + _rd_w;
                        
                        var _rd_y0 = _rd_ly - _rd_h / 2;
                        var _rd_y1 = _rd_ly + _rd_h / 2;
                        
                        draw_sprite_stretched_ext(THEME.box_r2, 0, _rd_x0, _rd_y0, _rd_w, _rd_h, COLORS._main_icon);
                        
                        draw_set_text(f_p3, fa_center, fa_center, COLORS._main_icon_dark);
                        draw_text(_rd_x0 + _rd_w / 2, _rd_y0 + _rd_h / 2, _rd_t);
                    }
                }
                
            } else {
                draw_set_text(f_p0b, fa_left, fa_center, COLORS._main_text);
                draw_text_int(tx0 + ui(8), tby0 + th / 2, tc);
                
                if(full_name) {
                    draw_set_color(COLORS._main_text_sub);
                    draw_text_int(tx0 + ui(8) + _tcw, tby0 + th / 2, ".pxc");
                }
                
            }
            
            draw_set_font(f_p0b);
            
            if(IS_PATREON && PREFERENCES.show_supporter_icon) {
                var _tw  = string_width(tc);
                var _th  = string_height(tc);
                var _cx, _cy;
                
                if(hori) {
                    _cx = tcx + _tw / 2;
                    _cy = (ty0 + ty1) / 2 - _th / 2;
                    
                } else {
                    _cx = tx0 + ui(8) + _tw;
                    _cy = tby0 + th / 2 - _th / 2;
                }
                
                if(full_name) _cx += string_width(".pxc");
                
                _cx += ui(2);
                _cy += ui(6);
                
                var _ib = COLORS._main_text_sub;
                
                if(pHOVER && point_in_rectangle(mx, my, _cx - 12, _cy - 12, _cx + 12, _cy + 12)) {
                    TOOLTIP = __txt("Supporter");
                    _ib = COLORS._main_accent;
                }
                
                draw_sprite_ext(THEME.patreon_supporter, 0, _cx, _cy, 1, 1, 0, _hov? COLORS._main_icon_dark : COLORS.panel_bg_clear, 1);
                draw_sprite_ext(THEME.patreon_supporter, 1, _cx, _cy, 1, 1, 0, _ib, 1);
            }
        #endregion
        
        #region drag
            if(_draggable) {
                if(DOUBLE_CLICK) {
                    if(window_is_maximized) 
                        winMan_Unmaximize();
                    else 
                        winMan_Maximize();
                    DISPLAY_REFRESH
                }
                
                if(mouse_press(mb_left)) winMan_initDrag(0b10000);
            }
        #endregion
    }
}