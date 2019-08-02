"""
Node storing all of the fixed values for the character. Can be modified per character.
"""
extends Node

const Shot = preload("res://enums/Common.gd").Shot

export var MAX_NEUTRAL_SPEED : int = 250
export var MAX_CHARGE_SPEED : int = 20
export var SERVE_NEUTRAL_SPEED : int = 200
export var PIVOT_ACCEL : int = 1000
export var RUN_ACCEL : int = 800
export var STOP_ACCEL : int = 800

# Define the hitbox of a shot via two parameters:
# Reach: How far the character can reach from the exact middle of the character.
#        Also used for shot activation plane checks.
# Stretch: Offset of the hitbox when the player is facing right.
#          Negative values mean the hitbox will be extended.
export var HIT_SIDE_REACH : Vector3 = Vector3(40, 40, 10)
export var HIT_SIDE_STRETCH : Vector3 = Vector3(-10, 0, -10)
export var HIT_OVERHEAD_REACH : Vector3 = Vector3(30, 80, 10)
export var HIT_OVERHEAD_STRETCH : Vector3 = Vector3(-10, 0, -10)
export var LUNGE_REACH : Vector3 = Vector3(60, 40, 10)
export var LUNGE_STRETCH : Vector3 = Vector3(-10, 0, -10)

export var SHOT_PARAMETERS : Dictionary = {
    Shot.S_TOP: {
        "power": {
            "base": 500,
            "max": 800
        },
        "spin": {
            "base": -50,
            "max": -100
        },
        "angle": 60,
        "placement": 20,
    },
    Shot.D_TOP: {
        "power": {
            "base": 600,
            "max": 1000
        },
        "spin": {
            "base": -100,
            "max": -200
        },
        "angle": 60,
        "placement": 30,
    },
    Shot.S_SLICE: {
        "power": {
            "base": 500,
            "max": 600
        },
        "spin": {
            "base": 100,
            "max": 100
        },
        "angle": 60,
        "placement": 20,
    },
    Shot.D_SLICE: {
        "power": {
            "base": 600,
            "max": 800
        },
        "spin": {
            "base": 50,
            "max": 50
        },
        "angle": 60,
        "placement": 20,
    },
    Shot.S_FLAT: {
        "power": {
            "base": 600,
            "max": 800
        },
        "angle": 60,
        "placement": 20,
    },
    Shot.D_FLAT: {
        "power": {
            "base": 800,
            "max": 1200
        },
        "angle": 60,
        "placement": 20,
    },
    Shot.LOB: {
        "angle": 60,
        "placement": 20,
    },
    Shot.DROP: {
        "angle": 60,
        "placement": 20,
    },
    Shot.LUNGE: {
        "angle": 60,
        "placement": 40,
    }
}