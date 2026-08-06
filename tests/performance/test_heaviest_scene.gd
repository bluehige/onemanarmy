extends SceneTree

const PresenterScene := preload("res://scenes/ui/cinematic_presenter.tscn")
const WARMUP_FRAMES := 30
const SAMPLE_FRAMES := 180

var _failures: Array[String] = []


func _init() -> void:
	_run.call_deferred()


func _run() -> void:
	await process_frame
	var viewport := SubViewport.new()
	viewport.name = "PerformanceViewport1920x1080"
	viewport.size = Vector2i(1920, 1080)
	viewport.disable_3d = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	var presenter: Control = PresenterScene.instantiate()
	viewport.add_child(presenter)
	await process_frame
	presenter.present({
		"scene_id": "S00",
		"purpose": "Heaviest authored CH01 formation fixture.",
		"settings": {"motion_reduction": true},
		"cinematic": {"id": "PERF-FULL-108", "sword_count": 108},
	}, "full")

	_assert(presenter.get_sword_count() == 108, "Heaviest fixture must contain exactly 108 swords.")
	_assert(presenter.get_squad_count() == 12, "Heaviest fixture must contain exactly 12 squads.")
	_assert(presenter.get_duplicate_slot_count() == 0, "Heaviest fixture must have zero duplicate slots.")

	for _frame in WARMUP_FRAMES:
		await process_frame
	var start_usec := Time.get_ticks_usec()
	var maximum_frame_msec := 0.0
	var previous_usec := start_usec
	for _frame in SAMPLE_FRAMES:
		await process_frame
		var now_usec := Time.get_ticks_usec()
		maximum_frame_msec = maxf(maximum_frame_msec, float(now_usec - previous_usec) / 1000.0)
		previous_usec = now_usec
	var elapsed_usec := Time.get_ticks_usec() - start_usec
	var average_frame_msec := float(elapsed_usec) / 1000.0 / float(SAMPLE_FRAMES)
	var measured_fps := 1000.0 / maxf(average_frame_msec, 0.0001)

	var metrics := {
		"godot_version": Engine.get_version_info().get("string", "unknown"),
		"renderer": RenderingServer.get_current_rendering_method(),
		"viewport_size": "1920x1080",
		"sample_frames": SAMPLE_FRAMES,
		"average_frame_msec": snappedf(average_frame_msec, 0.001),
		"maximum_frame_msec": snappedf(maximum_frame_msec, 0.001),
		"measured_unthrottled_fps": snappedf(measured_fps, 0.1),
		"node_count": int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT)),
		"orphan_node_count": int(Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT)),
		"static_memory_bytes": int(Performance.get_monitor(Performance.MEMORY_STATIC)),
		"sword_count": presenter.get_sword_count(),
		"squad_count": presenter.get_squad_count(),
		"duplicate_slot_count": presenter.get_duplicate_slot_count(),
	}
	print("PERFORMANCE_SAMPLE %s" % JSON.stringify(metrics))
	presenter.dismiss()
	presenter.queue_free()
	viewport.queue_free()
	await process_frame

	if _failures.is_empty():
		print("HEAVIEST_SCENE_PERFORMANCE_TEST_PASS")
		quit(0)
		return
	for failure in _failures:
		push_error("[performance-test] %s" % failure)
	quit(1)


func _assert(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
