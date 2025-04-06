extends Node
class_name MathUtils

static func signed_angle_to(a: Vector3, b: Vector3, up: Vector3) -> float:
	"""
	Vector3.angle_to returns the shortest positive angle to another vector,
	this function takes care of keeping the angle sign preserved in relation to the up vector
	"""
	var angle = a.angle_to(b)
	if a.cross(b).dot(up) < 0.0:
		return -angle
	else:
		return angle
