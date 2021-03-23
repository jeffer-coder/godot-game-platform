extends KinematicBody2D

onready var sprite = $Sprite

const GRAVITY = 1000
const ACCELERATION = 500
const VELOCITY = 150
const JUMPING = 300
const FRICTION_WALL = 25
const FRICTION_AIR = 0.10
const FRICTION_FLOOR = 1

var _snap_direction = Vector2.DOWN
var _snap_lenght = 10
var _snap_vector = _snap_direction * _snap_lenght
var _floor_max_angle = deg2rad(46)

var dir = 0
var physic = Vector2.ZERO;
var facing = false;

var coyote_can_jump = true;
var jump_was_pressed = false;

var rc_aside = false
var lc_aside = false;

var _moving = true;

var _anim_idle = false;
var _anim_walk = false;
var _anim_jump = false;
var _anim_fall = false;
var _anim_wall = false;


func _process(delta):

	_anim_idle = is_on_floor() and !abs(physic.x);
	_anim_walk = is_on_floor() and  abs(physic.x);
	_anim_jump = !is_on_floor() and physic.y < 0 and !(rc_aside || lc_aside)
	_anim_fall = !is_on_floor() and physic.y > 0 and !(rc_aside || lc_aside)
	_anim_wall = (rc_aside or lc_aside) and !is_on_floor() and physic.y > 0

	if _anim_idle: sprite.animation = "idle"
	if _anim_walk: sprite.animation = "walk"
	if _anim_jump: sprite.animation = "jump"
	if _anim_fall: sprite.animation = "fall"
	if _anim_wall: sprite.animation = "wall"


func _physics_process(delta):



	#fliping
	if dir: facing = dir < 0
	
	# change direction
	sprite.flip_h = facing
	
	# gravity
	physic.y += GRAVITY * delta;
	
	if is_on_floor(): 
		coyote_can_jump = true

		# jump is was pressed
		if jump_was_pressed:
			_jumping ()

	# dir
	dir = (-Input.get_action_strength("ui_left")) + Input.get_action_strength("ui_right")
	
	# velocity
	if dir:
		if (_moving):
			physic.x += dir * (ACCELERATION * 10) * delta
			physic.x = clamp(physic.x,-VELOCITY,VELOCITY);
	else: 
		
		# friction on floor
		if is_on_floor() and _moving: physic.x = lerp(physic.x,0,FRICTION_FLOOR);
		# friction on air
		else: physic.x = lerp(physic.x,0,FRICTION_AIR);
	
	
	# jumping
	if Input.is_action_just_pressed("ui_up"):

		#remember jump key was pressed
		jump_was_pressed = true;
		remember_jump_timer()

		if coyote_can_jump:
			_jumping ()


	# reset snap_vector
	if is_on_floor() and (!Input.is_action_just_pressed("ui_up") and !jump_was_pressed) and _snap_vector == Vector2.ZERO:
		_snap_vector = _snap_direction * _snap_lenght
	
	# reset coyote jump
	if !is_on_floor(): coyote_time()
	
	# wall slider
	if ((rc_aside or lc_aside) and !is_on_floor() and physic.y > 0):
		physic.y = FRICTION_WALL

		# jumping wall
		if Input.is_action_just_pressed("ui_up"):
			_moving = false
			physic.x = 100 * -dir
			_snap_vector = Vector2.ZERO;
			physic.y = -250
			jump_wall_time ()

	physic = move_and_slide_with_snap(physic,_snap_vector,Vector2.UP,true,4,_floor_max_angle)

func remember_jump_timer():
	yield(get_tree().create_timer(.1),"timeout")
	jump_was_pressed = false
	

func coyote_time ():
	yield(get_tree().create_timer(.1),"timeout")
	coyote_can_jump = false
	pass
	
func jump_wall_time ():
	yield(get_tree().create_timer(0.15),"timeout")
	_moving = true
	pass

	
func _jumping ():
	_snap_vector = Vector2.ZERO;
	physic.y = -JUMPING


func _on_RCollider_body_entered(body):

	
	
	if (body.get_collision_layer() == 8): rc_aside = true

	pass # Replace with function body.


func _on_RCollider_body_exited(body):
	if (body.get_collision_layer() == 8): rc_aside = false
	pass # Replace with function body.


func _on_LCollider_body_entered(body):
	if (body.get_collision_layer() == 8): lc_aside = true
	pass # Replace with function body.


func _on_LCollider_body_exited(body):
	if (body.get_collision_layer() == 8): lc_aside = false
	pass # Replace with function body.
