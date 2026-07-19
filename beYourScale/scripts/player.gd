extends CharacterBody3D


var SPEED: float = 5.0
var JUMP_VELOCITY: float = 4.5
var GRAVITY: float = 9.68
var CAMERA_SENSITIVITY = 0.005
var _applied_player_size: float = -1.0

const FREQ = 2.0
const AMP = 0.08
var signwave_timer = 0.0

@export var player_size: float = 1.0: set = set_player_size

@onready var head = $Head
@onready var camera = $Head/Camera3D

func set_player_size(value: float) -> void:
	player_size = max(value, 0.01)
	scale = Vector3.ONE * player_size
	_applied_player_size = player_size

func _ready():
	set_player_size(player_size)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(_delta: float) -> void:
	if !is_equal_approx(player_size, _applied_player_size):
		set_player_size(player_size)
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * CAMERA_SENSITIVITY)
		camera.rotate_x(-event.relative.y * CAMERA_SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))
		
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
		velocity.y = JUMP_VELOCITY

	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		print(input_dir)
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = lerp(velocity.x, direction.x * SPEED, delta * 5.0)
		velocity.z = lerp(velocity.z, direction.z * SPEED, delta * 5.0)
		
	signwave_timer += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(signwave_timer)

	move_and_slide()
