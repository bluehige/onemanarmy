extends SceneTree

const VisualCatalog := preload("res://scripts/data/ch01_visual_catalog.gd")

var _failures: Array[String] = []


func _init() -> void:
	_run.call_deferred()


func _run() -> void:
	var catalog := VisualCatalog.new()
	_expect(not catalog.title_art().is_empty(), "Title art must resolve to a runtime asset.")
	var unique_backgrounds := {}
	for scene_id in ["S00", "S01", "S02", "S03", "S04", "S05"]:
		var visual: Dictionary = catalog.scene_visual(scene_id)
		var background := str(visual.get("resolved_background", ""))
		_expect(not background.is_empty(), "%s must resolve a scene background." % scene_id)
		_expect(
			str(visual.get("background", "")).begins_with("res://assets/art/ch01-redesign-v2/"),
			"%s must target the approved redesign art pack." % scene_id
		)
		unique_backgrounds[background] = true
	_expect(unique_backgrounds.size() >= 5, "S00-S05 must not collapse back to one repeated background.")

	for cinematic_id in ["CIN-CH01-S00-CAPTURE", "CIN-CH01-S00-OPEN-PATH", "CIN-CH01-S05-COMMON"]:
		var visual: Dictionary = catalog.cinematic_visual(cinematic_id)
		_expect(not str(visual.get("resolved_opening_background", "")).is_empty(), "%s needs opening art." % cinematic_id)
		_expect(not str(visual.get("resolved_final_background", "")).is_empty(), "%s needs final art." % cinematic_id)
		_expect(not str(visual.get("formation_profile", "")).is_empty(), "%s needs an authored formation profile." % cinematic_id)

	if _failures.is_empty():
		print("CH01_VISUAL_CATALOG_TEST_PASS")
		quit(0)
		return
	for failure in _failures:
		push_error("[ch01-visual-catalog-test] %s" % failure)
	quit(1)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
