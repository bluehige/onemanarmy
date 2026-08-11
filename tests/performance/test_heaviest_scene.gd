extends SceneTree

const PresenterScene := preload("res://scenes/ui/cinematic_presenter.tscn")
const WARMUP_FRAMES := 30
const SAMPLE_FRAMES := 180
const CAPTURE_ARGUMENT_PREFIX := "--capture="
const OPENING_CAPTURE_ARGUMENT_PREFIX := "--capture-opening="
const CONTROLS_CAPTURE_ARGUMENT_PREFIX := "--capture-controls="
const S09_SIDE_CAPTURE_ARGUMENT_PREFIX := "--capture-s09-side="
const S09_LEDGER_CAPTURE_ARGUMENT_PREFIX := "--capture-s09-ledger="
const S09_ROGUE_CAPTURE_ARGUMENT_PREFIX := "--capture-s09-rogue="

var _failures: Array[String] = []


func _init() -> void:
	_run.call_deferred()


func _run() -> void:
	var capture_path := _capture_path_from_arguments(CAPTURE_ARGUMENT_PREFIX)
	var opening_capture_path := _capture_path_from_arguments(OPENING_CAPTURE_ARGUMENT_PREFIX)
	var controls_capture_path := _capture_path_from_arguments(CONTROLS_CAPTURE_ARGUMENT_PREFIX)
	var s09_side_capture_path := _capture_path_from_arguments(S09_SIDE_CAPTURE_ARGUMENT_PREFIX)
	var s09_ledger_capture_path := _capture_path_from_arguments(S09_LEDGER_CAPTURE_ARGUMENT_PREFIX)
	var s09_rogue_capture_path := _capture_path_from_arguments(S09_ROGUE_CAPTURE_ARGUMENT_PREFIX)
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
		"settings": {
			"motion_reduction": false,
			"flash_reduction": false,
			"blade_trail_intensity": 1.0,
		},
		"cinematic": {"id": "PERF-FULL-108", "sword_count": 108},
	}, "full")
	if not opening_capture_path.is_empty():
		await create_timer(0.25).timeout
		_assert(not presenter.is_control_rail_visible(), "Opening evidence must keep the P2 control rail hidden.")
		await _save_evidence_capture(viewport, opening_capture_path, presenter, "opening_art_first")
	presenter.apply_animation_cue({
		"phase": "curved_flight",
		"path_variant": "capture",
		"visible_blades": 108,
		# Keep the measured window inside curved flight while letting the evidence
		# frame reach a readable, spatially separated formation instead of the
		# deliberately compact launch pose.
		"duration_sec": 6.0,
	})
	presenter.apply_vfx_cue({"id": "FX_INTERCEPT", "squad_index": 0})

	_assert(presenter.get_sword_count() == 108, "Heaviest fixture must contain exactly 108 swords.")
	_assert(presenter.get_visible_sword_count() == 108, "Performance sampling must render all 108 swords visibly.")
	_assert(presenter.get_squad_count() == 12, "Heaviest fixture must contain exactly 12 squads.")
	_assert(presenter.get_duplicate_slot_count() == 0, "Heaviest fixture must have zero duplicate slots.")
	_assert(presenter.get_body_batch_count() == 1, "Heaviest fixture must submit sword bodies as one batch.")
	_assert(presenter.get_batched_instance_count() == 108, "The body batch must contain 108 instances.")
	_assert(presenter.get_trail_pool_size() == 12, "Heaviest fixture must use the twelve-trail pool.")
	_assert(presenter.get_active_trail_count() == 12, "Performance sampling must keep all twelve trails active.")
	_assert(presenter.get_active_local_effect_count() > 0, "Performance sampling must begin with local VFX active.")
	_assert(
		presenter.get_art_vfx_draw_submission_estimate() <= 24,
		"Heaviest authored art/VFX must stay within 24 submissions."
	)

	for _frame in WARMUP_FRAMES:
		await process_frame
	var start_usec := Time.get_ticks_usec()
	var maximum_frame_msec := 0.0
	var maximum_draw_calls := 0
	var peak_active_local_effect_count := 0
	var sample_frames_with_local_effect := 0
	var frame_samples: Array[float] = []
	var previous_usec := start_usec
	for frame_index in SAMPLE_FRAMES:
		if frame_index % 45 == 0:
			presenter.apply_vfx_cue({"id": "FX_INTERCEPT", "squad_index": frame_index / 45})
		await process_frame
		var now_usec := Time.get_ticks_usec()
		var frame_msec := float(now_usec - previous_usec) / 1000.0
		frame_samples.append(frame_msec)
		maximum_frame_msec = maxf(maximum_frame_msec, frame_msec)
		maximum_draw_calls = maxi(
			maximum_draw_calls,
			int(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME))
		)
		var active_local_effects: int = presenter.get_active_local_effect_count()
		peak_active_local_effect_count = maxi(peak_active_local_effect_count, active_local_effects)
		if active_local_effects > 0:
			sample_frames_with_local_effect += 1
		previous_usec = now_usec
	var elapsed_usec := Time.get_ticks_usec() - start_usec
	var average_frame_msec := float(elapsed_usec) / 1000.0 / float(SAMPLE_FRAMES)
	frame_samples.sort()
	var p95_index := clampi(int(ceil(float(frame_samples.size()) * 0.95)) - 1, 0, frame_samples.size() - 1)
	var p95_frame_msec := frame_samples[p95_index]
	var measured_fps := 1000.0 / maxf(average_frame_msec, 0.0001)
	var display_server := DisplayServer.get_name()
	_assert(
		peak_active_local_effect_count > 0 and sample_frames_with_local_effect > 0,
		"Performance sampling must include rendered local VFX frames."
	)

	# Refresh one pooled impact after timing so the evidence capture and final snapshot
	# describe the same visible-108 + trails + local-VFX state without skewing frame samples.
	if not capture_path.is_empty() and presenter.is_control_rail_visible():
		await create_timer(presenter.get_control_rail_hide_delay_sec() + 0.25).timeout
	presenter.apply_vfx_cue({"id": "FX_INTERCEPT", "squad_index": 0})
	await process_frame
	_assert(
		presenter.get_active_local_effect_count() > 0,
		"The post-sample evidence frame must retain a visible local impact."
	)
	if not capture_path.is_empty():
		await _save_evidence_capture(viewport, capture_path, presenter, "visible_108")
	if not controls_capture_path.is_empty():
		var pointer_activity := InputEventMouseMotion.new()
		pointer_activity.position = Vector2(1800, 980)
		presenter.call("_input", pointer_activity)
		await process_frame
		_assert(presenter.is_control_rail_visible(), "Input-activity evidence must reveal the cinematic rail.")
		await _save_evidence_capture(viewport, controls_capture_path, presenter, "input_revealed_controls")

	var metrics := {
		"godot_version": Engine.get_version_info().get("string", "unknown"),
		"renderer": RenderingServer.get_current_rendering_method(),
		"display_server": display_server,
		"viewport_size": "1920x1080",
		"sample_frames": SAMPLE_FRAMES,
		"frame_time_source": "process_frame_wall_clock",
		"gpu_frame_time_collected": false,
		"average_frame_msec": snappedf(average_frame_msec, 0.001),
		"p95_frame_msec": snappedf(p95_frame_msec, 0.001),
		"maximum_frame_msec": snappedf(maximum_frame_msec, 0.001),
		"maximum_total_draw_calls": maximum_draw_calls,
		"draw_call_monitor_available": display_server != "headless",
		"measured_unthrottled_fps": snappedf(measured_fps, 0.1),
		"node_count": int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT)),
		"orphan_node_count": int(Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT)),
		"static_memory_bytes": int(Performance.get_monitor(Performance.MEMORY_STATIC)),
		"sword_count": presenter.get_sword_count(),
		"visible_sword_count": presenter.get_visible_sword_count(),
		"squad_count": presenter.get_squad_count(),
		"duplicate_slot_count": presenter.get_duplicate_slot_count(),
		"body_batch_count": presenter.get_body_batch_count(),
		"batched_instance_count": presenter.get_batched_instance_count(),
		"trail_pool_size": presenter.get_trail_pool_size(),
		"active_trail_count": presenter.get_active_trail_count(),
		"active_local_effect_count": presenter.get_active_local_effect_count(),
		"peak_active_local_effect_count": peak_active_local_effect_count,
		"sample_frames_with_local_effect": sample_frames_with_local_effect,
		"motion_phase": presenter.get_motion_phase(),
		"art_vfx_draw_submission_estimate": presenter.get_art_vfx_draw_submission_estimate(),
	}
	print("PERFORMANCE_SAMPLE %s" % JSON.stringify(metrics))
	if not s09_side_capture_path.is_empty() or not s09_ledger_capture_path.is_empty() or not s09_rogue_capture_path.is_empty():
		await _capture_s09_aftermath_states(
			viewport,
			presenter,
			s09_side_capture_path,
			s09_ledger_capture_path,
			s09_rogue_capture_path
		)
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


func _capture_path_from_arguments(prefix: String) -> String:
	for argument in OS.get_cmdline_user_args():
		if not argument.begins_with(prefix):
			continue
		var requested_path := argument.trim_prefix(prefix).strip_edges()
		if requested_path.is_empty():
			return ""
		if requested_path.begins_with("res://") or requested_path.begins_with("user://"):
			return requested_path
		return "res://%s" % requested_path.trim_prefix("/")
	return ""


func _save_evidence_capture(
	viewport: SubViewport,
	capture_path: String,
	presenter: Control,
	capture_kind: String
) -> void:
	RenderingServer.force_draw(false)
	await process_frame
	var image := viewport.get_texture().get_image()
	if image == null or image.is_empty():
		_assert(false, "Cinematic evidence capture must produce a non-empty image.")
		return
	_assert(
		image.get_size() == viewport.size,
		"Cinematic evidence capture must retain the 1920x1080 logical frame."
	)
	var absolute_path := ProjectSettings.globalize_path(capture_path)
	var directory_error := DirAccess.make_dir_recursive_absolute(absolute_path.get_base_dir())
	if directory_error != OK:
		_assert(false, "Could not create the evidence capture directory (error %d)." % directory_error)
		return
	var save_error := image.save_png(absolute_path)
	if save_error != OK:
		_assert(false, "Could not save cinematic evidence capture (error %d)." % save_error)
		return
	print(
		"PERFORMANCE_CAPTURE_SAVED %s kind=%s renderer=%s display=%s swords=%d trails=%d local_vfx=%d"
		% [
			absolute_path,
			capture_kind,
			RenderingServer.get_current_rendering_method(),
			DisplayServer.get_name(),
			presenter.get_visible_sword_count(),
			presenter.get_active_trail_count(),
			presenter.get_active_local_effect_count(),
		]
	)


func _capture_s09_aftermath_states(
	viewport: SubViewport,
	presenter: Control,
	side_capture_path: String,
	ledger_capture_path: String,
	rogue_capture_path: String
) -> void:
	presenter.present({
		"scene_id": "S09",
		"purpose": "North-gate lock aftermath continuity fixture.",
		"settings": {
			"motion_reduction": false,
			"flash_reduction": false,
			"blade_trail_intensity": 1.0,
		},
		"cinematic": {
			"id": "CIN-CH01-S09-DEPARTURE",
			"source_scene": "S09",
			"sword_count": 108,
		},
	}, "full")
	presenter.apply_animation_cue({
		"phase": "aftermath",
		"path_variant": "north_gate_lock",
		"visible_blades": 108,
		"duration_sec": 0.0,
	})
	presenter.apply_camera_cue({"shot_id": "S09-GATE-LOCK", "visible_blades": 108})
	await create_timer(2.8).timeout
	_assert(not presenter.is_control_rail_visible(), "S09 evidence must retain the art-first hidden rail.")
	presenter.apply_camera_cue({
		"shot_id": "S09-NORTH-GATE-FINAL",
		"visible_blades": 108,
		"show_final_art": true,
	})
	await create_timer(0.36).timeout
	presenter.apply_camera_cue({
		"shot_id": "S09-SIDE-GATE",
		"visible_blades": 108,
		"return_to_layers": true,
	})
	await create_timer(0.40).timeout
	if not side_capture_path.is_empty():
		await _save_evidence_capture(viewport, side_capture_path, presenter, "s09_side_gate")
	presenter.apply_camera_cue({"shot_id": "S09-LEDGER", "visible_blades": 108})
	await create_timer(0.40).timeout
	if not ledger_capture_path.is_empty():
		await _save_evidence_capture(viewport, ledger_capture_path, presenter, "s09_ledger")
	presenter.apply_camera_cue({"shot_id": "S09-ROGUE-WAGON", "visible_blades": 108})
	await create_timer(0.40).timeout
	if not rogue_capture_path.is_empty():
		await _save_evidence_capture(viewport, rogue_capture_path, presenter, "s09_rogue_wagon")
