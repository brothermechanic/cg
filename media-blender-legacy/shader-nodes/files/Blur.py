#
#   Node Authors: Rudy Michau
#
#   Node Description: Blur
#
#   version: (0,0,1)
#

import bpy
import os
from glob import glob
from os import path
import re
from bpy.props import FloatProperty, EnumProperty, BoolProperty, IntProperty, StringProperty, FloatVectorProperty, CollectionProperty
from bpy_extras.io_utils import ImportHelper, ExportHelper
from ShaderNodeBase import ShaderNodeBase

class Blur(ShaderNodeBase):

    bl_name='Blur'
    bl_label='Blur'
    bl_icon='NONE'

    def updateFilePath(self, context):
        self.addNode('ShaderNodeTexImage', {'name':'Image Texture.001'})
        self.addLink('nodes["Mix.012"].outputs[0]', 'nodes["Image Texture.001"].inputs[0]')
        self.addLink('nodes["Image Texture.001"].outputs[0]', 'nodes["Mix.Image.001"].inputs[1]')

        self.addNode('ShaderNodeTexImage', {'name':'Image Texture.002'})
        self.addLink('nodes["Mix.013"].outputs[0]', 'nodes["Image Texture.002"].inputs[0]')
        self.addLink('nodes["Image Texture.002"].outputs[0]', 'nodes["Mix.Image.001"].inputs[2]')

        self.addNode('ShaderNodeTexImage', {'name':'Image Texture.003'})
        self.addLink('nodes["Mix.015"].outputs[0]', 'nodes["Image Texture.003"].inputs[0]')
        self.addLink('nodes["Image Texture.003"].outputs[0]', 'nodes["Mix.Image.002"].inputs[1]')

        self.addNode('ShaderNodeTexImage', {'name':'Image Texture.004'})
        self.addLink('nodes["Mix.016"].outputs[0]', 'nodes["Image Texture.004"].inputs[0]')
        self.addLink('nodes["Image Texture.004"].outputs[0]', 'nodes["Mix.Image.002"].inputs[2]')

        self.addNode('ShaderNodeTexImage', {'name':'Image Texture.005'})
        self.addLink('nodes["Mix.018"].outputs[0]', 'nodes["Image Texture.005"].inputs[0]')
        self.addLink('nodes["Image Texture.005"].outputs[0]', 'nodes["Mix.Image.003"].inputs[1]')

        self.addNode('ShaderNodeTexImage', {'name':'Image Texture.006'})
        self.addLink('nodes["Mix.020"].outputs[0]', 'nodes["Image Texture.006"].inputs[0]')
        self.addLink('nodes["Image Texture.006"].outputs[0]', 'nodes["Mix.Image.003"].inputs[2]')

        self.addNode('ShaderNodeTexImage', {'name':'Image Texture.007'})
        self.addLink('nodes["Mix.022"].outputs[0]', 'nodes["Image Texture.007"].inputs[0]')
        self.addLink('nodes["Image Texture.007"].outputs[0]', 'nodes["Mix.Image.004"].inputs[1]')

        self.addNode('ShaderNodeTexImage', {'name':'Image Texture.008'})
        self.addLink('nodes["Mix.024"].outputs[0]', 'nodes["Image Texture.008"].inputs[0]')
        self.addLink('nodes["Image Texture.008"].outputs[0]', 'nodes["Mix.Image.004"].inputs[2]')

        selectedfile = bpy.path.basename(self.filepath)
        bpy.data.images.load(self.filepath, check_existing=False)
        self.node_tree.nodes['Image Texture.001'].image = bpy.data.images[selectedfile]
        self.node_tree.nodes['Image Texture.002'].image = bpy.data.images[selectedfile]
        self.node_tree.nodes['Image Texture.003'].image = bpy.data.images[selectedfile]
        self.node_tree.nodes['Image Texture.004'].image = bpy.data.images[selectedfile]
        self.node_tree.nodes['Image Texture.005'].image = bpy.data.images[selectedfile]
        self.node_tree.nodes['Image Texture.006'].image = bpy.data.images[selectedfile]
        self.node_tree.nodes['Image Texture.007'].image = bpy.data.images[selectedfile]
        self.node_tree.nodes['Image Texture.008'].image = bpy.data.images[selectedfile]


    filepath = StringProperty(name="Maps DIR", description="image path", subtype="FILE_PATH", update=updateFilePath)

    def defaultNodeTree(self):
        self.addNode('NodeReroute', {'name':'Reroute.001'})
        self.addNode('ShaderNodeMixRGB', {'name':'Mix.015', 'blend_type':'ADD', 'use_clamp':0.000})
        self.addNode('ShaderNodeMixRGB', {'name':'Mix.020', 'blend_type':'ADD', 'use_clamp':0.000})
        self.addNode('ShaderNodeMixRGB', {'name':'Mix.018', 'blend_type':'ADD', 'use_clamp':0.000})
        self.addNode('ShaderNodeMixRGB', {'name':'Mix.016', 'blend_type':'ADD', 'use_clamp':0.000})
        self.addNode('ShaderNodeMixRGB', {'name':'Mix.022', 'blend_type':'ADD', 'use_clamp':0.000})
        self.addNode('ShaderNodeMixRGB', {'name':'Mix.024', 'blend_type':'ADD', 'use_clamp':0.000})
        self.addNode('ShaderNodeMixRGB', {'name':'Mix.013', 'blend_type':'ADD', 'use_clamp':0.000})
        self.addNode('ShaderNodeTexNoise', {'name':'Noise Texture.002', 'inputs[0].default_value':[0.000,0.000,0.000], 'inputs[1].default_value':9950.000, 'inputs[2].default_value':8.000, 'inputs[3].default_value':200.000})
        self.addNode('ShaderNodeTexNoise', {'name':'Noise Texture.004', 'inputs[0].default_value':[0.000,0.000,0.000], 'inputs[1].default_value':9850.000, 'inputs[2].default_value':0.000, 'inputs[3].default_value':200.000})
        self.addNode('ShaderNodeTexNoise', {'name':'Noise Texture.005', 'inputs[0].default_value':[0.000,0.000,0.000], 'inputs[1].default_value':9800.000, 'inputs[2].default_value':8.000, 'inputs[3].default_value':200.000})
        self.addNode('ShaderNodeTexNoise', {'name':'Noise Texture.006', 'inputs[0].default_value':[0.000,0.000,0.000], 'inputs[1].default_value':9750.000, 'inputs[2].default_value':8.000, 'inputs[3].default_value':200.000})
        self.addNode('ShaderNodeTexNoise', {'name':'Noise Texture.007', 'inputs[0].default_value':[0.000,0.000,0.000], 'inputs[1].default_value':9700.000, 'inputs[2].default_value':8.000, 'inputs[3].default_value':200.000})
        self.addNode('ShaderNodeTexNoise', {'name':'Noise Texture.008', 'inputs[0].default_value':[0.000,0.000,0.000], 'inputs[1].default_value':9650.000, 'inputs[2].default_value':8.000, 'inputs[3].default_value':200.000})
        self.addNode('NodeReroute', {'name':'Reroute.006'})
        self.addNode('ShaderNodeTexNoise', {'name':'Noise Texture.003', 'inputs[0].default_value':[0.000,0.000,0.000], 'inputs[1].default_value':9900.000, 'inputs[2].default_value':8.000, 'inputs[3].default_value':200.000})
        self.addNode('ShaderNodeMixRGB', {'name':'Mix.026', 'blend_type':'SUBTRACT', 'use_clamp':0.000, 'inputs[0].default_value':1.000, 'inputs[2].default_value':[0.500,0.500,0.500,1.000]})
        self.addNode('ShaderNodeMixRGB', {'name':'Mix.028', 'blend_type':'SUBTRACT', 'use_clamp':0.000, 'inputs[0].default_value':1.000, 'inputs[2].default_value':[0.500,0.500,0.500,1.000]})
        self.addNode('ShaderNodeMixRGB', {'name':'Mix.029', 'blend_type':'SUBTRACT', 'use_clamp':0.000, 'inputs[0].default_value':1.000, 'inputs[2].default_value':[0.500,0.500,0.500,1.000]})
        self.addNode('ShaderNodeMixRGB', {'name':'Mix.030', 'blend_type':'SUBTRACT', 'use_clamp':0.000, 'inputs[0].default_value':1.000, 'inputs[2].default_value':[0.500,0.500,0.500,1.000]})
        self.addNode('ShaderNodeMixRGB', {'name':'Mix.031', 'blend_type':'SUBTRACT', 'use_clamp':0.000, 'inputs[0].default_value':1.000, 'inputs[2].default_value':[0.500,0.500,0.500,1.000]})
        self.addNode('ShaderNodeMixRGB', {'name':'Mix.032', 'blend_type':'SUBTRACT', 'use_clamp':0.000, 'inputs[0].default_value':1.000, 'inputs[2].default_value':[0.500,0.500,0.500,1.000]})
        self.addNode('ShaderNodeMixRGB', {'name':'Mix.033', 'blend_type':'SUBTRACT', 'use_clamp':0.000, 'inputs[0].default_value':1.000, 'inputs[2].default_value':[0.500,0.500,0.500,1.000]})
        self.addNode('ShaderNodeTexNoise', {'name':'Noise Texture.001', 'inputs[0].default_value':[0.000,0.000,0.000], 'inputs[1].default_value':10000.000, 'inputs[2].default_value':8.000, 'inputs[3].default_value':200.000})
        self.addNode('ShaderNodeMath', {'name':'Math', 'operation':'DIVIDE', 'use_clamp':0.000, 'inputs[1].default_value':1000.000})

        self.addNode('ShaderNodeMixRGB', {'name':'Mix.021', 'blend_type':'SUBTRACT', 'use_clamp':0.000, 'inputs[0].default_value':1.000, 'inputs[2].default_value':[0.500,0.500,0.500,1.000]})
        self.addNode('ShaderNodeMixRGB', {'name':'Mix.012', 'blend_type':'ADD', 'use_clamp':0.000})
        self.addNode('ShaderNodeMixRGB', {'name':'Mix.Image.001', 'blend_type':'MIX', 'use_clamp':0.000, 'inputs[0].default_value':0.500})
        self.addNode('ShaderNodeMixRGB', {'name':'Mix.Image.002', 'blend_type':'MIX', 'use_clamp':0.000, 'inputs[0].default_value':0.500})
        self.addNode('ShaderNodeMixRGB', {'name':'Mix.Image.003', 'blend_type':'MIX', 'use_clamp':0.000, 'inputs[0].default_value':0.500})
        self.addNode('ShaderNodeMixRGB', {'name':'Mix.Image.004', 'blend_type':'MIX', 'use_clamp':0.000, 'inputs[0].default_value':0.500})
        self.addNode('ShaderNodeMixRGB', {'name':'Mix.Image.005', 'blend_type':'MIX', 'use_clamp':0.000, 'inputs[0].default_value':0.500})
        self.addNode('ShaderNodeMixRGB', {'name':'Mix.Image.006', 'blend_type':'MIX', 'use_clamp':0.000, 'inputs[0].default_value':0.500})
        self.addNode('ShaderNodeMixRGB', {'name':'Mix.Image.007', 'blend_type':'MIX', 'use_clamp':0.000, 'inputs[0].default_value':0.500})
        self.addInput('NodeSocketVector', {'name':'Input', 'default_value':[0.000,0.000,0.000], 'min_value':-340282346638528859811704183484516925440.000, 'max_value':340282346638528859811704183484516925440.000})
        self.addInput('NodeSocketFloat', {'name':'Blur Amount', 'default_value':0.000, 'min_value':-340282346638528859811704183484516925440.000, 'max_value':340282346638528859811704183484516925440.000})
        self.addOutput('NodeSocketColor', {'name':'Blured Image', 'default_value':[0.000,0.000,0.000,0.000]})
        self.addLink('nodes["Reroute.006"].outputs[0]', 'nodes["Mix.012"].inputs[1]')
        self.addLink('nodes["Noise Texture.001"].outputs[0]', 'nodes["Mix.021"].inputs[1]')

        self.addLink('nodes["Group Input"].outputs[0]', 'nodes["Reroute.006"].inputs[0]')
        self.addLink('nodes["Reroute.006"].outputs[0]', 'nodes["Mix.013"].inputs[1]')

        self.addLink('nodes["Noise Texture.002"].outputs[0]', 'nodes["Mix.026"].inputs[1]')



        self.addLink('nodes["Noise Texture.003"].outputs[0]', 'nodes["Mix.028"].inputs[1]')
        self.addLink('nodes["Reroute.006"].outputs[0]', 'nodes["Mix.015"].inputs[1]')

        self.addLink('nodes["Noise Texture.004"].outputs[0]', 'nodes["Mix.029"].inputs[1]')
        self.addLink('nodes["Reroute.006"].outputs[0]', 'nodes["Mix.016"].inputs[1]')

        self.addLink('nodes["Noise Texture.005"].outputs[0]', 'nodes["Mix.030"].inputs[1]')
        self.addLink('nodes["Reroute.006"].outputs[0]', 'nodes["Mix.018"].inputs[1]')

        self.addLink('nodes["Noise Texture.006"].outputs[0]', 'nodes["Mix.031"].inputs[1]')
        self.addLink('nodes["Reroute.006"].outputs[0]', 'nodes["Mix.020"].inputs[1]')

        self.addLink('nodes["Reroute.006"].outputs[0]', 'nodes["Mix.022"].inputs[1]')
        self.addLink('nodes["Noise Texture.007"].outputs[0]', 'nodes["Mix.032"].inputs[1]')
        self.addLink('nodes["Reroute.001"].outputs[0]', 'nodes["Mix.012"].inputs[0]')
        self.addLink('nodes["Reroute.001"].outputs[0]', 'nodes["Mix.013"].inputs[0]')
        self.addLink('nodes["Reroute.001"].outputs[0]', 'nodes["Mix.015"].inputs[0]')
        self.addLink('nodes["Reroute.001"].outputs[0]', 'nodes["Mix.016"].inputs[0]')
        self.addLink('nodes["Reroute.001"].outputs[0]', 'nodes["Mix.018"].inputs[0]')
        self.addLink('nodes["Reroute.001"].outputs[0]', 'nodes["Mix.020"].inputs[0]')
        self.addLink('nodes["Reroute.001"].outputs[0]', 'nodes["Mix.022"].inputs[0]')
        self.addLink('nodes["Group Input"].outputs[1]', 'nodes["Math"].inputs[0]')

        self.addLink('nodes["Reroute.006"].outputs[0]', 'nodes["Mix.024"].inputs[1]')
        self.addLink('nodes["Noise Texture.008"].outputs[0]', 'nodes["Mix.033"].inputs[1]')
        self.addLink('nodes["Reroute.001"].outputs[0]', 'nodes["Mix.024"].inputs[0]')






        self.addLink('nodes["Mix.Image.001"].outputs[0]', 'nodes["Mix.Image.005"].inputs[1]')
        self.addLink('nodes["Mix.Image.002"].outputs[0]', 'nodes["Mix.Image.005"].inputs[2]')
        self.addLink('nodes["Mix.Image.003"].outputs[0]', 'nodes["Mix.Image.006"].inputs[1]')
        self.addLink('nodes["Mix.Image.004"].outputs[0]', 'nodes["Mix.Image.006"].inputs[2]')
        self.addLink('nodes["Mix.Image.005"].outputs[0]', 'nodes["Mix.Image.007"].inputs[1]')
        self.addLink('nodes["Mix.Image.006"].outputs[0]', 'nodes["Mix.Image.007"].inputs[2]')
        self.addLink('nodes["Mix.Image.007"].outputs[0]', 'nodes["Group Output"].inputs[0]')
        self.addLink('nodes["Mix.021"].outputs[0]', 'nodes["Mix.012"].inputs[2]')
        self.addLink('nodes["Mix.026"].outputs[0]', 'nodes["Mix.013"].inputs[2]')
        self.addLink('nodes["Mix.028"].outputs[0]', 'nodes["Mix.015"].inputs[2]')
        self.addLink('nodes["Mix.029"].outputs[0]', 'nodes["Mix.016"].inputs[2]')
        self.addLink('nodes["Mix.030"].outputs[0]', 'nodes["Mix.018"].inputs[2]')
        self.addLink('nodes["Mix.031"].outputs[0]', 'nodes["Mix.020"].inputs[2]')
        self.addLink('nodes["Mix.032"].outputs[0]', 'nodes["Mix.022"].inputs[2]')
        self.addLink('nodes["Mix.033"].outputs[0]', 'nodes["Mix.024"].inputs[2]')
        self.addLink('nodes["Math"].outputs[0]', 'nodes["Reroute.001"].inputs[0]')

    def init(self, context):
        self.setupTree()

    #def copy(self, node):

    #def free(self):
    def free(self):
        if self.node_tree.users==1:
            bpy.data.node_groups.remove(self.node_tree, do_unlink=True)

    #def socket_value_update(self, context):

    #def update(self):

    #def draw_buttons(self, context, layout):
    def draw_buttons(self, context, layout):
        col=layout.column()
        col.prop(self, 'filepath', text="Image")

    #def draw_buttons_ext(self, contex, layout):

    #def draw_label(self):
    # def draw_label(self):
    #     node_label = path.basename(self.filepath)
    #     return node_label

    def draw_menu():
        return 'SH_NEW_CGT' , 'CG Thoughts'
