# PHILIPPINES LIFE: OPEN WORLD — Starter 0.1

Ito ay **Godot 4.x** starter project para sa Android-first 3D open-world life simulator.

## Kasalukuyang laman
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
- account registration/login backend
- avatar creator at cloud save
- GPS permission/location integration
- tunay na Philippine road/building dataset
- vehicles, jobs, economy, interiors
- online multiplayer synchronization
- optimized terrain streaming at final art

## Susunod na development milestones
1. Avatar creator + account/authentication
2. Philippine map data pipeline at region streaming
3. Vehicle system (jeepney, tricycle, taxi, motorcycle)
4. NPC schedules/interactions and life simulation
5. Secure approximate-location spawn system
6. Multiplayer presence and persistence
7. Android export, device profiling and optimization

## Safety and privacy
Huwag i-broadcast ang exact home GPS coordinates. Gumamit ng approximate public location, private home assignment, explicit permission, at user-controlled visibility.
