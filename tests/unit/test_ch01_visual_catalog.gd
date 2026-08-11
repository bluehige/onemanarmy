extends SceneTree

const VisualCatalog := preload("res://scripts/data/ch01_visual_catalog.gd")
const ShotCompositor := preload("res://scripts/ui/vn_shot_compositor.gd")
const PRODUCTION_MANIFEST := "res://data/visuals/ch01_manifest.json"
const LAYER_FIXTURE := "res://tests/fixtures/visual_manifest_layers.json"
const LEGACY_FIXTURE := "res://tests/fixtures/visual_manifest_v1.json"
const SCENE_IDS: Array[String] = [
	"S00", "S01", "S02", "S03", "S04", "S05", "S06", "S07A", "S07B", "S07C", "S08", "S09",
]
const CINEMATIC_IDS: Array[String] = [
	"CIN-CH01-S00-CAPTURE",
	"CIN-CH01-S00-OPEN-PATH",
	"CIN-CH01-S05-COMMON",
	"CIN-CH01-S07-TRACK",
	"CIN-CH01-S07-PROTECT",
	"CIN-CH01-S07-LOCKDOWN",
	"CIN-CH01-S09-DEPARTURE",
]
const VALID_LAYOUTS: Array[String] = ["full_frame", "sprite"]

var _failures: Array[String] = []
var _validated_layer_assets: Dictionary = {}


func _init() -> void:
	_run.call_deferred()


func _run() -> void:
	var catalog := VisualCatalog.new()
	var manifest_value: Variant = JSON.parse_string(FileAccess.get_file_as_string(PRODUCTION_MANIFEST))
	_expect(manifest_value is Dictionary, "Production visual manifest must parse as a dictionary.")
	var manifest: Dictionary = manifest_value if manifest_value is Dictionary else {}
	_expect(catalog.manifest_schema_version() == 2, "Production visual manifest must use the V5 shot schema.")
	_expect(not catalog.title_art().is_empty(), "Title art must resolve to a runtime asset.")
	var unique_backgrounds := {}
	var raw_scenes: Dictionary = manifest.get("scenes", {})
	_expect(raw_scenes.size() == SCENE_IDS.size(), "Production manifest must define all 12 story scenes.")
	for scene_id: String in SCENE_IDS:
		var visual: Dictionary = catalog.scene_visual(scene_id)
		var background := str(visual.get("resolved_background", ""))
		_expect(not background.is_empty(), "%s must resolve a scene background." % scene_id)
		_expect(
			str(visual.get("background", "")).begins_with("res://assets/art/ch01-v5/"),
			"%s must target the approved V5 clean-background pack." % scene_id
		)
		unique_backgrounds[background] = true
		var raw_scene: Dictionary = raw_scenes.get(scene_id, {})
		var raw_shot: Dictionary = raw_scene.get("shot", {})
		_validate_production_shot(catalog.scene_shot(scene_id), raw_shot, "scene %s" % scene_id)
	_expect(unique_backgrounds.size() >= 6, "CH01 scenes must retain six distinct clean environments.")
	var clean_dialogue_backgrounds := {
		"S00": "res://assets/art/ch01-v5/CH01_ENV_CANYON_CLEAN_v001.png",
		"S01": "res://assets/art/ch01-v5/CH01_ENV_SIDEGATE_CLEAN_v001.png",
		"S02": "res://assets/art/ch01-v5/CH01_ENV_ALLEY_CONTRACT_CLEAN_v001.png",
		"S03": "res://assets/art/ch01-v5/CH01_ENV_INN_EXT_CLEAN_v001.png",
		"S04": "res://assets/art/ch01-v5/CH01_ENV_INN_INT_CLEAN_v001.png",
		"S05": "res://assets/art/ch01-v5/CH01_ENV_INN_INT_CLEAN_v001.png",
		"S09": "res://assets/art/ch01-v5/CH01_ENV_NORTH_GATE_PRELOCK_CLEAN_v001.png",
	}
	for scene_id: String in clean_dialogue_backgrounds:
		var shot: Dictionary = catalog.scene_shot(scene_id)
		_expect(not str(shot.get("id", "")).is_empty(), "%s must expose a stable shot ID." % scene_id)
		_expect(not str(shot.get("resolved_background", "")).is_empty(), "%s shot must retain a safe background fallback." % scene_id)
		_expect(
			str(shot.get("resolved_background", "")) == str(clean_dialogue_backgrounds[scene_id]),
			"%s dialogue must use its clean V5 background." % scene_id
		)
		_expect(_max_simultaneous_layers(shot.get("layers", [])) <= 4, "%s must stay within the four-visible-overlay dialogue-layer budget." % scene_id)

	var raw_cinematics: Dictionary = manifest.get("cinematics", {})
	_expect(raw_cinematics.size() == CINEMATIC_IDS.size(), "Production manifest must define all seven cinematics.")
	for cinematic_id: String in CINEMATIC_IDS:
		var visual: Dictionary = catalog.cinematic_visual(cinematic_id)
		_expect(not str(visual.get("resolved_opening_background", "")).is_empty(), "%s needs opening art." % cinematic_id)
		_expect(not str(visual.get("resolved_final_background", "")).is_empty(), "%s needs final art." % cinematic_id)
		_expect(not str(visual.get("formation_profile", "")).is_empty(), "%s needs an authored formation profile." % cinematic_id)
		var opening_shot: Dictionary = catalog.cinematic_shot(cinematic_id, "opening")
		var final_shot: Dictionary = catalog.cinematic_shot(cinematic_id, "final")
		_expect(not str(opening_shot.get("resolved_background", "")).is_empty(), "%s opening must expose the shared shot shape." % cinematic_id)
		_expect(not str(final_shot.get("resolved_background", "")).is_empty(), "%s final must expose the shared shot shape." % cinematic_id)
		var raw_cinematic: Dictionary = raw_cinematics.get(cinematic_id, {})
		_validate_production_shot(opening_shot, raw_cinematic.get("opening_shot", {}), "%s opening" % cinematic_id)
		_validate_production_shot(final_shot, raw_cinematic.get("final_shot", {}), "%s final" % cinematic_id)

	_test_s02_hero_asset_contract()
	_test_layer_fixture_and_compositor()
	_test_cue_scoped_layers()
	_test_legacy_manifest_fallback()

	if _failures.is_empty():
		print("CH01_VISUAL_CATALOG_TEST_PASS")
		quit(0)
		return
	for failure in _failures:
		push_error("[ch01-visual-catalog-test] %s" % failure)
	quit(1)


func _validate_production_shot(shot: Dictionary, raw_shot: Dictionary, label: String) -> void:
	_expect(not str(shot.get("id", "")).is_empty(), "%s must expose a stable shot ID." % label)
	var background := str(shot.get("resolved_background", ""))
	_expect(not background.is_empty() and ResourceLoader.exists(background), "%s background must resolve." % label)
	var layers: Array = shot.get("layers", [])
	var raw_layers: Array = raw_shot.get("layers", [])
	_expect(layers.size() == raw_layers.size(), "%s must not silently drop authored layers." % label)
	_expect(_max_simultaneous_layers(layers) <= 4, "%s must use no more than four simultaneously visible overlay layers." % label)
	var layer_ids: Dictionary = {}
	var character_slots: Dictionary = {}
	var character_count := 0
	for layer_variant: Variant in layers:
		var layer: Dictionary = layer_variant
		var layer_id := str(layer.get("id", ""))
		var layer_type := str(layer.get("type", ""))
		var layout := str(layer.get("layout", ""))
		_expect(not layer_id.is_empty() and not layer_ids.has(layer_id), "%s layer IDs must be present and unique." % label)
		layer_ids[layer_id] = true
		_expect(layer_type in VisualCatalog.VALID_LAYER_TYPES, "%s/%s has an invalid layer type." % [label, layer_id])
		_expect(layout in VALID_LAYOUTS, "%s/%s has an invalid layout." % [label, layer_id])
		var asset_path := str(layer.get("resolved_asset", ""))
		_expect(not asset_path.is_empty() and ResourceLoader.exists(asset_path), "%s/%s texture must resolve." % [label, layer_id])
		_validate_layer_texture(asset_path, "%s/%s" % [label, layer_id])
		for cue_field: String in ["show_on_shots", "hide_on_shots"]:
			if not layer.has(cue_field):
				continue
			var cue_values: Variant = layer.get(cue_field, [])
			_expect(cue_values is Array, "%s/%s %s must be an array." % [label, layer_id, cue_field])
			if cue_values is Array:
				for cue_value: Variant in cue_values:
					_expect(not str(cue_value).is_empty(), "%s/%s %s cannot contain an empty cue." % [label, layer_id, cue_field])
		if layout == "sprite":
			var anchor: Variant = layer.get("anchor", [])
			_expect(anchor is Array and anchor.size() == 2, "%s/%s sprite must have a two-value anchor." % [label, layer_id])
			_expect(float(layer.get("width_ratio", 0.0)) > 0.0, "%s/%s sprite width ratio must be positive." % [label, layer_id])
			_expect(float(layer.get("height_ratio", 0.0)) > 0.0, "%s/%s sprite height ratio must be positive." % [label, layer_id])
		if layer_type == "character":
			character_count += 1
			var slot := str(layer.get("slot", ""))
			_expect(slot in VisualCatalog.CHARACTER_SLOTS, "%s/%s must use a valid character slot." % [label, layer_id])
			_expect(not character_slots.has(slot), "%s must not duplicate character slot %s." % [label, slot])
			character_slots[slot] = true
	_expect(character_count <= VisualCatalog.MAX_CHARACTER_SLOTS, "%s must not exceed three character slots." % label)


func _validate_layer_texture(asset_path: String, label: String) -> void:
	if asset_path.is_empty() or _validated_layer_assets.has(asset_path):
		return
	_validated_layer_assets[asset_path] = true
	var texture := load(asset_path) as Texture2D
	_expect(texture != null and texture.get_width() > 0 and texture.get_height() > 0, "%s must load as a non-empty Texture2D." % label)
	if texture == null:
		return
	var image := texture.get_image()
	_expect(image != null and not image.is_empty(), "%s imported texture must expose image data." % label)
	if image != null and not image.is_empty():
		_expect(image.detect_alpha() != Image.ALPHA_NONE, "%s must retain transparency after import." % label)


func _test_s02_hero_asset_contract() -> void:
	var scene_value: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://data/story/ch01/s02.json"))
	_expect(scene_value is Dictionary, "S02 story data must parse for Hero CG validation.")
	if not scene_value is Dictionary:
		return
	var hero_steps: Array[Dictionary] = []
	for step_variant: Variant in (scene_value as Dictionary).get("steps", []):
		if step_variant is Dictionary and not str((step_variant as Dictionary).get("hero_cg_asset", "")).is_empty():
			hero_steps.append((step_variant as Dictionary).duplicate(true))
	_expect(hero_steps.size() == 1, "S02 must expose exactly one decisive-beat Hero CG line.")
	if hero_steps.size() != 1:
		return
	var hero_step: Dictionary = hero_steps[0]
	_expect(str(hero_step.get("id", "")) == "S02-010A", "S02 Hero CG must stay on the contract-death narration beat.")
	var hero_path := str(hero_step.get("hero_cg_asset", ""))
	_expect(ResourceLoader.exists(hero_path), "S02 Hero CG texture must resolve after import.")
	var hero_texture := load(hero_path) as Texture2D
	_expect(hero_texture != null, "S02 Hero CG must load as a Texture2D.")
	if hero_texture != null:
		var hero_size := hero_texture.get_size()
		_expect(hero_size.x >= 1280.0 and hero_size.y >= 720.0, "S02 Hero CG must retain HD source resolution.")
		_expect(absf(hero_size.x / hero_size.y - 16.0 / 9.0) < 0.01, "S02 Hero CG must retain a 16:9 composition.")


func _test_layer_fixture_and_compositor() -> void:
	var catalog := VisualCatalog.new(LAYER_FIXTURE)
	_expect(catalog.manifest_schema_version() == 2, "Layer fixture must load schema version 2.")
	var shot: Dictionary = catalog.scene_shot("TEST_LAYERED")
	var layers: Array = shot.get("layers", [])
	_expect(layers.size() == 5, "Layer normalization should keep rear, three character slots, and foreground.")
	var character_slots: Dictionary = {}
	var layer_ids: Array[String] = []
	for layer_variant: Variant in layers:
		var layer: Dictionary = layer_variant
		layer_ids.append(str(layer.get("id", "")))
		_expect(not str(layer.get("resolved_asset", "")).is_empty(), "Every fixture layer must resolve an existing texture.")
		if str(layer.get("type", "")) == "character":
			character_slots[str(layer.get("slot", ""))] = true
	_expect(character_slots.size() == 3, "Layer catalog must enforce exactly three unique character slots.")
	_expect("character_overflow" not in layer_ids, "A fourth or duplicate character slot must be rejected.")

	var compositor := ShotCompositor.new() as VNShotCompositor
	compositor.z_index = -10
	root.add_child(compositor)
	compositor.present_shot(shot)
	_expect(compositor.get_current_shot_id() == "SHOT-TEST-LAYERED", "Compositor must retain the authored shot ID.")
	_expect(compositor.get_layer_count() == 5, "Compositor must render every resolved normalized layer.")
	_expect(compositor.get_character_count() == 3, "Compositor must never render more than three character slots.")
	_expect(not compositor.get_resolved_background_path().is_empty(), "Compositor must render the resolved background.")
	for layer_node: CanvasItem in compositor.get_node("Layers").get_children():
		_expect(layer_node.z_index <= VNShotCompositor.MAX_INTERNAL_LAYER_Z, "Internal art z-index must stay inside the isolated compositor range.")
		_expect(compositor.z_index + layer_node.z_index < 0, "Every effective art z-index must remain below product UI z=0.")
	compositor.set_active_speaker("lee_yeon_inner")
	_expect(compositor.get_active_speaker() == "lee_yeon_inner", "Compositor must retain speaker emphasis state.")
	_expect(
		compositor.get_layer_opacity("character_center") > compositor.get_layer_opacity("character_left"),
		"The active speaker should remain more visible than an inactive character."
	)

	var legacy_shot: Dictionary = catalog.cinematic_shot("TEST_CINEMATIC", "opening")
	compositor.present_shot(legacy_shot)
	_expect(compositor.get_layer_count() == 0, "A legacy full-frame shot must remain a valid zero-layer fallback.")
	_expect(not compositor.get_resolved_background_path().is_empty(), "Legacy fallback must keep its full-frame art.")
	compositor.free()


func _test_cue_scoped_layers() -> void:
	var catalog := VisualCatalog.new()
	var compositor := ShotCompositor.new() as VNShotCompositor
	root.add_child(compositor)
	var cinematic_shot: Dictionary = catalog.cinematic_shot("CIN-CH01-S09-DEPARTURE", "opening")
	var cue_backgrounds: Variant = cinematic_shot.get("cue_backgrounds", {})
	_expect(cue_backgrounds is Dictionary, "Catalog normalization must preserve S09's cue-background dictionary.")
	var postlock_path := "res://assets/art/ch01-v5/CH01_ENV_NORTH_GATE_POSTLOCK_CLEAN_v001.png"
	var postlock_cues: Array[String] = ["S09-SIDE-GATE", "S09-LEDGER", "S09-ROGUE-WAGON"]
	for cue_id: String in postlock_cues:
		var cue_entry: Variant = (cue_backgrounds as Dictionary).get(cue_id, {}) if cue_backgrounds is Dictionary else {}
		_expect(cue_entry is Dictionary, "%s cue background must retain its asset-entry shape." % cue_id)
		if cue_entry is Dictionary:
			_expect(str((cue_entry as Dictionary).get("asset", "")) == postlock_path, "%s must target the clean post-lock gate." % cue_id)

	compositor.present_shot(cinematic_shot)
	var base_background := compositor.get_resolved_background_path()
	_expect(base_background == "res://assets/art/ch01-v5/CH01_ENV_NORTH_GATE_PRELOCK_CLEAN_v001.png", "S09 cinematic must begin on its clean pre-lock background.")
	_expect(compositor.get_layer_count() == 7, "S09 cinematic must keep all seven base and cue-scoped layers loaded.")
	_expect_visible_layers(compositor, ["sealed_wagons", "lee_yeon", "sword_coffin"], "S09 pre-lock")
	compositor.apply_cue("S09-SIDE-GATE")
	_expect(compositor.get_resolved_background_path() == postlock_path, "S09-SIDE-GATE must switch to the clean post-lock background.")
	_expect_visible_layers(compositor, ["sealed_wagons", "lee_yeon", "sidegate_refugees"], "S09 side gate")
	compositor.apply_cue("S09-LEDGER")
	_expect(compositor.get_resolved_background_path() == postlock_path, "S09-LEDGER must switch to the clean post-lock background.")
	_expect_visible_layers(compositor, ["sealed_wagons", "lee_yeon", "gatekeeper"], "S09 ledger")
	compositor.apply_cue("S09-ROGUE-WAGON")
	_expect(compositor.get_resolved_background_path() == postlock_path, "S09-ROGUE-WAGON must switch to the clean post-lock background.")
	_expect_visible_layers(compositor, ["eleven_wagons", "lee_yeon", "rogue_wagon"], "S09 rogue wagon")
	compositor.apply_cue("S09-UNMAPPED")
	_expect(compositor.get_resolved_background_path() == base_background, "An unmapped cue must restore the shot's base background.")
	_expect_visible_layers(compositor, ["sealed_wagons", "lee_yeon", "sword_coffin"], "S09 unmapped restore")
	compositor.apply_cue("")
	_expect(compositor.get_resolved_background_path() == base_background, "The empty/base cue must retain the shot's pre-lock background.")
	_expect_visible_layers(compositor, ["sealed_wagons", "lee_yeon", "sword_coffin"], "S09 base restore")

	var shot: Dictionary = catalog.scene_shot("S09")
	compositor.present_shot(shot)
	_expect(compositor.get_layer_count() == 6, "Cue-scoped S09 layers must stay loaded instead of being dropped.")
	_expect(compositor.get_current_cue_id().is_empty(), "A newly presented shot must begin at its base cue.")
	_expect(compositor.is_layer_visible("gatekeeper"), "Base S09 must show the gatekeeper.")
	_expect(compositor.is_layer_visible("sword_coffin"), "Base S09 must show the sword coffin.")
	_expect(not compositor.is_layer_visible("sidegate_refugees"), "Side-gate refugees must remain hidden before their cue.")
	_expect(not compositor.is_layer_visible("rogue_wagon"), "The rogue wagon must remain hidden before its cue.")

	compositor.apply_cue("S09-SIDE-GATE")
	_expect(compositor.get_current_cue_id() == "S09-SIDE-GATE", "Compositor must retain the active camera cue.")
	_expect(compositor.is_layer_visible("sidegate_refugees"), "Side-gate cue must reveal its refugee plate.")
	_expect(not compositor.is_layer_visible("rogue_wagon"), "Side-gate cue must not reveal the rogue wagon.")
	_expect(not compositor.is_layer_visible("gatekeeper"), "Side-gate cue must hide the gatekeeper.")
	_expect(not compositor.is_layer_visible("sword_coffin"), "Side-gate cue must hide the coffin plate.")

	compositor.apply_cue("S09-ROGUE-WAGON")
	_expect(not compositor.is_layer_visible("sidegate_refugees"), "Leaving the side-gate cue must hide its refugees again.")
	_expect(compositor.is_layer_visible("rogue_wagon"), "Rogue-wagon cue must reveal only its wagon plate.")
	_expect(not compositor.is_layer_visible("gatekeeper"), "Rogue-wagon cue must preserve authored hide rules.")
	_expect(not compositor.is_layer_visible("sword_coffin"), "Rogue-wagon cue must preserve authored coffin hide rules.")

	compositor.apply_cue("S09-RETURN")
	_expect(compositor.is_layer_visible("gatekeeper"), "A non-scoped cue must restore ordinary base layers.")
	_expect(compositor.is_layer_visible("sword_coffin"), "A non-scoped cue must restore the coffin plate.")
	_expect(not compositor.is_layer_visible("sidegate_refugees"), "A non-scoped cue must hide cue-only refugees.")
	_expect(not compositor.is_layer_visible("rogue_wagon"), "A non-scoped cue must hide the cue-only wagon.")
	compositor.free()


func _expect_visible_layers(compositor: VNShotCompositor, expected_ids: Array, label: String) -> void:
	var actual: Array[String] = []
	for layer_id: String in compositor.get_layer_ids():
		if compositor.is_layer_visible(layer_id):
			actual.append(layer_id)
	actual.sort()
	var expected: Array = expected_ids.duplicate()
	expected.sort()
	_expect(actual == expected, "%s must show exactly %s; got %s." % [label, expected, actual])


func _max_simultaneous_layers(layer_values: Variant) -> int:
	if not layer_values is Array:
		return 0
	var cue_ids: Array[String] = [""]
	for layer_variant: Variant in layer_values:
		if not layer_variant is Dictionary:
			continue
		var layer: Dictionary = layer_variant
		for cue_field: String in ["show_on_shots", "hide_on_shots"]:
			var cue_values: Variant = layer.get(cue_field, [])
			if not cue_values is Array:
				continue
			for cue_value: Variant in cue_values:
				var cue_id := str(cue_value)
				if not cue_id.is_empty() and cue_id not in cue_ids:
					cue_ids.append(cue_id)
	var maximum := 0
	for cue_id: String in cue_ids:
		var visible_count := 0
		for layer_variant: Variant in layer_values:
			if not layer_variant is Dictionary:
				continue
			var layer: Dictionary = layer_variant
			var show_values: Variant = layer.get("show_on_shots", [])
			var hide_values: Variant = layer.get("hide_on_shots", [])
			var show_on: Array = show_values if show_values is Array else []
			var hide_on: Array = hide_values if hide_values is Array else []
			if (show_on.is_empty() or cue_id in show_on) and cue_id not in hide_on:
				visible_count += 1
		maximum = maxi(maximum, visible_count)
	return maximum


func _test_legacy_manifest_fallback() -> void:
	var catalog := VisualCatalog.new(LEGACY_FIXTURE)
	_expect(catalog.manifest_schema_version() == 1, "Catalog must keep accepting the V4 manifest schema.")
	var shot: Dictionary = catalog.scene_shot("LEGACY")
	_expect(not str(shot.get("resolved_background", "")).is_empty(), "V4 scene art must normalize into a valid shot background.")
	_expect((shot.get("layers", []) as Array).is_empty(), "V4 scene art must normalize as a zero-layer fallback.")
	_expect(str(shot.get("fallback_mode", "")) == "full_frame", "V4 scene art must retain full-frame fallback mode.")


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
