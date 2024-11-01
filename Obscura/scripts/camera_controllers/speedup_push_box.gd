class_name SpeedupPushBox
extends CameraControllerBase


@export var push_ratio:float = 0.8
@export var pushbox_top_left := Vector2(-10, -10)
@export var pushbox_bottom_right := Vector2(10, 10)
@export var speedup_zone_top_left := Vector2(-5, -5)
@export var speedup_zone_bottom_right := Vector2(5, 5)


func _ready() -> void:
	super()
	position = target.position
	

func _process(delta: float) -> void:
	if !current:
		position = target.position
		return
	
	if draw_camera_logic:
		draw_logic()
	
	var tvel = target.velocity
	var tpos = target.global_position
	var cpos = global_position
	
	# Boundary checks
	# Left
	var diff_between_left_edges = (tpos.x - target.WIDTH / 2.0) - (cpos.x + pushbox_top_left.x)
	var diff_from_left_push = (tpos.x + target.WIDTH / 2.0) - (cpos.x + speedup_zone_top_left.x)
	
	if diff_between_left_edges < 0:
		global_position.x += diff_between_left_edges
	elif diff_from_left_push < 0 and tvel.x < 0:
		global_position.x += tvel.x * push_ratio * delta
	
	# Right
	var diff_between_right_edges = (tpos.x + target.WIDTH / 2.0) - (cpos.x + pushbox_bottom_right.x)
	var diff_from_right_push = (tpos.x - target.WIDTH / 2.0) - (cpos.x + speedup_zone_bottom_right.x)
	
	if diff_between_right_edges > 0:
		global_position.x += diff_between_right_edges
	elif diff_from_right_push > 0 and tvel.x > 0:
		global_position.x += tvel.x * push_ratio * delta
	
	# Top
	var diff_between_top_edges = (tpos.z - target.HEIGHT / 2.0) - (cpos.z + pushbox_top_left.y)
	var diff_from_top_push = (tpos.z + target.WIDTH / 2.0) - (cpos.z + speedup_zone_top_left.y)
	
	if diff_between_top_edges < 0:
		global_position.z += diff_between_top_edges
	elif diff_from_top_push < 0 and tvel.z < 0:
		global_position.z += tvel.z * push_ratio * delta
	
	# Bottom
	var diff_between_bottom_edges = (tpos.z + target.HEIGHT / 2.0) - (cpos.z + pushbox_bottom_right.y)
	var diff_from_bottom_push = (tpos.z - target.WIDTH / 2.0) - (cpos.z + speedup_zone_bottom_right.y)
	
	if diff_between_bottom_edges > 0:
		global_position.z += diff_between_bottom_edges
	elif diff_from_bottom_push > 0 and tvel.z > 0:
		global_position.z += tvel.z * push_ratio * delta
		
	super(delta)


func draw_logic() -> void:
	var mesh_instance := MeshInstance3D.new()
	var immediate_mesh := ImmediateMesh.new()
	var material := ORMMaterial3D.new()
	
	mesh_instance.mesh = immediate_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	
	# Draw outer pushbox
	var pushbox_left:float = pushbox_top_left.y
	var pushbox_right:float = pushbox_bottom_right.y
	var pushbox_top:float = pushbox_top_left.x
	var pushbox_bottom:float = pushbox_bottom_right.x
	
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	immediate_mesh.surface_add_vertex(Vector3(pushbox_right, 0, pushbox_top))
	immediate_mesh.surface_add_vertex(Vector3(pushbox_right, 0, pushbox_bottom))
	
	immediate_mesh.surface_add_vertex(Vector3(pushbox_right, 0, pushbox_bottom))
	immediate_mesh.surface_add_vertex(Vector3(pushbox_left, 0, pushbox_bottom))
	
	immediate_mesh.surface_add_vertex(Vector3(pushbox_left, 0, pushbox_bottom))
	immediate_mesh.surface_add_vertex(Vector3(pushbox_left, 0, pushbox_top))
	
	immediate_mesh.surface_add_vertex(Vector3(pushbox_left, 0, pushbox_top))
	immediate_mesh.surface_add_vertex(Vector3(pushbox_right, 0, pushbox_top))
	
	# Draw inner box
	var speedup_zone_left:float = speedup_zone_top_left.y
	var speedup_zone_right:float = speedup_zone_bottom_right.y
	var speedup_zone_top:float = speedup_zone_top_left.x
	var speedup_zone_bottom:float = speedup_zone_bottom_right.x
	
	immediate_mesh.surface_add_vertex(Vector3(speedup_zone_right, 0, speedup_zone_top))
	immediate_mesh.surface_add_vertex(Vector3(speedup_zone_right, 0, speedup_zone_bottom))
	
	immediate_mesh.surface_add_vertex(Vector3(speedup_zone_right, 0, speedup_zone_bottom))
	immediate_mesh.surface_add_vertex(Vector3(speedup_zone_left, 0, speedup_zone_bottom))
	
	immediate_mesh.surface_add_vertex(Vector3(speedup_zone_left, 0, speedup_zone_bottom))
	immediate_mesh.surface_add_vertex(Vector3(speedup_zone_left, 0, speedup_zone_top))
	
	immediate_mesh.surface_add_vertex(Vector3(speedup_zone_left, 0, speedup_zone_top))
	immediate_mesh.surface_add_vertex(Vector3(speedup_zone_right, 0, speedup_zone_top))
	
	immediate_mesh.surface_end()

	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color.BLACK
	
	add_child(mesh_instance)
	mesh_instance.global_transform = Transform3D.IDENTITY
	mesh_instance.global_position = Vector3(global_position.x, target.global_position.y, global_position.z)
	
	#mesh is freed after one update of _process
	await get_tree().process_frame
	mesh_instance.queue_free()
