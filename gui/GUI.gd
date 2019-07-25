extends CanvasLayer

signal meter_updated(player_id, meter)

func _on_Player_meter_updated(player_id, meter):
    emit_signal("meter_updated", player_id, meter)
