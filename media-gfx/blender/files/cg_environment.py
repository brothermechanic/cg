#!/usr/bin/python3
# -*- coding: utf-8 -*-
# Copyright (C) 2023 Ilia Kurochkin <brothermechanic@gmail.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

__doc__ = 'Environment for use CG Overlay'
__version__ = '0.1'

import bpy
from bpy.app.handlers import persistent


@persistent
def cg_env():
    '''Scripts environment'''
    cg_blender_scripts_dir = ''
    if cg_blender_scripts_dir not in bpy.utils.script_paths_pref():
        script_directories = bpy.context.preferences.filepaths.script_directories
        new_dir = script_directories.new()
        new_dir.directory = cg_blender_scripts_dir
        new_dir.name = "CG_BLENDER_SCRIPTS_DIR"

    print("CG Environment activated!")


def register():
    '''register blender module'''
    bpy.app.handlers.load_post.append(cg_env)


def unregister():
    '''unregister blender module'''
    bpy.app.handlers.load_post.remove(cg_env)


if __name__ == "__main__":
    register()
