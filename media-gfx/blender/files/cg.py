import bpy

if not bpy.context.preferences.filepaths.script_directories:
    bpy.ops.preferences.script_directory_add(
        directory=""
    )
