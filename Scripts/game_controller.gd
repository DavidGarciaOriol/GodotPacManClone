class_name GameController
extends Node

# Máquina de estados de partida
enum EstadosPartida{
	PartidaEnCurso,
	Pausa,
	Victoria,
	GameOver
}

# Estado inicial por defecto de la partida
var estado_actual: EstadosPartida = EstadosPartida.PartidaEnCurso

# Vidas del jugador
@export var vidas: int = 3

# Label vidas
@export var label_vidas: Label

# Puntuación del jugador
var puntuacion: int = 0

# Multiplicador de puntos al atrapar fantasmas consecutivos
var multiplicador_puntos: int = 1

# Label puntuación
@export var label_puntuacion: Label

# Cantidad de objetos punto y puntos grandes recogidos por el jugador
var numero_puntos_recogidos: int = 0

# Total de puntos y puntos grandes del nivel
var numero_maximo_puntos_nivel: int = 0

@export var label_objetivo_puntos: Label
@export var pacman: CharacterBody2D
@export var fantasma_amarillo: CharacterBody2D
@export var fantasma_azul: CharacterBody2D
@export var fantasma_rojo: CharacterBody2D
@export var fantasma_rosa: CharacterBody2D
@export var escaner_puntos: Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if escaner_puntos:
		escaner_puntos.total_puntos_escaneados.connect(establecer_maximo_numero_puntos)
	
	if pacman:
		pacman.vida_perdida.connect(perder_vida)
		pacman.sumar_puntos.connect(sumar_puntuacion)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

### CONTROL DE LA PUNTUACIÓN DEL JUGADOR ###

# Suma puntuación al jugador cuando recoge puntos de cualquier tipo
func sumar_puntuacion(cantidad: int):
	puntuacion += cantidad
	sumar_numero_puntos()
	modificar_display_puntuacion()

# Suma puntos al jugador cuando atrapa a un fantasma en estado invencible
func sumar_puntos_fantasma(cantidad: int):
	puntuacion += cantidad * multiplicador_puntos
	aumentar_multiplicador_puntos()
	modificar_display_puntuacion()

# Multiplica los puntos obtenidos al atrapar fantasmas consecutivos
func aumentar_multiplicador_puntos():
	multiplicador_puntos *= 2

# Reinicia el multiplicador de puntos cuando pacman deja de ser invencible
func reiniciar_multiplicador_puntos():
	multiplicador_puntos = 1

# Modifica el display de las puntuaciones
func modificar_display_puntuacion():
	if label_puntuacion:
		label_puntuacion.text = "Puntos: " + str(puntuacion)

### CONTROL DEL NÚMERO DE PUNTOS/PELLETS TOTALES DEL NIVEL ###

# Establece el número objetivo de puntos que debe recoger el jugador durante una partida
# Un escáner le dará esta información al método
func establecer_maximo_numero_puntos(cantidad_maxima: int):
	numero_maximo_puntos_nivel = cantidad_maxima
	modificar_display_ojetivo_puntos()

# Suma puntos a la cantidad obtenida del total necesario para completar el nivel
func sumar_numero_puntos():
	numero_puntos_recogidos += 1
	modificar_display_ojetivo_puntos()
	comprueba_victoria()

# Modifica el display que muestra los puntos obtenidos respecto a los necesarios
func modificar_display_ojetivo_puntos():
	if label_objetivo_puntos:
		label_objetivo_puntos.text = "Meta " + str(numero_puntos_recogidos) + "/" + str(numero_maximo_puntos_nivel)

# Comprueba si puede acceder al estado de victoria verificando
# los puntos recogidos respecto a los objetivos del nivel
func comprueba_victoria():
	if numero_puntos_recogidos >= numero_maximo_puntos_nivel:
		victoria()

### CONTROL DE VIDAS DE PACMAN ###

# Pierde una vida del total
# Ocurre cuando pacman llama a su método
# de perder vida al ser golpeado por un fantasma
func perder_vida():	
	if vidas > 0:
		vidas -= 1
		modificar_display_vidas()
		comprueba_game_over()
		
		if estado_actual == EstadosPartida.PartidaEnCurso:
			proceso_perder_vida()

# Proceso tras perder una vida
# Se pausa la pantalla y se reinician las posiciones
func proceso_perder_vida():
	
	# Pausar la partida
	pausar()
	
	# Esperar dos segundos
	await get_tree().create_timer(2.0).timeout
	
	# Los fantasmas y pacman retornan a su posición inicial
	reiniciar_posiciones()
	
	# Reanudar partida
	reanudar_partida()

# Modifica el display que muestra las vidas restantes
func modificar_display_vidas():
	if label_vidas:
		label_vidas.text = "Vidas: " + str(vidas)

# Comprueba las vidas perdidas verificando que no sean cero
func comprueba_game_over():
	if vidas <= 0:
		game_over()

### CONTROL DE ESTADOS DE JUEGO ###

# Cambia el estado de juego a "victoria"
# Ocurre al obtener todos los puntos marcados por el objetivo del nivel
func victoria():
	pass

# Cambia el estado de juego a "game over"
# Ocurre al perder todas las vidas siendo alcanzado por los fantasmas
func game_over():
	modificar_estado(EstadosPartida.GameOver)

# Cambia el estado de juego a "en pausa"
# Ocurre al pausar el juego
# También cuando pierdes una vida, brevemente el juego cambia a este estado
func pausar():
	modificar_estado(EstadosPartida.Pausa)
	get_tree().paused = true

# Cambia el estado de juego a "partida en curso"
# Reestablece la partida a la normalidad
# Ocurre tras la pausa después de perder una vida
# también al reanudar tras pausar manualmente
# Es el estado por defecto del juego al comenzar la partida
func reanudar_partida():
	modificar_estado(EstadosPartida.PartidaEnCurso)
	get_tree().paused = false

# Función que modifica el estado de juego
func modificar_estado(nuevo_estado: EstadosPartida):
	estado_actual = nuevo_estado

# Retorna a los fantasmas y a pacman a sus posiciones de origen
func reiniciar_posiciones():
	pacman.global_position = pacman.posicion_inicial
	pacman.show()
	
	for fantasma in get_tree().get_nodes_in_group("fantasmas"):
		fantasma.global_position = fantasma.posicion_inicial
		fantasma.cambiar_modo_perseguir()
