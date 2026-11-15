extends SceneTree

func _initialize() -> void:
    call_deferred("_capture_world")

func _capture_world() -> void:
    var packed := load("res://scenes/Main.tscn") as PackedScene
    if packed == null:
        push_error("Could not load Main.tscn")
        quit(1)
        return

    var scene := packed.instantiate()
    root.add_child(scene)
    await process_frame

    var onboarding := scene.get_node_or_null("Onboarding")
    if onboarding:
        onboarding.visible = false
    var hud := scene.get_node_or_null("MobileHUD")
    if hud:
        hud.visible = false

    # Use a dedicated preview camera outside the moving Player rig.
    var old_camera := scene.get_node_or_null("Player/CameraPivot/Camera3D")
    if old_camera:
        old_camera.current = false
    var camera := Camera3D.new()
    camera.name = "PreviewCamera"
    camera.fov = 58.0
    scene.add_child(camera)
    camera.global_position = Vector3(48, 34, 62)
    camera.look_at(Vector3(0, 1.5, -14), Vector3.UP)
    camera.current = true

    for i in range(20):
        await process_frame
    await RenderingServer.frame_post_draw

    var viewport_image := root.get_viewport().get_texture().get_image()
    var save_error := viewport_image.save_png("philippines_world_preview.png")
    if save_error != OK:
        push_error("Failed to save world preview: " + str(save_error))
        quit(1)
        return

    print("Saved philippines_world_preview.png size=", viewport_image.get_size())
    quit(0)
