extends SceneTree

const VISIBLE_CHANNEL_DELTA := 8.0 / 255.0


func _init() -> void:
	var options := _parse_options(OS.get_cmdline_user_args())
	var reference_path := str(options.get("reference", ""))
	var candidate_path := str(options.get("candidate", ""))
	var diff_path := str(options.get("diff", ""))
	var mean_threshold := float(options.get("mean-threshold", "0.01"))
	var visible_threshold := float(options.get("visible-threshold", "0.05"))

	if reference_path.is_empty() or candidate_path.is_empty():
		printerr("UI_CAPTURE_COMPARE_USAGE: --reference=<png> --candidate=<png> [--diff=<png>] [--mean-threshold=0.01] [--visible-threshold=0.05]")
		quit(2)
		return

	var reference := Image.load_from_file(reference_path)
	var candidate := Image.load_from_file(candidate_path)
	if reference.is_empty() or candidate.is_empty():
		printerr("UI_CAPTURE_COMPARE_LOAD_FAIL: reference=%s candidate=%s" % [reference_path, candidate_path])
		quit(2)
		return
	if reference.get_size() != candidate.get_size():
		printerr("UI_CAPTURE_COMPARE_SIZE_FAIL: reference=%s candidate=%s" % [reference.get_size(), candidate.get_size()])
		quit(1)
		return

	reference.convert(Image.FORMAT_RGBA8)
	candidate.convert(Image.FORMAT_RGBA8)
	var size := reference.get_size()
	var diff := Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	var channel_error_sum := 0.0
	var peak_channel_error := 0.0
	var visible_pixels := 0
	var exact_pixels := 0

	for y in range(size.y):
		for x in range(size.x):
			var expected := reference.get_pixel(x, y)
			var actual := candidate.get_pixel(x, y)
			var delta := Color(
				absf(expected.r - actual.r),
				absf(expected.g - actual.g),
				absf(expected.b - actual.b),
				absf(expected.a - actual.a)
			)
			var channel_peak := maxf(maxf(delta.r, delta.g), maxf(delta.b, delta.a))
			channel_error_sum += (delta.r + delta.g + delta.b + delta.a) * 0.25
			peak_channel_error = maxf(peak_channel_error, channel_peak)
			if channel_peak > 0.0:
				exact_pixels += 1
			if channel_peak > VISIBLE_CHANNEL_DELTA:
				visible_pixels += 1
			diff.set_pixel(x, y, Color(
				clampf(delta.r * 4.0, 0.0, 1.0),
				clampf(delta.g * 4.0, 0.0, 1.0),
				clampf(delta.b * 4.0, 0.0, 1.0),
				1.0
			))

	var pixel_count := size.x * size.y
	var mean_error := channel_error_sum / float(pixel_count)
	var exact_ratio := float(exact_pixels) / float(pixel_count)
	var visible_ratio := float(visible_pixels) / float(pixel_count)
	print("UI_CAPTURE_COMPARE_METRICS size=%dx%d mean=%.8f peak=%.8f changed=%.8f visible=%.8f" % [
		size.x, size.y, mean_error, peak_channel_error, exact_ratio, visible_ratio
	])

	if not diff_path.is_empty():
		var parent := diff_path.get_base_dir()
		if not parent.is_empty():
			DirAccess.make_dir_recursive_absolute(parent)
		var save_error := diff.save_png(diff_path)
		if save_error != OK:
			printerr("UI_CAPTURE_COMPARE_DIFF_SAVE_FAIL: %s error=%d" % [diff_path, save_error])
			quit(2)
			return

	if mean_error > mean_threshold or visible_ratio > visible_threshold:
		printerr("UI_CAPTURE_COMPARE_FAIL: mean %.8f/%.8f visible %.8f/%.8f" % [
			mean_error, mean_threshold, visible_ratio, visible_threshold
		])
		quit(1)
	else:
		print("UI_CAPTURE_COMPARE_PASS")
		quit(0)


func _parse_options(arguments: PackedStringArray) -> Dictionary:
	var options := {}
	for argument in arguments:
		if not argument.begins_with("--") or not argument.contains("="):
			continue
		var separator := argument.find("=")
		options[argument.substr(2, separator - 2)] = argument.substr(separator + 1)
	return options
