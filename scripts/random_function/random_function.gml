function random1D(seed, startRange = 0, endRange = 1) {
	random_set_seed(GLOBAL_SEED + seed);
	return random_range(startRange, endRange);
}

function getWiggle(_min, _max, _freq, _time, seed_shift = 0, startTime = noone, endTime = noone) {
	_freq = max(1, _freq);
	var sdMin = floor(_time / _freq) * _freq;
	var sdMax = sdMin + _freq;
	if(endTime) 
		sdMax = min(endTime, sdMax);
	
	var _x0 = (startTime != noone && sdMin <= startTime)?     0.5 : random1D(GLOBAL_SEED + seed_shift + sdMin);
	var _x1 = (endTime != noone && sdMax * _freq >= endTime)? 0.5 : random1D(GLOBAL_SEED + seed_shift + sdMax);
	
	var t = (_time - sdMin) / (sdMax - sdMin);
	t = -(cos(pi * t) - 1) / 2;
	var _val = lerp(_x0, _x1, t);
	return lerp(_min, _max, _val);
}

function generateUUID() {
	randomize();
	var uuid;
	do {
		uuid = irandom(1000000000);
	} until(!ds_map_exists(NODE_MAP, uuid))
	return uuid;
}