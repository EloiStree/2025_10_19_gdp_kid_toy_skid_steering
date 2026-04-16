extends Node

# --- 4 motor control booleans ---
@export var button_left_front_on: bool = false
@export var button_right_front_on: bool = false
@export var button_left_back_on: bool = false
@export var button_right_back_on: bool = false

# --- Key bindings (customizable in Inspector) ---
@export var key_left_front: Key = KEY_W
@export var key_right_front: Key = KEY_E
@export var key_left_back: Key = KEY_S
@export var key_right_back: Key = KEY_D

# --- Individual signals for each motor ---
signal on_left_front(is_on: bool)
signal on_right_front(is_on: bool)
signal on_left_back(is_on: bool)
signal on_right_back(is_on: bool)

# --- Internal tracking of pressed states ---
var pressed_keys: Dictionary = {}

func _ready() -> void:
	# Initialize all keys as not pressed
	pressed_keys = {
		key_left_front: false,
		key_right_front: false,
		key_left_back: false,
		key_right_back: false
	}

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode in pressed_keys:
			if pressed_keys[event.keycode] != event.pressed:
				pressed_keys[event.keycode] = event.pressed
				_update_booleans_and_emit(event.keycode, event.pressed)

func _update_booleans_and_emit(keycode: Key, is_pressed: bool) -> void:
	match keycode:
		key_left_front:
			button_left_front_on = is_pressed
			on_left_front.emit(is_pressed)
		key_right_front:
			button_right_front_on = is_pressed
			on_right_front.emit(is_pressed)
		key_left_back:
			button_left_back_on = is_pressed
			on_left_back.emit(is_pressed)
		key_right_back:
			button_right_back_on = is_pressed
			on_right_back.emit(is_pressed)
