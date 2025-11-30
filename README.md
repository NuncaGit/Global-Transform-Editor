<img width="1582" height="799" alt="Captura de tela 2025-11-30 104112" src="https://github.com/user-attachments/assets/948abef2-db63-47a1-a79b-fa7accf5e61d" />

# Global Transform Editor

Adds **Global Position** and **Global Rotation** fields to the top of the Inspector for any `Node3D`.

## Features

- **Global View/Edit:** Modify absolute world coordinates using standard sliders.
- **Script Ready:** The "Copy" button places the `Vector3(...)` string into your clipboard for direct use in GDScript.
- **Performance:** Collapsible sections. Stops processing when closed or when the node is deselected.

## How to Use

1. Select a `Node3D`.
2. Expand **Global Position** or **Global Rotation** at the top of the Inspector.
3. Drag sliders to modify values.
4. Click **Copy** to get the Vector3 code.

## Installation

1. Place the plugin folder in `res://addons/`.
2. Enable it in **Project Settings > Plugins**.
