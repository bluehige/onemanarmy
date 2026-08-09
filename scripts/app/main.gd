class_name MainFlow
extends Node

signal flow_state_changed(state: String)
signal fatal_error_presented(payload: Dictionary)

const CHAPTER_ID := "CH-MVP-001"
const AUTOSAVE_SLOT_ID := "autosave"
const MANUAL_SLOT_ID := "manual_01"
const CINEMATIC_DURATION_SCALE := 1.0

const SPEAKER_NAMES := {
	"bokchil": "복칠",
	"cavalry_commander": "기병 지휘관",
	"child": "아이",
	"fugitive": "도주자",
	"gatekeeper": "문지기",
	"guardian": "보호자",
	"gwak_nosam": "곽노삼",
	"hongryeon": "홍련",
	"jo_muntak": "조문탁",
	"lee_yeon": "이연",
	"lee_yeon_inner": "이연",
	"merchant": "상인",
	"note": "쪽지",
	"other_swordsman": "다른 칼잡이",
	"refugee_man": "피난민 남자",
	"swordsman": "칼잡이",
}

@onready var _cinematic_director: CinematicDirector = $CinematicStage/CinematicDirector
@onready var _ui_layer: CanvasLayer = $UILayer
@onready var _title_screen: TitleScreen = $UILayer/TitleScreen
@onready var _story_screen: StoryScreen = $UILayer/StoryScreen
@onready var _interaction_director: InteractionDirector = $UILayer/InteractionDirector
@onready var _cinematic_presenter: CinematicPresenter = $UILayer/CinematicPresenter
@onready var _consequence_screen: ConsequenceScreen = $UILayer/ConsequenceScreen
@onready var _chapter_end_screen: ChapterEndScreen = $UILayer/ChapterEndScreen
@onready var _settings_screen: SettingsScreen = $UILayer/SettingsScreen
@onready var _runtime_audio: RuntimeAudioPlayer = $RuntimeAudioPlayer

var _app_state: Node
var _content_registry: Node
var _story_runtime: Node
var _save_service: Node
var _auto_timer: Timer
var _fatal_overlay: Control
var _fatal_message: Label
var _flow_state := "boot"
var _settings_return_state := "title"
var _pending_choice_id := ""
var _active_line_id := ""
var _active_line_was_seen := false
var _active_line_marked_seen := false
var _line_serial := 0
var _auto_enabled := false
var _skip_enabled := false
var _last_error: Dictionary = {}


func _ready() -> void:
	_app_state = get_node_or_null("/root/AppState")
	_content_registry = get_node_or_null("/root/ContentRegistry")
	_story_runtime = get_node_or_null("/root/StoryRuntime")
	_save_service = get_node_or_null("/root/SaveService")
	_build_fatal_overlay()
	_build_auto_timer()
	if not _services_available():
		_present_fatal_error({"code": "SERVICE_MISSING", "message": "필수 런타임 서비스를 찾지 못했습니다."})
		return
	_connect_signals()
	if not _load_global_state():
		return
	_apply_settings()
	return_to_title()


func _process(_delta: float) -> void:
	if _flow_state != "story" or _active_line_id.is_empty():
		return
	if not _story_screen.is_text_fully_visible():
		return
	if not _active_line_marked_seen:
		_active_line_marked_seen = true
		_mark_global_id("seen_text_ids", _active_line_id)
	if _auto_enabled and _auto_timer.is_stopped():
		_schedule_auto_advance()


func start_new_game() -> bool:
	if not _services_available():
		return false
	_clear_fatal_error()
	_reset_reading_modes()
	_app_state.call("reset_slot_state", AUTOSAVE_SLOT_ID)
	_prepare_story_view()
	var started := bool(_story_runtime.call("start_chapter", CHAPTER_ID))
	if not started and _last_error.is_empty():
		_present_fatal_error({"code": "CHAPTER_START_FAILED", "message": "제1장을 시작하지 못했습니다."})
	return started


func continue_game() -> bool:
	return _load_slot("load_autosave")


func load_game() -> bool:
	return _load_slot("load_manual_slot")


func save_game() -> bool:
	if _story_runtime == null:
		return false
	var snapshot: Dictionary = _story_runtime.call("snapshot")
	if str(snapshot.get("chapter_id", "")).is_empty():
		return false
	var document := RuntimeSaveAdapter.make_slot_document(snapshot, MANUAL_SLOT_ID)
	var result: Dictionary = _save_service.call("save_manual_slot", document)
	if not bool(result.get("ok", false)):
		_present_save_error("수동 저장", result)
		return false
	_persist_global_state()
	return true


func show_settings() -> void:
	_settings_return_state = _flow_state
	_settings_screen.present(_get_settings())
	_set_flow_state("settings")


func apply_settings(settings: Dictionary) -> void:
	_app_state.call("update_settings", settings)
	if not _persist_global_state():
		return
	_apply_settings()
	_settings_screen.hide()
	_restore_settings_return_state()


func return_to_title() -> void:
	_stop_automatic_progress()
	_clear_line_state()
	_interaction_director.hide()
	_cinematic_presenter.dismiss()
	_consequence_screen.hide()
	_chapter_end_screen.hide()
	_settings_screen.hide()
	_story_screen.hide()
	_runtime_audio.stop_all()
	_clear_fatal_error()
	_title_screen.show()
	_title_screen.configure(
		_has_saved_slot("has_autosave", AUTOSAVE_SLOT_ID),
		_has_saved_slot("has_manual_slot", MANUAL_SLOT_ID)
	)
	_set_flow_state("title")


func advance_story() -> void:
	if _flow_state == "story":
		_story_screen.request_advance()


func select_choice(option_id: String) -> bool:
	if _flow_state != "choice" or _pending_choice_id.is_empty():
		return false
	_on_choice_selected(option_id, option_id)
	return true


func complete_active_interaction() -> bool:
	if _flow_state != "interaction":
		return false
	_interaction_director.auto_complete()
	return true


func skip_active_cinematic() -> bool:
	if _flow_state != "cinematic" or not _cinematic_director.is_playing():
		return false
	_cinematic_director.skip_to_result()
	return true


func continue_consequence() -> bool:
	if _flow_state != "consequence":
		return false
	_on_consequence_continued()
	return true


func set_auto_mode(enabled: bool) -> void:
	_story_screen.set_auto_enabled(enabled)


func set_skip_mode(enabled: bool) -> void:
	_story_screen.set_skip_enabled(enabled)


func get_flow_state() -> String:
	return _flow_state


func get_runtime_snapshot() -> Dictionary:
	if _story_runtime == null:
		return {}
	return _story_runtime.call("snapshot")


func get_last_error() -> Dictionary:
	return _last_error.duplicate(true)


func get_active_line_id() -> String:
	return _active_line_id


func is_active_line_fully_visible() -> bool:
	return _story_screen.is_text_fully_visible()


func get_cinematic_mode() -> String:
	return str(_cinematic_director.get_current_mode())


func is_cinematic_paused() -> bool:
	return _cinematic_director.is_paused()


func get_presented_sword_count() -> int:
	return _cinematic_presenter.get_sword_count()


func get_presented_duplicate_slot_count() -> int:
	return _cinematic_presenter.get_duplicate_slot_count()


func _connect_signals() -> void:
	_title_screen.new_game_requested.connect(start_new_game)
	_title_screen.continue_requested.connect(continue_game)
	_title_screen.load_requested.connect(load_game)
	_title_screen.settings_requested.connect(show_settings)
	_story_screen.advance_requested.connect(_on_advance_requested)
	_story_screen.choice_selected.connect(_on_choice_selected)
	_story_screen.auto_toggled.connect(_on_auto_toggled)
	_story_screen.skip_toggled.connect(_on_skip_toggled)
	_story_screen.save_requested.connect(save_game)
	_story_screen.load_requested.connect(load_game)
	_story_screen.settings_requested.connect(show_settings)
	_interaction_director.completed.connect(_on_interaction_completed)
	_cinematic_presenter.pause_requested.connect(_on_cinematic_pause_requested)
	_cinematic_presenter.summary_requested.connect(_on_cinematic_summary_requested)
	_cinematic_presenter.skip_requested.connect(_on_cinematic_skip_requested)
	_cinematic_director.completed.connect(_on_cinematic_completed)
	_cinematic_director.camera_cue_requested.connect(_on_cinematic_camera_cue_requested)
	_cinematic_director.animation_cue_requested.connect(_on_cinematic_animation_cue_requested)
	_cinematic_director.audio_cue_requested.connect(_on_cinematic_audio_cue_requested)
	_cinematic_director.vfx_cue_requested.connect(_on_cinematic_vfx_cue_requested)
	_consequence_screen.continued.connect(_on_consequence_continued)
	_chapter_end_screen.replay_requested.connect(start_new_game)
	_chapter_end_screen.title_requested.connect(return_to_title)
	_settings_screen.applied.connect(apply_settings)
	_settings_screen.closed.connect(_on_settings_closed)
	_story_runtime.connect("scene_changed", Callable(self, "_on_scene_changed"))
	_story_runtime.connect("line_requested", Callable(self, "_on_line_requested"))
	_story_runtime.connect("choice_requested", Callable(self, "_on_choice_requested"))
	_story_runtime.connect("interaction_requested", Callable(self, "_on_interaction_requested"))
	_story_runtime.connect("cinematic_requested", Callable(self, "_on_cinematic_requested"))
	_story_runtime.connect("consequence_requested", Callable(self, "_on_consequence_requested"))
	_story_runtime.connect("autosave_requested", Callable(self, "_on_autosave_requested"))
	_story_runtime.connect("chapter_ended", Callable(self, "_on_chapter_ended"))
	_story_runtime.connect("runtime_error", Callable(self, "_on_runtime_error"))


func _services_available() -> bool:
	return (
		_app_state != null
		and _content_registry != null
		and _story_runtime != null
		and _save_service != null
	)


func _has_saved_slot(method_name: String, slot_id: String) -> bool:
	if _save_service == null:
		return false
	if bool(_save_service.call(method_name)):
		return true
	var slot_path := str(_save_service.call("get_slot_path", slot_id))
	return not slot_path.is_empty() and FileAccess.file_exists("%s.bak" % slot_path)


func _load_global_state() -> bool:
	var global_path := str(_save_service.call("get_global_path"))
	if not FileAccess.file_exists(global_path) and not FileAccess.file_exists("%s.bak" % global_path):
		return true
	var result: Dictionary = _save_service.call("load_global")
	if not bool(result.get("ok", false)):
		_present_save_error("전역 기록 불러오기", result)
		return false
	_app_state.call("replace_global_state", result.get("data", {}))
	return true


func _load_slot(method_name: String) -> bool:
	_clear_fatal_error()
	var result: Dictionary = _save_service.call(method_name)
	if not bool(result.get("ok", false)):
		_present_save_error("저장 불러오기", result)
		return false
	var document: Dictionary = result.get("data", {})
	if not RuntimeSaveAdapter.has_restorable_snapshot(document):
		_present_fatal_error({"code": "SAVE_SNAPSHOT_MISSING", "message": "복원 가능한 장면 상태가 없습니다."})
		return false
	_app_state.call("replace_slot_state", document)
	_prepare_story_view()
	var snapshot := RuntimeSaveAdapter.extract_runtime_snapshot(document)
	var restored := bool(_story_runtime.call("restore", snapshot))
	if not restored:
		return false
	if bool(snapshot.get("ended", false)):
		_show_chapter_completion(snapshot)
	return true


func _prepare_story_view() -> void:
	_title_screen.hide()
	_settings_screen.hide()
	_chapter_end_screen.hide()
	_consequence_screen.hide()
	_cinematic_presenter.dismiss()
	_interaction_director.hide()
	_story_screen.show()
	_set_flow_state("story")


func _on_scene_changed(payload: Dictionary) -> void:
	var scene_id := str(payload.get("scene_id", ""))
	var scene: Dictionary = _content_registry.call("get_scene", scene_id)
	var title := str(_content_registry.call("get_ko_text", str(scene.get("title_text_id", "")), ""))
	_story_screen.show_scene(scene_id, title)
	_runtime_audio.transition_scene_ambience(StringName(scene_id), {"restart": false})
	if scene_id == "S00":
		_runtime_audio.play_cue(&"SFX_SWORD_COFFIN_WHEEL", {"volume_db": -5.0})
	var manifest: Dictionary = _content_registry.call("get_chapter_manifest", CHAPTER_ID)
	_story_screen.set_chapter_label(
		str(_content_registry.call("get_ko_text", str(manifest.get("chapter_title_text_id", "")), "第一章"))
	)


func _on_line_requested(payload: Dictionary) -> void:
	_prepare_story_view()
	_auto_timer.stop()
	_pending_choice_id = ""
	_line_serial += 1
	_active_line_id = str(payload.get("text_id", ""))
	_active_line_was_seen = _global_id_seen("seen_text_ids", _active_line_id)
	_active_line_marked_seen = _active_line_was_seen
	var display_payload := payload.duplicate(true)
	var text_id := str(display_payload.get("text_id", ""))
	if text_id == "CH01-S04-009":
		_runtime_audio.play_cue(&"SFX_PAPER")
	elif text_id in ["CH01-S05-001A", "CH01-S05-001B"]:
		_runtime_audio.play_cue(&"SFX_BOW_TENSION", {"volume_db": -4.0})
	var speaker_id := str(display_payload.get("speaker_id", ""))
	if not speaker_id.is_empty():
		display_payload["speaker_name"] = str(SPEAKER_NAMES.get(speaker_id, speaker_id))
	var instant := _skip_enabled and _active_line_was_seen
	_story_screen.show_line(display_payload, instant)
	if instant:
		var serial := _line_serial
		call_deferred("_advance_seen_line", serial)
	elif _auto_enabled and _story_screen.is_text_fully_visible():
		_schedule_auto_advance()


func _on_choice_requested(payload: Dictionary) -> void:
	_prepare_story_view()
	_clear_line_state()
	_pending_choice_id = str(payload.get("choice_id", ""))
	_story_screen.show_choices(payload)
	_set_flow_state("choice")


func _on_interaction_requested(payload: Dictionary) -> void:
	_stop_automatic_progress()
	_clear_line_state()
	_title_screen.hide()
	_story_screen.show()
	_story_screen.set_interaction_mode(true)
	_consequence_screen.hide()
	_chapter_end_screen.hide()
	_cinematic_presenter.dismiss()
	var contract: Dictionary = payload.get("contract", {}).duplicate(true)
	match str(contract.get("type", "")):
		"HOLD_INTENT", "WEIGHTED_CONFIRM":
			_runtime_audio.play_cue(&"SFX_IRON_CHAIN_GRIP")
		"CHAIN_PULL":
			_runtime_audio.play_cue(&"SFX_IRON_CHAIN_PULL")
		"BLADE_RECALL":
			_runtime_audio.play_cue(&"SFX_BLADE_RECALL")
	var flags: Dictionary = get_runtime_snapshot().get("flags", {})
	var route := str(flags.get("priority_choice", "")).to_upper()
	var localized_points: Array = []
	for point_variant in contract.get("points", []):
		if not point_variant is Dictionary:
			continue
		var point: Dictionary = point_variant.duplicate(true)
		var point_route := str(point.get("route", "")).to_upper()
		if not point_route.is_empty() and not route.is_empty() and point_route != route:
			continue
		var label_id := str(point.get("label_text_id", ""))
		if not label_id.is_empty():
			point["label"] = str(_content_registry.call("get_ko_text", label_id, label_id))
		localized_points.append(point)
	contract["points"] = localized_points
	var interaction_id := str(payload.get("interaction_id", ""))
	_interaction_director.start(
		contract,
		{
			"prompt": payload.get("prompt", ""),
			"settings": _interaction_settings(),
			"replay_seen": _global_id_seen("completed_interaction_ids", interaction_id),
			"route": str(flags.get("priority_choice", "")),
		}
	)
	_set_flow_state("interaction")


func _on_cinematic_requested(payload: Dictionary) -> void:
	_stop_automatic_progress()
	_clear_line_state()
	_story_screen.hide()
	_interaction_director.hide()
	_consequence_screen.hide()
	_chapter_end_screen.hide()
	var cinematic_id := str(payload.get("cinematic_id", ""))
	var mode := str(_get_settings().get("cinematic_mode", "full"))
	if mode not in ["full", "summary", "result"]:
		mode = "full"
	var present_payload := payload.duplicate(true)
	present_payload["settings"] = _get_settings()
	_cinematic_presenter.present(present_payload, mode)
	_set_flow_state("cinematic")
	var play_result := _cinematic_director.play_cinematic(
		payload.get("cinematic", {}),
		StringName(mode),
		not _global_id_seen("seen_cinematic_ids", cinematic_id),
		CINEMATIC_DURATION_SCALE
	)
	if not bool(play_result.get("ok", false)):
		_present_fatal_error(play_result)


func _on_consequence_requested(payload: Dictionary) -> void:
	_stop_automatic_progress()
	_clear_line_state()
	_story_screen.hide()
	_interaction_director.hide()
	_cinematic_presenter.dismiss()
	_chapter_end_screen.hide()
	var line_texts: Array[String] = []
	for line_variant in payload.get("lines", []):
		if line_variant is Dictionary:
			line_texts.append(str(line_variant.get("text", "")))
		else:
			line_texts.append(str(line_variant))
	var display_payload := payload.duplicate(true)
	display_payload["lines"] = line_texts
	display_payload["title"] = _consequence_title(str(payload.get("consequence_id", "")))
	display_payload["recall_text"] = "검 회수  9 / 9"
	_consequence_screen.show_result(display_payload)
	_set_flow_state("consequence")


func _on_autosave_requested(payload: Dictionary) -> void:
	var snapshot: Dictionary = payload.get("snapshot", {})
	var document := RuntimeSaveAdapter.make_slot_document(snapshot, AUTOSAVE_SLOT_ID)
	var result: Dictionary = _save_service.call("save_autosave", document)
	if not bool(result.get("ok", false)):
		_present_save_error("자동 저장", result)
		return
	_app_state.call("replace_slot_state", document)
	_persist_global_state()


func _on_chapter_ended(payload: Dictionary) -> void:
	_stop_automatic_progress()
	_clear_line_state()
	var snapshot := get_runtime_snapshot()
	var document := RuntimeSaveAdapter.make_slot_document(snapshot, AUTOSAVE_SLOT_ID)
	var save_result: Dictionary = _save_service.call("save_autosave", document)
	if not bool(save_result.get("ok", false)):
		_present_save_error("챕터 완료 저장", save_result)
		return
	_app_state.call("replace_slot_state", document)
	_persist_global_state()
	_show_chapter_completion(payload)


func _show_chapter_completion(payload: Dictionary) -> void:
	_story_screen.hide()
	_interaction_director.hide()
	_cinematic_presenter.dismiss()
	_consequence_screen.hide()
	_title_screen.hide()
	_chapter_end_screen.show_completion(payload)
	_set_flow_state("chapter_end")


func _on_advance_requested() -> void:
	if _flow_state != "story":
		return
	_stop_automatic_progress()
	_mark_current_line_seen_if_visible()
	_story_runtime.call("advance")


func _on_choice_selected(option_id: String, _value: Variant) -> void:
	if _flow_state != "choice" or _pending_choice_id.is_empty():
		return
	var choice_id := _pending_choice_id
	_pending_choice_id = ""
	_story_runtime.call("choose", choice_id, option_id)


func _on_interaction_completed(result: Dictionary) -> void:
	if _flow_state != "interaction":
		return
	var interaction_id := str(result.get("interaction_id", ""))
	_mark_global_id("completed_interaction_ids", interaction_id)
	_story_runtime.call("complete_interaction", interaction_id, result)


func _on_cinematic_completed(payload: Dictionary) -> void:
	if _flow_state != "cinematic":
		return
	var cinematic_id := str(payload.get("cinematic_id", ""))
	_mark_global_id("seen_cinematic_ids", cinematic_id)
	_cinematic_presenter.dismiss()
	_story_screen.show()
	var mode := "skip" if bool(payload.get("skipped", false)) else str(payload.get("mode", "full"))
	_story_runtime.call("complete_cinematic", cinematic_id, mode)


func _on_cinematic_camera_cue_requested(cue: Dictionary) -> void:
	if _flow_state == "cinematic":
		_cinematic_presenter.apply_camera_cue(cue)


func _on_cinematic_animation_cue_requested(cue: Dictionary) -> void:
	if _flow_state == "cinematic":
		_cinematic_presenter.apply_animation_cue(cue)


func _on_cinematic_audio_cue_requested(cue: Dictionary) -> void:
	if _flow_state != "cinematic":
		return
	var cue_id := StringName(str(cue.get("id", cue.get("cue_id", ""))))
	if cue_id.is_empty():
		return
	var options := {}
	if cue.has("volume_db"):
		options["volume_db"] = cue["volume_db"]
	if cue.has("pitch_scale"):
		options["pitch_scale"] = cue["pitch_scale"]
	_runtime_audio.play_cue(cue_id, options)


func _on_cinematic_vfx_cue_requested(cue: Dictionary) -> void:
	if _flow_state == "cinematic":
		_cinematic_presenter.apply_vfx_cue(cue)


func _on_consequence_continued() -> void:
	if _flow_state != "consequence":
		return
	var snapshot := get_runtime_snapshot()
	var consequence_id := str(snapshot.get("pending_step", {}).get("consequence_id", ""))
	_consequence_screen.hide()
	_story_screen.show()
	_story_runtime.call("complete_consequence", consequence_id)


func _on_runtime_error(payload: Dictionary) -> void:
	_last_error = payload.duplicate(true)
	if bool(payload.get("fatal", false)):
		_present_fatal_error(payload)


func _on_auto_toggled(enabled: bool) -> void:
	_auto_enabled = enabled
	_auto_timer.stop()
	if enabled and _flow_state == "story" and _story_screen.is_text_fully_visible():
		_schedule_auto_advance()


func _on_skip_toggled(enabled: bool) -> void:
	_skip_enabled = enabled
	_line_serial += 1
	if not enabled or _flow_state != "story" or not _active_line_was_seen:
		return
	if not _story_screen.is_text_fully_visible():
		_story_screen.finish_typing()
	var serial := _line_serial
	call_deferred("_advance_seen_line", serial)


func _on_cinematic_pause_requested() -> void:
	if _flow_state != "cinematic":
		return
	_cinematic_director.toggle_pause()
	_cinematic_presenter.set_paused(_cinematic_director.is_paused())


func _on_cinematic_summary_requested() -> void:
	if _flow_state == "cinematic" and _cinematic_director.switch_to_summary():
		_cinematic_presenter.set_mode("summary")


func _on_cinematic_skip_requested() -> void:
	if _flow_state == "cinematic":
		_cinematic_director.skip_to_result()


func _on_settings_closed() -> void:
	_restore_settings_return_state()


func _restore_settings_return_state() -> void:
	_set_flow_state(_settings_return_state)
	if _settings_return_state == "title":
		_title_screen.configure(
			_has_saved_slot("has_autosave", AUTOSAVE_SLOT_ID),
			_has_saved_slot("has_manual_slot", MANUAL_SLOT_ID)
		)


func _apply_settings() -> void:
	var settings := _get_settings()
	_story_screen.set_text_scale(float(settings.get("text_scale", 1.0)))
	_interaction_director.apply_accessibility(_interaction_settings())


func _interaction_settings() -> Dictionary:
	var settings := _get_settings()
	return {
		"hold_toggle": str(settings.get("hold_mode", "hold")) == "toggle",
		"interaction_auto_complete": bool(settings.get("interaction_auto_complete", false)),
	}


func _get_settings() -> Dictionary:
	var global_state := _get_global_state()
	var settings: Variant = global_state.get("settings", {})
	return settings.duplicate(true) if settings is Dictionary else {}


func _get_global_state() -> Dictionary:
	if _app_state == null:
		return {}
	var state: Variant = _app_state.get("global_state")
	return state.duplicate(true) if state is Dictionary else {}


func _global_id_seen(key: String, content_id: String) -> bool:
	if content_id.is_empty():
		return false
	match key:
		"seen_text_ids":
			return bool(_app_state.call("is_text_seen", content_id))
		"seen_cinematic_ids":
			return bool(_app_state.call("is_cinematic_seen", content_id))
		"completed_interaction_ids":
			return bool(_app_state.call("is_interaction_completed", content_id))
	return false


func _mark_global_id(key: String, content_id: String) -> void:
	if content_id.is_empty():
		return
	var changed := false
	match key:
		"seen_text_ids":
			changed = bool(_app_state.call("mark_text_seen", content_id))
		"seen_cinematic_ids":
			changed = bool(_app_state.call("mark_cinematic_seen", content_id))
		"completed_interaction_ids":
			changed = bool(_app_state.call("mark_interaction_completed", content_id))
	if changed:
		_persist_global_state()


func _persist_global_state() -> bool:
	if _save_service == null or _app_state == null:
		return false
	var result: Dictionary = _save_service.call("save_global", _get_global_state())
	if bool(result.get("ok", false)):
		return true
	_present_save_error("전역 기록 저장", result)
	return false


func _mark_current_line_seen_if_visible() -> void:
	if (
		not _active_line_marked_seen
		and not _active_line_id.is_empty()
		and _story_screen.is_text_fully_visible()
	):
		_active_line_marked_seen = true
		_mark_global_id("seen_text_ids", _active_line_id)


func _advance_seen_line(serial: int) -> void:
	if serial != _line_serial or not _skip_enabled or _flow_state != "story":
		return
	var snapshot := get_runtime_snapshot()
	if (
		str(snapshot.get("waiting_kind", "")) == "line"
		and str(snapshot.get("pending_step", {}).get("text_id", "")) == _active_line_id
	):
		_story_runtime.call("advance")


func _schedule_auto_advance() -> void:
	if not _auto_enabled or _flow_state != "story":
		return
	_auto_timer.start(maxf(float(_get_settings().get("auto_advance_delay_sec", 2.5)), 0.05))


func _on_auto_timer_timeout() -> void:
	if not _auto_enabled or _flow_state != "story" or not _story_screen.is_text_fully_visible():
		return
	_mark_current_line_seen_if_visible()
	_story_runtime.call("advance")


func _stop_automatic_progress() -> void:
	if _auto_timer != null:
		_auto_timer.stop()
	_line_serial += 1


func _clear_line_state() -> void:
	_stop_automatic_progress()
	_active_line_id = ""
	_active_line_was_seen = false
	_active_line_marked_seen = false


func _reset_reading_modes() -> void:
	_auto_enabled = false
	_skip_enabled = false
	_story_screen.set_auto_enabled(false)
	_story_screen.set_skip_enabled(false)


func _consequence_title(consequence_id: String) -> String:
	match consequence_id:
		"CON-CH01-TRACK":
			return "추적 · 놓치지 않은 대가"
		"CON-CH01-PROTECT":
			return "수호 · 사람을 먼저 남기다"
		"CON-CH01-LOCKDOWN":
			return "봉쇄 · 객잔에 남은 불"
	return "선택 뒤 남은 것"


func _set_flow_state(state: String) -> void:
	if _flow_state == state:
		return
	_flow_state = state
	flow_state_changed.emit(state)


func _build_auto_timer() -> void:
	_auto_timer = Timer.new()
	_auto_timer.name = "AutoAdvanceTimer"
	_auto_timer.one_shot = true
	_auto_timer.timeout.connect(_on_auto_timer_timeout)
	add_child(_auto_timer)


func _build_fatal_overlay() -> void:
	_fatal_overlay = Control.new()
	_fatal_overlay.name = "FatalErrorOverlay"
	_fatal_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_fatal_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	_ui_layer.add_child(_fatal_overlay)
	var veil := ColorRect.new()
	veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	veil.color = Color(0.02, 0.018, 0.016, 0.94)
	_fatal_overlay.add_child(veil)
	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -420
	panel.offset_top = -180
	panel.offset_right = 420
	panel.offset_bottom = 180
	_fatal_overlay.add_child(panel)
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 20)
	panel.add_child(stack)
	var title := Label.new()
	title.text = "기록을 이어갈 수 없습니다"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 32)
	stack.add_child(title)
	_fatal_message = Label.new()
	_fatal_message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_fatal_message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_fatal_message.add_theme_font_size_override("font_size", 20)
	stack.add_child(_fatal_message)
	var back := Button.new()
	back.text = "표지로 돌아가기"
	back.pressed.connect(return_to_title)
	stack.add_child(back)
	_fatal_overlay.hide()


func _present_save_error(operation: String, result: Dictionary) -> void:
	_present_fatal_error(
		{
			"code": str(result.get("code", "SAVE_ERROR")),
			"message": "%s에 실패했습니다. %s" % [operation, result.get("message", "")],
			"fatal": true,
		}
	)


func _present_fatal_error(payload: Dictionary) -> void:
	_stop_automatic_progress()
	_last_error = payload.duplicate(true)
	_title_screen.hide()
	_story_screen.hide()
	_interaction_director.hide()
	_cinematic_presenter.dismiss()
	_consequence_screen.hide()
	_chapter_end_screen.hide()
	_settings_screen.hide()
	_fatal_message.text = "%s\n%s" % [payload.get("code", "RUNTIME_ERROR"), payload.get("message", "알 수 없는 오류")]
	_fatal_overlay.show()
	_set_flow_state("fatal_error")
	fatal_error_presented.emit(_last_error.duplicate(true))


func _clear_fatal_error() -> void:
	_last_error.clear()
	if _fatal_overlay != null:
		_fatal_overlay.hide()
