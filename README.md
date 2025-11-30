
<img width="1407" height="745" alt="Captura de tela 2025-11-30 170617" src="https://github.com/user-attachments/assets/8d8788ab-2d04-4934-bd68-98f9f9cd5045" />

# Global Transform Editor

Adds **Global Position** and **Global Rotation** fields to the top of the Inspector for any `Node3D`.

## Features

- **Global View/Edit:** Modify absolute world coordinates using standard sliders.
- **Smart Copy/Paste:** Use the icons to transfer global transforms between nodes.
  - **Copy:** Saves the `Vector3(...)` string to the system clipboard.
  - **Paste:** Reads `Vector3(...)` text from the clipboard and applies it (supports Undo/Redo).
- **Performance:** Collapsible sections. Stops processing when closed or when the node is deselected.

## How to Use

1. Select a `Node3D`.
2. Expand **Global Position** or **Global Rotation** at the top of the Inspector.
3. Drag sliders to modify values.
4. Use the **Copy/Paste icons** to transfer values between objects or scripts.

## Installation

1. Place the plugin folder in `res://addons/`.
2. Enable it in **Project Settings > Plugins**.
