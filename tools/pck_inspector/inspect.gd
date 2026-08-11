extends SceneTree


const FORBIDDEN_PREFIXES := [
	"res://build/",
	"res://output/",
	"res://reports/",
	"res://tests/",
	"res://docs/",
	"res://tools/",
	"res://web/",
	"res://assets/concept-art/",
	"res://assets/art/ch01-v5/source/",
	"res://.godot/imported/CH01_CG_INN_NINE_SWORDS_v001.png-",
	"res://.godot/imported/CH01_ENV_CANYON_PREDEPLOY_v001.png-",
]

const FORBIDDEN_FILES := [
	"res://data/localization/ko.zip",
	"res://data/story/ch01.zip",
	"res://assets/art/ch01-redesign-v2/CH01_CG_INN_NINE_SWORDS_v001.png.import",
	"res://assets/art/ch01-redesign-v2/CH01_ENV_CANYON_PREDEPLOY_v001.png.import",
]

const REQUIRED_FILES := [
	"res://assets/art/ch01-v5/CH01_ENV_CANYON_CLEAN_v001.png.import",
	"res://assets/art/ch01-v5/hero/CH01_CG_JO_MUNTAK_CONTRACT_v001.png.import",
	"res://assets/fonts/NotoSansKR-VF.ttf.import",
	"res://data/story/ch01/chapter_manifest.json",
	"res://data/visuals/ch01_manifest.json",
	"res://scripts/cinematic/formation_visual_director.gdc",
	"res://scripts/ui/vn_shot_compositor.gdc",
]

const REQUIRED_PREFIXES := [
	"res://.godot/imported/CH01_ENV_CANYON_CLEAN_v001.png-",
	"res://.godot/imported/CH01_CG_JO_MUNTAK_CONTRACT_v001.png-",
	"res://.godot/imported/NotoSansKR-VF.ttf-",
]


func _init() -> void:
	var pack_path := ""
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--pack="):
			pack_path = argument.trim_prefix("--pack=")
	if pack_path.is_empty() or not ProjectSettings.load_resource_pack(pack_path, true):
		printerr("PCK_INSPECT_LOAD_FAIL: %s" % pack_path)
		quit(1)
		return

	var files: Array[String] = []
	_walk("res://", files)
	files.sort()
	var file_set := {}
	for path in files:
		file_set[path] = true

	var failures := 0
	for path in files:
		if FORBIDDEN_FILES.has(path) or path.ends_with(".zip"):
			printerr("PCK_FORBIDDEN_FILE: %s" % path)
			failures += 1
			continue
		for prefix in FORBIDDEN_PREFIXES:
			if path.begins_with(prefix):
				printerr("PCK_FORBIDDEN_FILE: %s" % path)
				failures += 1
				break

	for path in REQUIRED_FILES:
		if not file_set.has(path):
			printerr("PCK_REQUIRED_FILE_MISSING: %s" % path)
			failures += 1

	for prefix in REQUIRED_PREFIXES:
		var found := false
		for path in files:
			if path.begins_with(prefix):
				found = true
				break
		if not found:
			printerr("PCK_REQUIRED_PREFIX_MISSING: %s" % prefix)
			failures += 1

	print("PCK_FILE_COUNT: %d" % files.size())
	if failures > 0:
		printerr("PCK_INSPECT_FAIL: %d issue(s)" % failures)
		quit(1)
		return

	print("PCK_INSPECT_PASS")
	quit(0)


func _walk(path: String, files: Array[String]) -> void:
	var directory := DirAccess.open(path)
	if directory == null:
		return
	directory.list_dir_begin()
	while true:
		var entry := directory.get_next()
		if entry.is_empty():
			break
		if entry == "." or entry == "..":
			continue
		var child := path.path_join(entry)
		if directory.current_is_dir():
			_walk(child, files)
		else:
			files.append(child)
	directory.list_dir_end()
