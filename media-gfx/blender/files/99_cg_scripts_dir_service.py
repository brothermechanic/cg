#!/usr/bin/python3
# coding: utf-8
'''
Copyright (C) 2024 brothermechanic@yandex.com

Created by brothermechanic

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
'''

__doc__ = 'CG Scripts Directory Setup'
__version__ = '0.2'

import bpy
from bpy.app.handlers import persistent


@persistent
def cg_scripts_dir_service(dummy):
    '''Scripts environment'''
    cg_blender_scripts_dir = ''
    if cg_blender_scripts_dir not in bpy.utils.script_paths_pref():
        script_directories = bpy.context.preferences.filepaths.script_directories
        new_dir = script_directories.new()
        new_dir.directory = cg_blender_scripts_dir
        new_dir.name = 'CG_BLENDER_SCRIPTS_DIR'
        print('CG Scripts Directory Activated!')
        bpy.ops.wm.save_userpref()
        bpy.ops.wm.quit_blender()

    return True


def register():
    '''register blender module'''
    bpy.app.handlers.load_post.append(cg_scripts_dir_service)


def unregister():
    '''unregister blender module'''
    bpy.app.handlers.load_post.remove(cg_scripts_dir_service)


if __name__ == '__main__':
    register()
