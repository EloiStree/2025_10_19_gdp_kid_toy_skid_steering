extends Node

# --- Signals (équivalent des UnityEvent<bool>)
signal on_left_up_button_on(is_on: bool)
signal on_right_up_button_on(is_on: bool)
signal on_left_down_button_on(is_on: bool)
signal on_right_down_button_on(is_on: bool)

# --- Variables exposées à l'inspecteur (équivalent des public)
@export var left_up_button_on_state: bool = false
@export var right_up_button_on_state: bool = false
@export var left_down_button_on_state: bool = false
@export var right_down_button_on_state: bool = false

@export var use_update: bool = true


func _process(delta: float) -> void:
	if use_update:
		push_state()


@export_category("Button Control")
func push_state() -> void:
	set_left_up_button_down(left_up_button_on_state)
	set_left_down_button_down(left_down_button_on_state)
	set_right_down_button_down(right_down_button_on_state)
	set_right_up_button_down(right_up_button_on_state)


func set_left_up_button_down(is_on: bool) -> void:
	left_up_button_on_state = is_on
	emit_signal("on_left_up_button_on", is_on)


func set_left_down_button_down(is_on: bool) -> void:
	left_down_button_on_state = is_on
	emit_signal("on_left_down_button_on", is_on)


func set_right_up_button_down(is_on: bool) -> void:
	right_up_button_on_state = is_on
	emit_signal("on_right_up_button_on", is_on)


func set_right_down_button_down(is_on: bool) -> void:
	right_down_button_on_state = is_on
	emit_signal("on_right_down_button_on", is_on)


func _on_node_input_on_left_front(is_on: bool) -> void:
	pass # Replace with function body.


func _on_node_input_on_left_back(is_on: bool) -> void:
	pass # Replace with function body.


func _on_node_keyboard_on_left_front(is_on: bool) -> void:
	pass # Replace with function body.


func _on_node_keyboard_on_right_back(is_on: bool) -> void:
	pass # Replace with function body.


func _on_node_keyboard_on_right_front(is_on: bool) -> void:
	pass # Replace with function body.
