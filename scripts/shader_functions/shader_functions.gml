function shader_set_i(uniform, value) {
	INLINE
	
	var shader = shader_current();
	if(shader == -1) return;
	
	if(is_array(value)) {
		shader_set_i_array(shader, uniform, value);
		return;
	}
	
	switch(argument_count) {
		case 2 : shader_set_uniform_i(shader_get_uniform(shader, uniform), value);								break;
		case 3 : shader_set_uniform_i(shader_get_uniform(shader, uniform), value, argument[2]);					break;
		case 4 : shader_set_uniform_i(shader_get_uniform(shader, uniform), value, argument[2], argument[3]);	break;
		default:
			var array = array_create(argument_count - 1);
			for( var i = 1; i < argument_count; i++ )
				array[i - 1] = argument[i];
			shader_set_i_array(shader, uniform, array)
	}
}

function shader_set_i_array(shader, uniform, array) {
	INLINE
	
	shader_set_uniform_i_array(shader_get_uniform(shader, uniform), array);
}

function shader_set_2(uniform, v) { INLINE var shader = shader_current(); shader_set_uniform_f(shader_get_uniform(shader, uniform), aGetF(v, 0), aGetF(v, 1)); } 
function shader_set_3(uniform, v) { INLINE var shader = shader_current(); shader_set_uniform_f(shader_get_uniform(shader, uniform), aGetF(v, 0), aGetF(v, 1), aGetF(v, 2)); } 
function shader_set_4(uniform, v) { INLINE var shader = shader_current(); shader_set_uniform_f(shader_get_uniform(shader, uniform), aGetF(v, 0), aGetF(v, 1), aGetF(v, 2), aGetF(v, 3)); } 

function shader_set_f_array(uniform, value, max_length = 128) {
	var shader = shader_current();
	if(shader == -1) return;
	
	if(array_empty(value)) return;
	shader_set_uniform_f_array_safe(shader_get_uniform(shader, uniform), value, max_length);
}

function shader_set_f(uniform, value) {
	INLINE
	
	var shader = shader_current();
	if(shader == -1) return;
	
	if(is_array(value)) {
		if(array_empty(value)) return;
		shader_set_uniform_f_array_safe(shader_get_uniform(shader, uniform), value);
		return;
	}
	
	switch(argument_count) {
		case 2 : shader_set_uniform_f(shader_get_uniform(shader, uniform), value);											break;
		case 3 : shader_set_uniform_f(shader_get_uniform(shader, uniform), value, argument[2]);								break;
		case 4 : shader_set_uniform_f(shader_get_uniform(shader, uniform), value, argument[2], argument[3]);				break;
		case 5 : shader_set_uniform_f(shader_get_uniform(shader, uniform), value, argument[2], argument[3], argument[4]);	break;
		default:
			var array = array_create(argument_count - 1);
			for( var i = 1; i < argument_count; i++ )
				array[i - 1] = argument[i];
			shader_set_uniform_f_array(shader_get_uniform(shader, uniform), array)
	}
	
	if(argument_count == 2)
		shader_set_uniform_f(shader_get_uniform(shader, uniform), value);
	else if(argument_count == 3)
		shader_set_uniform_f(shader_get_uniform(shader, uniform), value, argument[2]);
	else if(argument_count == 4)
		shader_set_uniform_f(shader_get_uniform(shader, uniform), value, argument[2], argument[3]);
	else {
		var array = array_create(argument_count - 1);
		for( var i = 1; i < argument_count; i++ )
			array[i - 1] = argument[i];
		shader_set_uniform_f_array(shader_get_uniform(shader, uniform), array);
	}
}

function shader_set_f_map(uniform, value, surface = noone, junc = noone) {
	INLINE
	
	shader_set_f(uniform, is_array(value)? value : [ value, value ]); 
	
	if(surface == noone) {
		shader_set_i(      uniform + "UseSurf", false);
	} else {
		shader_set_i(      uniform + "UseSurf", junc.attributes.mapped && is_surface(surface));
		shader_set_surface(uniform + "Surf",    surface);
	}
}

function shader_set_f_map_s(uniform, value, surface, junc) {
	INLINE
	
	shader_set_f(uniform, is_array(value)? value : [ value, value ]); 
	shader_set_i(uniform + "UseSurf", junc.attributes.mapped && is_surface(surface));
}

function shader_set_uniform_f_array_safe(uniform, array, max_length = 4096) {
	INLINE
	
	if(!is_array(array)) return;
	
	var _len = array_length(array);
	if(_len == 0) return;
	if(_len > max_length) array_resize(array, max_length)
	
	shader_set_uniform_f_array(uniform, array);
}

function shader_set_surface(sampler, surface, linear = false, _repeat = false) {
	INLINE
	
	var shader = shader_current();
	if(shader == -1) return noone;
	
	var t = shader_get_sampler_index(shader, sampler);
	
	if(is_instanceof(surface, dynaSurf)) 
		surface = surface.surfaces[0];
	if(!is_surface(surface)) return t;
	
	texture_set_stage(t, surface_get_texture(surface));
	gpu_set_tex_filter_ext(t, linear);
	gpu_set_tex_repeat_ext(t, _repeat);
	
	return t;
}

function shader_set_surface_dimension(uniform, surface) {
	INLINE
	
	var shader = shader_current();
	if(!is_surface(surface)) return;
	if(shader == -1) return;
	
	var texture = surface_get_texture(surface);
	var tw = texture_get_texel_width(texture);
	var th = texture_get_texel_height(texture);
	
	tw = 2048;
	th = 2048;
	
	shader_set_uniform_f(shader_get_uniform(shader, uniform), tw, th);
}

function shader_set_dim(uniform = "dimension", surf = noone) {
	INLINE
	
	if(!is_surface(surf)) return;
	shader_set_f(uniform, surface_get_width_safe(surf), surface_get_height_safe(surf));
}

function shader_set_color(uniform, col, alpha = 1) {
	INLINE
	
	shader_set_f(uniform, colToVec4(col, alpha));
}

function shader_set_palette(pal, pal_uni = "palette", amo_uni = "paletteAmount", max_length = 1024) {
	INLINE
	
	if(MAC) max_length = min(max_length, 256);
	var _amo = min(max_length, array_length(pal));
	if(_amo == 0) return;
	
	var _pal = [];
	for( var i = 0, n = _amo; i < n; i++ )
		array_append(_pal, colToVec4(pal[i]));
	
	shader_set_i(amo_uni, _amo);
	shader_set_f(pal_uni, _pal);
}

#region prebuild
	enum BLEND {
		normal,
		add,
		over,
		alpha,
		alphamulp,
		subtract,
	}

	function shader_preset_interpolation(shader = sh_sample) {
		INLINE
		
		shader_set_uniform_i(shader_get_uniform(shader, "interpolation"),	getAttribute("interpolate"));
		shader_set_uniform_i(shader_get_uniform(shader, "sampleMode"),		getAttribute("oversample"));
	}

	function shader_postset_interpolation() {
		INLINE
		
		gpu_set_tex_filter(false);
	}
	
	function shader_set_interpolation_surface(surface) {
		INLINE
		
		shader_set_f("sampleDimension", surface_get_width_safe(surface), surface_get_height_safe(surface));
	}
	
	function shader_set_interpolation(surface, _dim = noone) {
		INLINE
		
		var intp   = getAttribute("interpolate");
		
		gpu_set_tex_filter(intp > 1);
		shader_set_i("interpolation",	intp);
		shader_set_f("sampleDimension", _dim == noone? surface_get_dimension(surface) : _dim);
		shader_set_i("sampleMode",		getAttribute("oversample"));
	}
	
	function surface_set_shader(surface, shader = sh_sample, clear = true, blend = BLEND.alpha) {
		if(!is_surface(surface)) {
			__surface_set = false;
			return;
		}
		
		__surface_set = true;
		surface_set_target(surface);
		if(clear) DRAW_CLEAR;
		
		switch(blend) {
			case BLEND.add :		BLEND_ADD			break;
			case BLEND.over:		BLEND_OVERRIDE		break;
			case BLEND.alpha:		BLEND_ALPHA		break;
			case BLEND.alphamulp:	BLEND_ALPHA_MULP	break;
		}
		
		if(shader == noone)
			__shader_set = false;
		else {
			__shader_set = true;
			shader_set(shader);
		}
	}
	
	function surface_reset_shader() {
		if(!__surface_set) return;
		
		shader_set_i("interpolation",	0);
		
		BLEND_NORMAL
		surface_reset_target();
		gpu_set_tex_filter(false);
		
		if(__shader_set)
			shader_reset();
	}
#endregion