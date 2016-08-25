cpdef createFalloffEvaluator(falloff, str sourceType):
    cdef FalloffEvaluator evaluator
    cdef FalloffBase _falloffBase

    if isinstance(falloff, FalloffBase):
        _falloffBase = falloff
        dataType = _falloffBase.dataType
        if dataType == "All" or sourceType == dataType:
            evaluator = SimpleFalloffBaseEvaluator(_falloffBase)
        else:
            evaluator = ComplexFalloffBaseEvaluator(_falloffBase, sourceType)

    if getattr(evaluator, "isValid", False):
        return evaluator
    else:
        return None


cdef class FalloffEvaluator:
    cdef double evaluate(self, void* value, long index):
        raise NotImplementedError()


cdef class SimpleFalloffBaseEvaluator(FalloffEvaluator):
    def __cinit__(self, FalloffBase falloff):
        self.falloff = falloff
        self.isValid = True

    cdef double evaluate(self, void* value, long index):
        return self.falloff.evaluate(value, index)


cdef class ComplexFalloffBaseEvaluator(FalloffEvaluator):
    def __cinit__(self, FalloffBase falloff, str sourceType):
        self.evaluator = getEvaluatorWithConversion(sourceType, falloff.dataType)
        self.isValid = self.evaluator != NULL
        self.falloff = falloff

    cdef double evaluate(self, void* value, long index):
        return self.evaluator(self.falloff, value, index)


# Value Conversion
###########################################################

cdef FalloffBaseEvaluatorWithConversion getEvaluatorWithConversion(str sourceType, str targetType):
    if sourceType == "Transformation Matrix" and targetType == "Location":
        return convert_TransformationMatrix_Location
    return NULL

cdef double convert_TransformationMatrix_Location(FalloffBase falloff, void* value, long index):
    cdef Matrix4* matrix = <Matrix4*>value
    cdef Vector3 vector
    vector.x = matrix.a14
    vector.y = matrix.a24
    vector.z = matrix.a34
    return falloff.evaluate(&vector, index)
