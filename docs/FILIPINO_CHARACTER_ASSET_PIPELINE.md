# Filipino Character Asset Pipeline

## Goal
Replace the current procedural placeholder avatar with a genuinely modeled, textured, rigged humanoid. The target is a believable adult Filipino/Southeast Asian male protagonist for the Manila/Quiapo vertical slice, not a caricature and not a capsule-based final character.

## Engine and import contract
- Engine: Godot 4.3, GL Compatibility renderer.
- Preferred delivery: one `.glb` (glTF 2.0 binary) with embedded PBR materials and a humanoid skeleton.
- Target file: `res://assets/characters/filipino_male.glb`.
- Forward direction: Godot character faces local **-Z**. If the source faces +Z, correct the orientation in Blender before export.
- Character height: approximately 1.70–1.80 m; feet at Y=0; origin centered between the feet.
- Apply transforms; use meters; avoid unapplied negative scale.
- Include a humanoid armature and at least Idle, Walk and Run animations. Keep the rig deformation clean at shoulders, elbows, hips and knees.
- Use 2K textures for the first desktop-quality source; create/ship 1K mobile textures after profiling. Prefer packed ORM maps if supported by the material workflow.
- Keep the first playable character within a practical mobile budget; remove hidden geometry and excessive material slots.

## Free asset creation route
1. Generate or build a neutral adult male base using a self-hosted/open-source human generator such as Ara 3D Gen, or MakeHuman/MPFB. Do not assume an output is Filipino just because a prompt says so; inspect the face, proportions and skin tone.
2. Refine in Blender: natural Southeast Asian facial proportions, medium warm brown skin, dark brown eyes, black hair, realistic but ordinary build, and everyday Manila clothing (plain shirt, jeans/trousers and practical sneakers). Avoid stereotyped costume details.
3. Create UVs and PBR textures; inspect the face and hands close-up. Do not bake in text/logos.
4. Rig and animate with a compatible humanoid rig. Mixamo can be used for a quick animation pass if its current account terms and the source model's license permit it. Verify licensing before shipping.
5. Export as GLB and place it at `assets/characters/filipino_male.glb`.
6. Open in Godot 4.3, inspect the imported skeleton/materials/animations, then test on an Android device.

## License and provenance
Record the source generator, model author, model license, texture sources and animation source in `assets/characters/ASSET_CREDITS.md`. Never ship a downloaded model until its individual license explicitly permits the intended game use. A free download is not automatically public domain or commercially usable.

## Acceptance checks
- Not a primitive capsule/box character.
- Face, hands, hair, clothing and footwear are textured and proportionate.
- No missing textures, pink materials, broken normals or visible rig tears.
- Idle/Walk/Run play correctly; feet do not slide excessively.
- Character faces the same direction as movement and camera framing is correct.
- Android test shows acceptable frame time and memory use.
- Actual in-engine screenshot and device test are required before calling the character complete.

## Current status
The repository currently contains a procedural avatar assembled from primitive meshes. This pipeline defines the real-model handoff, but it does **not** claim that a realistic GLB has already been generated. The model file is intentionally not fabricated or silently replaced with concept art.
