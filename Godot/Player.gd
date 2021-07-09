extends RigidBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var cam
var sens = PI/180/10
var aim
var fore = [0, 0]
var left = [0, 0]
var back = [0, 0]
var right = [0, 0]
var lastTime = 0
# Horizontal force applied, in newtons
const ACCEL = 400
# Vertical force applied, in newtons
const JETPACK = 840


# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	cam = get_node("Camera")
	aim = cam.rotation
	# Commented code is to test for framerate dependency
	#Engine.set_iterations_per_second(120)




func _integrate_forces(state):
	cam.rotation = aim-rotation
	var stepSize = state.get_step()
	var glob_xform = get_global_transform()
	# Note that the / 2 term here means that the cylinder's movement is somewhat gradual
	state.set_angular_velocity(Vector3.UP * -(Basis(aim).x.cross(Basis(rotation).x).y / stepSize / 2))
	var move = Vector2.ZERO
	var current = OS.get_ticks_usec()
	move.y += timeMoveHandler(current, fore)
	move.y -= timeMoveHandler(current, back)
	move.x += timeMoveHandler(current, right)
	move.x -= timeMoveHandler(current, left)
	
	move /= (current-lastTime)/1000000.0
	if move.length_squared() > 1:
		move = move.normalized()
	var dir = Vector3()
	dir += -glob_xform.basis.z * move.y
	dir += glob_xform.basis.x * move.x
	# Character can currently fly, need to use collision detection to change
	if Input.is_action_pressed("fp_jump"):
		state.add_central_force(Vector3.UP*JETPACK)
	state.add_central_force(dir * ACCEL)
	lastTime = current

# timestamps are in usecs
func timeMoveHandler(current, timestamps):
	if timestamps[1] == -1:
		var move = (current - timestamps[0])/1000000.0
		timestamps[0] = current
		return move
	elif timestamps[0] < timestamps[1]:
		var move = (timestamps[1] - timestamps[0])/1000000.0
		timestamps[0] = timestamps[1]
		return move
	return 0
	

func _input(event):
	if event is InputEventMouseMotion:
		var movement = event.relative
		aim.x -= movement.y*sens
		aim.y -= movement.x*sens
		if aim.x > PI/2:
			aim.x = PI/2
		if aim.x < -PI/2:
			aim.x = -PI/2
		cam.rotation = aim - rotation
	timePressedHandler(event, "fp_forward", fore)
	timePressedHandler(event, "fp_left", left)
	timePressedHandler(event, "fp_backward", back)
	timePressedHandler(event, "fp_right", right)

func timePressedHandler(event, action, timestamps):
	if event.is_action_pressed(action):
		timestamps[0] = OS.get_ticks_usec()
		timestamps[1] = -1
	elif event.is_action_released(action):
		timestamps[1] = OS.get_ticks_usec()
	
