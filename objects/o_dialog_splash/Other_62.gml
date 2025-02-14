/// @description 
var _id = async_load[? "id"];

if(_id == contest_req) { 
	var r_str = async_load[? "result"];
	if(is_undefined(r_str)) exit;
	
	var thr_str = json_try_parse(r_str, noone);
	if(thr_str == noone) exit;
	
	if(struct_has(thr_str, "threads")) {
		var thrs = thr_str.threads;
		for( var i = 0, n = array_length(thrs); i < n; i++ ) {
			var thr = thrs[i];
			if(thr.parent_id != "1113080578351312906") continue; //not in contest channel
			
			if(struct_has(thr, "flags") && thr.flags & 2) continue;
			if(struct_has(thr, "applied_tags") && array_exists(thr.applied_tags, "1113145223938326658")) continue; //has announcement tag
			thr.messages = [];
			
			array_push(contests, thr);
			
			var url = $"https://discord.com/api/v10/channels/{thr.id}/messages";
			array_push(contest_message_req, [ http_request(url, "GET", discord_map, ""), array_length(contests) - 1 ]);
		}
		
		array_insert(pages, 0, "Contests");
		project_page++;
	}
	
	exit;
}

if(_id == news_req) { 
	var r_str = async_load[? "result"];
	if(is_undefined(r_str)) exit;
	
	var thr_str = json_try_parse(r_str, noone);
	if(!is_array(thr_str)) exit;
	
	for (var i = 0, n = array_length(thr_str); i < n; i++) {
		var _inf = thr_str[i];
	    _inf.img     = noone;
		
		if(_inf.img_url != "") {
			var _fil = $"{DIRECTORY}Cache/{_inf.header}.png";
			
			if(file_exists_empty(_fil)) {
				_inf.img = sprite_add(_fil, 0, false, false, 0, 0);
				
			} else {
				var _rid = http_get_file(_inf.img_url, _fil);
				news_requests[$ _rid] = _inf;
			}
		}
		
		news_content[i] = _inf;
	}
	
	exit;
}

if(struct_has(news_requests, _id)) {
	var _status = ds_map_find_value(async_load, "status");
    if (_status != 0) exit;
    
    var _path = ds_map_find_value(async_load, "result");
    var _inf  = news_requests[$ _id];
    
    if(file_exists_empty(_path))
    	_inf.img = sprite_add(_path, 0, false, false, 0, 0);
	exit;
}

for( var i = 0, n = array_length(contest_message_req); i < n; i++ ) {
	if(async_load[? "id"] != contest_message_req[i][0]) continue;
	
	var r_str = async_load[? "result"];
	if(is_undefined(r_str)) exit;
	
	var msgs = json_try_parse(r_str, noone);
	if(msgs == noone) exit;
	
	var ind  = contest_message_req[i][1];
	var thr  = contests[ind];
	thr.messages = msgs;
	
	for( var j = 0; j < array_length(msgs); j++ ) {
		var msg = msgs[j];
		
		var aut = msg.author.id;
		if(ds_map_exists(nicknames, aut)) continue;
		
		var url = $"https://discord.com/api/v10/guilds/953634069646835773/members/{aut}";
		nicknames[? aut] = [ http_request(url, "GET", discord_map, ""), msg.author.username ];
	}
	
	thr.title = msgs[array_length(msgs) - 1];
	thr.title.meta = {};
	
	var content = thr.title.content;
	var _metaSp = string_split(content, "```", false, 2);
	
	if(array_length(_metaSp) == 3 && _metaSp[0] == "") {
		var _meta = _metaSp[1];
		var _mtS  = string_splice(_meta, "\n");
		
		for( var j = 0; j < array_length(_mtS); j++ ) {
			var __mt = string_splice(_mtS[j], ":");
			if(array_length(__mt) < 2) continue;
			
			thr.title.meta[$ string_lower(string_trim(__mt[0]))] = string_trim(__mt[1]);
		}
		
		thr.title.content = string_trim(_metaSp[2]);
	}
	
	if(struct_has(thr.title, "attachments") && array_length(thr.title.attachments)) {
		var att = thr.title.attachments[0];
		thr.title.attachments = att;
		
		var path = TEMPDIR + att.id + filename_ext(att.url);
		attachment[? att.id] = [ http_get_file(att.url, path), path ];
	} else 
		thr.title.attachments = noone;
	
	exit;
}

var keys = ds_map_keys_to_array(nicknames);
for( var i = 0, n = array_length(keys); i < n; i++ ) {
	var nick = nicknames[? keys[i]];
	
	if(!is_array(nick)) continue;
	if(async_load[? "id"] != nick[0]) continue;
	
	var r_str = async_load[? "result"];
	if(is_undefined(r_str)) exit;
	
	var auth = json_try_parse(r_str, noone);
	if(auth == noone) exit;
	
	nicknames[? keys[i]] = struct_try_get(auth, "nick", nick[1]);
	
	exit;
}

var keys = ds_map_keys_to_array(attachment);
for( var i = 0, n = array_length(keys); i < n; i++ ) {
	var att = attachment[? keys[i]];
	
	if(!is_array(att)) continue;
	if(async_load[? "id"] != att[0]) continue;
	
	var path = att[1];
	
	if(!file_exists_empty(path)) {
		attachment[? keys[i]] = noone;
		exit;
	}
	
	var spr = sprite_add(path, 0, false, 0, 0, 0);
	attachment[? keys[i]] = spr;
	var _sw = sprite_get_width(spr);
	var _sh = sprite_get_height(spr);
	sprite_set_offset(spr, _sw / 2, _sh / 2);
	
	exit;
}