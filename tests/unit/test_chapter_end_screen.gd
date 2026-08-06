extends SceneTree

const ChapterEndScene := preload("res://scenes/ui/chapter_end_screen.tscn")

var _failures: Array[String] = []


func _init() -> void:
	_run.call_deferred()


func _run() -> void:
	await process_frame
	var screen: Control = ChapterEndScene.instantiate()
	root.add_child(screen)
	await process_frame
	for route in ["TRACK", "PROTECT", "LOCKDOWN"]:
		screen.show_completion({
			"choices": {"CH01-C06-PRIORITY": route},
			"flags": {"swords_recalled": 9},
		})
		var text: String = screen.get_display_text()
		_assert(route.to_lower() not in text.to_lower(), "Route result should use story language, not internal route IDs.")
		_assert("검 회수 9 / 9" in text, "Every ending should show full nine-sword recall.")
		for forbidden in ["랭크", "경험치", "명성", "성공 등급"]:
			_assert(forbidden not in text, "Chapter result should omit score language: %s" % forbidden)
	screen.queue_free()
	await process_frame
	_finish()


func _assert(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("CHAPTER_END_SCREEN_TEST_PASS")
		quit(0)
		return
	for failure in _failures:
		push_error("[chapter-end-screen-test] %s" % failure)
	quit(1)
