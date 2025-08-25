extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 7.0  # Aumentado para un salto más rápido
const ROTATION_SPEED = 10.0

# Gravedad personalizada (más fuerte para caída más rápida)
const GRAVITY = 20.0  # Valor por defecto es ~9.8, aumentamos para mayor velocidad

# Referencia al AnimationTree
@onready var anim_tree = $AnimationTree
@onready var anim_state = anim_tree.get("parameters/playback")

# Variables para control de animaciones
var was_in_air = false

func _ready():
	# Asegurarse de que el AnimationTree está activo
	anim_tree.active = true

func _physics_process(delta: float) -> void:
	# Aplicar gravedad personalizada
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
		was_in_air = true

	# Manejar salto
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		# Disparar animación de inicio de salto
		anim_state.travel("Jump Start")

	# Movimiento solo en el eje X
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = Vector3(input_dir.x, 0, 0).normalized()
	
	if direction:
		velocity.x = direction.x * SPEED
		
		# Rotar el personaje según la dirección
		if direction.x > 0:  # Derecha
			rotation.y = lerp_angle(rotation.y, PI/2, ROTATION_SPEED * delta)
		elif direction.x < 0:  # Izquierda
			rotation.y = lerp_angle(rotation.y, -PI/2, ROTATION_SPEED * delta)
			
		# Animación de caminar si está en el suelo
		if is_on_floor():
			anim_state.travel("Walk")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		# Animación de idle si está en el suelo
		if is_on_floor():
			anim_state.travel("Idle")
	
	# Manejar transiciones de salto
	if not is_on_floor():
		# Cambiar a Jump Idle después del inicio del salto
		if anim_state.get_current_node() == "Jump Start" and velocity.y < 0:
			anim_state.travel("Jump Idle")
		elif anim_state.get_current_node() != "Jump Start":
			anim_state.travel("Jump Idle")
	
	# Detectar aterrizaje
	if is_on_floor() and was_in_air:
		was_in_air = false
		# Animación de aterrizaje
		anim_state.travel("Jump Land")
		# Después de aterrizar, volver a idle o walk
		if direction:
			# Pequeño retraso para permitir que la animación de aterrizaje se reproduzca
			#await get_tree().create_timer(0.2).timeout  # Reducido por salto más rápido
			anim_state.travel("Walk")
		else:
			#await get_tree().create_timer(0.2).timeout  # Reducido por salto más rápido
			anim_state.travel("Idle")
	
	# Mantenemos Z en 0 para evitar movimiento en ese eje
	velocity.z = 0

	move_and_slide()
