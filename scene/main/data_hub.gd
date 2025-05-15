class_name DataHub
extends Node2D
## 1. Store public variables that will be used by other nodes.
## 2. If a property has an explicit setter function, it means the property is
## defined in a specific node and its value is read-only to other nodes.

var ground_index: int = 0

var pc: Sprite2D:
	get:
		return _pc

var pc_coord: Vector2i:
	get:
		return ConvertCoord.get_coord(pc)

var game_mode: int:
	get:
		return _game_mode

var ground_coords: Array[Vector2i]:
	get:
		return _ground_coords

var spawn_duration: int:
	get:
		return _spawn_duration

var _pc: Sprite2D
var _game_mode: int = PcAction.NORMAL_MODE
var _ground_coords: Array[Vector2i]
var _spawn_duration: int = GameData.MAX_SPAWN_DURATION


func set_pc(value: Sprite2D) -> void:
	_pc = value


func set_game_mode(value: int) -> void:
	_game_mode = value


func set_spawn_duration(value: int) -> void:
	_spawn_duration = value


func subtract_spawn_duration(value: int) -> void:
	_spawn_duration -= value


func set_ground_coords(value: Vector2i) -> void:
	_ground_coords.push_back(value)
