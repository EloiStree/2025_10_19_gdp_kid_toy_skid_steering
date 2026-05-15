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

	## add a fake gravity of linear
	character_to_move.velocity.y -= fake_gravity

	# Apply linear velocity in forward direction
	var forward_direction = -character_to_move.global_transform.basis.z
	character_to_move.velocity.x = forward_direction.x * linear_velocity
	character_to_move.velocity.z = forward_direction.z * linear_velocity
	
	character_to_move.move_and_slide()

	
	# if Engine.is_editor_hint() or OS.is_debug_build():
	# 	if abs(_left_wheel_percent_power) > 0.01 or abs(_right_wheel_percent_power) > 0.01:
	# 		print("L: %.2f  R: %.2f | Lin: %.3f m/s | Ang: %.2f rad/s" % 
	# 			[_left_wheel_percent_power, _right_wheel_percent_power, linear_velocity, angular_velocity])
			
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
