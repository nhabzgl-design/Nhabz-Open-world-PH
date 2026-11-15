extends CharacterBody3D

@export var move_speed: float = 6.0
@export var jump_velocity: float = 4.5
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _physics_process(delta: float) -> void:
    if not is_on_floor():
        velocity.y -= gravity * delta
    elif Input.is_action_just_pressed("jump"):
        velocity.y = jump_velocity

    var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
    var direction := Vector3(input_dir.x, 0, input_dir.y).normalized()
    if direction.length() > 0.01:
        velocity.x = direction.x * move_speed
        velocity.z = direction.z * move_speed
        look_at(global_position + Vector3(direction.x, 0, direction.z), Vector3.UP)
    else:
        velocity.x = move_toward(velocity.x, 0, move_speed * 5 * delta)
        velocity.z = move_toward(velocity.z, 0, move_speed * 5 * delta)

    move_and_slide()
