# PHILIPPINES LIFE: OPEN WORLD — Starter 0.1

Ito ay **Godot 4.x** starter project para sa Android-first 3D open-world life simulator.

## Kasalukuyang laman
- Registration/login screen prototype (local device storage only; not cloud authentication)
- Character creator prototype: character name, skin tone, hairstyle, outfit
- Saved avatar is assembled in-game from simple 3D parts
- 3D starter town prototype
- Third-person player capsule at follow camera
- Basic movement at jump
- Touchscreen movement buttons
- Simple Philippine-inspired roadside, beach, buildings, trees at placeholder NPCs
- Mobile-friendly Godot Compatibility renderer

## Kailangan
- Godot Engine 4.3 o mas bago (4.x)
- Android export templates at Android SDK/JDK para gumawa ng APK

## Paano buksan
1. I-clone o i-download ang repository.
2. Buksan ang Godot.
3. Piliin ang Import, pagkatapos piliin ang `project.godot`.
4. Patakbuhin ang `scenes/Main.tscn`.

## Mahalagang status
Hindi pa ito final game at hindi pa APK. Ito ang unang playable foundation. Placeholder geometry pa ang mga gusali/NPC at wala pang:
- secure account registration/login backend (current UI is local-only prototype)
- cloud avatar save and cross-device account sync
- GPS permission/location integration
- tunay na Philippine road/building dataset
- vehicles, jobs, economy, interiors
- online multiplayer synchronization
- optimized terrain streaming at final art

## Development scope: Manila muna
Hindi muna bubuuin ang buong Pilipinas nang sabay-sabay. Ang unang playable region ay isang maliit at bounded na bahagi ng **Manila** (unang target district: Quiapo-inspired urban core), saka lamang palalawakin kapag pasado ang performance at gameplay.

### Manila vertical slice — unang release target
- Isang compact na magkakaugnay na urban district na may ilang city blocks, hindi buong Metro Manila.
- Mga landmark at lugar na madaling makilala: simbahan/plaza-inspired civic landmark, city/barangay service point, palengke at sari-sari stores.
- Street network na may sidewalks, crossings, alleys, storefronts at local signage.
- Jeepney, tricycle, motorsiklo, taxi at private cars sa limitadong test routes.
- Pedestrians/NPCs na may idle, walk at simple daily routines.
- Player home/spawn point at ilang unang missions: maglakad, bumili sa tindahan, sumakay ng jeepney at pumunta sa civic landmark.
- Optimize assets, draw calls, shadows at texture sizes para sa Android bago dagdagan ang lawak.

### Quality gate bago palawakin
- Gumamit ng tunay na humanoid at vehicle 3D assets (GLB/glTF na may materials; humanoid rig/animations), hindi primitive capsules/boxes bilang final art.
- Ipakita ang aktuwal na in-engine gameplay screenshot at Android performance test.
- Huwag markahang complete ang isang feature kung placeholder lamang ito.
- Panatilihin sa development branch hanggang ma-review at maaprubahan ng user.

### Expansion roadmap pagkatapos ng Manila
1. Iba pang bahagi ng Manila at karatig-lungsod sa Metro Manila.
2. Cebu City.
3. Davao City.
4. Baguio at iba pang pangunahing lungsod/probinsya.
5. Regional streaming at mas malawak na Philippines map.

## Susunod na development milestones
1. Build the compact Manila district vertical slice and validate actual gameplay.
2. Replace placeholder player/NPC/vehicle assets with rigged, textured 3D models.
3. Add NPC schedules, interactions, jobs and basic life simulation.
4. Add jeepney/tricycle/taxi/motorcycle driving and passenger flow.
5. Add secure cloud authentication and avatar persistence after review.
6. Add secure approximate-location spawn system (never expose exact home GPS).
7. Add multiplayer presence, persistence, Android export and device profiling.

## Safety and privacy
Huwag i-broadcast ang exact home GPS coordinates. Gumamit ng approximate public location, private home assignment, explicit permission, at user-controlled visibility.
