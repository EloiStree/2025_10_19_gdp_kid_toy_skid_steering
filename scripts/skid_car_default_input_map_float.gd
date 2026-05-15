class_name SkidCarDefaultInputMapFloat
extends Node


signal on_left_wheel_percent_power_updated(left_wheel_percent_power: float)
signal on_right_wheel_percent_power_updated(right_wheel_percent_power: float)
signal on_both_wheels_percent_power_updated(left_wheel_percent_power: float, right_wheel_percent_power: float)

@export var use_input: bool = true

@export var input_map_action_left_forward: String = "left_forward"
@export var input_map_action_left_backward: String = "left_backward"
@export var input_map_action_right_forward: String = "right_forward"
@export var input_map_action_right_backward: String = "right_backward"


@export var current_left_input: float = 0.0
@export var current_right_input: float = 0.0


func set_as_using_input(is_on: bool) -> void:
    use_input = is_on


func turn_on_input():
    set_as_using_input(true)

func turn_off_input():
    set_as_using_input(false)


func _process(delta: float) -> void:
    if not use_input:
        return
    var left_input = Input.get_action_strength(input_map_action_left_forward) - Input.get_action_strength(input_map_action_left_backward)
    var right_input = Input.get_action_strength(input_map_action_right_forward) - Input.get_action_strength(input_map_action_right_backward)
    left_input = clamp(left_input, -1.0, 1.0)
    right_input = clamp(right_input, -1.0, 1.0)
    var has_changed :bool = (left_input != current_left_input) or (right_input != current_right_input)
    current_left_input = left_input
    current_right_input = right_input
    if has_changed:
        on_left_wheel_percent_power_updated.emit(left_input)
        on_right_wheel_percent_power_updated.emit(right_input)
        on_both_wheels_percent_power_updated.emit(left_input, right_input)
