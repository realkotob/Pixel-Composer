#region vb
	vertex_format_begin();
	vertex_format_add_position();
	vertex_format_add_color();
	vertex_format_add_texcoord();
	global.HLSL_VB_FORMAT = vertex_format_end();

	global.HLSL_VB_PLANE = vertex_create_buffer();
	vertex_begin(global.HLSL_VB_PLANE, global.HLSL_VB_FORMAT);
		
		vertex_add_2pct(global.HLSL_VB_PLANE, 0, 0, 0, 0, c_white);
		vertex_add_2pct(global.HLSL_VB_PLANE, 0, 1, 0, 1, c_white);
		vertex_add_2pct(global.HLSL_VB_PLANE, 1, 0, 1, 0, c_white);
		vertex_add_2pct(global.HLSL_VB_PLANE, 1, 1, 1, 1, c_white);
		
	vertex_end(global.HLSL_VB_PLANE);
#endregion

#region libraries
	globalvar HLSL_LIBRARIES, HLSL_LIBRARIES_ARR;
	
	function __initHLSL() {
		HLSL_LIBRARIES     = {};
		HLSL_LIBRARIES_ARR = [];
		
		var _dir = $"{DIRECTORY}Nodes/HLSL";
		directory_verify(_dir);
		var _files = readFolder(_dir);
		
		for( var i = 0, n = array_length(_files); i < n; i++ ) {
			var _f = _files[i];
			var _n = string_replace(_f, _dir + "/", "");
			    _n = string_replace(_n, filename_ext(_n), "");
			
			HLSL_LIBRARIES[$ _n] = _f;
			array_push(HLSL_LIBRARIES_ARR, _n);
		}
	}
#endregion

function Node_HLSL(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name   = "HLSL";
	shader = { vs: -1, fs: -1 };
	
	newInput(0, nodeValue_Text("Vertex", self, ""))
		.setDisplay(VALUE_DISPLAY.codeHLSL)
		.rejectArray();
	
	newInput(1, nodeValue_Text("Main", self, 
@"float4 surfaceColor = gm_BaseTextureObject.Sample(gm_BaseTexture, input.uv);
output.color = surfaceColor;"))
		.setDisplay(VALUE_DISPLAY.codeHLSL)
		.rejectArray();
	
	newInput(2, nodeValue_Surface("Base Texture", self));
	
	newInput(3, nodeValue_Text("Libraries", self, "" ))
		.setDisplay(VALUE_DISPLAY.codeHLSL)
		.rejectArray();
	
	newInput(4, nodeValue_Text("Global", self, ""))
		.setDisplay(VALUE_DISPLAY.codeHLSL)
		.rejectArray();
	
	newOutput(0, nodeValue_Output("Surface", self, VALUE_TYPE.surface, noone ));
	
	static createNewInput = function() {
		var index = array_length(inputs);
		newInput(index + 0, nodeValue_Text("Argument name", self, "" ));
		
		newInput(index + 1, nodeValue_Enum_Scroll("Argument type", self,  0 , { data: [ "Float", "Int", "Vec2", "Vec3", "Vec4", "Mat3", "Mat4", "Sampler2D", "Color" ], update_hover: false }));
		inputs[index + 1].editWidget.interactable = false;
		
		newInput(index + 2, nodeValue("Argument value", self, CONNECT_TYPE.input, VALUE_TYPE.float, 0 ))
			.setVisible(true, true);
		inputs[index + 2].editWidget.interactable = false;
	}
	
	argumentRenderer();
	
	#region Template
		vs_string  = "#define MATRIX_WORLD                 0\n#define MATRIX_WORLD_VIEW            1\n#define MATRIX_WORLD_VIEW_PROJECTION 2";
		vs_string += @"

cbuffer Matrices : register(b0) {
    float4x4 gm_Matrices[3];
};

struct VertexShaderInput {
    float3 pos      : POSITION;
    float3 color    : COLOR0;
    float2 uv       : TEXCOORD0;
};

struct VertexShaderOutput {
    float4 pos      : SV_POSITION;
    float2 uv       : TEXCOORD0;
};

void main(in VertexShaderInput input, out VertexShaderOutput output) {
    output.pos  = mul(gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION], float4(input.pos, 1.0f));
    output.uv   = input.uv;   
}";
	
		fs_preMain  = @"Texture2D gm_BaseTextureObject : register(t0);
SamplerState gm_BaseTexture    : register(s0);

struct VertexShaderOutput {
    float4 pos      : SV_POSITION;
    float2 uv       : TEXCOORD0;
};

struct PixelShaderOutput {
    float4 color : SV_TARGET0;
};

";
		fs_postMain   = @"void main(in VertexShaderOutput _input, out PixelShaderOutput output) {
    VertexShaderOutput input = _input;
";

		fs_postString = "}";
	#endregion
	
	libraries     = [];
	libraryParams = [];
	preMainLabel  = new Inspector_Label(fs_preMain,  _f_code_s);
	postMainLabel = new Inspector_Label(fs_postMain, _f_code_s);
	
	inspector_label_values = ["Values", true];
	
	input_display_list = [ 2, 
		["Preprocessor",     true], 3, 
		["Vertex Shader [read only]", true], new Inspector_Label(vs_string, _f_code_s),
		["Fragment Shader", false], preMainLabel, 4, postMainLabel, 1, new Inspector_Label(fs_postString, _f_code_s), 
		["Arguments",	    false], argument_renderer,
		inspector_label_values, 
	];

	setDynamicInput(3, false);
	
	static refreshDynamicInput = function() {
		var _in = [];
		
		for( var i = 0; i < input_fix_len; i++ )
			array_push(_in, inputs[i]);
		
		array_resize(input_display_list, input_display_len);
		
		for( var i = input_fix_len; i < array_length(inputs); i += data_length ) {
			var inp_name = inputs[i].getValue();
			var inp_type = inputs[i + 1];
			var inp_valu = inputs[i + 2];
			var cur_valu = inputs[i + 2].getValue();
			
			if(inp_name == "") {
				delete inputs[i + 0];
				delete inputs[i + 1];
				delete inputs[i + 2];
				continue;
			}
			
			array_push(_in, inputs[i + 0]);
			array_push(_in, inp_type);
			array_push(_in, inp_valu);
				
			inp_type.editWidget.interactable = true;
			if(inp_valu.editWidget != noone)
				inp_valu.editWidget.interactable = true;
			inp_valu.name = inp_name;
				
			var type = inp_type.getValue();
			switch(type) {
				
				case 0 : // Float
					if(is_array(cur_valu)) inp_valu.overrideValue(0);
					
					inp_valu.setType(VALUE_TYPE.float);
					inp_valu.setDisplay(VALUE_DISPLAY._default);
					break;
					
				case 1 : // Int
					if(is_array(cur_valu)) inp_valu.overrideValue(0);
					
					inp_valu.setType(VALUE_TYPE.integer);	
					inp_valu.setDisplay(VALUE_DISPLAY._default);
					break;
						
				case 2 : //Vec2
					if(!is_array(cur_valu) || array_length(cur_valu) != 2)
						inp_valu.overrideValue([ 0, 0 ]);
					
					inp_valu.setType(VALUE_TYPE.float);	
					inp_valu.setDisplay(VALUE_DISPLAY.vector);
					break;
					
				case 3 : //Vec3
					if(!is_array(cur_valu) || array_length(cur_valu) != 3)
						inp_valu.overrideValue([ 0, 0, 0 ]);
					
					inp_valu.setType(VALUE_TYPE.float);	
					inp_valu.setDisplay(VALUE_DISPLAY.vector);
					break;
					
				case 4 : //Vec4
					if(!is_array(cur_valu) || array_length(cur_valu) != 4)
						inp_valu.overrideValue([ 0, 0, 0, 0 ]);
					
					inp_valu.setType(VALUE_TYPE.float);	
					inp_valu.setDisplay(VALUE_DISPLAY.vector);
					break;
					
				case 5 : //Mat3
					if(!is_array(cur_valu) || array_length(cur_valu) != 9)
						inp_valu.overrideValue(array_create(9));
					
					inp_valu.setType(VALUE_TYPE.float);	
					inp_valu.setDisplay(VALUE_DISPLAY.matrix, { size: 3 });
					break;
					
				case 6 : //Mat4
					if(!is_array(cur_valu) || array_length(cur_valu) != 16)
						inp_valu.overrideValue(array_create(16));
					
					inp_valu.setType(VALUE_TYPE.float);	
					inp_valu.setDisplay(VALUE_DISPLAY.matrix, { size: 4 });
					break;
					
				case 7 : //Sampler2D
					if(is_array(cur_valu))
						inp_valu.overrideValue(noone);
						
					inp_valu.setType(VALUE_TYPE.surface);	
					inp_valu.setDisplay(VALUE_DISPLAY._default);
					break;
					
				case 8 : //Color
					if(is_array(cur_valu))
						inp_valu.overrideValue(c_black);
					
					inp_valu.setType(VALUE_TYPE.color);	
					inp_valu.setDisplay(VALUE_DISPLAY._default);
					break;
					
			}
				
			array_push(input_display_list, i + 2);
		}
		
		for( var i = 0; i < array_length(_in); i++ )
			_in[i].index = i;
		
		inputs = _in;
		createNewInput();
		
		//print("==========================");
		//for( var i = 0, n = array_length(input_display_list); i < n; i++ )
		//	print(input_display_list[i]);
		//print("==========================");
		
	} if(!LOADING && !APPENDING) refreshDynamicInput();
	
	setTrigger(1, __txt("Compile"), [ THEME.refresh_icon, 1, COLORS._main_value_positive ], function() /*=>*/ { refreshShader(); triggerRender(); });
	
	setTrigger(2, __txt("Libraries"), [ THEME.libraries, 1, COLORS._main_icon ], function() /*=>*/ { dialogPanelCall(new Panel_HLSL_Libraries()); });
	
	static step = function() { argument_renderer.showValue = inspector_label_values[1]; }
	
	static refreshShader = function() {
		var  vs  = getInputData(0);
		var  fs  = getInputData(1);
		var _lib = getInputData(3);
		var _glo = getInputData(4);
		
		var _dir = TEMPDIR;
		directory_verify(_dir);
		
		var vs        = vs_string;
		file_text_write_all(_dir + "vout.shader", vs);
		
		var fs_param  = "cbuffer Data : register(b10) {\n";
		var fs_sample = "";
		var sampler_slot = 1;
		
		for( var i = input_fix_len, n = array_length(inputs); i < n; i += data_length ) {
			var _arg_name = getInputData(i + 0);
			if(_arg_name == "") continue;
			
			var _arg_type = getInputData(i + 1);
			
			switch(_arg_type) {
				case 0 : fs_param += $"    float    {_arg_name};\n"; break;							// u_float
				case 1 : fs_param += $"    int      {_arg_name};\n"; break;							// u_int
				case 2 : fs_param += $"    float2   {_arg_name};\n"; break;							// u_vec2
				case 3 : fs_param += $"    float3   {_arg_name};\n"; break;							// u_vec3
				case 4 : fs_param += $"    float4   {_arg_name};\n"; break;							// u_vec4
				case 5 : fs_param += $"    float3x3 {_arg_name};\n"; break;							// u_mat3
				case 6 : fs_param += $"    float4x4 {_arg_name};\n"; break;							// u_mat4
				case 7 :																			// u_sampler2D
					fs_sample += $"Texture2D {_arg_name}Object : register(t{sampler_slot});\n";
					fs_sample += $"SamplerState {_arg_name} : register(s{sampler_slot});\n";
					sampler_slot++;
					break;
					
				case 8 : fs_param += $"    float4   {_arg_name};\n";   break;							// u_vec4 color
			}
		}
		
		fs_param += "};\n";
		fs_param += fs_sample;
		
	        _lib  = string_replace(_lib, "\n", "");
		var _libs = string_splice(_lib, ";");
		
		if(project.data[$ "hlsl"] == undefined)
			project.data[$ "hlsl"] = {};
		
		libraries     = [];
		libraryParams = [];
		var fs_lib    = "\n";
		
		for( var i = 0, n = array_length(_libs); i < n; i++ ) {
			var _l  = _libs[i];
			var _ll = _l;
			    _ll = string_replace(_ll, "using", "");
			    _ll = string_replace(_ll, ";",     "");
			    _ll = string_replace(_ll, "\"",    "");
			    _ll = string_trim(_ll);
			
			if(_ll == "") continue;
			
			if(!struct_has(project.data.hlsl, _ll)) {
				if(!struct_has(HLSL_LIBRARIES, _ll)) { noti_warning($"HLSL error: library '{_ll}' not found."); continue; }
				project.data.hlsl[$ _ll] = file_read_all(HLSL_LIBRARIES[$ _ll])
			}
			
			array_push(libraries, _ll);
			array_append(libraryParams, hlsl_document_parser(project.data.hlsl[$ _ll]));
			
			fs_lib += $"{project.data.hlsl[$ _ll]}\n";
		}
		fs_lib += "\n";
		
		var _fs_preString = fs_param + fs_preMain;
		var _fs = fs_lib + _fs_preString + _glo + "\n" + fs_postMain + fs + fs_postString;
		file_text_write_all(_dir + "fout.shader", _fs);
		
		preMainLabel.text = _fs_preString;
		
		shader.vs = d3d11_shader_compile_vs(_dir + "vout.shader", "main", "vs_4_0");
		if (!d3d11_shader_exists(shader.vs)) 
			noti_warning(d3d11_get_error_string());
			
		shader.fs = d3d11_shader_compile_ps(_dir + "fout.shader", "main", "ps_4_0");
		if (!d3d11_shader_exists(shader.fs))
			noti_warning(d3d11_get_error_string());
	} if(!LOADING && !APPENDING) refreshShader();
	
	static onValueUpdate = function(index) {
		var _refresh = index == 0 || index == 1 || (index >= input_fix_len && (index - input_fix_len) % data_length != 2);
		
		if(_refresh) {
			refreshShader();
			refreshDynamicInput();
		}
	}
	
	static onCodeEdited = function() {
		var _global_edit = inputs[4].editWidget;
		var _fsmain_edit = inputs[1].editWidget;
		var _globalParams = array_clone(_global_edit.localParams);
		array_append(_globalParams, libraryParams);
		
		_global_edit.globalParams = libraryParams;
		_fsmain_edit.globalParams = _globalParams;
	}
	
	static processData = function(_output, _data, _output_index, _array_index = 0) {
		onCodeEdited();
		
		var _surf = _data[2];
		if(!is_surface(_surf)) return noone;
		if(!d3d11_shader_exists(shader.vs)) return noone;
		if(!d3d11_shader_exists(shader.fs)) return noone;
		
		_output = surface_verify(_output, surface_get_width_safe(_surf), surface_get_height_safe(_surf));
			
		surface_set_target(_output);
			DRAW_CLEAR
			BLEND_OVERRIDE
			
			// ############################ SET SHADER ############################
			d3d11_shader_override_vs(shader.vs);
			d3d11_shader_override_ps(shader.fs);
			
			#region uniforms 
				var uTypes = array_create(8, 0);
				var sampler_slot = 1;
		
				d3d11_cbuffer_begin();
				var _buffer = buffer_create(1, buffer_grow, 1);
				var _cbSize = 0;
		
				for( var i = input_fix_len, n = array_length(_data); i < n; i += data_length ) {
					var _arg_name = _data[i + 0];
					var _arg_type = _data[i + 1];
					var _arg_valu = _data[i + 2];
			
					if(_arg_name == "") continue;
					
					switch(_arg_type) {
						case 0 :														// u_float
							d3d11_cbuffer_add_float(1); 
							_cbSize++;
					
							buffer_write(_buffer, buffer_f32, _arg_valu);
							break;
						case 1 :														// u_int
							d3d11_cbuffer_add_int(1); 
							_cbSize++;
					
							buffer_write(_buffer, buffer_s32, _arg_valu);
							break;
							
						case 2 :														// u_vec2
						case 3 :														// u_vec3
						case 4 :														// u_vec4
						case 5 :														// u_mat3
						case 6 :														// u_mat4
							if(is_array(_arg_valu)) {
								d3d11_cbuffer_add_float(array_length(_arg_valu)); 
								_cbSize += array_length(_arg_valu);
						
								for( var j = 0, m = array_length(_arg_valu); j < m; j++ ) 
									buffer_write(_buffer, buffer_f32, _arg_valu[j]);		
							}
							break;
							
						case 7 :														// u_sampler2D
							if(is_surface(_arg_valu))
								d3d11_texture_set_stage_ps(sampler_slot, surface_get_texture(_arg_valu));
							sampler_slot++;
							break;
							
						case 8 :														// u_vec4 color
							var _clr = colToVec4(_arg_valu); 
							d3d11_cbuffer_add_float(4);
							_cbSize += 4;
							
							for( var j = 0; j < 4; j++ ) 
								buffer_write(_buffer, buffer_f32, _clr[j]);
							break;
					}
				}
		
				d3d11_cbuffer_add_float(4 - _cbSize % 4);
				var cbuff = d3d11_cbuffer_end();
				d3d11_cbuffer_update(cbuff, _buffer);
				buffer_delete(_buffer);
				
				d3d11_shader_set_cbuffer_ps(10, cbuff);
			#endregion

			matrix_set(matrix_world, matrix_build(0, 0, 0, 0, 0, 0, surface_get_width_safe(_surf), surface_get_height_safe(_surf), 1));
			vertex_submit(global.HLSL_VB_PLANE, pr_trianglestrip, surface_get_texture(_surf));
			matrix_set(matrix_world, matrix_build_identity());
		
			d3d11_shader_override_vs(-1);
			d3d11_shader_override_ps(-1);
			
			BLEND_NORMAL
		surface_reset_target();
		
		return _output;
	}
	
	static postLoad = function() { 
		refreshShader(); 
		refreshDynamicInput();
	}
}