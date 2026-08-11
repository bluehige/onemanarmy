class_name CinematicDirector
extends Node

signal playback_started(cinematic_id: StringName, mode: StringName)
signal mode_changed(mode: StringName)
signal pause_changed(paused: bool)
signal cue_requested(kind: StringName, cue: Dictionary)
signal camera_cue_requested(cue: Dictionary)
signal animation_cue_requested(cue: Dictionary)
signal audio_cue_requested(cue: Dictionary)
signal vfx_cue_requested(cue: Dictionary)
signal completed(payload: Dictionary)

const MODE_AUTO: StringName = &"auto"
const MODE_FULL: StringName = &"full"
const MODE_SUMMARY: StringName = &"summary"
const MODE_RESULT: StringName = &"result"
const PLAYBACK_MODES: Array[StringName] = [MODE_FULL, MODE_SUMMARY, MODE_RESULT]

var _cinematic: Dictionary = {}
var _cinematic_id: StringName = &""
var _mode: StringName = MODE_FULL
var _duration_scale := 1.0
var _duration_sec := 0.0
var _elapsed_sec := 0.0
var _paused := false
var _playing := false
var _skipped := false
var _playback_serial := 0
var _cues: Array[Dictionary] = []
var _cue_index := 0
var _result_events: Array = []
var _last_completion: Dictionary = {}


func _ready() -> void:
	set_process(false)


func _process(delta: float) -> void:
	if not _playing or _paused:
		return
	_elapsed_sec += delta
	_emit_due_cues(_elapsed_sec)
	if _elapsed_sec >= _duration_sec:
		_complete_playback(_playback_serial)


func play_from_manifest(
	manifest: Dictionary,
	cinematic_id: StringName,
	requested_mode: StringName = MODE_AUTO,
	is_first_view: bool = true,
	duration_scale: float = 1.0
) -> Dictionary:
	var cinematics: Variant = manifest.get("cinematics", [])
	if not cinematics is Array:
		return _error("INVALID_MANIFEST", "Manifest cinematics must be an array.")

	for candidate in cinematics:
		if candidate is Dictionary and StringName(candidate.get("id", "")) == cinematic_id:
			var mode := requested_mode
			if requested_mode == MODE_AUTO and is_first_view:
				var manifest_default := StringName(
					manifest.get("default_first_view_mode", MODE_FULL)
				)
				if PLAYBACK_MODES.has(manifest_default):
					mode = manifest_default
			return play_cinematic(candidate, mode, is_first_view, duration_scale)

	return _error("CINEMATIC_NOT_FOUND", "Unknown cinematic ID: %s." % cinematic_id)


func play_cinematic(
	cinematic: Dictionary,
	requested_mode: StringName = MODE_AUTO,
	is_first_view: bool = true,
	duration_scale: float = 1.0
) -> Dictionary:
	var validation := _validate_cinematic(cinematic)
	if not bool(validation.get("ok", false)):
		return validation

	_playback_serial += 1
	_cinematic = cinematic.duplicate(true)
	_cinematic_id = StringName(_cinematic.get("id", ""))
	_result_events = _duplicate_event_array(_cinematic.get("result_events", []))
	_duration_scale = maxf(duration_scale, 0.0)
	_skipped = false
	_playing = true
	_paused = false
	_last_completion = {}

	var resolved_mode := resolve_initial_mode(requested_mode, is_first_view)
	_configure_mode(resolved_mode)
	playback_started.emit(_cinematic_id, _mode)
	mode_changed.emit(_mode)
	_emit_due_cues(0.0)

	if _duration_sec <= 0.0 or _mode == MODE_RESULT:
		call_deferred("_complete_playback", _playback_serial)
	else:
		set_process(true)

	return {
		"ok": true,
		"cinematic_id": _cinematic_id,
		"mode": _mode,
		"is_first_view": is_first_view,
	}


func resolve_initial_mode(requested_mode: StringName, is_first_view: bool) -> StringName:
	if PLAYBACK_MODES.has(requested_mode):
		return requested_mode
	return MODE_FULL if is_first_view else MODE_SUMMARY


func set_paused(value: bool) -> bool:
	if not _playing or _paused == value:
		return false
	_paused = value
	pause_changed.emit(_paused)
	return true


func toggle_pause() -> bool:
	return set_paused(not _paused)


func switch_to_summary() -> bool:
	if not _playing or _mode == MODE_SUMMARY or _mode == MODE_RESULT:
		return false
	_playback_serial += 1
	if _paused:
		_paused = false
		pause_changed.emit(false)
	_configure_mode(MODE_SUMMARY)
	mode_changed.emit(_mode)
	_emit_due_cues(0.0)
	if _duration_sec <= 0.0:
		call_deferred("_complete_playback", _playback_serial)
	else:
		set_process(true)
	return true


func skip_to_result() -> Array:
	return _move_to_result(true)


func move_to_result() -> Array:
	return _move_to_result(false)


func get_current_mode() -> StringName:
	return _mode


func is_playing() -> bool:
	return _playing


func is_paused() -> bool:
	return _paused


func get_result_events() -> Array:
	return _result_events.duplicate(true)


func get_last_completion() -> Dictionary:
	return _last_completion.duplicate(true)


func _move_to_result(mark_skipped: bool) -> Array:
	var events := get_result_events()
	if not _playing:
		return events
	_playback_serial += 1
	_skipped = mark_skipped
	_paused = false
	_configure_mode(MODE_RESULT)
	mode_changed.emit(_mode)
	_complete_playback(_playback_serial)
	return events


func _configure_mode(mode: StringName) -> void:
	_mode = mode
	_elapsed_sec = 0.0
	_cue_index = 0
	var playback: Dictionary = _cinematic.get("playback", {})
	var mode_data: Dictionary = playback.get(String(mode), {})
	_duration_sec = maxf(float(mode_data.get("duration_sec", 0.0)), 0.0) * _duration_scale
	_cues = _build_cues(mode_data)


func _build_cues(mode_data: Dictionary) -> Array[Dictionary]:
	var built: Array[Dictionary] = []
	var unscaled_duration := 0.0
	if _duration_scale > 0.0:
		unscaled_duration = _duration_sec / _duration_scale

	var explicit_camera_cues: Variant = mode_data.get("camera_cues", [])
	var has_explicit_camera_cues: bool = explicit_camera_cues is Array and not explicit_camera_cues.is_empty()
	var authored_animation_cues: Variant = mode_data.get("animation_cues", [])
	var animation_owns_visibility: bool = authored_animation_cues is Array and not authored_animation_cues.is_empty()
	var shot_ids: Variant = mode_data.get("shot_ids", [])
	if not has_explicit_camera_cues and shot_ids is Array and not shot_ids.is_empty():
		for shot_index in range(shot_ids.size()):
			var shot_time := unscaled_duration * float(shot_index) / float(shot_ids.size())
			built.append(
				_prepare_cue(
					&"camera",
					{
						"shot_id": shot_ids[shot_index],
						"time_sec": shot_time,
						"formation_animation_owned": animation_owns_visibility,
					}
				)
			)

	_append_generic_cues(built, _cinematic.get("cues", []), unscaled_duration)
	_append_generic_cues(built, mode_data.get("cues", []), unscaled_duration)

	var cue_groups := {
		&"camera": "camera_cues",
		&"animation": "animation_cues",
		&"audio": "audio_cues",
		&"vfx": "vfx_cues",
	}
	for kind: StringName in cue_groups:
		var key: String = cue_groups[kind]
		_append_typed_cues(built, kind, _cinematic.get(key, []), unscaled_duration)
		_append_typed_cues(built, kind, mode_data.get(key, []), unscaled_duration)

	built.sort_custom(_cue_time_less)
	return built


func _append_generic_cues(
	destination: Array[Dictionary],
	values: Variant,
	duration: float
) -> void:
	if not values is Array:
		return
	for index in range(values.size()):
		var cue := _coerce_cue(values[index])
		var kind := StringName(cue.get("kind", cue.get("type", "")))
		if kind.is_empty():
			continue
		if not cue.has("time_sec"):
			cue["time_sec"] = _distributed_time(index, values.size(), duration)
		destination.append(_prepare_cue(kind, cue))


func _append_typed_cues(
	destination: Array[Dictionary],
	kind: StringName,
	values: Variant,
	duration: float
) -> void:
	if not values is Array:
		return
	for index in range(values.size()):
		var cue := _coerce_cue(values[index])
		if not cue.has("time_sec"):
			cue["time_sec"] = _distributed_time(index, values.size(), duration)
		destination.append(_prepare_cue(kind, cue))


func _prepare_cue(kind: StringName, cue: Dictionary) -> Dictionary:
	var prepared := cue.duplicate(true)
	prepared["kind"] = kind
	prepared["cinematic_id"] = _cinematic_id
	prepared["mode"] = _mode
	prepared["time_sec"] = maxf(float(prepared.get("time_sec", 0.0)), 0.0) * _duration_scale
	return prepared


func _coerce_cue(value: Variant) -> Dictionary:
	if value is Dictionary:
		return value.duplicate(true)
	return {"id": value}


func _distributed_time(index: int, count: int, duration: float) -> float:
	if count <= 0:
		return 0.0
	return duration * float(index) / float(count)


func _cue_time_less(left: Dictionary, right: Dictionary) -> bool:
	var left_time := float(left.get("time_sec", 0.0))
	var right_time := float(right.get("time_sec", 0.0))
	if not is_equal_approx(left_time, right_time):
		return left_time < right_time
	return _cue_kind_priority(StringName(left.get("kind", ""))) < _cue_kind_priority(
		StringName(right.get("kind", ""))
	)


func _cue_kind_priority(kind: StringName) -> int:
	match kind:
		&"camera":
			return 0
		&"animation":
			return 1
		&"vfx":
			return 2
		&"audio":
			return 3
	return 4


func _emit_due_cues(elapsed_sec: float) -> void:
	while _cue_index < _cues.size():
		var cue := _cues[_cue_index]
		if float(cue.get("time_sec", 0.0)) > elapsed_sec + 0.000001:
			break
		_cue_index += 1
		var kind := StringName(cue.get("kind", ""))
		var emitted_cue := cue.duplicate(true)
		cue_requested.emit(kind, emitted_cue)
		match kind:
			&"camera":
				camera_cue_requested.emit(emitted_cue)
			&"animation":
				animation_cue_requested.emit(emitted_cue)
			&"audio":
				audio_cue_requested.emit(emitted_cue)
			&"vfx":
				vfx_cue_requested.emit(emitted_cue)


func _complete_playback(serial: int) -> void:
	if serial != _playback_serial or not _playing:
		return
	_playing = false
	set_process(false)
	if _paused:
		_paused = false
		pause_changed.emit(false)
	var payload := {
		"cinematic_id": _cinematic_id,
		"mode": _mode,
		"skipped": _skipped,
		"result_events": get_result_events(),
	}
	_last_completion = payload.duplicate(true)
	completed.emit(payload)


func _validate_cinematic(cinematic: Dictionary) -> Dictionary:
	if String(cinematic.get("id", "")).is_empty():
		return _error("MISSING_CINEMATIC_ID", "Cinematic requires a non-empty id.")
	var playback: Variant = cinematic.get("playback", {})
	if not playback is Dictionary:
		return _error("INVALID_PLAYBACK", "Cinematic playback must be a dictionary.")
	for mode in PLAYBACK_MODES:
		if not playback.has(String(mode)) or not playback[String(mode)] is Dictionary:
			return _error("MISSING_PLAYBACK_MODE", "Cinematic is missing %s playback." % mode)
	if not cinematic.get("result_events", []) is Array:
		return _error("INVALID_RESULT_EVENTS", "Cinematic result_events must be an array.")
	return {"ok": true}


func _duplicate_event_array(values: Variant) -> Array:
	if not values is Array:
		return []
	return values.duplicate(true)


func _error(code: String, message: String) -> Dictionary:
	return {"ok": false, "code": code, "message": message}
