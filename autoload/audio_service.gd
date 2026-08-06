extends Node

signal cue_requested(cue_id: StringName, options: Dictionary)
signal cue_stop_requested(cue_id: StringName)
signal all_audio_stop_requested


func play_cue(cue_id: StringName, options: Dictionary = {}) -> bool:
	if cue_id.is_empty():
		return false
	cue_requested.emit(cue_id, options.duplicate(true))
	return true


func stop_cue(cue_id: StringName) -> bool:
	if cue_id.is_empty():
		return false
	cue_stop_requested.emit(cue_id)
	return true


func stop_all() -> void:
	all_audio_stop_requested.emit()
