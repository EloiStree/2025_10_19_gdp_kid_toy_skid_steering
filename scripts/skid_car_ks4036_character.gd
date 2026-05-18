class_name SkidCarKS4036Character
extends Node

signal on_linear_velocity_updated(linear_velocity: float)
signal on_angular_velocity_updated(angular_velocity: float)
signal on_left_wheel_percent_power_updated(percent_power: float)
signal on_right_wheel_percent_power_updated(percent_power: float)
signal on_left_wheel_degree_per_second_updated(degree_per_second: float)
signal on_right_wheel_degree_per_second_updated(degree_per_second: float)
signal on_left_wheel_current_rotation_updated(rotation_in_degree_total: float)
signal on_right_wheel_current_rotation_updated(rotation_in_degree_total: float)


@export_range(-1.0, 1.0,0.0001) var _left_wheel_percent_power: float = 0.0
@export_range(-1.0, 1.0,0.0001) var _right_wheel_percent_power: float = 0.0
@export var fake_gravity: float = 0.2

@export var character_to_move: CharacterBody3D

@export var rotation_per_second_in_degree: float = 720.0

@export var car_center_reference_node: Node3D
@export var left_wheel_reference_node: Node3D
@export var right_wheel_reference_node: Node3D
@export var right_wheel_top_radius_reference_node: Node3D

@export_group("Debug")
@export var distance_between_wheels_in_mm: float = 70.0
@export var radius_of_wheels_in_mm: float = 16.6
@export var diameter_of_wheels_in_mm: float = 33.2
@export var circumference_of_wheels_in_mm: float = 0.0
@export var max_wheel_speed_in_meter_per_sec: float = 0.0

@export var left_rotation_in_degree_total: float = 0.0
@export var right_rotation_in_degree_total: float = 0.0
# Internal state
var _distance_between_wheels_m: float = 0.07


func _ready() -> void:
	if not character_to_move:
		push_error("character_to_move is not assigned!")
		return
	refresh_wheel_parameters()


func refresh_wheel_parameters() -> void:
		
	# Measure real distances from references
	var left_wheel = left_wheel_reference_node.global_position
	var right_wheel = right_wheel_reference_node.global_position
	var radius_point = right_wheel_top_radius_reference_node.global_position
	
	distance_between_wheels_in_mm = abs(left_wheel.distance_to(right_wheel) * 1000.0)
	radius_of_wheels_in_mm = (right_wheel.distance_to(radius_point)) * 1000.0
	diameter_of_wheels_in_mm = radius_of_wheels_in_mm * 2.0
	circumference_of_wheels_in_mm = diameter_of_wheels_in_mm * PI
	
	max_wheel_speed_in_meter_per_sec = circumference_of_wheels_in_mm * \
									   (rotation_per_second_in_degree / 360.0) * 0.001
	
	_distance_between_wheels_m = distance_between_wheels_in_mm / 1000.0
	
	# print("Differential Drive Initialized:")
	# print("  Wheel distance: %.1f mm" % distance_between_wheels_in_mm)
	# print("  Wheel radius: %.2f mm" % radius_of_wheels_in_mm)
	# print("  Max wheel speed: %.3f m/s" % max_wheel_speed_in_meter_per_sec)
	


func set_left_wheel_percent_power(percent_power: float) -> void:
	_left_wheel_percent_power = clamp(percent_power, -1.0, 1.0)

func set_right_wheel_percent_power(percent_power: float) -> void:
	_right_wheel_percent_power = clamp(percent_power, -1.0, 1.0)


func set_both_wheels_percent_power(left_percent_power: float, right_percent_power: float) -> void:
	set_left_wheel_percent_power(left_percent_power)
	set_right_wheel_percent_power(right_percent_power)

func override_angle_per_second_in_degree(new_rotation_per_second_in_degree: float) -> void:
	rotation_per_second_in_degree = new_rotation_per_second_in_degree
	max_wheel_speed_in_meter_per_sec = circumference_of_wheels_in_mm * \
									   (rotation_per_second_in_degree / 360.0) * 0.001


## SIMULATE CONTROLLER OF FOUR BUTTONS OF KS4036 (FRONT LEFT, FRONT RIGHT, BACK LEFT, BACK RIGHT)
func set_with_four_buttons(front_left: bool, front_right: bool, back_left: bool, back_right: bool) -> void:
	
	if front_left 		and front_right 		and back_left 		and back_right:
		set_both_wheels_percent_power(0,0)

	elif not front_left and front_right 		and back_left 		and back_right:
		set_both_wheels_percent_power(-1,0)

	elif front_left 	and not front_right 	and back_left 		and back_right:
		set_both_wheels_percent_power(0,-1)

	elif not front_left and not front_right 	and back_left 		and back_right:
		set_both_wheels_percent_power(-1,-1)

	elif front_left 	and front_right 		and not back_left 	and back_right:
		set_both_wheels_percent_power(1,0)

	elif not front_left and front_right 		and not back_left 	and back_right:
		set_both_wheels_percent_power(0,0)

	elif  front_left 	and not front_right 	and not back_left 	and back_right:
		set_both_wheels_percent_power(1,-1)

	elif not front_left and not front_right 	and not back_left 	and back_right:
		set_both_wheels_percent_power(0,-1)


	elif front_left 	and front_right 		and back_left 		and not back_right:
		set_both_wheels_percent_power(0,1)

	elif not front_left and front_right 		and back_left 		and not  back_right:
		set_both_wheels_percent_power(-1,1)

	elif front_left 	and not front_right 	and back_left 		and not  back_right:
		set_both_wheels_percent_power(0,0)

	elif not front_left and not front_right 	and back_left 		and not  back_right:
		set_both_wheels_percent_power(-1,0)

	elif front_left 	and front_right 		and not back_left 	and not  back_right:
		set_both_wheels_percent_power(1,1)

	elif not front_left 	and front_right 		and not back_left 	and not  back_right:
		set_both_wheels_percent_power(0,1)

	elif  front_left 	and not front_right 	and not back_left 	and not  back_right:
		set_both_wheels_percent_power(1,0)

	elif not front_left and not front_right 	and not back_left 	and not  back_right:
		set_both_wheels_percent_power(0,0)
	pass


## SET WITH A SIMPLE JOYSTICK TYPE ARROW
func set_with_one_joystick_using_a_threshold_of_50_percent(joystick_input: Vector2):
	set_with_one_joystick_using_a_threshold(joystick_input, 0.5)

## SET WITH A SIMPLE JOYSTICK TYPE ARROW
func set_with_one_joystick_using_a_threshold(joystick_input: Vector2, threshold: float):
	var is_left = joystick_input.x < -threshold
	var is_right = joystick_input.x > threshold
	var is_forward = joystick_input.y >threshold
	var is_backward = joystick_input.y <-threshold

	if is_left and is_forward:
		set_both_wheels_percent_power(0.5, 1.0)  
	elif is_right and is_forward:
		set_both_wheels_percent_power(1.0, 0.5)  
	elif is_left and is_backward:
		set_both_wheels_percent_power(-0.5, -1.0)  
	elif is_right and is_backward:
		set_both_wheels_percent_power(-1.0, -0.5)

	elif is_left and not is_right:
		set_both_wheels_percent_power(0.0, 1.0)  
	elif is_right and not is_left:
		set_both_wheels_percent_power(1.0, 0.0)  
	elif is_forward and not is_backward:
		set_both_wheels_percent_power(1.0, 1.0)  
	elif is_backward and not is_forward:
		set_both_wheels_percent_power(-1.0, -1.0)
	else :
		set_both_wheels_percent_power(0.0, 0.0)


func set_with_one_joystick(joystick_input: Vector2):
	var forward = joystick_input.y          
	var turn   = -joystick_input.x            	

	if joystick_input.length() < 0.1:
		set_both_wheels_percent_power(0.0, 0.0)
		return
	
	var left_wheel  = forward - turn
	var right_wheel = forward + turn
	
	var max_power = max(abs(left_wheel), abs(right_wheel))
	if max_power > 1.0:
		left_wheel  /= max_power
		right_wheel /= max_power
	
	set_both_wheels_percent_power(left_wheel, right_wheel)




## SET WITH THE TWO JOYSTICKS LEFT RIGHT
func set_with_double_joystick(left_joystick: Vector2, right_joystick: Vector2):
	set_both_wheels_percent_power(left_joystick.y, right_joystick.y)
	


func _physics_process(delta: float) -> void:
	if not character_to_move:
		return

	refresh_wheel_parameters()
	
	# ROBOT CONTROL AND ODEMTRY CALCULATIONS
	# DIFFERNTIAL DRIVE KINEMATIC CALCULATIONS
	# SOURCE https://youtu.be/LrsTBWf6Wsc?t=1098

	# === Get input (-1.0 to 1.0) ===
	var left_input = _left_wheel_percent_power
	var right_input = _right_wheel_percent_power
	
	left_input = clamp(left_input, -1.0, 1.0)
	right_input = clamp(right_input, -1.0, 1.0)
	
	# === Wheel linear velocities (m/s) ===
	var left_speed: float = left_input * max_wheel_speed_in_meter_per_sec
	var right_speed: float = right_input * max_wheel_speed_in_meter_per_sec
	
	# === Differential drive kinematics ===
	var linear_velocity = (left_speed + right_speed) * 0.5          # m/s
	var angular_velocity = (right_speed - left_speed) / _distance_between_wheels_m  # rad/s
	
	# === Apply rotation ===
	character_to_move.rotation.y += angular_velocity * delta
	
	# Apply linear velocity in forward direction
	var forward_direction = -character_to_move.global_transform.basis.z
	character_to_move.velocity.x = forward_direction.x * linear_velocity
	character_to_move.velocity.z = forward_direction.z * linear_velocity
	
	if not character_to_move.is_on_floor():
		character_to_move.velocity.y -= fake_gravity

	character_to_move.move_and_slide()
				
	on_linear_velocity_updated.emit(linear_velocity)
	on_angular_velocity_updated.emit(angular_velocity)
	on_left_wheel_percent_power_updated.emit(_left_wheel_percent_power)
	on_right_wheel_percent_power_updated.emit(_right_wheel_percent_power)
	on_left_wheel_degree_per_second_updated.emit(left_input * rotation_per_second_in_degree)
	on_right_wheel_degree_per_second_updated.emit(right_input * rotation_per_second_in_degree)

	left_rotation_in_degree_total += left_input * rotation_per_second_in_degree * delta
	right_rotation_in_degree_total += right_input * rotation_per_second_in_degree * delta

	left_rotation_in_degree_total = fmod(left_rotation_in_degree_total, 360.0)
	right_rotation_in_degree_total = fmod(right_rotation_in_degree_total, 360.0)
	
	on_left_wheel_current_rotation_updated.emit(left_rotation_in_degree_total)
	on_right_wheel_current_rotation_updated.emit(right_rotation_in_degree_total)






func set_motor_left_foward_on() -> void:
	set_left_wheel_percent_power(1.0)

func set_motor_left_backward_on() -> void:
	set_left_wheel_percent_power(-1.0)

func set_motor_right_forward_on() -> void:
	set_right_wheel_percent_power(1.0)  

func set_motor_right_backward_on() -> void:
	set_right_wheel_percent_power(-1.0)

func set_motor_left_forward(is_on: bool) -> void:
	set_left_wheel_percent_power(1.0 if is_on else 0.0)

func set_motor_left_backward(is_on: bool) -> void:
	set_left_wheel_percent_power(-1.0 if is_on else 0.0)

func set_motor_right_forward(is_on: bool) -> void:
	set_right_wheel_percent_power(1.0 if is_on else 0.0)

func set_motor_right_backward(is_on: bool) -> void:
	set_right_wheel_percent_power(-1.0 if is_on else 0.0)

func set_motors_off() -> void:
	set_left_wheel_percent_power(0.0)
	set_right_wheel_percent_power(0.0)
	
