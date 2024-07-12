extends CharacterBody2D

const speed = 140
var current_dir = "none"
var last_movement_dir = Vector2.ZERO

var enemy_inattack_range = false
var enemy_attack_cooldown = true
var health = 100
var player_alive = true

var attack_ip = false
var in_combat = false  # Variable para indicar si el jugador está en combate

func _ready():
	$AnimatedSprite2D.play("idle_down")
	$regen_timer.start()  # Inicia el temporizador aquí

func _physics_process(delta):
	enemy_attack()
	player_movement(delta)
	attack()
	update_health()
	
	if health <= 0:
		player_alive = false
		health = 0
		print("player has been killed")
		self.queue_free()

func player_movement(_delta):
	var direction = Vector2.ZERO

	if Input.is_action_pressed("ui_right"):
		direction.x += 1
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_down"):
		direction.y += 1
	if Input.is_action_pressed("ui_up"):
		direction.y -= 1

	direction = direction.normalized()
	velocity = direction * speed

	if direction.length() > 0:
		last_movement_dir = direction
		play_anim(1, direction)
	else:
		play_anim(0, last_movement_dir)

	move_and_slide()

func play_anim(movement, direction):
	var anim = $AnimatedSprite2D

	if direction.x > 0:
		anim.flip_h = false
		current_dir = "right"
		if movement == 1:
			anim.play("walk_right")
		else:
			if attack_ip == false:
				anim.play("idle_right")

	elif direction.x < 0:
		anim.flip_h = true
		current_dir = "left"
		if movement == 1:
			anim.play("walk_right")
		else:
			if attack_ip == false:
				anim.play("idle_right")

	elif direction.y > 0:
		anim.flip_h = false
		current_dir = "down"
		if movement == 1:
			anim.play("walk_down")
		else:
			if attack_ip == false:
				anim.play("idle_down")

	elif direction.y < 0:
		anim.flip_h = false
		current_dir = "up"
		if movement == 1:
			anim.play("walk_up")
		else:
			if attack_ip == false:
				anim.play("idle_up")

func player():
	pass

func _on_player_hitbox_body_entered(body):
	if body.has_method("enemy"):
		enemy_inattack_range = true
		in_combat = true
		print("En combate")

func _on_player_hitbox_body_exited(body):
	if body.has_method("enemy"):
		enemy_inattack_range = false
		in_combat = false
		print("Fuera de combate")

func enemy_attack():
	if enemy_inattack_range and enemy_attack_cooldown == true:
		health = health - 20
		enemy_attack_cooldown = false
		$attack_cooldown.start()
		print(health)

func _on_attack_cooldown_timeout():
	enemy_attack_cooldown = true
	
func attack():
	var dir = current_dir
	if Input.is_action_just_pressed("attack"):
		Global.player_current_attack = true
		attack_ip = true
		if dir == "right":
			$AnimatedSprite2D.flip_h = false
			$AnimatedSprite2D.play("attack_right")
			$deal_attack_timer.start()
		if dir == "left":
			$AnimatedSprite2D.flip_h = true
			$AnimatedSprite2D.play("attack_right")
			$deal_attack_timer.start()
		if dir == "down":
			$AnimatedSprite2D.play("attack_down")
			$deal_attack_timer.start()
		if dir == "up":
			$AnimatedSprite2D.play("attack_up")
			$deal_attack_timer.start()

func _on_deal_attack_timer_timeout():
	$deal_attack_timer.stop()
	Global.player_current_attack = false
	attack_ip = false

func update_health():
	var healthbar = $healthbar
	healthbar.value = health
	if health >= 100:
		healthbar.visible = false
	else: 
		healthbar.visible = true

func _on_regen_timer_timeout():
	if not in_combat and health < 100:  # Verifica si no está en combate y si la salud está por debajo de 100
		print("Regen timer timeout")
		health += 20
		if health > 100:
			health = 100
		print("Current health: ", health)
		update_health()
