extends RigidBody2D
class_name Projectile

var dir: Vector2
var speed: float = 100
var lifetime: float = 10

var color: Color:
	get:
		return modulate
	set(new_val):
		modulate = new_val

func _ready() -> void:
	linear_velocity = dir * speed
	get_tree().create_timer(lifetime).timeout.connect(queue_free)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _physics_process(delta: float) -> void:
#	move_and_collide(linear_velocity)

func collided_with(area: Node2D) -> void:
	if is_queued_for_deletion(): return #dont do shit if we've already hit something
	
	if area is TileMap:
		#TODO BOuncing?
		return
		
	if area is TerritoryTile:
		var ter: TerritoryTile = area as TerritoryTile
		if ter.color != color:
			ter.color = color
			queue_free()


func _on_body_entered(body):
	return
	collided_with(body)


func _on_area_entered(area):
	collided_with(area)



func get_collision_point(body: Node2D) -> void:
	var collision_shape_2d: CollisionShape2D = $CollisionShape2D as CollisionShape2D
	var space_state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	var shape_query: PhysicsShapeQueryParameters2D = PhysicsShapeQueryParameters2D.new()
	shape_query.set_exclude([self])
	shape_query.set_shape(collision_shape_2d.shape)
	shape_query.set_transform(Transform2D(global_rotation, global_position))
	var result = space_state.intersect_shape(shape_query);
	for dict in result:
		print(dict)

func _on_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	var collision_shape_2d: CollisionShape2D = $CollisionShape2D as CollisionShape2D
	var local_shape: Shape2D = collision_shape_2d.shape
	
	var tilemap: TileMap = body as TileMap
	var coord: Vector2i = tilemap.get_coords_for_body_rid(body_rid)
	var layer: int = tilemap.get_layer_for_body_rid(body_rid)
	tilemap.get_cell_tile_data(layer, coord)
	
	pass # Replace with function body.

#func _on_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	#if not body is TileMap: return
	#var cell_collided_with: Vector2i =  body.get_coords_for_body_rid(body_rid)
	#var body
	#var body_shape_owner_id = 
	#var body_shape_owner = body.shape_owner_get_owner(body_shape_owner_id)
	#var body_shape_2d = body.shape_owner_get_shape(body_shape_owner_id, 0)
	#var body_global_transform = body_shape_owner.global_transform
	#
	#var area_shape_owner_id = shape_find_owner(local_shape_index)
	#var area_shape_owner = shape_owner_get_owner(area_shape_owner_id)
	#var area_shape_2d = shape_owner_get_shape(area_shape_owner_id, 0)
	#var area_global_transform = area_shape_owner.global_transform
	#
	#var collision_points = area_shape_2d.collide_and_get_contacts(area_global_transform,
									#body_shape_2d,
									#body_global_transform)
	#print(collision_points)



