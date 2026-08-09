class_name FormationVisualDirector
extends Node2D

signal formation_built(snapshot: Dictionary)
signal formation_cleared

const SWORDS_PER_SQUAD := 9
const FULL_SQUAD_COUNT := 12
const FULL_SWORD_COUNT := SWORDS_PER_SQUAD * FULL_SQUAD_COUNT

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
	Vector2(-650.0, -250.0),
	Vector2(-390.0, -260.0),
	Vector2(-130.0, -280.0),
	Vector2(130.0, -280.0),
	Vector2(390.0, -260.0),
	Vector2(650.0, -250.0),
	Vector2(-650.0, 250.0),
	Vector2(-390.0, 260.0),
	Vector2(-130.0, 280.0),
	Vector2(130.0, 280.0),
	Vector2(390.0, 260.0),
	Vector2(650.0, 250.0),
]

const CAPTURE_SQUAD_CENTERS: Array[Vector2] = [
	Vector2(-570.0, -220.0), Vector2(-280.0, -250.0),
	Vector2(280.0, -250.0), Vector2(570.0, -220.0),
	Vector2(-670.0, 0.0), Vector2(-440.0, 70.0),
	Vector2(440.0, 70.0), Vector2(670.0, 0.0),
	Vector2(-330.0, 245.0), Vector2(0.0, 275.0),
	Vector2(330.0, 245.0), Vector2(0.0, -30.0),
]

const OPEN_PATH_SQUAD_CENTERS: Array[Vector2] = [
	Vector2(-420.0, -285.0), Vector2(-420.0, -170.0),
	Vector2(-420.0, -55.0), Vector2(-420.0, 60.0),
	Vector2(-420.0, 175.0), Vector2(-420.0, 290.0),
	Vector2(420.0, -285.0), Vector2(420.0, -170.0),
	Vector2(420.0, -55.0), Vector2(420.0, 60.0),
	Vector2(420.0, 175.0), Vector2(420.0, 290.0),
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

@export var blade_length := 56.0
@export var blade_width := 4.0

var _squad_nodes: Array[Node2D] = []
var _blade_nodes: Array[Node2D] = []
var _slot_records: Array[Dictionary] = []
var _slot_keys: Dictionary = {}
var _duplicate_slot_count := 0
var _profile := "default"


class BladeVisual:
	extends Node2D

	var _blade_length := 56.0
	var _blade_width := 4.0
	var _blade_color := Color("8f8a82")
	var _ink_color := Color("24211f")


	func configure(length: float, width: float, shade: float) -> void:
		_blade_length = length
		_blade_width = width
		_blade_color = Color(shade, shade, shade * 0.96, 1.0)
		queue_redraw()


	func _draw() -> void:
		var half_width := _blade_width * 0.5
		var point := -_blade_length * 0.58
		var shoulder := -_blade_length * 0.42
		var heel := _blade_length * 0.30
		var blade_points := PackedVector2Array(
			[
				Vector2(0.0, point),
				Vector2(half_width, shoulder),
				Vector2(half_width, heel),
				Vector2(-half_width, heel),
				Vector2(-half_width, shoulder),
			]
		)
		draw_colored_polygon(blade_points, Color(_blade_color, 0.22))
		draw_polyline(blade_points, Color(_ink_color, 0.62), 1.2, true)
		draw_line(
			Vector2(0.0, shoulder + 3.0),
			Vector2(0.0, heel - 3.0),
			Color(_blade_color, 0.36),
			0.7,
			true
		)
		draw_line(
			Vector2(-_blade_width * 1.35, heel),
			Vector2(_blade_width * 1.35, heel),
			Color(_ink_color, 0.54),
			1.4
		)
		draw_line(
			Vector2(0.0, heel),
			Vector2(0.0, _blade_length * 0.54),
			Color(_ink_color, 0.48),
			1.6
		)


func set_profile(profile: String) -> void:
	_profile = profile if not profile.is_empty() else "default"


func get_profile() -> String:
	return _profile


func build_formation(squad_count: int = FULL_SQUAD_COUNT, role_overrides: Array = []) -> Dictionary:
	if squad_count < 1 or squad_count > FULL_SQUAD_COUNT:
		return {
			"ok": false,
			"code": "INVALID_SQUAD_COUNT",
			"message": "Squad count must be between 1 and 12.",
		}

	clear_formation()
	for squad_index in range(squad_count):
		var role := _role_for_squad(squad_index, role_overrides)
		var squad := Node2D.new()
		squad.name = "Squad_%02d_%s" % [squad_index + 1, role]
		squad.position = _center_for_squad(squad_count, squad_index)
		squad.rotation = deg_to_rad(float((squad_index % 3) - 1) * 4.0)
		squad.set_meta("formation_squad", true)
		squad.set_meta("squad_index", squad_index)
		squad.set_meta("role", role)
		add_child(squad)
		_squad_nodes.append(squad)

		for slot_index in range(SWORDS_PER_SQUAD):
			_add_blade(squad, squad_index, slot_index, role)

	var snapshot := get_formation_snapshot()
	formation_built.emit(snapshot)
	return {"ok": true, "snapshot": snapshot}


func clear_formation() -> void:
	for squad in _squad_nodes:
		if not is_instance_valid(squad):
			continue
		if squad.get_parent() == self:
			remove_child(squad)
		squad.free()
	_squad_nodes.clear()
	_blade_nodes.clear()
	_slot_records.clear()
	_slot_keys.clear()
	_duplicate_slot_count = 0
	formation_cleared.emit()


func get_sword_count() -> int:
	return _slot_records.size()


func get_visible_sword_count() -> int:
	var count := 0
	for blade in _blade_nodes:
		if is_instance_valid(blade) and blade.visible:
			count += 1
	return count


func set_reveal_squad_count(count: int, animate: bool = true) -> void:
	set_reveal_blade_count(clampi(count, 0, _squad_nodes.size()) * SWORDS_PER_SQUAD, animate)


func set_reveal_blade_count(count: int, animate: bool = true) -> void:
	var visible_count := clampi(count, 0, _blade_nodes.size())
	for index in range(_blade_nodes.size()):
		var blade := _blade_nodes[index]
		var should_show := index < visible_count
		if should_show and not blade.visible:
			blade.visible = true
			if animate:
				blade.modulate = Color(1, 1, 1, 0)
				blade.scale = Vector2.ONE * 0.62
				var tween := create_tween().set_parallel(true)
				tween.tween_property(blade, "modulate", Color(1, 1, 1, 0.82), 0.20)
				tween.tween_property(blade, "scale", Vector2.ONE, 0.24).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
		elif not should_show:
			blade.visible = false


func pulse_visible_blades() -> void:
	for blade in _blade_nodes:
		if not is_instance_valid(blade) or not blade.visible:
			continue
		var tween := create_tween()
		tween.tween_property(blade, "modulate", Color(0.78, 0.72, 0.66, 0.64), 0.08)
		tween.tween_property(blade, "modulate", Color(1, 1, 1, 0.82), 0.18)


func get_squad_count() -> int:
	return _squad_nodes.size()


func get_duplicate_slot_count() -> int:
	return _duplicate_slot_count


func get_slot_records() -> Array[Dictionary]:
	return _slot_records.duplicate(true)


func get_squad_roles() -> Array[StringName]:
	var roles: Array[StringName] = []
	for squad in _squad_nodes:
		roles.append(StringName(squad.get_meta("role", &"")))
	return roles


func get_squad_centers() -> Array[Vector2]:
	var centers: Array[Vector2] = []
	for squad in _squad_nodes:
		centers.append(squad.position)
	return centers


func get_squad_instance_counts() -> Array[int]:
	var counts: Array[int] = []
	for squad in _squad_nodes:
		var count := 0
		for child in squad.get_children():
			if bool(child.get_meta("formation_blade", false)):
				count += 1
		counts.append(count)
	return counts


func get_formation_snapshot() -> Dictionary:
	return {
		"squad_count": get_squad_count(),
		"swords_per_squad": SWORDS_PER_SQUAD,
		"sword_count": get_sword_count(),
		"duplicate_slot_count": get_duplicate_slot_count(),
		"profile": _profile,
		"squad_roles": get_squad_roles(),
		"squad_centers": get_squad_centers(),
		"squad_instance_counts": get_squad_instance_counts(),
		"slots": get_slot_records(),
		"authored_only": true,
		"uses_randomness": false,
		"uses_physics_resolution": false,
	}


func _add_blade(
	squad: Node2D,
	squad_index: int,
	slot_index: int,
	role: StringName
) -> void:
	var slot_key := "%02d:%02d" % [squad_index, slot_index]
	if _slot_keys.has(slot_key):
		_duplicate_slot_count += 1
	else:
		_slot_keys[slot_key] = true

	var local_transform := _authored_slot_transform(squad_index, slot_index)
	var blade := BladeVisual.new()
	blade.name = "Sword_%03d" % (squad_index * SWORDS_PER_SQUAD + slot_index + 1)
	blade.transform = local_transform
	blade.z_index = slot_index
	blade.set_meta("formation_blade", true)
	blade.set_meta("slot_key", slot_key)
	blade.set_meta("slot_id", squad_index * SWORDS_PER_SQUAD + slot_index + 1)
	blade.set_meta("squad_index", squad_index)
	blade.set_meta("slot_index", slot_index)
	blade.set_meta("role", role)
	blade.configure(blade_length, blade_width, 0.52 + float(squad_index % 4) * 0.025)
	squad.add_child(blade)
	_blade_nodes.append(blade)

	_slot_records.append(
		{
			"slot_key": slot_key,
			"slot_id": squad_index * SWORDS_PER_SQUAD + slot_index + 1,
			"squad_index": squad_index,
			"slot_index": slot_index,
			"role": role,
			"position": squad.transform * local_transform.origin,
			"rotation": squad.rotation + local_transform.get_rotation(),
		}
	)


func _center_for_squad(squad_count: int, squad_index: int) -> Vector2:
	if squad_count == 1:
		return Vector2.ZERO
	if _profile == "canyon_capture":
		return CAPTURE_SQUAD_CENTERS[squad_index]
	if _profile == "canyon_open_path":
		return OPEN_PATH_SQUAD_CENTERS[squad_index]
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
