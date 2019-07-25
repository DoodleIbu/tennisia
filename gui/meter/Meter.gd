extends TextureProgress

export var _ID = 1

const _RED_TEXTURE = preload("res://assets/graphics/meter/meterfillred.png")
const _ORANGE_TEXTURE = preload("res://assets/graphics/meter/meterfillorange.png")
const _YELLOW_TEXTURE = preload("res://assets/graphics/meter/meterfillyellow.png")
const _GREEN_TEXTURE = preload("res://assets/graphics/meter/meterfillgreen.png")
const _BLUE_TEXTURE = preload("res://assets/graphics/meter/meterfillblue.png")

func _on_GUI_meter_updated(player_id, meter):
    if player_id == _ID:
        set_value(meter)

        if meter < 25:
            set_progress_texture(_RED_TEXTURE)
        elif meter < 50:
            set_progress_texture(_ORANGE_TEXTURE)
        elif meter < 75:
            set_progress_texture(_YELLOW_TEXTURE)
        elif meter < 100:
            set_progress_texture(_GREEN_TEXTURE)
        else:
            set_progress_texture(_BLUE_TEXTURE)
