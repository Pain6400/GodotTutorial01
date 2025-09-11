extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 7.0
const ROTATION_SPEED = 10.0
const GRAVITY = 20.0
const CLIMB_SPEED = 3.0

@onready var anim_tree = $AnimationTree
@onready var anim_state = anim_tree.get("parameters/playback")
var is_climbing: bool = false
var current_ladder: Node3D = null
var was_in_air = false

func _ready():
	anim_tree.active = true

func _physics_process(delta: float) -> void:
	if is_climbing:
		handle_climbing(delta)
	else:
		move_player(delta)

func set_ladder(ladder: Node3D):
	current_ladder = ladder

func handle_climbing(delta: float):
	# Obtener input vertical para escalar
	var vertical_input = Input.get_axis("ui_down", "ui_up")
	var horizontal_input = Input.get_axis("ui_left", "ui_right")
	
	# Movimiento vertical en la escalera
	velocity = Vector3.ZERO
	velocity.y = vertical_input * CLIMB_SPEED
	
	# 🔹 Forzar rotación mirando hacia -Z
	var target_angle = atan2(0, -1)  # -Z
	rotation.y = lerp_angle(rotation.y, target_angle, ROTATION_SPEED * delta)
	
	# Permitir salir de la escalera con movimiento horizontal o salto
	if horizontal_input != 0 or Input.is_action_just_pressed("ui_accept"):
		exit_ladder()
		return
	
	# Animación de escalar
	if vertical_input != 0:
		anim_state.travel("Climb")
	else:
		anim_state.travel("Idle")
		
	move_and_slide()
	
	# Verificar si todavía está en la escalera
	if not current_ladder:
		exit_ladder()

func exit_ladder():
	is_climbing = false
	velocity.y = 0

func move_player(delta: float):
	# Detectar si está en una escalera y comenzar a escalar
	if Input.is_action_pressed("ui_up") and current_ladder and not is_climbing:
		is_climbing = true
		# Posicionar al jugador en la escalera
		global_position.x = current_ladder.global_position.x
		return

	# Gravedad normal cuando no está escalando
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
		was_in_air = true

	# Manejar salto
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		anim_state.travel("Jump Start")

	# Movimiento horizontal
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = Vector3(input_dir.x, 0, 0).normalized()
	
	if direction:
		velocity.x = direction.x * SPEED
		if direction.x > 0:
			rotation.y = lerp_angle(rotation.y, PI/2, ROTATION_SPEED * delta)
		elif direction.x < 0:
			rotation.y = lerp_angle(rotation.y, -PI/2, ROTATION_SPEED * delta)
		if is_on_floor():
			anim_state.travel("Walk")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if is_on_floor():
			anim_state.travel("Idle")
	
	# Manejar transiciones de salto
	if not is_on_floor():
		if anim_state.get_current_node() == "Jump Start" and velocity.y < 0:
			anim_state.travel("Jump Idle")
		elif anim_state.get_current_node() != "Jump Start":
			anim_state.travel("Jump Idle")
	
	# Detectar aterrizaje
	if is_on_floor() and was_in_air:
		was_in_air = false
		anim_state.travel("Jump Land")
	
	velocity.z = 0
	move_and_slide()
