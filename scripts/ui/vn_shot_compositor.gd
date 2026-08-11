class_name VNShotCompositor
extends Control

const MAX_CHARACTER_SLOTS := 3
const MAX_INTERNAL_LAYER_Z := 4
const TRANSIENT_HERO_LAYER_ID := "transient_hero_cg"
const TRANSIENT_HERO_FADE_SEC := 0.18
const VALID_LAYER_TYPES: Array[String] = ["rear", "character", "foreground", "vfx", "hero_cg"]
const CHARACTER_SLOTS: Array[String] = ["left", "center", "right"]
const LAYER_Z := {
	"rear": 0,
	"character": 1,
	"foreground": 2,
	"vfx": 3,
	"hero_cg": 4,
}
const SLOT_ANCHOR_X := {
	"left": 0.24,
	"center": 0.50,
	"right": 0.76,
}

var _background: TextureRect
var _layers_root: Control
var _layer_nodes: Dictionary = {}
var _layer_entries: Dictionary = {}
var _layer_ids: Array[String] = []
var _current_shot_id := ""
var _current_cue_id := ""
var _base_background_path := ""
var _cue_backgrounds: Dictionary = {}
var _resolved_background_path := ""
var _active_speaker_id := ""
var _transient_hero_tween: Tween


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ensure_interface()


func present_shot(shot: Dictionary, background_override: String = "") -> void:
	_ensure_interface()
	_current_shot_id = str(shot.get("id", ""))
	_current_cue_id = ""
	_active_speaker_id = ""
	_clear_layers()
	_background.texture = null
	_base_background_path = ""
	_cue_backgrounds = _normalized_cue_backgrounds(shot.get("cue_backgrounds", {}))
	_resolved_background_path = ""

	var background_path := _background_path(shot, background_override)
	var background_texture := _load_texture(background_path)
	if background_texture != null:
		_background.texture = background_texture
		_base_background_path = background_path
		_resolved_background_path = background_path

	var occupied_character_slots: Dictionary = {}
	var character_count := 0
	for layer_variant: Variant in shot.get("layers", []):
		if not layer_variant is Dictionary:
			continue
		var layer: Dictionary = (layer_variant as Dictionary).duplicate(true)
		if not bool(layer.get("visible", true)):
			continue
		var layer_id := str(layer.get("id", ""))
		var layer_type := str(layer.get("type", ""))
		if layer_id.is_empty() or _layer_nodes.has(layer_id) or layer_type not in VALID_LAYER_TYPES:
			continue
		if layer_type == "character":
			var slot := str(layer.get("slot", ""))
			if (
				character_count >= MAX_CHARACTER_SLOTS
				or slot not in CHARACTER_SLOTS
				or occupied_character_slots.has(slot)
			):
				continue
			occupied_character_slots[slot] = true
			character_count += 1
		var texture_path := _layer_texture_path(layer)
		var texture := _load_texture(texture_path)
		if texture == null:
			continue
		_add_layer(layer, texture)

	_apply_cue_visibility()
	_apply_speaker_emphasis()


func set_active_speaker(speaker_id: String) -> void:
	_active_speaker_id = speaker_id
	_apply_speaker_emphasis()


func apply_cue(shot_id: String) -> void:
	_current_cue_id = shot_id
	_apply_cue_background()
	_apply_cue_visibility()


func show_transient_hero(asset_path: String, fade_duration_sec: float = TRANSIENT_HERO_FADE_SEC) -> bool:
	_ensure_interface()
	clear_transient_hero()
	var texture := _load_texture(asset_path)
	if texture == null:
		return false
	_add_layer(
		{
			"id": TRANSIENT_HERO_LAYER_ID,
			"type": "hero_cg",
			"asset": asset_path,
			"resolved_asset": asset_path,
			"layout": "full_frame",
			"fit": "cover",
		},
		texture
	)
	var hero := _layer_nodes.get(TRANSIENT_HERO_LAYER_ID) as TextureRect
	if hero == null:
		return false
	var fade_sec := clampf(fade_duration_sec, 0.0, 0.5)
	if fade_sec <= 0.0:
		hero.modulate.a = 1.0
		return true
	hero.modulate.a = 0.0
	_transient_hero_tween = create_tween()
	_transient_hero_tween.tween_property(hero, "modulate:a", 1.0, fade_sec)
	return true


func clear_transient_hero() -> void:
	_kill_transient_hero_tween()
	var hero := _layer_nodes.get(TRANSIENT_HERO_LAYER_ID) as TextureRect
	if hero != null:
		_layers_root.remove_child(hero)
		hero.queue_free()
	_layer_nodes.erase(TRANSIENT_HERO_LAYER_ID)
	_layer_entries.erase(TRANSIENT_HERO_LAYER_ID)
	_layer_ids.erase(TRANSIENT_HERO_LAYER_ID)


func has_transient_hero() -> bool:
	return _layer_nodes.has(TRANSIENT_HERO_LAYER_ID)


func clear_shot() -> void:
	_ensure_interface()
	_clear_layers()
	_background.texture = null
	_current_shot_id = ""
	_current_cue_id = ""
	_base_background_path = ""
	_cue_backgrounds.clear()
	_resolved_background_path = ""
	_active_speaker_id = ""


func get_current_shot_id() -> String:
	return _current_shot_id


func get_current_cue_id() -> String:
	return _current_cue_id


func get_resolved_background_path() -> String:
	return _resolved_background_path


func get_layer_ids() -> Array[String]:
	return _layer_ids.duplicate()


func get_layer_count() -> int:
	return _layer_ids.size()


func get_character_count() -> int:
	var count := 0
	for layer_id: String in _layer_ids:
		var entry: Dictionary = _layer_entries.get(layer_id, {})
		if str(entry.get("type", "")) == "character":
			count += 1
	return count


func get_active_speaker() -> String:
	return _active_speaker_id


func get_layer_opacity(layer_id: String) -> float:
	var node := _layer_nodes.get(layer_id) as TextureRect
	return node.modulate.a if node != null else -1.0


func is_layer_visible(layer_id: String) -> bool:
	var node := _layer_nodes.get(layer_id) as TextureRect
	return node != null and node.visible


func _ensure_interface() -> void:
	if _background != null:
		return
	_background = TextureRect.new()
	_background.name = "Background"
	_background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_background)

	_layers_root = Control.new()
	_layers_root.name = "Layers"
	_layers_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_layers_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_layers_root)


func _clear_layers() -> void:
	_kill_transient_hero_tween()
	for child: Node in _layers_root.get_children():
		_layers_root.remove_child(child)
		child.queue_free()
	_layer_nodes.clear()
	_layer_entries.clear()
	_layer_ids.clear()


func _kill_transient_hero_tween() -> void:
	if _transient_hero_tween != null and _transient_hero_tween.is_valid():
		_transient_hero_tween.kill()
	_transient_hero_tween = null


func _add_layer(entry: Dictionary, texture: Texture2D) -> void:
	var layer_id := str(entry.get("id", ""))
	var layer_type := str(entry.get("type", ""))
	var texture_rect := TextureRect.new()
	texture_rect.name = layer_id
	texture_rect.texture = texture
	texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_rect.z_index = int(LAYER_Z.get(layer_type, 0))
	texture_rect.modulate.a = clampf(float(entry.get("opacity", 1.0)), 0.0, 1.0)
	texture_rect.flip_h = bool(entry.get("mirror", false))

	var layout := str(entry.get("layout", "sprite" if layer_type == "character" else "full_frame"))
	if layout == "sprite":
		_apply_sprite_layout(texture_rect, entry)
	else:
		texture_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		texture_rect.stretch_mode = (
			TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			if str(entry.get("fit", "cover")) == "contain"
			else TextureRect.STRETCH_KEEP_ASPECT_COVERED
		)

	_layers_root.add_child(texture_rect)
	_layer_nodes[layer_id] = texture_rect
	_layer_entries[layer_id] = entry.duplicate(true)
	_layer_ids.append(layer_id)
	texture_rect.visible = _is_layer_visible_for_cue(entry, _current_cue_id)


func _apply_sprite_layout(texture_rect: TextureRect, entry: Dictionary) -> void:
	var slot := str(entry.get("slot", "center"))
	var anchor_x := float(SLOT_ANCHOR_X.get(slot, 0.5))
	var anchor_values: Variant = entry.get("anchor", [])
	if anchor_values is Array and anchor_values.size() == 2:
		anchor_x = clampf(float(anchor_values[0]), 0.0, 1.0)
	var anchor_y := 1.0
	if anchor_values is Array and anchor_values.size() == 2:
		anchor_y = clampf(float(anchor_values[1]), 0.0, 1.0)
	var width_ratio := clampf(float(entry.get("width_ratio", 0.44)), 0.1, 1.0)
	var height_ratio := clampf(float(entry.get("height_ratio", 0.90)), 0.1, 1.0)
	texture_rect.anchor_left = clampf(anchor_x - width_ratio * 0.5, 0.0, 1.0)
	texture_rect.anchor_right = clampf(anchor_x + width_ratio * 0.5, 0.0, 1.0)
	texture_rect.anchor_top = clampf(anchor_y - height_ratio, 0.0, 1.0)
	texture_rect.anchor_bottom = anchor_y
	texture_rect.offset_left = 0.0
	texture_rect.offset_top = 0.0
	texture_rect.offset_right = 0.0
	texture_rect.offset_bottom = 0.0
	var offset_values: Variant = entry.get("offset", [])
	if offset_values is Array and offset_values.size() == 2:
		var offset := Vector2(float(offset_values[0]), float(offset_values[1]))
		texture_rect.offset_left += offset.x
		texture_rect.offset_right += offset.x
		texture_rect.offset_top += offset.y
		texture_rect.offset_bottom += offset.y
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED


func _apply_speaker_emphasis() -> void:
	var has_matching_character := false
	if not _active_speaker_id.is_empty():
		for layer_id: String in _layer_ids:
			var entry: Dictionary = _layer_entries.get(layer_id, {})
			if str(entry.get("type", "")) == "character" and _matches_speaker(entry, _active_speaker_id):
				has_matching_character = true
				break

	for layer_id: String in _layer_ids:
		var entry: Dictionary = _layer_entries.get(layer_id, {})
		if str(entry.get("type", "")) != "character":
			continue
		var node := _layer_nodes.get(layer_id) as TextureRect
		if node == null:
			continue
		var base_opacity := clampf(float(entry.get("opacity", 1.0)), 0.0, 1.0)
		var is_active := has_matching_character and _matches_speaker(entry, _active_speaker_id)
		var inactive_opacity := clampf(float(entry.get("inactive_opacity", 0.68)), 0.0, 1.0)
		node.modulate.a = base_opacity if not has_matching_character or is_active else base_opacity * inactive_opacity
		node.z_index = int(LAYER_Z["character"])


func _apply_cue_visibility() -> void:
	for layer_id: String in _layer_ids:
		if layer_id == TRANSIENT_HERO_LAYER_ID:
			continue
		var node := _layer_nodes.get(layer_id) as TextureRect
		var entry: Dictionary = _layer_entries.get(layer_id, {})
		if node != null:
			node.visible = _is_layer_visible_for_cue(entry, _current_cue_id)


func _apply_cue_background() -> void:
	var selected_path := _base_background_path
	if _cue_backgrounds.has(_current_cue_id):
		selected_path = str(_cue_backgrounds.get(_current_cue_id, _base_background_path))
	var selected_texture := _load_texture(selected_path)
	if selected_texture == null and selected_path != _base_background_path:
		selected_path = _base_background_path
		selected_texture = _load_texture(selected_path)
	_background.texture = selected_texture
	_resolved_background_path = selected_path if selected_texture != null else ""


func _is_layer_visible_for_cue(entry: Dictionary, cue_id: String) -> bool:
	var show_on_shots := _string_array(entry.get("show_on_shots", []))
	var hide_on_shots := _string_array(entry.get("hide_on_shots", []))
	if not show_on_shots.is_empty() and cue_id not in show_on_shots:
		return false
	return cue_id not in hide_on_shots


func _string_array(value: Variant) -> Array[String]:
	var result: Array[String] = []
	if not value is Array:
		return result
	for item: Variant in value:
		var text := str(item)
		if not text.is_empty() and text not in result:
			result.append(text)
	return result


func _normalized_cue_backgrounds(value: Variant) -> Dictionary:
	var result: Dictionary = {}
	if not value is Dictionary:
		return result
	for cue_variant: Variant in (value as Dictionary).keys():
		var cue_id := str(cue_variant)
		if cue_id.is_empty():
			continue
		var background_path := _background_variant_path((value as Dictionary).get(cue_variant))
		if not background_path.is_empty():
			result[cue_id] = background_path
	return result


func _background_variant_path(value: Variant) -> String:
	if value is Dictionary:
		for key: String in ["resolved_asset", "asset", "fallback"]:
			var candidate := str((value as Dictionary).get(key, ""))
			if not candidate.is_empty() and ResourceLoader.exists(candidate):
				return candidate
		return ""
	var candidate := str(value)
	return candidate if not candidate.is_empty() and ResourceLoader.exists(candidate) else ""


func _matches_speaker(entry: Dictionary, speaker_id: String) -> bool:
	if str(entry.get("character_id", "")) == speaker_id:
		return true
	var speaker_ids: Variant = entry.get("speaker_ids", [])
	return speaker_ids is Array and speaker_ids.has(speaker_id)


func _background_path(shot: Dictionary, background_override: String) -> String:
	if not background_override.is_empty() and ResourceLoader.exists(background_override):
		return background_override
	var resolved := str(shot.get("resolved_background", ""))
	if not resolved.is_empty() and ResourceLoader.exists(resolved):
		return resolved
	var background: Variant = shot.get("background", "")
	if background is Dictionary:
		for key: String in ["resolved_asset", "asset", "fallback"]:
			var candidate := str((background as Dictionary).get(key, ""))
			if not candidate.is_empty() and ResourceLoader.exists(candidate):
				return candidate
	elif not str(background).is_empty() and ResourceLoader.exists(str(background)):
		return str(background)
	var fallback := str(shot.get("fallback", ""))
	return fallback if not fallback.is_empty() and ResourceLoader.exists(fallback) else ""


func _layer_texture_path(entry: Dictionary) -> String:
	for key: String in ["resolved_asset", "asset", "fallback"]:
		var candidate := str(entry.get(key, ""))
		if not candidate.is_empty() and ResourceLoader.exists(candidate):
			return candidate
	return ""


func _load_texture(path: String) -> Texture2D:
	if path.is_empty() or not ResourceLoader.exists(path):
		return null
	return load(path) as Texture2D
