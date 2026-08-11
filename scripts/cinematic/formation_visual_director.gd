class_name FormationVisualDirector
extends Node2D

signal formation_built(snapshot: Dictionary)
signal formation_cleared

const SWORDS_PER_SQUAD := 9
const FULL_SQUAD_COUNT := 12
const FULL_SWORD_COUNT := SWORDS_PER_SQUAD * FULL_SQUAD_COUNT
const TRAIL_POOL_SIZE := FULL_SQUAD_COUNT
const LOCAL_EFFECT_POOL_SIZE := 2

const PHASE_IDLE := &"idle"
const PHASE_ANTICIPATION := &"anticipation"
const PHASE_CURVED_FLIGHT := &"curved_flight"
const PHASE_ACCELERATION := &"acceleration"
const PHASE_IMPACT := &"impact"
const PHASE_AFTERMATH := &"aftermath"
const MOTION_PHASES: Array[StringName] = [
	PHASE_ANTICIPATION,
	PHASE_CURVED_FLIGHT,
	PHASE_ACCELERATION,
	PHASE_IMPACT,
	PHASE_AFTERMATH,
]

const PHASE_DURATIONS := {
	PHASE_ANTICIPATION: 0.42,
	PHASE_CURVED_FLIGHT: 0.82,
	PHASE_ACCELERATION: 0.38,
	PHASE_IMPACT: 0.20,
	PHASE_AFTERMATH: 0.56,
}

const SQUAD_ROLES: Array[StringName] = [
	&"silent_precision",
	&"projectile_intercept",
	&"space_lock",
	&"bulwark",
	&"passage",
	&"formation_break",
	&"pursuit",
	&"capture",
	&"vertical_control",
	&"redirect",
	&"route_lock",
	&"reserve",
]

const FULL_SQUAD_CENTERS: Array[Vector2] = [
	Vector2(-650.0, -250.0), Vector2(-390.0, -260.0),
	Vector2(-130.0, -280.0), Vector2(130.0, -280.0),
	Vector2(390.0, -260.0), Vector2(650.0, -250.0),
	Vector2(-650.0, 250.0), Vector2(-390.0, 260.0),
	Vector2(-130.0, 280.0), Vector2(130.0, 280.0),
	Vector2(390.0, 260.0), Vector2(650.0, 250.0),
]

const CAPTURE_SQUAD_CENTERS: Array[Vector2] = [
	Vector2(-260.0, -240.0), Vector2(-40.0, -240.0),
	Vector2(180.0, -240.0), Vector2(400.0, -240.0),
	Vector2(-260.0, 0.0), Vector2(-40.0, 0.0),
	Vector2(180.0, 0.0), Vector2(400.0, 0.0),
	Vector2(-260.0, 240.0), Vector2(-40.0, 240.0),
	Vector2(180.0, 240.0), Vector2(400.0, 240.0),
]

const OPEN_PATH_SQUAD_CENTERS: Array[Vector2] = [
	Vector2(-420.0, -285.0), Vector2(-420.0, -170.0),
	Vector2(-420.0, -55.0), Vector2(-420.0, 60.0),
	Vector2(-420.0, 175.0), Vector2(-420.0, 290.0),
	Vector2(420.0, -285.0), Vector2(420.0, -170.0),
	Vector2(420.0, -55.0), Vector2(420.0, 60.0),
	Vector2(420.0, 175.0), Vector2(420.0, 290.0),
]

const NORTH_GATE_LOCK_SQUAD_CENTERS: Array[Vector2] = [
	Vector2(-260.0, -210.0), Vector2(-260.0, 0.0), Vector2(-260.0, 210.0),
	Vector2(260.0, -210.0), Vector2(260.0, 0.0), Vector2(260.0, 210.0),
	Vector2(-180.0, -320.0), Vector2(0.0, -320.0), Vector2(180.0, -320.0),
	Vector2(-180.0, 320.0), Vector2(0.0, 320.0), Vector2(180.0, 320.0),
]

const INN_NINE_SLOTS: Array[Vector2] = [
	Vector2(-650.0, -165.0),
	Vector2(-405.0, -35.0),
	Vector2(-155.0, -155.0),
	Vector2(-270.0, 175.0),
	Vector2(-35.0, 185.0),
	Vector2(205.0, -70.0),
	Vector2(420.0, 5.0),
	Vector2(610.0, -115.0),
	Vector2(665.0, 225.0),
]

@export var blade_length := 96.0
@export var blade_width := 24.0

var _body_batch: MultiMeshInstance2D
var _multimesh: MultiMesh
var _trail_texture: ImageTexture
var _trail_nodes: Array[Line2D] = []
var _effect_nodes: Array[LocalImpactVisual] = []
var _effect_cursor := 0
var _last_effect_peak_alpha := 0.0

var _slot_records: Array[Dictionary] = []
var _slot_keys: Dictionary = {}
var _target_transforms: Array[Transform2D] = []
var _rendered_transforms: Array[Transform2D] = []
var _local_transforms: Array[Transform2D] = []
var _slot_squad_indexes: Array[int] = []
var _squad_centers: Array[Vector2] = []
var _squad_rotations: Array[float] = []
var _squad_paths: Array[Dictionary] = []
var _squad_roles: Array[StringName] = []
var _duplicate_slot_count := 0
var _squad_count := 0
var _visible_blade_count := 0

var _profile := "default"
var _path_variant := "default"
var _phase: StringName = PHASE_IDLE
var _phase_elapsed := 0.0
var _phase_duration := 0.0
var _phase_progress := 0.0
var _motion_paused := false
var _motion_reduction := false
var _flash_reduction := false
var _trail_intensity := 1.0
var _phase_history: Array[StringName] = []


class LocalImpactVisual:
	extends Node2D

	var _tween: Tween
	var _peak_alpha := 0.0
	var _blood_accent := false


	func burst(origin: Vector2, blood_accent: bool, reduced_flash: bool) -> void:
		if _tween != null and _tween.is_valid():
			_tween.kill()
		position = origin
		_blood_accent = blood_accent
		_peak_alpha = 0.18 if reduced_flash else 0.82
		modulate = Color(1.0, 1.0, 1.0, _peak_alpha)
		scale = Vector2.ONE * 0.86
		visible = true
		queue_redraw()
		_tween = create_tween().set_parallel(true)
		_tween.tween_property(self, "scale", Vector2.ONE * 1.42, 0.28).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
		_tween.tween_property(self, "modulate:a", 0.0, 0.34)
		_tween.chain().tween_callback(func() -> void: visible = false)


	func reset() -> void:
		if _tween != null and _tween.is_valid():
			_tween.kill()
		visible = false
		_peak_alpha = 0.0


	func get_peak_alpha() -> float:
		return _peak_alpha


	func _draw() -> void:
		var ink := Color("24201d")
		var accent := Color("78251f") if _blood_accent else Color("ddd2bf")
		# A dry-ink cut with one restrained steel core reads as contact, not glow.
		draw_line(Vector2(-105, 36), Vector2(105, -36), ink, 8.0, true)
		draw_line(Vector2(-96, 33), Vector2(96, -33), accent, 3.2, true)
		draw_line(Vector2(-9, -52), Vector2(9, 49), Color(ink, 0.82), 5.0, true)
		draw_line(Vector2(-7, -46), Vector2(7, 43), Color(accent, 0.64), 2.0, true)
		draw_arc(Vector2.ZERO, 42.0, -2.7, 0.45, 18, Color(ink, 0.80), 3.8, true)
		draw_arc(Vector2.ZERO, 38.0, -2.62, 0.36, 18, Color(accent, 0.70), 1.6, true)
		for index in range(5):
			var angle := -2.48 + float(index) * 0.96
			var start := Vector2.from_angle(angle) * 24.0
			var finish := Vector2.from_angle(angle) * (43.0 + float(index % 3) * 10.0)
			draw_line(start, finish, Color(ink, 0.58), 1.5, true)
		for index in range(3):
			var offset := Vector2(-38.0 + float(index) * 36.0, -28.0 + float(index % 2) * 55.0)
			var debris := PackedVector2Array([
				offset + Vector2(-6, -3),
				offset + Vector2(7, -1),
				offset + Vector2(4, 5),
				offset + Vector2(-4, 4),
			])
			draw_colored_polygon(debris, Color("b0a493"))


func _ready() -> void:
	_ensure_render_nodes()
	set_process(false)


func _process(delta: float) -> void:
	if _motion_paused or _phase_duration <= 0.0:
		return
	_phase_elapsed = minf(_phase_elapsed + delta, _phase_duration)
	_phase_progress = _phase_elapsed / _phase_duration
	_refresh_motion_frame()
	if _phase_progress >= 1.0:
		set_process(false)


func set_profile(profile: String) -> void:
	_profile = profile if not profile.is_empty() else "default"


func get_profile() -> String:
	return _profile


func apply_settings(settings: Dictionary) -> void:
	_motion_reduction = bool(settings.get("motion_reduction", false))
	_flash_reduction = bool(settings.get("flash_reduction", false))
	_trail_intensity = clampf(float(settings.get("blade_trail_intensity", 1.0)), 0.0, 1.0)
	if _motion_reduction:
		set_process(false)
	_update_trail_style()
	_refresh_motion_frame()


func get_settings_snapshot() -> Dictionary:
	return {
		"motion_reduction": _motion_reduction,
		"flash_reduction": _flash_reduction,
		"blade_trail_intensity": _trail_intensity,
	}


func build_formation(squad_count: int = FULL_SQUAD_COUNT, role_overrides: Array = []) -> Dictionary:
	if squad_count < 1 or squad_count > FULL_SQUAD_COUNT:
		return {
			"ok": false,
			"code": "INVALID_SQUAD_COUNT",
			"message": "Squad count must be between 1 and 12.",
		}

	_ensure_render_nodes()
	clear_formation()
	_squad_count = squad_count
	for squad_index in range(squad_count):
		var role := _role_for_squad(squad_index, role_overrides)
		var center := _center_for_squad(squad_count, squad_index)
		var rotation := deg_to_rad(float((squad_index % 3) - 1) * 4.0)
		_squad_roles.append(role)
		_squad_centers.append(center)
		_squad_rotations.append(rotation)

		for slot_index in range(SWORDS_PER_SQUAD):
			_add_blade_record(squad_index, slot_index, role, center, rotation)

	_rebuild_paths()
	_build_body_batch()
	_phase = PHASE_IDLE
	_phase_progress = 0.0
	_visible_blade_count = 0
	_refresh_motion_frame()
	var snapshot := get_formation_snapshot()
	formation_built.emit(snapshot)
	return {"ok": true, "snapshot": snapshot}


func clear_formation() -> void:
	set_process(false)
	_phase = PHASE_IDLE
	_phase_elapsed = 0.0
	_phase_duration = 0.0
	_phase_progress = 0.0
	_phase_history.clear()
	_path_variant = "default"
	_motion_paused = false
	_squad_count = 0
	_visible_blade_count = 0
	_slot_records.clear()
	_slot_keys.clear()
	_target_transforms.clear()
	_rendered_transforms.clear()
	_local_transforms.clear()
	_slot_squad_indexes.clear()
	_squad_centers.clear()
	_squad_rotations.clear()
	_squad_paths.clear()
	_squad_roles.clear()
	_duplicate_slot_count = 0
	_effect_cursor = 0
	_last_effect_peak_alpha = 0.0
	_multimesh = null
	if _body_batch != null:
		_body_batch.multimesh = null
		_body_batch.visible = false
	for trail in _trail_nodes:
		trail.clear_points()
		trail.visible = false
	for effect in _effect_nodes:
		effect.reset()
	formation_cleared.emit()


func play_motion_phase(phase_value: Variant, cue: Dictionary = {}) -> bool:
	var normalized := _normalize_phase(StringName(str(phase_value)))
	if not MOTION_PHASES.has(normalized) or _multimesh == null:
		return false
	var requested_variant := str(cue.get("path_variant", _path_variant))
	if not requested_variant.is_empty() and requested_variant != _path_variant:
		_path_variant = requested_variant
		_rebuild_paths()
	if cue.has("visible_blades"):
		set_reveal_blade_count(int(cue.get("visible_blades", 0)), false)
	elif _visible_blade_count == 0:
		set_reveal_blade_count(get_sword_count(), false)

	_phase = normalized
	_phase_elapsed = 0.0
	_phase_duration = maxf(
		float(cue.get("duration_sec", PHASE_DURATIONS.get(normalized, 0.0))),
		0.0
	)
	_phase_progress = 1.0 if _motion_reduction or _phase_duration <= 0.0 else 0.0
	_phase_history.append(_phase)
	if _phase == PHASE_IMPACT:
		trigger_local_impact(cue)
	_refresh_motion_frame()
	set_process(not _motion_reduction and _phase_duration > 0.0)
	return true


func set_motion_paused(value: bool) -> void:
	_motion_paused = value


func trigger_local_impact(cue: Dictionary = {}) -> void:
	if _effect_nodes.is_empty() or _squad_centers.is_empty():
		return
	var default_squad_index: int = (int(_squad_count / 2.0) + _effect_cursor * 3) % _squad_count
	var squad_index := clampi(int(cue.get("squad_index", default_squad_index)), 0, _squad_centers.size() - 1)
	var origin := _squad_centers[squad_index]
	if squad_index < _squad_paths.size():
		origin = _quadratic_path(_squad_paths[squad_index], _path_progress_for_phase())
	if cue.has("position") and cue["position"] is Vector2:
		origin = cue["position"]
	var cue_id := str(cue.get("id", cue.get("cue_id", ""))).to_upper()
	var blood_accent := "BLOOD" in cue_id or "CUT" in cue_id
	var effect := _effect_nodes[_effect_cursor % _effect_nodes.size()]
	_effect_cursor += 1
	effect.burst(origin, blood_accent, _flash_reduction)
	_last_effect_peak_alpha = effect.get_peak_alpha()


func set_reveal_squad_count(count: int, animate: bool = true) -> void:
	set_reveal_blade_count(clampi(count, 0, _squad_count) * SWORDS_PER_SQUAD, animate)


func set_reveal_blade_count(count: int, animate: bool = true) -> void:
	_visible_blade_count = clampi(count, 0, get_sword_count())
	if _body_batch == null or _multimesh == null:
		return
	_body_batch.visible = _visible_blade_count > 0
	for index in range(get_sword_count()):
		_apply_instance_color(index)
	if animate and _visible_blade_count > 0 and not _motion_reduction:
		_body_batch.modulate = Color(1, 1, 1, 0.18)
		create_tween().tween_property(_body_batch, "modulate", Color.WHITE, 0.20)
	else:
		_body_batch.modulate = Color.WHITE
	_update_trails(_path_progress_for_phase())


func pulse_visible_blades() -> void:
	if _body_batch == null or not _body_batch.visible:
		return
	if _motion_reduction:
		_body_batch.modulate = Color.WHITE
		return
	var tween := create_tween()
	tween.tween_property(_body_batch, "modulate", Color(0.82, 0.75, 0.68, 0.82), 0.08)
	tween.tween_property(_body_batch, "modulate", Color.WHITE, 0.18)


func get_sword_count() -> int:
	return _slot_records.size()


func get_visible_sword_count() -> int:
	return _visible_blade_count if _body_batch != null and _body_batch.visible else 0


func get_squad_count() -> int:
	return _squad_count


func get_duplicate_slot_count() -> int:
	return _duplicate_slot_count


func get_slot_records() -> Array[Dictionary]:
	return _slot_records.duplicate(true)


func get_squad_roles() -> Array[StringName]:
	return _squad_roles.duplicate()


func get_squad_centers() -> Array[Vector2]:
	return _squad_centers.duplicate()


func get_squad_instance_counts() -> Array[int]:
	var counts: Array[int] = []
	for _squad_index in range(_squad_count):
		counts.append(SWORDS_PER_SQUAD)
	return counts


func get_formation_snapshot() -> Dictionary:
	return {
		"squad_count": get_squad_count(),
		"swords_per_squad": SWORDS_PER_SQUAD,
		"sword_count": get_sword_count(),
		"visible_sword_count": get_visible_sword_count(),
		"duplicate_slot_count": get_duplicate_slot_count(),
		"profile": _profile,
		"path_variant": _path_variant,
		"squad_roles": get_squad_roles(),
		"squad_centers": get_squad_centers(),
		"squad_instance_counts": get_squad_instance_counts(),
		"slots": get_slot_records(),
		"body_renderer": "MultiMeshInstance2D",
		"body_batch_count": get_body_batch_count(),
		"batched_instance_count": get_batched_instance_count(),
		"trail_pool_size": get_trail_pool_size(),
		"authored_only": true,
		"uses_randomness": false,
		"uses_physics_resolution": false,
	}


func get_body_batch_count() -> int:
	return 1 if _body_batch != null and _multimesh != null else 0


func get_batched_instance_count() -> int:
	return _multimesh.instance_count if _multimesh != null else 0


func get_trail_pool_size() -> int:
	return _trail_nodes.size()


func get_active_trail_count() -> int:
	var count := 0
	for trail in _trail_nodes:
		if trail.visible and trail.points.size() > 1:
			count += 1
	return count


func get_active_local_effect_count() -> int:
	var count := 0
	for effect in _effect_nodes:
		if effect.visible:
			count += 1
	return count


func get_peak_local_effect_alpha() -> float:
	return _last_effect_peak_alpha


func get_last_local_effect_position() -> Vector2:
	if _effect_cursor <= 0 or _effect_nodes.is_empty():
		return Vector2.INF
	return _effect_nodes[(_effect_cursor - 1) % _effect_nodes.size()].position


func get_art_vfx_draw_submission_estimate() -> int:
	return get_body_batch_count() + get_active_trail_count() + get_active_local_effect_count()


func get_motion_phase() -> StringName:
	return _phase


func get_motion_phase_progress() -> float:
	return _phase_progress


func get_motion_phase_history() -> Array[StringName]:
	return _phase_history.duplicate()


func is_motion_animating() -> bool:
	return is_processing() and not _motion_paused


func get_rendered_instance_transform(index: int) -> Transform2D:
	if index < 0 or index >= _rendered_transforms.size():
		return Transform2D.IDENTITY
	return _rendered_transforms[index]


func _ensure_render_nodes() -> void:
	if _body_batch == null:
		_body_batch = MultiMeshInstance2D.new()
		_body_batch.name = "SwordBodyBatch"
		_body_batch.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		_body_batch.z_index = 2
		_body_batch.visible = false
		add_child(_body_batch)
	if _trail_texture == null:
		_trail_texture = _create_trail_texture()
	if _trail_nodes.is_empty():
		for index in range(TRAIL_POOL_SIZE):
			var trail := Line2D.new()
			trail.name = "SquadTrail_%02d" % (index + 1)
			trail.width = 12.0
			trail.default_color = Color.WHITE
			trail.texture = _trail_texture
			trail.texture_mode = Line2D.LINE_TEXTURE_STRETCH
			var taper := Curve.new()
			taper.min_value = 0.0
			taper.max_value = 1.0
			taper.add_point(Vector2(0.0, 0.06))
			taper.add_point(Vector2(0.42, 0.34))
			taper.add_point(Vector2(1.0, 1.0))
			trail.width_curve = taper
			trail.joint_mode = Line2D.LINE_JOINT_ROUND
			trail.begin_cap_mode = Line2D.LINE_CAP_ROUND
			trail.end_cap_mode = Line2D.LINE_CAP_ROUND
			trail.antialiased = true
			trail.z_index = 1
			trail.visible = false
			add_child(trail)
			_trail_nodes.append(trail)
	if _effect_nodes.is_empty():
		for index in range(LOCAL_EFFECT_POOL_SIZE):
			var effect := LocalImpactVisual.new()
			effect.name = "LocalImpact_%02d" % (index + 1)
			effect.z_index = 3
			effect.visible = false
			add_child(effect)
			_effect_nodes.append(effect)
	_update_trail_style()


func _build_body_batch() -> void:
	_multimesh = MultiMesh.new()
	_multimesh.transform_format = MultiMesh.TRANSFORM_2D
	_multimesh.use_colors = true
	_multimesh.instance_count = get_sword_count()
	var quad := QuadMesh.new()
	quad.size = Vector2(blade_width, blade_length)
	_multimesh.mesh = quad
	_body_batch.texture = _create_sword_texture()
	_body_batch.multimesh = _multimesh
	_body_batch.visible = false
	_rendered_transforms.assign(_target_transforms)
	for index in range(get_sword_count()):
		_multimesh.set_instance_transform_2d(index, _target_transforms[index])
		_apply_instance_color(index)


func _create_sword_texture() -> ImageTexture:
	var image := Image.create(24, 96, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	var ink := Color("211e1b")
	var steel_dark := Color("6f6a63")
	var steel := Color("a9a196")
	var steel_glint := Color("d0c6b5")
	var grip := Color("75685a")
	for y in range(3, 69):
		var half_width := int(round(lerpf(0.0, 7.0, float(y - 3) / 65.0)))
		var left := 12 - half_width
		var right := 12 + half_width
		for x in range(left, right + 1):
			if x <= left + 1 or x >= right - 1:
				image.set_pixel(x, y, ink)
			elif x == left + 2:
				image.set_pixel(x, y, steel_dark)
			elif x == 11:
				image.set_pixel(x, y, steel_glint)
			else:
				image.set_pixel(x, y, steel)
	for y in range(69, 75):
		for x in range(3, 22):
			image.set_pixel(x, y, ink if y in [69, 74] or x in [3, 21] else grip)
	for y in range(75, 92):
		for x in range(9, 16):
			var is_edge := x in [9, 15]
			var is_wrap := y % 4 == 0
			image.set_pixel(x, y, ink if is_edge else (steel_dark if is_wrap else grip))
	for y in range(92, 96):
		for x in range(7, 18):
			image.set_pixel(x, y, ink if y in [92, 95] or x in [7, 17] else grip)
	return ImageTexture.create_from_image(image)


func _create_trail_texture() -> ImageTexture:
	var image := Image.create(64, 12, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	var ink := Color("655a50")
	var steel := Color("c4baab")
	var glint := Color("e0d5c3")
	for x in range(image.get_width()):
		for y in range(image.get_height()):
			var distance_from_core := absf(float(y) - 5.5)
			var color := ink
			var alpha := 0.88
			if distance_from_core <= 0.55:
				color = glint
				alpha = 0.90
			elif distance_from_core <= 2.6:
				color = steel
				alpha = 0.90
			elif distance_from_core >= 4.5:
				alpha = 0.36
			if ((x * 3 + y * 5) % 23) <= 1 and distance_from_core > 2.6:
				alpha *= 0.18
			elif x % 19 == 0 and distance_from_core <= 2.6:
				alpha *= 0.52
			image.set_pixel(x, y, Color(color, alpha))
	return ImageTexture.create_from_image(image)


func _apply_instance_color(index: int) -> void:
	if _multimesh == null:
		return
	var squad_index := _slot_squad_indexes[index]
	var shade := 0.98 if _squad_count == 1 else 0.84 + float(squad_index % 4) * 0.035
	var alpha := 0.96 if index < _visible_blade_count else 0.0
	_multimesh.set_instance_color(index, Color(shade, shade * 0.98, shade * 0.94, alpha))


func _add_blade_record(
	squad_index: int,
	slot_index: int,
	role: StringName,
	center: Vector2,
	squad_rotation: float
) -> void:
	var slot_key := "%02d:%02d" % [squad_index, slot_index]
	if _slot_keys.has(slot_key):
		_duplicate_slot_count += 1
	else:
		_slot_keys[slot_key] = true

	var local_transform := _authored_slot_transform(squad_index, slot_index)
	var squad_transform := Transform2D(squad_rotation, center)
	var target_transform := squad_transform * local_transform
	var slot_id := squad_index * SWORDS_PER_SQUAD + slot_index + 1
	_local_transforms.append(local_transform)
	_target_transforms.append(target_transform)
	_slot_squad_indexes.append(squad_index)
	_slot_records.append(
		{
			"slot_key": slot_key,
			"slot_id": slot_id,
			"squad_index": squad_index,
			"slot_index": slot_index,
			"role": role,
			"position": target_transform.origin,
			"rotation": target_transform.get_rotation(),
		}
	)


func _rebuild_paths() -> void:
	_squad_paths.clear()
	for squad_index in range(_squad_count):
		_squad_paths.append(_authored_squad_path(squad_index))


func _authored_squad_path(squad_index: int) -> Dictionary:
	var target := _squad_centers[squad_index]
	if _squad_count == 1:
		match _path_variant:
			"pursuit":
				return {"start": Vector2(-760, 230), "control": Vector2(-120, -330), "end": target}
			"guard":
				return {"start": Vector2(0, 410), "control": Vector2(-360, 40), "end": target}
			"seal":
				return {"start": Vector2(720, -250), "control": Vector2(0, 330), "end": target}
			_:
				return {"start": Vector2(-720, 250), "control": Vector2(-80, -310), "end": target}

	var lane := float(squad_index % 6) - 2.5
	var side := -1.0 if squad_index < 6 else 1.0
	var start := Vector2(lane * 38.0, 410.0 + side * 28.0)
	var control := Vector2(target.x * 0.32 + side * 180.0, -80.0 + lane * 34.0)
	if _profile == "canyon_open_path":
		start = Vector2(side * 90.0, 430.0 + lane * 12.0)
		control = Vector2(target.x * 1.16, 20.0 + lane * 52.0)
	elif _profile == "canyon_capture":
		control = Vector2(target.x * 0.44, -250.0 + float(squad_index % 4) * 155.0)
	elif _profile == "north_gate_lock":
		start = Vector2(lane * 44.0, 440.0)
		control = Vector2(target.x * 0.58, -60.0 + side * 120.0)
	return {"start": start, "control": control, "end": target}


func _refresh_motion_frame() -> void:
	if _multimesh == null:
		return
	var path_progress := _path_progress_for_phase()
	for index in range(get_sword_count()):
		var squad_index := _slot_squad_indexes[index]
		var path := _squad_paths[squad_index]
		var center := _quadratic_path(path, path_progress)
		var tangent := _quadratic_tangent(path, path_progress)
		var local_transform := _local_transforms[index]
		var target_transform := _target_transforms[index]
		var spread := lerpf(0.16, 1.0, path_progress)
		var local_offset := local_transform.origin.rotated(_squad_rotations[squad_index]) * spread
		if _phase == PHASE_ANTICIPATION:
			center -= tangent.normalized() * 18.0 * _phase_progress
		elif _phase == PHASE_CURVED_FLIGHT:
			center -= tangent.normalized() * 18.0 * (1.0 - _phase_progress)
		var travel_rotation := tangent.angle() + PI * 0.5
		var rotation_weight := path_progress * path_progress
		var rotation := lerp_angle(travel_rotation, target_transform.get_rotation(), rotation_weight)
		var rendered_transform := Transform2D(rotation, center + local_offset)
		_rendered_transforms[index] = rendered_transform
		_multimesh.set_instance_transform_2d(index, rendered_transform)
	_update_trails(path_progress)


func _path_progress_for_phase() -> float:
	match _phase:
		PHASE_ANTICIPATION:
			return 0.0
		PHASE_CURVED_FLIGHT:
			return lerpf(0.0, 0.68, smoothstep(0.0, 1.0, _phase_progress))
		PHASE_ACCELERATION:
			return lerpf(0.68, 0.96, _phase_progress * _phase_progress)
		PHASE_IMPACT:
			return lerpf(0.96, 1.0, 1.0 - pow(1.0 - _phase_progress, 3.0))
		PHASE_AFTERMATH:
			return 1.0
		_:
			return 1.0


func _update_trails(path_progress: float) -> void:
	var phase_supports_trails := _phase in [PHASE_CURVED_FLIGHT, PHASE_ACCELERATION, PHASE_IMPACT, PHASE_AFTERMATH]
	var aftermath_alpha := 1.0 - _phase_progress if _phase == PHASE_AFTERMATH else 1.0
	for squad_index in range(_trail_nodes.size()):
		var trail := _trail_nodes[squad_index]
		var squad_visible := squad_index < _squad_count and _visible_blade_count > squad_index * SWORDS_PER_SQUAD
		var should_show := phase_supports_trails and squad_visible and _trail_intensity > 0.001 and not _motion_reduction and aftermath_alpha > 0.001
		if not should_show:
			trail.clear_points()
			trail.visible = false
			continue
		var path := _squad_paths[squad_index]
		var points := PackedVector2Array()
		for point_index in range(7):
			var lag := float(6 - point_index) * 0.021
			points.append(_quadratic_path(path, maxf(path_progress - lag, 0.0)))
		trail.points = points
		trail.modulate = Color(1.0, 0.98, 0.94, _trail_intensity * aftermath_alpha * (0.50 if _flash_reduction else 0.94))
		trail.visible = true


func _update_trail_style() -> void:
	for trail in _trail_nodes:
		trail.width = lerpf(2.0, 12.0, _trail_intensity)
		var fade := Gradient.new()
		fade.offsets = PackedFloat32Array([0.0, 0.42, 1.0])
		fade.colors = PackedColorArray([
			Color(1.0, 1.0, 1.0, 0.0),
			Color(1.0, 1.0, 1.0, 0.82),
			Color.WHITE,
		])
		trail.gradient = fade


func _quadratic_path(path: Dictionary, t: float) -> Vector2:
	var start := Vector2(path.get("start", Vector2.ZERO))
	var control := Vector2(path.get("control", Vector2.ZERO))
	var finish := Vector2(path.get("end", Vector2.ZERO))
	var inverse := 1.0 - t
	return inverse * inverse * start + 2.0 * inverse * t * control + t * t * finish


func _quadratic_tangent(path: Dictionary, t: float) -> Vector2:
	var start := Vector2(path.get("start", Vector2.ZERO))
	var control := Vector2(path.get("control", Vector2.ZERO))
	var finish := Vector2(path.get("end", Vector2.ZERO))
	var tangent := 2.0 * (1.0 - t) * (control - start) + 2.0 * t * (finish - control)
	return tangent if tangent.length_squared() > 0.001 else Vector2.UP


func _normalize_phase(value: StringName) -> StringName:
	match String(value).to_lower():
		"flight", "curve", "curved", "curved_flight":
			return PHASE_CURVED_FLIGHT
		"accelerate", "acceleration":
			return PHASE_ACCELERATION
		"lock", "impact":
			return PHASE_IMPACT
		"linger", "aftermath":
			return PHASE_AFTERMATH
		"anticipation":
			return PHASE_ANTICIPATION
	return value


func _center_for_squad(squad_count: int, squad_index: int) -> Vector2:
	if squad_count == 1:
		return Vector2.ZERO
	if _profile == "canyon_capture":
		return CAPTURE_SQUAD_CENTERS[squad_index]
	if _profile == "canyon_open_path":
		return OPEN_PATH_SQUAD_CENTERS[squad_index]
	if _profile == "north_gate_lock":
		return NORTH_GATE_LOCK_SQUAD_CENTERS[squad_index]
	return FULL_SQUAD_CENTERS[squad_index]


func _role_for_squad(squad_index: int, role_overrides: Array) -> StringName:
	if squad_index < role_overrides.size() and not String(role_overrides[squad_index]).is_empty():
		return StringName(role_overrides[squad_index])
	return SQUAD_ROLES[squad_index]


func _authored_slot_transform(squad_index: int, slot_index: int) -> Transform2D:
	if _profile == "inn_nine" and squad_index == 0:
		var position := INN_NINE_SLOTS[slot_index]
		var rotation := deg_to_rad([-90.0, -86.0, -90.0, -92.0, -88.0, -90.0, -90.0, -90.0, 0.0][slot_index])
		return Transform2D(rotation, position)
	match squad_index % 4:
		0:
			return _row_transform(slot_index)
		1:
			return _arc_transform(slot_index)
		2:
			return _grid_transform(slot_index)
		_:
			return _corridor_transform(slot_index)


func _row_transform(slot_index: int) -> Transform2D:
	var position := Vector2(float(slot_index - 4) * 20.0, 0.0)
	var rotation := deg_to_rad(float(slot_index - 4) * 1.5)
	return Transform2D(rotation, position)


func _arc_transform(slot_index: int) -> Transform2D:
	var ratio := float(slot_index) / float(SWORDS_PER_SQUAD - 1)
	var angle := lerpf(-0.8, 0.8, ratio)
	var position := Vector2(sin(angle) * 92.0, (1.0 - cos(angle)) * 42.0 - 20.0)
	return Transform2D(angle * 0.35, position)


func _grid_transform(slot_index: int) -> Transform2D:
	var column := slot_index % 3
	var row: int = slot_index / 3
	var position := Vector2(float(column - 1) * 30.0, float(row - 1) * 34.0)
	var rotation := deg_to_rad(float(column - 1) * 5.0)
	return Transform2D(rotation, position)


func _corridor_transform(slot_index: int) -> Transform2D:
	var position: Vector2
	if slot_index < 5:
		position = Vector2(float(slot_index - 2) * 28.0, -18.0)
	else:
		position = Vector2(float(slot_index - 6) * 28.0, 22.0)
	var rotation := deg_to_rad(-8.0 if slot_index < 5 else 8.0)
	return Transform2D(rotation, position)
