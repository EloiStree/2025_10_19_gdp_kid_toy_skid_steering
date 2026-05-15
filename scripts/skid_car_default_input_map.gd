class_name SkidCarDefaultInputMap
extends Node




signal on_wheel_left_right_percent_11(left_percent_11: float, right_percent_11: float)
signal on_wheel_left_percent_11(left_percent_11: float)
signal on_wheel_right_percent_11(right_percent_11: float)
signal on_left_front(is_on: bool)
signal on_right_front(is_on: bool)
signal on_left_back(is_on: bool)
signal on_right_back(is_on: bool)


@export var is_enabled: bool = true
@export var action_left_front: String = "motor_left_front"
@export var action_right_front: String = "motor_right_front"
@export var action_left_back: String = "motor_left_back"
@export var action_right_back: String = "motor_right_back"

var button_left_front_on := false
var button_right_front_on := false
var button_left_back_on := false
var button_right_back_on := false


func set_left_front_on(is_on: bool) -> void:
	if button_left_front_on != is_on:
		button_left_front_on = is_on
		on_left_front.emit(is_on)
		push_wheel_as_percent()	
func set_right_front_on(is_on: bool) -> void:
	if button_right_front_on != is_on:
		button_right_front_on = is_on
		on_right_front.emit(is_on)
		push_wheel_as_percent()	
func set_left_back_on(is_on: bool) -> void:
	if button_left_back_on != is_on:	
		button_left_back_on = is_on
		on_left_back.emit(is_on)
		push_wheel_as_percent()	
func set_right_back_on(is_on: bool) -> void:
	if button_right_back_on != is_on:
		button_right_back_on = is_on
		on_right_back.emit(is_on)
		push_wheel_as_percent()

func _process(_delta: float) -> void:
	if not is_enabled:
		return
	set_left_front_on(get_value(action_left_front))
	set_right_front_on(get_value(action_right_front))
	set_left_back_on(get_value(action_left_back))
	set_right_back_on(get_value(action_right_back))
	

func get_value(name:String) -> bool:
	if InputMap.has_action(name):
		return Input.is_action_pressed(name)
	return false

func push_wheel_as_percent() -> void:
	var left_percent_11: float = 0.0
	var right_percent_11: float = 0.0
	if button_left_front_on:
		left_percent_11 += 1.0
	if button_left_back_on:
		left_percent_11 -= 1.0
	if button_right_front_on:
		right_percent_11 += 1.0
	if button_right_back_on:
		right_percent_11 -= 1.0
	on_wheel_left_right_percent_11.emit(left_percent_11, right_percent_11)
	on_wheel_left_percent_11.emit(left_percent_11)
	on_wheel_right_percent_11.emit(right_percent_11)
