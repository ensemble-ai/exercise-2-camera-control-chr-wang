class_name FollowLerp
extends CameraControllerBase


@export var follow_speed:float = 0.8
@export var catchup_speed:float = 0.3
@export var leash_distance:float = 5.0


func _ready() -> void:
	super()
	position = target.position


func _process(delta: float) -> void:
	if !current:
		position = target.position
		return
	
	if draw_camera_logic:
		draw_logic()
	
	var tvel := target.velocity
	var tpos := target.global_position
	var cpos := global_position
	var dist_from_target := sqrt((tpos.x - cpos.x) ** 2 + (tpos.z - cpos.z) ** 2)
	
	if tvel == Vector3(0, 0, 0):
		# Move toward target once it stops
		if dist_from_target < catchup_speed:
			position = target.position
		else:
			global_position.x += (tpos.x - cpos.x) * catchup_speed / dist_from_target
			global_position.z += (tpos.z - cpos.z) * catchup_speed / dist_from_target
	else:
		# Move in the direction of the target
		global_position.x += tvel.x * follow_speed * delta
		global_position.z += tvel.z * follow_speed * delta
		
		cpos = global_position
		dist_from_target = sqrt((tpos.x - cpos.x) ** 2 + (tpos.z - cpos.z) ** 2)
		var angle = Vector2(cpos.x, cpos.z).angle_to_point(Vector2(tpos.x, tpos.z))
		
		# Stay within leash distance
		if dist_from_target > leash_distance:
			global_position.x = tpos.x - leash_distance * cos(angle)
			global_position.z = tpos.z - leash_distance * sin(angle)
	
	super(delta)


func draw_logic() -> void:
	var mesh_instance := MeshInstance3D.new()
	var immediate_mesh := ImmediateMesh.new()
	var material := ORMMaterial3D.new()
	
	mesh_instance.mesh = immediate_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	
	var cross_height := 5.0
	
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	immediate_mesh.surface_add_vertex(Vector3(0, 0, cross_height))
	immediate_mesh.surface_add_vertex(Vector3(0, 0, -cross_height))
	
	immediate_mesh.surface_add_vertex(Vector3(cross_height, 0, 0))
	immediate_mesh.surface_add_vertex(Vector3(-cross_height, 0, 0))
	immediate_mesh.surface_end()

	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color.BLACK
	
	add_child(mesh_instance)
	mesh_instance.global_transform = Transform3D.IDENTITY
	mesh_instance.global_position = Vector3(global_position.x, target.global_position.y, global_position.z)
	
	#mesh is freed after one update of _process
	await get_tree().process_frame
	mesh_instance.queue_free()
