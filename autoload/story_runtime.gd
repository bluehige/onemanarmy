extends Node

signal scene_changed(payload: Dictionary)
signal line_requested(payload: Dictionary)
signal choice_requested(payload: Dictionary)
signal interaction_requested(payload: Dictionary)
signal cinematic_requested(payload: Dictionary)
signal consequence_requested(payload: Dictionary)
signal autosave_requested(payload: Dictionary)
signal chapter_ended(payload: Dictionary)
signal runtime_error(payload: Dictionary)

const SNAPSHOT_VERSION := 1
const MAX_INTERNAL_STEPS_PER_DRIVE := 512
const VALID_CINEMATIC_COMPLETION_MODES := ["full", "summary", "result", "skip"]
const WAITING_KINDS := ["", "line", "choice", "interaction", "cinematic", "consequence", "error"]

var _content_registry: Node
var _chapter_id := ""
var _scene_id := ""
var _flags: Dictionary = {}
var _choices: Dictionary = {}
var _state_log: Array[Dictionary] = []
var _frames: Array[Dictionary] = []
var _waiting_kind := ""
var _pending_step: Dictionary = {}
var _pending_payload: Dictionary = {}
var _completed_interaction_ids: Array[String] = []
var _cinematic_history: Dictionary = {}
var _result_event_suppressions: Dictionary = {}
var _ended := false
var _driving := false
var _last_error: Dictionary = {}


func _ready() -> void:
	_content_registry = get_node_or_null("/root/ContentRegistry")


func start_chapter(chapter_id: String = "CH-MVP-001", entry_scene: String = "") -> bool:
	_reset_runtime()
	if not _ensure_registry():
		return false
	var manifest := _registry_dictionary("get_chapter_manifest", [chapter_id])
	if manifest.is_empty():
		_fatal("CHAPTER_NOT_FOUND", "Chapter manifest was not found.", {"chapter_id": chapter_id})
		return false

	_chapter_id = chapter_id
	var state_schema: Variant = manifest.get("state_schema", {})
	if not state_schema is Dictionary:
		_fatal("INVALID_CHAPTER_STATE", "Chapter state schema must be a dictionary.")
		return false
	for flag_name in state_schema:
		var specification: Variant = state_schema[flag_name]
		if specification is Dictionary:
			_flags[str(flag_name)] = specification.get("default")

	var first_scene := entry_scene
	if first_scene.is_empty():
		first_scene = str(manifest.get("entry_scene", ""))
	if first_scene.is_empty() or not _enter_scene(first_scene):
		return false
	_drive()
	return _last_error.is_empty()


func advance() -> bool:
	if _waiting_kind != "line":
		return _input_error("NOT_WAITING_FOR_LINE", "advance() requires a pending line.")
	_clear_pending()
	_drive()
	return _last_error.is_empty()


func choose(choice_id: String, option_id: String) -> bool:
	if _waiting_kind != "choice":
		return _input_error("NOT_WAITING_FOR_CHOICE", "choose() requires a pending choice.")
	if str(_pending_step.get("choice_id", "")) != choice_id:
		return _input_error(
			"CHOICE_ID_MISMATCH",
			"Pending choice is %s, not %s." % [_pending_step.get("choice_id", ""), choice_id]
		)
	var selected: Dictionary = {}
	var options: Variant = _pending_step.get("options", [])
	if options is Array:
		for option in options:
			if option is Dictionary and str(option.get("id", "")) == option_id:
				selected = option
				break
	if selected.is_empty():
		return _input_error("OPTION_NOT_FOUND", "Choice option %s was not found." % option_id)

	var output_flag := str(_pending_step.get("output_flag", ""))
	if output_flag.is_empty():
		return _input_error("CHOICE_OUTPUT_MISSING", "Choice has no output flag.")
	var before_state := {
		"flags": _flags.duplicate(true),
		"choices": _choices.duplicate(true),
	}
	_flags[output_flag] = selected.get("value")
	_choices[choice_id] = option_id
	_state_log.append(
		{
			"type": "choice",
			"step_id": str(_pending_step.get("id", "")),
			"choice_id": choice_id,
			"option_id": option_id,
			"before": before_state,
			"after": {
				"flags": _flags.duplicate(true),
				"choices": _choices.duplicate(true),
			},
		}
	)
	_clear_pending()
	_drive()
	return _last_error.is_empty()


func complete_interaction(interaction_id: String, result: Dictionary = {}) -> bool:
	if _waiting_kind != "interaction":
		return _input_error(
			"NOT_WAITING_FOR_INTERACTION",
			"complete_interaction() requires a pending interaction."
		)
	if str(_pending_step.get("interaction_id", "")) != interaction_id:
		return _input_error(
			"INTERACTION_ID_MISMATCH",
			"Pending interaction is %s, not %s." % [_pending_step.get("interaction_id", ""), interaction_id]
		)

	var output_flag := str(_pending_step.get("output_flag", ""))
	if not output_flag.is_empty():
		var has_value := result.has("value") or result.has("selection") or result.has(output_flag)
		if not has_value:
			return _input_error(
				"INTERACTION_RESULT_MISSING",
				"Interaction %s must provide a value for %s." % [interaction_id, output_flag]
			)
		var output_value: Variant = result.get("value", result.get("selection", result.get(output_flag)))
		_flags[output_flag] = output_value
	if interaction_id not in _completed_interaction_ids:
		_completed_interaction_ids.append(interaction_id)
	_clear_pending()
	_drive()
	return _last_error.is_empty()


func complete_cinematic(cinematic_id: String, mode: String = "full") -> bool:
	if _waiting_kind != "cinematic":
		return _input_error(
			"NOT_WAITING_FOR_CINEMATIC",
			"complete_cinematic() requires a pending cinematic."
		)
	if str(_pending_step.get("cinematic_id", "")) != cinematic_id:
		return _input_error(
			"CINEMATIC_ID_MISMATCH",
			"Pending cinematic is %s, not %s." % [_pending_step.get("cinematic_id", ""), cinematic_id]
		)
	var normalized_mode := mode.to_lower()
	if normalized_mode not in VALID_CINEMATIC_COMPLETION_MODES:
		return _input_error("INVALID_CINEMATIC_MODE", "Unsupported cinematic completion mode %s." % mode)

	var cinematic := _registry_dictionary("get_cinematic", [cinematic_id])
	if cinematic.is_empty():
		_fatal("CINEMATIC_NOT_FOUND", "Cinematic was not found.", {"cinematic_id": cinematic_id})
		return false
	var result_events: Variant = cinematic.get("result_events", [])
	if result_events is Array:
		for event in result_events:
			if not event is Dictionary:
				_fatal("INVALID_RESULT_EVENT", "Cinematic result event must be a dictionary.")
				return false
			if not _apply_state_event(event):
				return false
			var signature := _state_event_signature(event)
			_result_event_suppressions[signature] = int(_result_event_suppressions.get(signature, 0)) + 1
	_cinematic_history[cinematic_id] = normalized_mode
	_clear_pending()
	_drive()
	return _last_error.is_empty()


func complete_consequence(consequence_id: String) -> bool:
	if _waiting_kind != "consequence":
		return _input_error(
			"NOT_WAITING_FOR_CONSEQUENCE",
			"complete_consequence() requires a pending consequence."
		)
	if str(_pending_step.get("consequence_id", "")) != consequence_id:
		return _input_error(
			"CONSEQUENCE_ID_MISMATCH",
			"Pending consequence is %s, not %s." % [_pending_step.get("consequence_id", ""), consequence_id]
		)
	_clear_pending()
	_drive()
	return _last_error.is_empty()


func snapshot() -> Dictionary:
	return {
		"snapshot_version": SNAPSHOT_VERSION,
		"chapter_id": _chapter_id,
		"scene_id": _scene_id,
		"flags": _flags.duplicate(true),
		"choices": _choices.duplicate(true),
		"state_log": _state_log.duplicate(true),
		"frames": _frames.duplicate(true),
		"waiting_kind": _waiting_kind,
		"pending_step": _pending_step.duplicate(true),
		"pending_payload": _pending_payload.duplicate(true),
		"completed_interaction_ids": _completed_interaction_ids.duplicate(),
		"cinematic_history": _cinematic_history.duplicate(true),
		"result_event_suppressions": _result_event_suppressions.duplicate(true),
		"ended": _ended,
		"last_error": _last_error.duplicate(true),
	}


func restore(state: Dictionary) -> bool:
	if not _ensure_registry():
		return false
	if int(state.get("snapshot_version", 0)) != SNAPSHOT_VERSION:
		return _input_error("SNAPSHOT_VERSION", "Unsupported StoryRuntime snapshot version.")
	var chapter_id := str(state.get("chapter_id", ""))
	var scene_id := str(state.get("scene_id", ""))
	if chapter_id.is_empty() or scene_id.is_empty() or not _registry_bool("has_scene", [scene_id]):
		return _input_error("INVALID_SNAPSHOT", "Snapshot chapter or scene is invalid.")
	var raw_frames: Variant = state.get("frames", [])
	var raw_flags: Variant = state.get("flags", {})
	var raw_choices: Variant = state.get("choices", {})
	var raw_state_log: Variant = state.get("state_log", [])
	var waiting_kind := str(state.get("waiting_kind", ""))
	if (
		not raw_frames is Array
		or not raw_flags is Dictionary
		or not raw_choices is Dictionary
		or not raw_state_log is Array
	):
		return _input_error("INVALID_SNAPSHOT", "Snapshot execution or state data is invalid.")
	if waiting_kind not in WAITING_KINDS:
		return _input_error("INVALID_SNAPSHOT", "Snapshot waiting state is invalid.")

	_reset_runtime()
	_chapter_id = chapter_id
	_scene_id = scene_id
	_flags = raw_flags.duplicate(true)
	_choices = raw_choices.duplicate(true)
	for raw_log_entry in raw_state_log:
		if not raw_log_entry is Dictionary:
			_fatal("INVALID_SNAPSHOT", "Snapshot contains an invalid state log entry.")
			return false
		_state_log.append(raw_log_entry.duplicate(true))
	for raw_frame in raw_frames:
		if not raw_frame is Dictionary or not raw_frame.get("steps", []) is Array:
			_fatal("INVALID_SNAPSHOT", "Snapshot contains an invalid execution frame.")
			return false
		_frames.append(raw_frame.duplicate(true))
	_waiting_kind = waiting_kind
	var raw_pending_step: Variant = state.get("pending_step", {})
	var raw_pending_payload: Variant = state.get("pending_payload", {})
	if raw_pending_step is Dictionary:
		_pending_step = raw_pending_step.duplicate(true)
	if raw_pending_payload is Dictionary:
		_pending_payload = raw_pending_payload.duplicate(true)
	var completed_ids: Variant = state.get("completed_interaction_ids", [])
	if completed_ids is Array:
		for interaction_id in completed_ids:
			_completed_interaction_ids.append(str(interaction_id))
	var history: Variant = state.get("cinematic_history", {})
	if history is Dictionary:
		_cinematic_history = history.duplicate(true)
	var suppressions: Variant = state.get("result_event_suppressions", {})
	if suppressions is Dictionary:
		_result_event_suppressions = suppressions.duplicate(true)
	_ended = bool(state.get("ended", false))
	var restored_error: Variant = state.get("last_error", {})
	if restored_error is Dictionary:
		_last_error = restored_error.duplicate(true)

	var scene := _registry_dictionary("get_scene", [_scene_id])
	scene_changed.emit({"scene_id": _scene_id, "route": scene.get("route", "COMMON"), "restored": true})
	if _ended:
		return true
	if not _waiting_kind.is_empty():
		_emit_pending()
	else:
		_drive()
	return _last_error.is_empty()


func _ensure_registry() -> bool:
	if _content_registry == null:
		_content_registry = get_node_or_null("/root/ContentRegistry")
	if _content_registry == null or not _content_registry.has_method("ensure_loaded"):
		_fatal("CONTENT_REGISTRY_MISSING", "ContentRegistry autoload is unavailable.")
		return false
	if not bool(_content_registry.call("ensure_loaded")):
		var errors: Variant = _content_registry.call("get_load_errors")
		_fatal("CONTENT_LOAD_FAILED", "ContentRegistry failed to load content.", {"errors": errors})
		return false
	return true


func _registry_dictionary(method: String, arguments: Array = []) -> Dictionary:
	if _content_registry == null or not _content_registry.has_method(method):
		return {}
	var value: Variant = _content_registry.callv(method, arguments)
	if value is Dictionary:
		return value
	return {}


func _registry_bool(method: String, arguments: Array = []) -> bool:
	if _content_registry == null or not _content_registry.has_method(method):
		return false
	return bool(_content_registry.callv(method, arguments))


func _registry_text(text_id: String) -> String:
	if _content_registry == null or not _content_registry.has_method("get_ko_text"):
		return ""
	return str(_content_registry.call("get_ko_text", text_id, ""))


func _reset_runtime() -> void:
	_chapter_id = ""
	_scene_id = ""
	_flags.clear()
	_choices.clear()
	_state_log.clear()
	_frames.clear()
	_waiting_kind = ""
	_pending_step.clear()
	_pending_payload.clear()
	_completed_interaction_ids.clear()
	_cinematic_history.clear()
	_result_event_suppressions.clear()
	_ended = false
	_driving = false
	_last_error.clear()


func _enter_scene(scene_id: String) -> bool:
	var scene := _registry_dictionary("get_scene", [scene_id])
	if scene.is_empty():
		_fatal("SCENE_NOT_FOUND", "Story scene was not found.", {"scene_id": scene_id})
		return false
	var steps: Variant = scene.get("steps", [])
	if not steps is Array or steps.is_empty():
		_fatal("SCENE_STEPS_INVALID", "Story scene has no executable steps.", {"scene_id": scene_id})
		return false
	_scene_id = scene_id
	_frames.clear()
	_frames.append({"steps": steps.duplicate(true), "index": 0})
	scene_changed.emit({"scene_id": scene_id, "route": scene.get("route", "COMMON"), "restored": false})
	return true


func _drive() -> void:
	if _driving or _ended or not _waiting_kind.is_empty():
		return
	_driving = true
	var processed := 0
	while not _ended and _waiting_kind.is_empty():
		processed += 1
		if processed > MAX_INTERNAL_STEPS_PER_DRIVE:
			_fatal(
				"INFINITE_LOOP",
				"StoryRuntime exceeded the internal step limit without reaching an external wait."
			)
			break
		var step := _next_step()
		if step.is_empty():
			_fatal("SCENE_EXHAUSTED", "Scene ended without jump or end_chapter.", {"scene_id": _scene_id})
			break
		_execute_step(step)
	_driving = false


func _next_step() -> Dictionary:
	while not _frames.is_empty():
		var frame_index := _frames.size() - 1
		var frame: Dictionary = _frames[frame_index]
		var steps: Variant = frame.get("steps", [])
		var index := int(frame.get("index", 0))
		if not steps is Array:
			return {}
		if index >= steps.size():
			_frames.pop_back()
			continue
		frame["index"] = index + 1
		_frames[frame_index] = frame
		var step: Variant = steps[index]
		if step is Dictionary:
			return step
		return {}
	return {}


func _execute_step(step: Dictionary) -> void:
	match str(step.get("type", "")):
		"say", "narrate":
			_request_line(step)
		"choice":
			_request_choice(step)
		"set_flag":
			_apply_story_state_step(step)
		"conditional":
			_execute_conditional(step)
		"focus_interaction", "intent_interaction", "blade_recall":
			_request_interaction(step)
		"play_cinematic":
			_request_cinematic(step)
		"show_consequence":
			_request_consequence(step)
		"autosave":
			autosave_requested.emit(
				{"save_id": step.get("save_id", ""), "scene_id": _scene_id, "snapshot": snapshot()}
			)
		"jump":
			_enter_scene(str(step.get("target", "")))
		"end_chapter":
			_ended = true
			var next_title := _registry_text(str(step.get("next_title_text_id", "")))
			var next_chapter := _registry_text(str(step.get("next_chapter_text_id", "")))
			var next_label := next_title
			if not next_chapter.is_empty():
				next_label = "%s · %s" % [next_title, next_chapter] if not next_title.is_empty() else next_chapter
			chapter_ended.emit(
				{
					"chapter_id": _chapter_id,
					"scene_id": _scene_id,
					"flags": _flags.duplicate(true),
					"choices": _choices.duplicate(true),
					"completion_title": _registry_text(str(step.get("completion_title_text_id", ""))),
					"completion_subtitle": _registry_text(str(step.get("completion_subtitle_text_id", ""))),
					"next_title": next_label,
				}
			)
		_:
			_fatal("UNKNOWN_STEP_TYPE", "Unsupported story step type.", {"step": step})


func _request_line(step: Dictionary) -> void:
	var text_id := str(step.get("text_id", ""))
	var text := _registry_text(text_id)
	if text_id.is_empty() or text.is_empty():
		_fatal("TEXT_NOT_FOUND", "Localized story text was not found.", {"text_id": text_id})
		return
	var payload := step.duplicate(true)
	payload["scene_id"] = _scene_id
	payload["text"] = text
	_set_pending("line", step, payload)
	line_requested.emit(payload.duplicate(true))


func _request_choice(step: Dictionary) -> void:
	var payload := step.duplicate(true)
	payload["scene_id"] = _scene_id
	var resolved_options: Array[Dictionary] = []
	var options: Variant = step.get("options", [])
	if options is Array:
		for option in options:
			if not option is Dictionary:
				continue
			var resolved: Dictionary = option.duplicate(true)
			resolved["label"] = _registry_text(str(option.get("label_text_id", "")))
			var description_id := str(option.get("description_text_id", ""))
			if not description_id.is_empty():
				resolved["description"] = _registry_text(description_id)
			resolved_options.append(resolved)
	payload["options"] = resolved_options
	_set_pending("choice", step, payload)
	choice_requested.emit(payload.duplicate(true))


func _request_interaction(step: Dictionary) -> void:
	var interaction_id := str(step.get("interaction_id", ""))
	var contract := _registry_dictionary("get_interaction", [interaction_id])
	if contract.is_empty():
		_fatal("INTERACTION_NOT_FOUND", "Interaction contract was not found.", {"interaction_id": interaction_id})
		return
	var payload := {
		"scene_id": _scene_id,
		"step_type": step.get("type", ""),
		"interaction_id": interaction_id,
		"prompt": _registry_text(str(contract.get("prompt_key", ""))),
		"contract": contract,
	}
	_set_pending("interaction", step, payload)
	interaction_requested.emit(payload.duplicate(true))


func _request_cinematic(step: Dictionary) -> void:
	var cinematic_id := str(step.get("cinematic_id", ""))
	var cinematic := _registry_dictionary("get_cinematic", [cinematic_id])
	if cinematic.is_empty():
		_fatal("CINEMATIC_NOT_FOUND", "Cinematic was not found.", {"cinematic_id": cinematic_id})
		return
	var payload := {
		"scene_id": _scene_id,
		"cinematic_id": cinematic_id,
		"purpose": _registry_text(str(cinematic.get("purpose_text_id", ""))),
		"cinematic": cinematic,
	}
	_set_pending("cinematic", step, payload)
	cinematic_requested.emit(payload.duplicate(true))


func _request_consequence(step: Dictionary) -> void:
	var resolved_lines: Array[Dictionary] = []
	var text_ids: Variant = step.get("line_text_ids", [])
	if text_ids is Array:
		for text_id in text_ids:
			resolved_lines.append({"text_id": text_id, "text": _registry_text(str(text_id))})
	var payload := step.duplicate(true)
	payload["scene_id"] = _scene_id
	payload["lines"] = resolved_lines
	_set_pending("consequence", step, payload)
	consequence_requested.emit(payload.duplicate(true))


func _execute_conditional(step: Dictionary) -> void:
	var selected_steps: Array = []
	var branches: Variant = step.get("branches", [])
	if branches is Array:
		for branch in branches:
			if not branch is Dictionary:
				continue
			var condition: Variant = branch.get("when", {})
			if condition is Dictionary and _condition_matches(condition):
				var branch_steps: Variant = branch.get("steps", [])
				if branch_steps is Array:
					selected_steps = branch_steps
				break
	if selected_steps.is_empty():
		var default_steps: Variant = step.get("default_steps", [])
		if default_steps is Array:
			selected_steps = default_steps
	if not selected_steps.is_empty():
		_frames.append({"steps": selected_steps.duplicate(true), "index": 0})


func _condition_matches(condition: Dictionary) -> bool:
	var flag := str(condition.get("flag", ""))
	return _flags.has(flag) and _flags[flag] == condition.get("equals")


func _apply_story_state_step(step: Dictionary) -> void:
	var signature := _state_event_signature(step)
	var suppression_count := int(_result_event_suppressions.get(signature, 0))
	if suppression_count > 0:
		if suppression_count == 1:
			_result_event_suppressions.erase(signature)
		else:
			_result_event_suppressions[signature] = suppression_count - 1
		return
	_apply_state_event(step)


func _apply_state_event(event: Dictionary) -> bool:
	var flag := str(event.get("flag", ""))
	if flag.is_empty() or not _flags.has(flag):
		_fatal("UNKNOWN_FLAG", "State event references an unknown flag.", {"flag": flag})
		return false
	match str(event.get("operation", "set")):
		"set":
			_flags[flag] = event.get("value")
		"increment":
			_flags[flag] = int(_flags.get(flag, 0)) + int(event.get("value", 0))
		_:
			_fatal("UNKNOWN_FLAG_OPERATION", "State event operation is unsupported.", {"event": event})
			return false
	return true


func _state_event_signature(event: Dictionary) -> String:
	return JSON.stringify(
		[
			str(event.get("flag", "")),
			str(event.get("operation", "set")),
			event.get("value"),
		]
	)


func _set_pending(kind: String, step: Dictionary, payload: Dictionary) -> void:
	_waiting_kind = kind
	_pending_step = step.duplicate(true)
	_pending_payload = payload.duplicate(true)


func _clear_pending() -> void:
	_waiting_kind = ""
	_pending_step.clear()
	_pending_payload.clear()


func _emit_pending() -> void:
	match _waiting_kind:
		"line":
			line_requested.emit(_pending_payload.duplicate(true))
		"choice":
			choice_requested.emit(_pending_payload.duplicate(true))
		"interaction":
			interaction_requested.emit(_pending_payload.duplicate(true))
		"cinematic":
			cinematic_requested.emit(_pending_payload.duplicate(true))
		"consequence":
			consequence_requested.emit(_pending_payload.duplicate(true))
		"error":
			runtime_error.emit(_last_error.duplicate(true))


func _input_error(code: String, message: String) -> bool:
	runtime_error.emit({"code": code, "message": message, "fatal": false})
	return false


func _fatal(code: String, message: String, details: Dictionary = {}) -> void:
	_last_error = {
		"code": code,
		"message": message,
		"details": details.duplicate(true),
		"scene_id": _scene_id,
		"fatal": true,
	}
	_waiting_kind = "error"
	_pending_step.clear()
	_pending_payload.clear()
	runtime_error.emit(_last_error.duplicate(true))
