extends SceneTree

const PresenterScene := preload("res://scenes/ui/cinematic_presenter.tscn")

var _failures: Array[String] = []


func _init() -> void:
	_run.call_deferred()


func _run() -> void:
	await process_frame
	var presenter: Control = PresenterScene.instantiate()
	root.add_child(presenter)
	await process_frame

	presenter.present(_payload("S00", 108), "full")
	_assert(presenter.visible, "Presenter should be visible during a cinematic.")
	_assert(presenter.get_sword_count() == 108, "S00 should visibly instantiate exactly 108 swords.")
	_assert(presenter.get_squad_count() == 12, "S00 should visibly instantiate exactly 12 squads.")
	_assert(presenter.get_duplicate_slot_count() == 0, "108-sword presentation should have no duplicate slots.")
	_assert("12개 검대 × 9자루 = 108" in presenter.get_display_text(), "Count authority should be visible to the player.")

	presenter.present(_payload("S07A", 9), "summary")
	_assert(presenter.get_sword_count() == 9, "Inn cinematic should visibly instantiate exactly 9 swords.")
	_assert(presenter.get_squad_count() == 1, "Inn cinematic should use one nine-sword squad.")
	_assert("검 9 / 9" in presenter.get_display_text(), "Nine-sword count should be visible.")
	_assert("요약 연출" in presenter.get_display_text(), "Requested playback mode should be visible.")
	for forbidden in ["랭크", "경험치", "명성", "콤보", "피해량"]:
		_assert(forbidden not in presenter.get_display_text(), "Cinematic UI should omit score/combat language: %s" % forbidden)

	presenter.dismiss()
	_assert(not presenter.visible, "Presenter should hide after completion.")
	_assert(presenter.get_sword_count() == 0, "Dismiss should release procedural blades.")
	presenter.queue_free()
	await process_frame
	_finish()


func _payload(scene_id: String, sword_count: int) -> Dictionary:
	return {
		"scene_id": scene_id,
		"purpose": "선택한 우선순위가 검대의 역할을 바꾼다.",
		"settings": {"motion_reduction": true},
		"cinematic": {
			"id": "TEST-%s" % scene_id,
			"source_scene": scene_id,
			"sword_count": sword_count,
		},
	}


func _assert(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("CINEMATIC_PRESENTER_TEST_PASS")
		quit(0)
		return
	for failure in _failures:
		push_error("[cinematic-presenter-test] %s" % failure)
	quit(1)
