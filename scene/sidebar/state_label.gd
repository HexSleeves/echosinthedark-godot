class_name StateLabel
extends CustomLabel

const YOU_WIN: String = "\n\nYou win.\n[Space]"
const YOU_LOSE: String = "\n\nYou lose.\n[Space]"

var game_over: bool = false
var player_win: bool = false


func init_gui() -> void:
	_set_font(true)
	update_gui()


func update_gui() -> void:
	var pcAction: PcAction = NodeHub.ref_PcAction

	var ammo: String = "Ammo: %d" % [pcAction.ammo]
	var enemy: String = "\nHit: %d-%d" % [pcAction.enemy_count, pcAction.progress_bar]
	var end_game: String = ""

	if game_over:
		end_game = YOU_WIN if player_win else YOU_LOSE

	text = "%s%s%s" % [ammo, enemy, end_game]
