extends Node

signal event_recorded(event_name: StringName, payload: Dictionary)

var enabled := false


func set_enabled(value: bool) -> void:
	enabled = value


func record_event(event_name: StringName, payload: Dictionary = {}) -> void:
	if not enabled or event_name.is_empty():
		return
	event_recorded.emit(event_name, payload.duplicate(true))
