extends KinematicBody2D

onready var sprite = $Sprite

const GRAVITY = 1000
const ACCELERATION = 500
const VELOCITY = 150
const JUMPING = 300
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



func _physics_process(delta):

	#fliping
	if dir: facing = dir < 0
	
	# change direction
	sprite.flip_h = facing
	
	# gravity
	physic.y += GRAVITY * delta;
	
	# dir
	dir = (-Input.get_action_strength("ui_left")) + Input.get_action_strength("ui_right")
	
	# velocity
	if dir:
		physic.x += dir * (ACCELERATION * 10) * delta
		physic.x = clamp(physic.x,-VELOCITY,VELOCITY);
	else: 
		
		# friction on floor
		if is_on_floor(): physic.x = lerp(physic.x,0,FRICTION_FLOOR);
		# friction on air
		else: physic.x = lerp(physic.x,0,FRICTION_AIR);
	
	
	# jummping
	if Input.is_action_just_pressed("ui_up"):
		if coyote_can_jump: 
			_snap_vector = Vector2.ZERO;
			physic.y = -JUMPING

	
	
	# reset snap_vector
	if is_on_floor() and !Input.is_action_just_pressed("ui_up") and _snap_vector == Vector2.ZERO:
		_snap_vector = _snap_direction * _snap_lenght
	

	if is_on_floor(): coyote_can_jump = true

	# reset coyote jump
	if not is_on_floor(): coyote_time()

	print(coyote_can_jump)
	
	physic = move_and_slide_with_snap(physic,_snap_vector,Vector2.UP,true,4,_floor_max_angle)


func coyote_time ():
	yield(get_tree().create_timer(2),'timeout')
	coyote_can_jump = false
	pass