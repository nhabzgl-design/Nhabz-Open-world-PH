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

    var camera := scene.get_node_or_null("Player/CameraPivot/Camera3D") as Camera3D
    if camera == null:
        push_error("Main camera is missing")
        quit(1)
        return
    camera.global_position = Vector3(34, 27, 48)
    camera.look_at(Vector3(0, 0, -10), Vector3.UP)
    camera.current = true

    for i in range(8):
        await process_frame
    await RenderingServer.frame_post_draw

    var viewport_image := root.get_viewport().get_texture().get_image()
    var save_error := viewport_image.save_png("philippines_world_preview.png")
    if save_error != OK:
        push_error("Failed to save world preview: " + str(save_error))
        quit(1)
        return

    print("Saved philippines_world_preview.png")
    quit(0)
