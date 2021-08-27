extends Node

class_name ScriptExecutor

signal stopping

export(NodePath) var object_callback_ref_path

enum ExecutionState {
	idle,
	running,
	paused,
}

var functions = {
	"stop": funcref(self, "stop")
}

var magic_variables = {
	"iteration": funcref(self, "get_iteration")
}

var program = []
var state = ExecutionState.idle
var context = {}

func _ready():
	pass
	
func _get_variable_value(name: String):
	return self.context.variables[name].value
	
func _get_magic_variable_value(name: String):
	return magic_variables[name].call_func()
	
func _evaluate(expression):
	var variable_names = self.context.variables.keys()
	variable_names += self.magic_variables.keys()
	variable_names.sort()
	var variable_values = []
	for variable_name in variable_names:
		if variable_name in self.context.variables:
			variable_values.append(
				_get_variable_value(variable_name)
			)
		else:
			variable_values.append(
				_get_magic_variable_value(variable_name)
			)
	var _expression = Expression.new()
	var error = _expression.parse(expression, variable_names)
	if error != OK:
		push_error(_expression.get_error_text())
		return
	var result = _expression.execute(
		variable_values, 
		get_node(object_callback_ref_path)
	)
	print(result)
	return result
	
func _store_variable(variable_data: Dictionary, indent: int):
	assert ("name" in variable_data)
	assert ("persistent" in variable_data)
	assert ("value" in variable_data)
	
	if variable_data.persistent and variable_data.name in self.context.variables:
		return
	
	self.context.variables[variable_data.name] = {
		"persistent": variable_data.persistent,
		"name": variable_data.name,
		"value": _evaluate(variable_data.value),
		"level": indent,
	}
	
func _update_variable(name: String, value):
	assert (name in self.context.variables)
	var newValue = _evaluate(value)
	self.context.variables[name].value = newValue

func _execute(line_data: Dictionary):
	assert ("type" in line_data)
	assert ("indents" in line_data)
	
	var unindent = line_data.indents < self.context.indentation
	
	if self.context.in_while_loop >= 0 and unindent:
		self.context.line = self.context.in_while_loop
		self.context.auto_increment = false
	
	if self.context.indent_expected:
		assert (line_data.indents > self.context.indentation)
		
		self.context.indentation = line_data.indents
		self.context.indent_expected = false
		
	if self.context.skip_indents:
		if line_data.indents > self.context.indentation:
			return
		if line_data.indents == self.context.indentation:
			self.context.skip_indents = false
			
	if self.context.expecting_else:
		self.context.expecting_else = false
	else:
		if line_data.type == "else":
			self.context.skip_indents = true
			return
	
	match line_data.type:
		"variable_definition":
			assert ("name" in line_data.data)
			assert ("value" in line_data.data)
			
			_store_variable(line_data.data, line_data.indents)
		"if":
			assert ("condition" in line_data.data)
			
			if _evaluate(line_data.data.condition):
				self.context.indent_expected = true
			else:
				self.context.expecting_else = true
				self.context.skip_indents = true
		"else":
			self.context.indent_expected = true
		"while":
			assert ("condition" in line_data.data)
			
			if _evaluate(line_data.data.condition):
				self.context.in_while_loop = self.context.line
				self.context.indent_expected = true
			else:
				self.context.skip_indents = true
		"assignment":
			assert ("variable_name" in line_data.data)
			assert ("value" in line_data.data)
			_update_variable(line_data.data.variable_name, line_data.data.value)
		"expression":
			_evaluate(line_data.data.value)

func _clear_non_persistent_variables():
	var variables_to_remove = []
	for variable_name in self.context.variables.keys():
		if not "persistent" in self.context.variables[variable_name] or not self.context.variables[variable_name].persistent:
			variables_to_remove.append(variable_name)
	for variable_name in variables_to_remove:
		self.context["variables"].erase(variable_name)

func _increment_line():
	if self.context.auto_increment:
		self.context.line += 1
		if self.context.line >= len(program):
			self.context.iteration += 1
			self.context.line = 0
			self.context.indentation = 0
			self.context.skip_indents = false
			self.context.expecting_else = false
			self.context.in_while_loop = -1
			self._clear_non_persistent_variables()
	else:
		self.context.auto_increment = true

func reset():
	self.state = ExecutionState.idle
	
	self.context = {
		"iteration": 0,
		"line": 0,
		"indentation": 0,
		"indent_expected": false,
		"skip_indents": false,
		"expecting_else": false,
		"in_while_loop": -1,
		"variables": {
			"TRUE": {
				"value": true,
				"persistent": true,
				"level": 0,
			},
			"FALSE": {
				"value": false,
				"persistent": true,
				"level": 0,
			}
		},
		"auto_increment": true,
	}

func start(prog, auto_run=true):
	reset()
	if ScriptParser.has_errors(prog):
		emit_signal("stopping")
	else:
		self.program = prog
		self.state = ExecutionState.running
		if auto_run:
			Clock.connect("tick", self, "step")

func step(_at_time = null):
	if self.state != ExecutionState.running:
		return
	
	var line_raw = self.program[self.context.line]
	var parsed_line_data = ScriptParser.evaluate_line(line_raw)	
	self._execute(parsed_line_data)
	
	_increment_line()
	
func wait_for_callback():
	self.state = ExecutionState.paused
	
func continue_running():
	if self.state == ExecutionState.paused:
		self.state = ExecutionState.running
	
func stop():
	emit_signal("stopping")
	reset()

func get_iteration():
	return self.context.iteration
