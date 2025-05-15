# class_name NodeHub
extends Node2D

var ref_SpriteCoord: SpriteCoord
var ref_SpriteTag: SpriteTag
var ref_Schedule: Schedule
var ref_PcAction: PcAction
var ref_ActorAction: ActorAction
var ref_RandomNumber: RandomNumber
# var ref_GameProgress: GameProgress
var ref_SignalHub: SignalHub
var ref_DataHub: DataHub


func _ready() -> void:
	print("NodeHub ready")
	print(ref_SpriteCoord)
	print(ref_SpriteTag)
	print(ref_Schedule)
	print(ref_PcAction)
	print(ref_ActorAction)
	print(ref_RandomNumber)
	print(ref_SignalHub)
	print(ref_DataHub)
