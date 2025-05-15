class_name DataHub
extends Node2D
## 1. Store public variables that will be used by other nodes.
## 2. If a property has an explicit setter function, it means the property is
## defined in a specific node and its value is read-only to other nodes.

var pc: Sprite2D:
    get:
        return _pc


var pc_coord: Vector2i:
    get:
        return ConvertCoord.get_coord(pc)


var game_mode: int:
    get:
        return _game_mode

var _pc: Sprite2D
var _game_mode: int = PcAction.NORMAL_MODE

func set_pc(value: Sprite2D) -> void:
    _pc = value


func set_game_mode(value: int) -> void:
    _game_mode = value
