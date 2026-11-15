extends Node3D

func _ready() -> void:
    _build_environment()
    _build_ground()
    _build_island_landmarks()
    _build_npcs()
    _build_welcome_label()

func _build_environment() -> void:
    var env := WorldEnvironment.new()
    var environment := Environment.new()
    environment.background_mode = Environment.BG_SKY
    var sky := Sky.new()
    var sky_mat := ProceduralSkyMaterial.new()
    sky.sky_material = sky_mat
    environment.sky = sky
    environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    environment.ambient_light_color = Color(0.72, 0.79, 0.86)
    environment.ambient_light_energy = 0.8
    env.environment = environment
    add_child(env)

    var sun := DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-48, -32, 0)
    sun.light_energy = 1.15
    sun.shadow_enabled = true
    add_child(sun)

func _build_ground() -> void:
    var ground := StaticBody3D.new()
    ground.name = "Ground"
    add_child(ground)

    var mesh := MeshInstance3D.new()
    var plane := PlaneMesh.new()
    plane.size = Vector2(180, 180)
    mesh.mesh = plane
    var mat := StandardMaterial3D.new()
    mat.albedo_color = Color(0.28, 0.48, 0.25)
    mat.roughness = 1.0
    mesh.material_override = mat
    ground.add_child(mesh)

    var collision := CollisionShape3D.new()
    var shape := BoxShape3D.new()
    shape.size = Vector3(180, 0.5, 180)
    collision.shape = shape
    collision.position.y = -0.25
    ground.add_child(collision)

    # Simple beach strip beside the starter town.
    var beach := MeshInstance3D.new()
    var beach_mesh := PlaneMesh.new()
    beach_mesh.size = Vector2(180, 14)
    beach.mesh = beach_mesh
    beach.position = Vector3(0, 0.015, -73)
    var sand := StandardMaterial3D.new()
    sand.albedo_color = Color(0.78, 0.68, 0.48)
    beach.material_override = sand
    add_child(beach)

func _build_island_landmarks() -> void:
    _make_road(Vector3(0, 0.04, 0), Vector3(12, 0.08, 120), Color(0.17, 0.18, 0.19))
    _make_road(Vector3(0, 0.045, -24), Vector3(90, 0.08, 8), Color(0.17, 0.18, 0.19))
    _make_building(Vector3(-12, 0, -12), Vector3(9, 6, 8), Color(0.82, 0.72, 0.53), "Sari-Sari Store")
    _make_building(Vector3(15, 0, -16), Vector3(10, 8, 10), Color(0.72, 0.75, 0.78), "Town Hall")
    _make_building(Vector3(-18, 0, 16), Vector3(8, 5, 9), Color(0.75, 0.48, 0.32), "Player Home")
    _make_tree(Vector3(-28, 0, -8))
    _make_tree(Vector3(28, 0, 9))
    _make_tree(Vector3(24, 0, -34))
    _make_tree(Vector3(-30, 0, 34))

func _make_road(pos: Vector3, size: Vector3, color: Color) -> void:
    var road := MeshInstance3D.new()
    var box := BoxMesh.new()
    box.size = size
    road.mesh = box
    road.position = pos
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    road.material_override = mat
    add_child(road)

func _make_building(pos: Vector3, size: Vector3, color: Color, label: String) -> void:
    var body := StaticBody3D.new()
    body.position = pos + Vector3(0, size.y / 2.0, 0)
    add_child(body)
    var mesh := MeshInstance3D.new()
    var box := BoxMesh.new()
    box.size = size
    mesh.mesh = box
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    mesh.material_override = mat
    body.add_child(mesh)
    var collision := CollisionShape3D.new()
    var shape := BoxShape3D.new()
    shape.size = size
    collision.shape = shape
    body.add_child(collision)

func _make_tree(pos: Vector3) -> void:
    var trunk := MeshInstance3D.new()
    var cylinder := CylinderMesh.new()
    cylinder.top_radius = 0.22
    cylinder.bottom_radius = 0.32
    cylinder.height = 2.4
    trunk.mesh = cylinder
    trunk.position = pos + Vector3(0, 1.2, 0)
    var trunk_mat := StandardMaterial3D.new()
    trunk_mat.albedo_color = Color(0.32, 0.19, 0.1)
    trunk.material_override = trunk_mat
    add_child(trunk)

    var leaves := MeshInstance3D.new()
    var sphere := SphereMesh.new()
    sphere.radius = 1.5
    sphere.height = 2.4
    leaves.mesh = sphere
    leaves.position = pos + Vector3(0, 3.0, 0)
    var leaf_mat := StandardMaterial3D.new()
    leaf_mat.albedo_color = Color(0.12, 0.38, 0.16)
    leaves.material_override = leaf_mat
    add_child(leaves)

func _build_npcs() -> void:
    for i in range(5):
        var npc := MeshInstance3D.new()
        var capsule := CapsuleMesh.new()
        capsule.radius = 0.35
        capsule.height = 1.7
        npc.mesh = capsule
        npc.position = Vector3(-8 + i * 4, 0.85, -5 - (i % 2) * 3)
        var mat := StandardMaterial3D.new()
        mat.albedo_color = [Color(0.75,0.35,0.22), Color(0.2,0.35,0.75), Color(0.8,0.7,0.25)][i % 3]
        npc.material_override = mat
        add_child(npc)

func _build_welcome_label() -> void:
    var label := Label3D.new()
    label.text = "MALIGAYANG PAGDATING SA PILIPINAS!"
    label.position = Vector3(0, 4, -28)
    label.font_size = 48
    label.modulate = Color(1, 0.95, 0.72)
    add_child(label)
