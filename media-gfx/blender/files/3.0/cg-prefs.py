import bpy
from bpy.app.handlers import persistent
@persistent
def cg_prefs(dummy):
    bpy.context.preferences.inputs.view_rotate_method = "TRACKBALL"
    bpy.context.preferences.addons['mesh_f2'].preferences.autograb = False
def register():
    bpy.app.handlers.load_post.append(cg_prefs)
def unregister():
    pass
if __name__ == "__main__":
    register()
