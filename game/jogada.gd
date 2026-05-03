extends Resource
class_name Jogada

var movimento: Array
var avaliacao: int

func _init(mov: Array, aval: int):
	self.movimento = mov
	self.avaliacao = aval
