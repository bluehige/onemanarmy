extends SceneTree

const TRANSPARENT_DISTANCE := 0.075
const OPAQUE_DISTANCE := 0.38


func _init() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() != 2:
		printerr("Usage: godot --headless --path . --script res://tools/art/process_chroma_plate.gd -- <input.png> <output.png>")
		quit(2)
		return

	var input_path := ProjectSettings.globalize_path(args[0]) if args[0].begins_with("res://") else args[0]
	var output_path := ProjectSettings.globalize_path(args[1]) if args[1].begins_with("res://") else args[1]
	var source := Image.new()
	var load_error := source.load(input_path)
	if load_error != OK:
		printerr("Could not load chroma plate: %s (%s)" % [input_path, error_string(load_error)])
		quit(3)
		return

	if source.is_compressed():
		source.decompress()
	if source.get_format() != Image.FORMAT_RGBA8:
		source.convert(Image.FORMAT_RGBA8)
	var key := _sample_border_key(source)
	if key.r < 0.70 or key.b < 0.70 or key.g > 0.30:
		printerr("Border is not a valid magenta key field: %s" % key)
		quit(6)
		return

	var transparent_pixels := 0
	var softened_pixels := 0
	for y in source.get_height():
		for x in source.get_width():
			var observed := source.get_pixel(x, y)
			var distance := Vector3(observed.r - key.r, observed.g - key.g, observed.b - key.b).length()
			var alpha := smoothstep(TRANSPARENT_DISTANCE, OPAQUE_DISTANCE, distance)
			var magenta_spill := maxf(0.0, minf(observed.r, observed.b) - observed.g)
			alpha = minf(alpha, 1.0 - smoothstep(0.12, 0.42, magenta_spill))
			if alpha <= 0.001:
				source.set_pixel(x, y, Color(0.0, 0.0, 0.0, 0.0))
				transparent_pixels += 1
				continue

			var clean_rgb := Vector3(observed.r, observed.g, observed.b)
			if magenta_spill > 0.01:
				var despill_strength := smoothstep(0.01, 0.18, magenta_spill)
				clean_rgb.x = maxf(0.0, clean_rgb.x - magenta_spill * despill_strength)
				clean_rgb.z = maxf(0.0, clean_rgb.z - magenta_spill * despill_strength)
			if alpha < 0.999:
				softened_pixels += 1
			source.set_pixel(x, y, Color(clean_rgb.x, clean_rgb.y, clean_rgb.z, alpha))

	var output_dir := output_path.get_base_dir()
	if not DirAccess.dir_exists_absolute(output_dir):
		var mkdir_error := DirAccess.make_dir_recursive_absolute(output_dir)
		if mkdir_error != OK:
			printerr("Could not create output directory: %s (%s)" % [output_dir, error_string(mkdir_error)])
			quit(4)
			return

	var save_error := source.save_png(output_path)
	if save_error != OK:
		printerr("Could not save keyed plate: %s (%s)" % [output_path, error_string(save_error)])
		quit(5)
		return

	print("CHROMA_PLATE_OK width=%d height=%d key=%s transparent=%d softened=%d output=%s" % [
		source.get_width(), source.get_height(), key, transparent_pixels, softened_pixels, output_path
	])
	quit()


func _sample_border_key(image: Image) -> Color:
	var inset := maxi(2, int(mini(image.get_width(), image.get_height()) / 100.0))
	var stride := maxi(1, inset / 3)
	var sum := Vector3.ZERO
	var samples := 0
	for y in range(0, image.get_height(), stride):
		for x in range(0, inset, stride):
			var left := image.get_pixel(x, y)
			var right := image.get_pixel(image.get_width() - 1 - x, y)
			sum += Vector3(left.r, left.g, left.b) + Vector3(right.r, right.g, right.b)
			samples += 2
	for x in range(inset, image.get_width() - inset, stride):
		for y in range(0, inset, stride):
			var top := image.get_pixel(x, y)
			var bottom := image.get_pixel(x, image.get_height() - 1 - y)
			sum += Vector3(top.r, top.g, top.b) + Vector3(bottom.r, bottom.g, bottom.b)
			samples += 2
	var average := sum / maxf(float(samples), 1.0)
	return Color(average.x, average.y, average.z, 1.0)
