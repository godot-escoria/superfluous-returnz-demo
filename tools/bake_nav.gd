# godot --headless --path . -s res://tools/bake_nav.gd -- res://game/rooms/x.tscn
# Prints the baked navigation polygon of ESCTerrain/NavigationRegion2D.
extends SceneTree

func _initialize():
	await process_frame
	var path: String = OS.get_cmdline_user_args()[0]
	var scene: Node = load(path).instantiate()
	root.add_child(scene)
	await process_frame
	var region: NavigationRegion2D = scene.get_node("ESCTerrain/NavigationRegion2D")
	var np: NavigationPolygon = region.navigation_polygon.duplicate()
	np.agent_radius = 0.0
	np.parsed_geometry_type = NavigationPolygon.PARSED_GEOMETRY_STATIC_COLLIDERS
	np.source_geometry_mode = NavigationPolygon.SOURCE_GEOMETRY_GROUPS_EXPLICIT
	var src := NavigationMeshSourceGeometryData2D.new()
	NavigationServer2D.parse_source_geometry_data(np, src, region)
	NavigationServer2D.bake_from_source_geometry_data(np, src)
	print("VERTS " + ",".join(Array(np.get_vertices()).map(func(p): return "%s,%s" % [snappedf(p.x, 0.001), snappedf(p.y, 0.001)])))
	for i in np.get_polygon_count():
		print("POLY " + ",".join(Array(np.get_polygon(i)).map(func(x): return str(x))))
	quit()
