extends CharacterBody2D

# Movimiento
@export var velocidad: float = 50.0 # Velocidad

# Inteligencia Artificial
var posicion_jugador: Vector2 # Posición del jugador
var posicion_inicial: Vector2 # Posición de inicio y retorno del fantasma

# Sprite y shading
@onready var sprite = $Sprite2D
@onready var shader_material = preload("res://shaders/negative_ghosts.gdshader")

# Agente de navegación
@onready var agente_navegacion = $NavigationAgent2D

enum EstadoFantasma {
	Persiguiendo,
	Huyendo,
	Retornando
}

# Estado inicial
var estado_actual = EstadoFantasma.Persiguiendo

func _ready() -> void:
	# La posición inicial se guarda para el retorno
	posicion_inicial = global_position

func _process(delta: float) -> void:
	match estado_actual:
		EstadoFantasma.Persiguiendo:
			perseguir_jugador()
			
			# Quitamos el shader
			sprite.material = null  
			
		EstadoFantasma.Huyendo:
			huir_del_jugador()
			
			# Aplicamos el shader
			sprite.material = ShaderMaterial.new()
			sprite.material.shader = shader_material
			
		EstadoFantasma.Retornando:
			retornar_al_inicio()
			
			# Quitamos el shader
			sprite.material = null  
			
	move_and_slide()

# Estado convencional de la IA de los fantasmas
func perseguir_jugador():
	if posicion_jugador:
		agente_navegacion.target_position = posicion_jugador # Direcciona al fantasma hacia el jugador
		var direccion = agente_navegacion.get_next_path_position() - global_position
		if direccion.length() > 1:
			velocity = direccion.normalized() * velocidad
		else:
			velocity = Vector2.ZERO

# Cuando el jugador coge un punto grande, durante la duración de su efecto
func huir_del_jugador():
	if posicion_jugador:
		var direccion_huida = (global_position - posicion_jugador).normalized()
		agente_navegacion.target_position = global_position + direccion_huida * 100  # Se mueve lejos
		velocity = direccion_huida * velocidad * 0.8  # Disminuye un poco la velocidad

# Si el fantasma es alcanzado por el jugador durante la duración del punto grande
func retornar_al_inicio():
	agente_navegacion.target_position = posicion_inicial
	var direccion = agente_navegacion.get_next_path_position() - global_position
	if direccion.length() > 1:
		velocity = direccion.normalized() * velocidad * 3  # Retorno más rápido
		sprite.modulate.a = 0.3  # Hacer el sprite semi-transparente
	else:
		sprite.modulate.a = 1.0  # Restaurar visibilidad
		cambiar_estado(EstadoFantasma.Persiguiendo)  # Al llegar, vuelve a la normalidad

# Función para cambiar el estado del fantasma
func cambiar_estado(nuevo_estado):
	estado_actual = nuevo_estado

# Comprueba cada poco tiempo la posición del jugador
func _on_timer_timeout() -> void:
	var jugador = get_node_or_null("/root/Node2D/PacmanPlayer")
	if jugador:
		posicion_jugador = jugador.global_position
		$NavigationAgent2D.target_position = posicion_jugador
