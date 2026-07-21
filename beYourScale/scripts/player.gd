extends CharacterBody3D

@export var player_size: float = 1.0: set = _set_player_size

@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var logs: Label = $Logs
@onready var player_height: Label = $Height

enum Skill {NONE, SIZE}

const FREQ = 2.0
const AMP = 0.08
const CAMERA_SENSITIVITY = 0.005

var speed: float = 5.0
var jump_velocity: float = 4.5
var gravity: float = 9.68
var signwave_timer = 0.0
var active_skill: Skill = Skill.SIZE
var target_size: float = 1


func _set_player_size(value: float) -> void:
	player_size = max(value, 0.01)
	target_size = player_size

func _ready():
	_set_player_size(player_size)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	logs.text = "ACTIVE SKILL: " + Skill.keys()[active_skill]

func _process(delta: float) -> void:
	scale = Vector3.ONE * lerp(scale.x, target_size, delta * 3.0)
	player_height.text = "Height: %.2f" % scale.x
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * CAMERA_SENSITIVITY)
		camera.rotate_x(-event.relative.y * CAMERA_SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))

	if event is InputEventKey and event.pressed:
		var keycode = event.keycode
		if keycode >= KEY_0 and keycode <= KEY_9:
			var number = keycode - KEY_0
			if number == 1:
				active_skill = Skill.SIZE
			else:
				active_skill = Skill.NONE
			if logs:
				logs.text = "ACTIVE SKILL: " + Skill.keys()[active_skill]

	if Input.is_action_just_pressed("cast"):
		if active_skill == Skill.SIZE:
			target_size = 1.0 if scale.x < 0.9 else 0.5

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * FREQ) * AMP
	pos.x = cos(time * FREQ / 2) * AMP
	return pos

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("exit"):
		get_tree().quit()
		
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		print(input_dir)
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 5.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 5.0)
		
	signwave_timer += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(signwave_timer)

	move_and_slide()
