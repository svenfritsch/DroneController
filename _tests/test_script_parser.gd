extends Node

var program_1 = [
	"var myName = 'Sven'",
	"say('Greetings, '; myName;)",
	"	say()",
	"		say()"
]

func _ready():
	test_program_1()
	
func test_program_1():
	var evaluated_lines = []
	for line in program_1:
		evaluated_lines.append(ScriptParser.evaluate_line(line))
		
	assert (evaluated_lines[0].type == "variable_definition")
	assert (evaluated_lines[1].type == "function_call")
	assert (evaluated_lines[1].data.parameter.data.type == "list")
	assert (evaluated_lines[2].indents == 1)
	assert (evaluated_lines[3].indents == 2)
	
	print("Success!")
