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

	presenter.present(_payload("S00", 108, {"motion_reduction": false}), "full")
	_assert(not presenter.is_control_rail_visible(), "Cinematic playback must open on art without persistent controls.")
	var target_size: Vector2 = presenter.get_control_target_minimum_size()
	var scale_to_1280 := 1280.0 / 1920.0
	var compact_scale := minf(844.0 / 1280.0, 390.0 / 720.0)
	_assert(
		target_size.x * scale_to_1280 >= 44.0 and target_size.y * scale_to_1280 >= 44.0,
		"Cinematic controls must retain a 44px physical target at 1280x720."
	)
	_assert(
		target_size.x * compact_scale >= 44.0 and target_size.y * compact_scale >= 44.0,
		"Cinematic controls must retain a 44px physical target at 844x390 compact landscape."
	)
	_assert(
		is_equal_approx(presenter.get_control_rail_hide_delay_sec(), 2.5),
		"Cinematic controls must use the approved 2.5 second inactivity delay."
	)
	var pointer_activity := InputEventMouseMotion.new()
	pointer_activity.position = Vector2(100, 100)
	presenter.call("_input", pointer_activity)
	_assert(presenter.is_control_rail_visible(), "Pointer activity must reveal cinematic controls.")
	await create_timer(2.8).timeout
	_assert(not presenter.is_control_rail_visible(), "Playing cinematic controls must auto-hide after inactivity.")
	_assert(
		presenter.get_intro_caption_opacity() <= 0.01,
		"Motion reduction must end the intro caption without leaving permanent chrome."
	)
	var navigation_activity := InputEventAction.new()
	navigation_activity.action = &"ui_focus_next"
	navigation_activity.pressed = true
	presenter.call("_input", navigation_activity)
	await process_frame
	_assert(presenter.is_control_rail_visible(), "Keyboard or gamepad navigation must reveal cinematic controls.")
	_assert(presenter.is_control_rail_focused(), "Navigation reveal must preserve the keyboard focus path.")
	presenter.set_paused(true)
	presenter.call("_on_control_rail_hide_timeout")
	_assert(presenter.is_control_rail_visible(), "Paused cinematic controls must remain visible.")
	presenter.apply_animation_cue({"phase": "curved_flight", "duration_sec": 8.0})
	_assert(not presenter.is_formation_motion_animating(), "Paused cinematic formation must hold motion.")
	presenter.set_mode("summary")
	_assert(not presenter.is_paused(), "Summary mode must clear presenter pause state.")
	_assert(
		presenter.is_formation_motion_animating(),
		"Paused-to-summary mode transition must resume formation motion."
	)
	_assert(
		presenter.get_opening_shot_id() == "SHOT-CH01-S00-DIALOGUE",
		"Cinematic fallback art must consume the same normalized shot source as StoryScreen."
	)
	_assert(
		presenter.get_final_shot_id() == "SHOT-CH01-S00-DIALOGUE-FINAL",
		"A legacy cinematic without a catalog entry must receive a deterministic final shot."
	)
	_assert(
		presenter.get_formation_overlay_opacity() > 0.0,
		"Procedural formation traces should remain available during the authored reveal."
	)
	presenter.show_final_state()
	_assert(presenter.visible, "Presenter should be visible during a cinematic.")
	_assert(presenter.get_sword_count() == 108, "S00 should visibly instantiate exactly 108 swords.")
	_assert(presenter.get_squad_count() == 12, "S00 should visibly instantiate exactly 12 squads.")
	_assert(presenter.get_body_batch_count() == 1, "S00 must render 108 sword bodies in one batch.")
	_assert(presenter.get_batched_instance_count() == 108, "The visible body batch must own 108 instances.")
	_assert(presenter.get_trail_pool_size() == 12, "The cinematic must pool twelve squad trails.")
	_assert(presenter.get_duplicate_slot_count() == 0, "108-sword presentation should have no duplicate slots.")
	_assert(presenter.get_visible_sword_count() == 108, "Final S00 frame should reveal all 108 authored swords.")
	_assert(
		presenter.get_formation_overlay_opacity() <= 0.01,
		"Final S00 art should own the sword silhouettes without procedural duplicates."
	)
	_assert(not presenter.shows_qa_counter(), "Product cinematic UI must not expose QA counters.")
	_assert(presenter.get_ui_coverage_estimate() < 0.10, "Cinematic controls must occupy less than ten percent of the frame.")
	_assert("중복 슬롯" not in presenter.get_display_text(), "Duplicate-slot QA text must stay out of the product view.")

	presenter.present(_payload("S07A", 9), "summary")
	presenter.apply_camera_cue({"shot_id": "S05-LAMP"})
	_assert(presenter.get_visible_sword_count() == 0, "S05 lamp beat should precede sword reveal.")
	presenter.apply_camera_cue({"shot_id": "S05-INTERCEPT"})
	_assert(presenter.get_visible_sword_count() == 1, "S05 intercept beat should reveal one sword.")
	presenter.apply_camera_cue({"shot_id": "S05-PIN-STAIR"})
	_assert(presenter.get_visible_sword_count() == 3, "S05 pin beat should reveal three swords.")
	presenter.apply_camera_cue({"shot_id": "S05-CIVILIAN"})
	_assert(presenter.get_visible_sword_count() == 5, "S05 civilian beat should reveal five swords.")
	presenter.apply_camera_cue({"shot_id": "S05-CONTROL"})
	_assert(presenter.get_visible_sword_count() == 9, "S05 control beat should reveal all nine swords.")
	presenter.apply_camera_cue({"shot_id": "A01", "formation_animation_owned": true})
	_assert(
		presenter.get_visible_sword_count() == 9,
		"Authored animation visibility must not be overwritten by a legacy camera heuristic."
	)
	presenter.show_final_state()
	_assert(presenter.get_sword_count() == 9, "Inn cinematic should visibly instantiate exactly 9 swords.")
	_assert(presenter.get_squad_count() == 1, "Inn cinematic should use one nine-sword squad.")
	_assert(presenter.get_visible_sword_count() == 9, "Final inn frame should reveal all nine authored swords.")
	_assert(
		presenter.get_formation_overlay_opacity() <= 0.01,
		"Final inn art should own its nine sword silhouettes without a second overlay."
	)
	_assert("요약" in presenter.get_display_text(), "Requested playback mode should be visible without QA copy.")
	for forbidden in ["랭크", "경험치", "명성", "콤보", "피해량"]:
		_assert(forbidden not in presenter.get_display_text(), "Cinematic UI should omit score/combat language: %s" % forbidden)

	presenter.present(_payload("S09", 108, {}, "CIN-CH01-S09-DEPARTURE"), "full")
	_assert(
		presenter.get_opening_shot_id() == "SHOT-CIN-S09-PRELOCK",
		"S09 must use its normalized opening cinematic shot."
	)
	_assert(
		presenter.get_final_shot_id() == "SHOT-CIN-S09-FINAL-LOCK",
		"S09 Hero CG must use its normalized final cinematic shot."
	)
	presenter.apply_camera_cue({"shot_id": "S09-GATE-LOCK", "visible_blades": 108})
	_assert(
		presenter.get_final_background_opacity() <= 0.01,
		"S09 must retain the pre-lock background through the execution shot."
	)
	presenter.apply_camera_cue({
		"shot_id": "S09-NORTH-GATE-FINAL",
		"visible_blades": 108,
		"show_final_art": true,
	})
	_assert(
		presenter.get_final_background_opacity() >= 0.99,
		"S09 completed-lock Hero CG must appear on the explicit final shot."
	)
	presenter.apply_camera_cue({
		"shot_id": "S09-SIDE-GATE",
		"visible_blades": 108,
		"return_to_layers": true,
	})
	_assert(
		presenter.get_last_camera_shot_id() == "S09-SIDE-GATE"
		and presenter.get_opening_compositor_cue_id() == "S09-SIDE-GATE",
		"Every camera cue must reach the presenter's shot-compositor bridge."
	)
	_assert(
		presenter.get_final_background_opacity() <= 0.01,
		"S09 Hero CG must end before the side-gate aftermath shot."
	)
	_assert(
		presenter.get_opening_background_opacity() >= 0.99,
		"S09 side-gate aftermath must restore the layered opening compositor."
	)
	_assert(
		presenter.get_formation_overlay_opacity() >= 0.80,
		"S09 side-gate aftermath must restore the authored locked formation."
	)

	presenter.present(_payload("S00", 108, {
		"motion_reduction": false,
		"flash_reduction": false,
		"blade_trail_intensity": 1.0,
	}), "full")
	presenter.apply_animation_cue({
		"phase": "curved_flight",
		"path_variant": "capture",
		"visible_blades": 108,
		"duration_sec": 0.0,
	})
	_assert(presenter.get_active_trail_count() == 12, "Full trail output must activate all twelve paths.")
	presenter.apply_vfx_cue({"id": "FX_INTERCEPT"})
	var normal_flash_peak: float = presenter.get_last_flash_peak_alpha()
	_assert(presenter.get_active_local_effect_count() > 0, "VFX cues must produce a spatial local impact.")
	_assert(
		presenter.get_art_vfx_draw_submission_estimate() <= 24,
		"Peak authored art/VFX submissions must stay inside the V5 budget."
	)

	presenter.present(_payload("S00", 108, {
		"motion_reduction": false,
		"flash_reduction": true,
		"blade_trail_intensity": 0.0,
	}), "full")
	presenter.apply_animation_cue({
		"phase": "curved_flight",
		"path_variant": "capture",
		"visible_blades": 108,
		"duration_sec": 0.0,
	})
	_assert(presenter.get_active_trail_count() == 0, "Trail intensity zero must change the rendered output.")
	presenter.apply_vfx_cue({"id": "FX_INTERCEPT"})
	_assert(
		presenter.get_last_flash_peak_alpha() < normal_flash_peak,
		"Flash reduction must lower the presenter's actual wash output."
	)

	presenter.dismiss()
	_assert(not presenter.visible, "Presenter should hide after completion.")
	_assert(presenter.get_sword_count() == 0, "Dismiss should release procedural blades.")
	presenter.queue_free()
	await process_frame
	_finish()


func _payload(
	scene_id: String,
	sword_count: int,
	setting_overrides: Dictionary = {},
	cinematic_id: String = ""
) -> Dictionary:
	var settings := {
		"motion_reduction": true,
		"flash_reduction": false,
		"blade_trail_intensity": 1.0,
	}
	settings.merge(setting_overrides, true)
	return {
		"scene_id": scene_id,
		"purpose": "선택한 우선순위가 검대의 역할을 바꾼다.",
		"settings": settings,
		"cinematic": {
			"id": cinematic_id if not cinematic_id.is_empty() else "TEST-%s" % scene_id,
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
