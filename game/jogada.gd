extends Resource
class_name Jogada

var movimento: Array
var avaliacao: float

func _init(mov: Array, aval: float):
	self.movimento = mov
	self.avaliacao = aval
