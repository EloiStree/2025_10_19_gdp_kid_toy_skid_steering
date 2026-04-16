extends Node

# Source https://github.com/EloiStree/2023_11_01_upm_KidToyCarSkidSteeringCode/blob/main/Runtime/ExostCarRCDefaultMono.cs

# --- INPUT BUTTON STATES ---
var button_left_front_on: bool = false
var button_right_front_on: bool = false
var button_left_back_on: bool = false
var button_right_back_on: bool = false

# --- CAR PARAMETERS ---
@export var forward_distance_per_second: float = 1.0
@export var time_to_do_full_rotation_on_pivot: float = 1.5
var turn_hard_amplification: float = 1.3
var turn_ratio_control: float = 1.0
var wheel_turn_per_second: float = 1.0

# --- REFERENCES TO SCENE NODES ---
@export var what_to_move: Node3D
@export var exost_car_to_move_direction: Node3D
@export var pivot_left_front: Node3D
@export var pivot_right_front: Node3D
@export var pivot_left_back: Node3D
@export var pivot_right_back: Node3D
@export var pivot_right_back_wheel_top_anchor: Node3D

# --- COMPUTED PARAMETERS ---
var deducted_move_speed_during_rotation_per_second: float = 1.0
var front_wheel_distance: float = 0.0
var wheel_height: float = 0.0
var wheel_distance_per_turn: float = 0.0
var pivot_circle_distance: float = 0.0
var distance_per_second: float = 0.0
var wheel_rotation_per_second: float = 0.0
var wheel_rotation_angle_per_second: float = 0.0
var pivot_angle_per_second: float = 0.0
var pivot_angle_per_second_amplified: float = 0.0

# --- ENUM FOR ROTATION TYPES ---
enum RotateType { LEFT_FRONT, RIGHT_FRONT, LEFT_BACK, RIGHT_BACK }

var is_car_good_side: bool = false



# Define signals for each wheel
signal on_front_left_motor_speed_changed(new_percent: float)
signal on_front_right_motor_speed_changed(new_percent: float)
signal on_back_left_motor_speed_changed(new_percent: float)
signal on_back_right_motor_speed_changed(new_percent: float)

# Internal state tracking
var front_left_speed := 0.0
var front_right_speed := 0.0
var back_left_speed := 0.0
var back_right_speed := 0.0

func set_wheel_state(left_front: float, right_front: float, left_back: float, right_back: float) -> void:
	# Update front left
	if !is_equal_approx(front_left_speed, left_front):
		front_left_speed = left_front
		emit_signal("on_front_left_motor_speed_changed", left_front)

	# Update front right
	if !is_equal_approx(front_right_speed, right_front):
		front_right_speed = right_front
		emit_signal("on_front_right_motor_speed_changed", right_front)

	# Update back left
	if !is_equal_approx(back_left_speed, left_back):
		back_left_speed = left_back
		emit_signal("on_back_left_motor_speed_changed", left_back)

	# Update back right
	if !is_equal_approx(back_right_speed, right_back):
		back_right_speed = right_back
		emit_signal("on_back_right_motor_speed_changed", right_back)
		
func _process(delta: float) -> void:
	if impossible_situation_of_buttons():
		return

	compute_deducted_info()
	is_car_good_side = exost_car_to_move_direction.transform.basis.y.y > 0.0
	deducted_move_speed_during_rotation_per_second = (pivot_left_front.global_position.distance_to(pivot_right_front.global_position)) * 2.0 * PI

	set_wheel_state(0,0,0,0)
	# --- Movement Logic ---
	if move_forward():
		set_wheel_state(1,1,1,1)
		move_straight(delta, true)
	elif move_backward():
		set_wheel_state(-1,-1,-1,-1)
		move_straight(delta, false)
	elif turn_left_hard():
		set_wheel_state(-1, 1, -1, 1)
		turn_in_place(delta, true)
	elif turn_right_hard():
		set_wheel_state(1, -1, 1, -1)
		turn_in_place(delta, false)
	elif turn_left_light():
		set_wheel_state(0, 1, 0, 1)
		if is_car_good_side:
			rotate_around(RotateType.LEFT_FRONT, delta, false)
		else:
			rotate_around(RotateType.LEFT_BACK, delta, true)
	elif turn_right_light():
		set_wheel_state(1, 0, 1, 0)
		if is_car_good_side:
			rotate_around(RotateType.RIGHT_FRONT, delta, false)
		else:
			rotate_around(RotateType.RIGHT_BACK, delta, true)
	elif turn_left_light_backward():
		set_wheel_state(0, -1, 0, -1)
		if is_car_good_side:
			rotate_around(RotateType.LEFT_BACK, delta, false)
		else:
			rotate_around(RotateType.LEFT_FRONT, delta, true)
	elif turn_right_light_backward():
		set_wheel_state(-1, 0, -1, 0)
		if is_car_good_side:
			rotate_around(RotateType.RIGHT_BACK, delta, false)
		else:
			rotate_around(RotateType.RIGHT_FRONT, delta, true)


# ---------------------------
#  HELPER METHODS
# ---------------------------

func compute_deducted_info() -> void:
	pivot_angle_per_second = 360.0 / time_to_do_full_rotation_on_pivot
	pivot_angle_per_second_amplified = turn_hard_amplification * pivot_angle_per_second
	front_wheel_distance = pivot_left_front.global_position.distance_to(pivot_right_front.global_position)
	wheel_height = pivot_right_back.global_position.distance_to(pivot_right_back_wheel_top_anchor.global_position)
	wheel_distance_per_turn = wheel_height * 2.0 * PI
	pivot_circle_distance = front_wheel_distance * 2.0 * PI
	distance_per_second = pivot_circle_distance / time_to_do_full_rotation_on_pivot
	wheel_rotation_per_second = distance_per_second / wheel_distance_per_turn
	wheel_rotation_angle_per_second = wheel_rotation_per_second * 360.0


func move_straight(delta: float, forward: bool = true) -> void:
	if what_to_move == null or exost_car_to_move_direction == null:
		return

	# In Godot, forward is -Z (Unity uses +Z)
	var dir = -exost_car_to_move_direction.global_transform.basis.z.normalized()

	# Flip direction if the car is flipped upside-down
	if not is_car_good_side:
		dir = -dir

	# Compute movement vector
	var move_dir = dir * distance_per_second * delta * (1 if forward else -1)

	# Apply translation globally (world space)
	what_to_move.global_translate(move_dir)


func turn_in_place(delta: float, left: bool = true) -> void:
	if what_to_move == null:
		return
	var direction := 1
	if left != is_car_good_side:
		direction = 1
	else:
		direction = -1
	var angle_deg := pivot_angle_per_second_amplified * turn_ratio_control * delta * direction
	what_to_move.rotate_y(deg_to_rad(angle_deg))


# --- FIXED rotate_around() ---
func rotate_around(rot_type: int, delta: float, inverse_rotation: bool = false) -> void:
	var rotation_point: Node3D = null
	var inverse_angle := false
	var is_back := false
	
	match rot_type:
		RotateType.LEFT_FRONT:
			rotation_point = pivot_left_front
		RotateType.RIGHT_FRONT:
			rotation_point = pivot_right_front
			inverse_angle = true
		RotateType.LEFT_BACK:
			rotation_point = pivot_left_back
			is_back = true
		RotateType.RIGHT_BACK:
			rotation_point = pivot_right_back
			inverse_angle = true
			is_back = true

	if rotation_point == null or what_to_move == null:
		return

	var angle_deg := pivot_angle_per_second * turn_ratio_control * delta
	var sign := 1.0
	if is_back:
		sign *= -1.0
	if inverse_angle:
		sign *= -1.0
	if inverse_rotation:
		sign *= -1.0

	# --- Manual rotation around a pivot point (Unity-style) ---
	var pivot_pos: Vector3 = rotation_point.global_position
	var obj_pos: Vector3 = what_to_move.global_position
	var axis := Vector3.UP
	var angle_rad := deg_to_rad(angle_deg * sign)

	# Compute offset and rotate
	var offset := obj_pos - pivot_pos
	offset = offset.rotated(axis, angle_rad)

	# Apply new position and orientation
	what_to_move.global_position = pivot_pos + offset
	what_to_move.rotate(axis, angle_rad)


# ---------------------------
#  BUTTON STATE LOGIC
# ---------------------------

func move_forward() -> bool:
	return not button_left_back_on and not button_right_back_on and button_left_front_on and button_right_front_on

func move_backward() -> bool:
	return button_left_back_on and button_right_back_on and not button_left_front_on and not button_right_front_on

func turn_left_hard() -> bool:
	return button_left_back_on and not button_right_back_on and not button_left_front_on and button_right_front_on

func turn_right_hard() -> bool:
	return not button_left_back_on and button_right_back_on and button_left_front_on and not button_right_front_on

func turn_left_light() -> bool:
	return not button_left_back_on and not button_right_back_on and not button_left_front_on and button_right_front_on

func turn_right_light() -> bool:
	return not button_left_back_on and not button_right_back_on and button_left_front_on and not button_right_front_on

func turn_left_light_backward() -> bool:
	return not button_left_back_on and button_right_back_on and not button_left_front_on and not button_right_front_on

func turn_right_light_backward() -> bool:
	return button_left_back_on and not button_right_back_on and not button_left_front_on and not button_right_front_on

func impossible_situation_of_buttons() -> bool:
	return (button_right_back_on and button_right_front_on) or (button_left_back_on and button_left_front_on)


# ---------------------------
#  INPUT CONTROL API
# ---------------------------

func set_motor_left_front(on: bool) -> void:
	button_left_front_on = on

func set_motor_right_front(on: bool) -> void:
	button_right_front_on = on

func set_motor_left_back(on: bool) -> void:
	button_left_back_on = on

func set_motor_right_back(on: bool) -> void:
	button_right_back_on = on
