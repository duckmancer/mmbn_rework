extends Node

static func scale_vector(v1: Vector2, v2: Vector2) -> Vector2:
	return Vector2(v1.x * v2.x, v1.y * v2.y)

static func frames_to_seconds(frames):
	return float(frames) / Constants.FRAMES_PER_SECOND
