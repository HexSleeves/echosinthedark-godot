class_name PcAction
extends Node2D

signal ui_force_updated

enum {
	NORMAL_MODE,
	AIM_MODE,
}

var ammo: int:
	get:
		return _ammo

var alert_duration: int:
	get:
		return _alert_duration

var alert_coord: Vector2i:
	get:
		return _alert_coord

var enemy_count: int:
	get:
		return _enemy_count

var progress_bar: int:
	get:
		return _progress_bar

var _ammo: int = GameData.MAGAZINE
var _alert_duration: int = 0
var _alert_coord: Vector2i
var _enemy_count: int = GameData.MIN_ENEMY_COUNT
var _progress_bar: int = GameData.MIN_PROGRESS_BAR

var _is_first_turn: bool = true
var _fov_map: Dictionary = Map2D.init_map(PcFov.DEFAULT_FOV_FLAG)
var _shadow_cast_fov_data: ShadowCastFov.FovData = ShadowCastFov.FovData.new(GameData.PC_SIGHT_RANGE)
var _cross_fov_data: CrossFov.FovData = (
	CrossFov
	.FovData
	.new(
		GameData.CROSS_FOV_WIDTH,
		GameData.PC_AIM_RANGE,
		GameData.PC_AIM_RANGE,
		GameData.PC_AIM_RANGE,
		GameData.PC_AIM_RANGE,
	)
)


func render_fov() -> void:
	PcFov.render_fov(NodeHub.ref_DataHub.pc, _fov_map, _cross_fov_data, _shadow_cast_fov_data)


func _on_SignalHub_sprite_created(tagged_sprites: Array) -> void:
	for i: TaggedSprite in tagged_sprites:
		match i.sub_tag:
			SubTag.PC:
				if NodeHub.ref_DataHub.pc != null:
					continue
				NodeHub.ref_DataHub.set_pc(i.sprite)


func _on_SignalHub_turn_started(sprite: Sprite2D) -> void:
	if not sprite.is_in_group(SubTag.PC):
		return

	# Wait 1 frame when the very first turn starts, so that sprites from the
	# previous scene are properly removed.
	if _is_first_turn:
		await get_tree().create_timer(0).timeout
		_is_first_turn = false

	GameProgress.update_world(NodeHub.ref_DataHub, NodeHub.ref_RandomNumber)

	render_fov()

	_alert_duration = max(0, _alert_duration - 1)
	# print("%d, %d" % [enemy_count, progress_bar])


func _on_SignalHub_action_pressed(input_tag: StringName) -> void:
	var coord: Vector2i
	var pc: Sprite2D = NodeHub.ref_DataHub.pc
	var game_mode: int = NodeHub.ref_DataHub.game_mode

	match input_tag:
		InputTag.ADD_AMMO:
			_ammo = _get_valid_ammo(_ammo + 1)
			ui_force_updated.emit()
			return
		InputTag.ADD_HIT:
			_add_enemy_count()
			ui_force_updated.emit()
			return
		InputTag.AIM:
			NodeHub.ref_DataHub.set_game_mode(_aim(pc, _ammo, game_mode))
			render_fov()
			return
		InputTag.MOVE_LEFT:
			coord = Vector2i.LEFT
		InputTag.MOVE_RIGHT:
			coord = Vector2i.RIGHT
		InputTag.MOVE_UP:
			coord = Vector2i.UP
		InputTag.MOVE_DOWN:
			coord = Vector2i.DOWN
		_:
			return

	coord += ConvertCoord.get_coord(pc)
	match game_mode:
		AIM_MODE:
			game_mode = _aim(pc, _ammo, game_mode)
			_ammo = _shoot(pc, coord, _ammo)
			if game_mode == NORMAL_MODE:
				_alert_hound(pc)
				_end_turn()
			return
		NORMAL_MODE:
			if not DungeonSize.is_in_dungeon(coord):
				return
			elif SpriteState.has_building_at_coord(coord):
				return
			# If there is a trap under an actor, interact with the actor rather
			# than the trap.
			elif SpriteState.has_actor_at_coord(coord):
				_kick_back(pc, coord)
				_end_turn()
				return
			elif SpriteState.has_trap_at_coord(coord):
				_ammo = _pick_ammo(pc, coord, _ammo)
				# print(ammo)
				_end_turn()
				return
			_move(coord)
			_end_turn()
			return


func _on_SignalHub_game_over(player_win: bool) -> void:
	render_fov()
	if not player_win:
		VisualEffect.set_dark_color(NodeHub.ref_DataHub.pc)

# func _handle_normal_input(input_tag: StringName) -> bool:
# 	match input_tag:
# 		InputTag.MOVE_LEFT:
# 			_move(Vector2i.LEFT)
# 		InputTag.MOVE_RIGHT:
# 			_move(Vector2i.RIGHT)
# 		InputTag.MOVE_UP:
# 			_move(Vector2i.UP)
# 		InputTag.MOVE_DOWN:
# 			_move(Vector2i.DOWN)
# 		_:
# 			return true
# 	return true

# func _handle_aim_input(input_tag: StringName) -> bool:
# 	return true

func _pick_ammo(pc: Sprite2D, coord: Vector2i, current_ammo: int) -> int:
	SpriteFactory.remove_sprite(SpriteState.get_trap_by_coord(coord))
	SpriteState.move_sprite(pc, coord)
	return _get_valid_ammo(current_ammo + GameData.MAGAZINE)


func _get_valid_ammo(current_ammo: int) -> int:
	return max(min(current_ammo, GameData.MAX_AMMO), GameData.MIN_AMMO)


func _aim(pc: Sprite2D, current_ammo: int, current_mode: int) -> int:
	match current_mode:
		AIM_MODE:
			VisualEffect.switch_sprite(pc, VisualTag.DEFAULT)
			return NORMAL_MODE
		NORMAL_MODE:
			if current_ammo > GameData.MIN_AMMO:
				VisualEffect.switch_sprite(pc, VisualTag.ACTIVE)
				return AIM_MODE
	return NORMAL_MODE


func _shoot(pc: Sprite2D, coord: Vector2i, current_ammo: int) -> int:
	var coords: Array
	var target_coord: Vector2i
	var actor: Sprite2D

	coords = CastRay.get_coords(ConvertCoord.get_coord(pc), coord, _block_shoot_ray, [])
	coords = CastRay.trim_coords(coords, true, true)

	if not coords.is_empty():
		target_coord = coords.back()
		actor = SpriteState.get_actor_by_coord(target_coord)
		if actor != null:
			_kill_hound(actor, target_coord)
	return _get_valid_ammo(current_ammo - 1)


func _kick_back(pc: Sprite2D, coord: Vector2i) -> void:
	var coords: Array
	var target_coord: Vector2i
	var actor: Sprite2D = SpriteState.get_actor_by_coord(coord)
	var new_trap_coord: Vector2i

	coords = CastRay.get_coords(ConvertCoord.get_coord(pc), coord, _block_hit_back_ray, [])
	coords = CastRay.trim_coords(coords, true, false)
	target_coord = coords.back()

	# If the last grid is impassable, create a trap in the second last grid. The
	# hound is killed there by game design.
	if _is_impassable(target_coord):
		new_trap_coord = coords[-2]
		_kill_hound(actor, new_trap_coord)
	else:
		SpriteState.move_sprite(actor, target_coord)
		NodeHub.ref_ActorAction.hit_actor(actor)


func _move(coord: Vector2i) -> void:
	var pc: Sprite2D = NodeHub.ref_DataHub.pc
	SpriteState.move_sprite(pc, coord)


func _is_impassable(coord: Vector2i) -> bool:
	if not DungeonSize.is_in_dungeon(coord):
		return true
	elif SpriteState.has_building_at_coord(coord):
		return true
	elif SpriteState.has_actor_at_coord(coord):
		return true
	return false


func _block_shoot_ray(_source_coord: Vector2i, target_coord: Vector2i, _args: Array) -> bool:
	return _is_impassable(target_coord)


func _block_hit_back_ray(source_coord: Vector2i, target_coord: Vector2i, _args: Array) -> bool:
	var ray_length_squared: int = (source_coord - target_coord).length_squared()

	if DungeonSize.is_in_dungeon(target_coord) and SpriteState.has_trap_at_coord(target_coord):
		SpriteFactory.remove_sprite(SpriteState.get_trap_by_coord(target_coord))

	if ray_length_squared == 1:
		return false
	elif ray_length_squared > (GameData.HIT_BACK ** 2):
		return true
	return _is_impassable(target_coord)


func _kill_hound(sprite: Sprite2D, coord: Vector2i) -> void:
	_add_enemy_count()
	SpriteFactory.remove_sprite(sprite)
	SpriteFactory.create_trap(SubTag.BULLET, coord, true)


func _end_turn() -> void:
	_subtract_progress_bar()
	if _enemy_count >= GameData.MAX_ENEMY_COUNT:
		NodeHub.ref_SignalHub.game_over.emit(true)
	else:
		NodeHub.ref_Schedule.start_next_turn()


func _alert_hound(pc: Sprite2D) -> void:
	_alert_duration = GameData.MAX_ALERT_DURATION
	_alert_coord = ConvertCoord.get_coord(pc)


func _add_enemy_count() -> void:
	_enemy_count = min(enemy_count + 1, GameData.MAX_ENEMY_COUNT)
	_progress_bar = GameData.MAX_PROGRES_BAR + 1


func _subtract_progress_bar() -> void:
	if _progress_bar > GameData.MIN_PROGRESS_BAR:
		_progress_bar -= 1
	if _progress_bar == GameData.MIN_PROGRESS_BAR:
		_enemy_count = max(enemy_count - 1, GameData.MIN_ENEMY_COUNT)
		if _enemy_count > GameData.MIN_ENEMY_COUNT:
			_progress_bar = GameData.MAX_PROGRES_BAR
