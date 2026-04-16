extends Node3D

@export var is_wheel_motor_on: bool = false
@export var is_motor_rotating_inverse: bool = false
@export var rotation_speed_when_on: float = 180.0
@export var what_to_rotate: Node3D
@export var wheel_center: Node3D
@export var wheel_height: Node3D
@export var axis_to_rotate: Vector3 = Vector3.RIGHT


func _process(delta: float) -> void:
	if is_wheel_motor_on and what_to_rotate:
		var direction := -1.0 if is_motor_rotating_inverse else 1.0
		var angle := direction * rotation_speed_when_on * delta
		what_to_rotate.rotate_object_local(axis_to_rotate.normalized(), deg_to_rad(angle))


func get_rotation_info() -> Dictionary:
	if wheel_center and wheel_height:
		var radius := wheel_center.global_position.distance_to(wheel_height.global_position)
		return {
			"angle_per_second": rotation_speed_when_on,
			"radius": radius
		}
	return {}


func set_motor_from_percent11(percent11:float):
	is_wheel_motor_on=percent11!=0.0
	if (percent11>=0):
		is_motor_rotating_inverse=false
	else :
		is_motor_rotating_inverse=true
		
	
		

func set_motor_on(is_on: bool) -> void:
	is_wheel_motor_on = is_on


func set_motor_inverse(is_inverse: bool) -> void:
	is_motor_rotating_inverse = is_inverse


func _on_move_from_wheel_height_on_back_right_motor_speed_changed(new_percent: float) -> void:
	pass # Replace with function body.
