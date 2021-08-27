extends Node

var program_1 = [
	"var myVar = 'foo'",
	"stop()",
]


func _ready():
	test_program_1() 
	
func test_program_1():
	$ScriptExecutor.start(program_1)
	
	assert ("myVar" in $ScriptExecutor.context.variables)

