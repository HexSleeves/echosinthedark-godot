class_name GameProgress

const MAX_RETRY: int = 10


static func update_world(ref_DataHub: DataHub, ref_RandomNumber: RandomNumber) -> void:
	if _count_npc() >= GameData.MAX_ENEMY_COUNT:
		return

	_update_spawn_duration(ref_DataHub)
	_init_ground_coords(ref_DataHub, ref_RandomNumber)
	_create_rand_sprite(MainTag.ACTOR, SubTag.HOUND, ref_DataHub, ref_RandomNumber, MAX_RETRY)


static func _create_rand_sprite(
	main_tag: StringName, sub_tag: StringName, ref_DataHub: DataHub, ref_RandomNumber: RandomNumber, retry: int
) -> void:
	if retry < 1:
		return

	var coord: Vector2i = ref_DataHub.ground_coords[ref_DataHub.ground_index]
	var is_created: bool = false

	if _is_valid_coord(coord, ref_DataHub.pc_coord):
		SpriteFactory.create_actor(sub_tag, coord, true)
		is_created = true

	_update_ground_index(ref_DataHub, ref_RandomNumber)

	if not is_created:
		_create_rand_sprite(main_tag, sub_tag, ref_DataHub, ref_RandomNumber, retry - 1)


static func _count_npc() -> int:
	var actors: Array = SpriteState.get_sprites_by_tag(MainTag.ACTOR, "")
	var count: int = actors.size()

	for i: Sprite2D in actors:
		if i.is_in_group(SubTag.PC):
			count -= 1

	return count


static func _update_ground_index(ref_DataHub: DataHub, ref_RandomNumber: RandomNumber) -> void:
	ref_DataHub.ground_index += 1
	if ref_DataHub.ground_index < ref_DataHub.ground_coords.size():
		return
	ref_DataHub.ground_index = 0
	ArrayHelper.shuffle(ref_DataHub.ground_coords, ref_RandomNumber)


static func _update_spawn_duration(ref_DataHub: DataHub) -> void:
	ref_DataHub.subtract_spawn_duration(1)
	if ref_DataHub.spawn_duration > 0:
		return

	ref_DataHub.set_spawn_duration(GameData.MAX_SPAWN_DURATION)


static func _init_ground_coords(ref_DataHub: DataHub, ref_RandomNumber: RandomNumber) -> void:
	if not ref_DataHub.ground_coords.is_empty():
		return

	var sprites: Array
	var save_coord: bool
	var coord: Vector2i = Vector2i(0, 0)

	for x in range(0, DungeonSize.MAX_X):
		for y in range(0, DungeonSize.MAX_Y):
			coord.x = x
			coord.y = y
			save_coord = true
			sprites = SpriteState.get_sprites_by_coord(coord)

			for i: Sprite2D in sprites:
				if _is_invalid_sprite(i):
					save_coord = false
					break
			if save_coord:
				ref_DataHub.set_ground_coords(coord)

	ArrayHelper.shuffle(ref_DataHub.ground_coords, ref_RandomNumber)


static func _is_invalid_sprite(sprite: Sprite2D) -> bool:
	return (
		sprite.is_in_group(SubTag.WALL)
		or sprite.is_in_group(MainTag.BUILDING)
		or (sprite.is_in_group(MainTag.ACTOR) and (not sprite.is_in_group(SubTag.PC)))
	)


static func _is_valid_coord(check_coord: Vector2i, pc_coord: Vector2i) -> bool:
	if SpriteState.has_actor_at_coord(check_coord):
		return false
	elif SpriteState.has_trap_at_coord(check_coord):
		return false
	elif ConvertCoord.is_in_range(check_coord, pc_coord, GameData.MIN_DISTANCE_TO_PC):
		return false
	elif not ConvertCoord.is_in_range(check_coord, pc_coord, GameData.MAX_DISTANCE_TO_PC):
		return false
	return true
