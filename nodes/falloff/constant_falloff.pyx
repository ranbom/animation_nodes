import bpy
from ... data_structures cimport FalloffBase
from ... base_types.node import AnimationNode

class ConstantFalloffNode(bpy.types.Node, AnimationNode):
    bl_idname = "an_ConstantFalloffNode"
    bl_label = "Constant Falloff"

    def create(self):
        self.newInput("Float", "Strength", "strength")
        self.newOutput("Falloff", "Falloff", "falloff")

    def execute(self, strength):
        return ConstantFalloff(strength)


cdef class ConstantFalloff(FalloffBase):
    cdef double value

    def __cinit__(self, double value):
        self.value = value
        self.dataType = "All"

    cdef double evaluate(self, void* object, long index):
        return self.value
