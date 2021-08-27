extends Node

var match_variable_definition = RegEx.new()
var match_persistent_variable_definition = RegEx.new()
var match_if = RegEx.new()
var match_else = RegEx.new()
var match_while = RegEx.new()
var match_assignment = RegEx.new()
var match_empty_line = RegEx.new()
var match_comment = RegEx.new()

const NAME = "(?<name>[a-zA-Z0-9_]*)"
const VALUE = "(?<value>.*)"
const SPACE = "[\\t ]*"
const OPEN_BLOCK = "%s:%s" % [SPACE, SPACE]

const VARIABLE_KEYWORD = "var"
const PERSISTENT_KEYWORD = "persistent"
const ASSIGNMENT_SYMBOL = "="
const COMMENT_LINE_BEGINNING = "#"
const RESTRICTED_VARIABLE_NAMES = [
	"var",
	"persistent",
	"if", "else", "while",
]

const FORMAT_DICT = {
	"s": SPACE,
	"v": VARIABLE_KEYWORD,
	"p": PERSISTENT_KEYWORD,
	"f": NAME,
	"v_name": NAME,
	"variable": NAME,
	"assign": ASSIGNMENT_SYMBOL,
	"val": VALUE,
	"open": OPEN_BLOCK,
	"c": COMMENT_LINE_BEGINNING
}

func add_syntax_highlighting(text_edit: TextEdit):
	text_edit.add_keyword_color(VARIABLE_KEYWORD, Color(0.557776, 0.604901, 0.859375))
	text_edit.add_keyword_color(PERSISTENT_KEYWORD, Color(0.84995, 0.557776, 0.859375))
	
	var if_else_while_color = Color(0.557776, 0.859375, 0.746275)
	text_edit.add_keyword_color("if", if_else_while_color)
	text_edit.add_keyword_color("else", if_else_while_color)
	text_edit.add_keyword_color("while", if_else_while_color)
	
	text_edit.add_color_region(COMMENT_LINE_BEGINNING, "", Color.gray, true)
	text_edit.add_color_region("'", "'", Color(0.767861, 0.871094, 0.342544), false)

func _ready():
	match_comment.compile(
		"^{c}(?<comment>.*)$".format(FORMAT_DICT)
	)
	
	# line types
	match_variable_definition.compile(
		"^{v}{s}{v_name}{s}{assign}{s}{val}{s}$".format(FORMAT_DICT)
	)
	match_persistent_variable_definition.compile(
		"^{p}{s}{v_name}{s}{assign}{s}{val}{s}$".format(FORMAT_DICT)
	)
	match_if.compile(
		"^if{s}(?<condition>.*){s}{open}$".format(FORMAT_DICT)
	)
	match_else.compile(
		"^else{s}{open}$".format(FORMAT_DICT)
	)
	match_while.compile(
		"^while{s}(?<condition>.*){s}{open}$".format(FORMAT_DICT)
	)
	match_assignment.compile(
		"^{variable}{s}{assign}{s}{val}$".format(FORMAT_DICT)
	)

func _is_match(value: String, matcher: RegEx) -> bool:
	var has_match = matcher.search(value)
	return has_match
	
func _extract(from_value: String, with_matcher: RegEx, group_name: String) -> String:
	var matches: RegExMatch = with_matcher.search(from_value)
	if matches:
		return matches.get_string(group_name)
	return ""
	
func _invalid_variable_name(name: String) -> bool:
	return name in RESTRICTED_VARIABLE_NAMES
	
func _variable_name_error(name: String):
	return {
		"type": "error",
		"data": {
			"parsed_value": name,
			"message": "`%s` is a keyword and can't be used for naming variables" % name
		}
	}

func evaluate_line(line_of_code: String):
	var line = {
		"indents": line_of_code.length() - line_of_code.dedent().length()
	}
	var stripped_line = line_of_code.dedent().strip_edges()
	
	if not stripped_line:
		line["type"] = "empty_line"
		return line
		
	if _is_match(stripped_line, match_comment):
		line["type"] = "comment"
		line["data"] = {
			"comment": _extract(stripped_line, match_comment, "comment")
		}
		return line
	
	if _is_match(stripped_line, match_variable_definition):
		line["type"] = "variable_definition"

		var name = _extract(stripped_line, match_variable_definition, "name")
		if _invalid_variable_name(name):
			return _variable_name_error(name)

		line["data"] = {
			"persistent": false,
			"name": name,
			"value": _extract(stripped_line, match_variable_definition, "value")
		}
		return line
		
	if _is_match(stripped_line, match_persistent_variable_definition):
		line["type"] = "variable_definition"

		var name = _extract(stripped_line, match_persistent_variable_definition, "name")
		if _invalid_variable_name(name):
			return _variable_name_error(name)

		line["data"] = {
			"persistent": true,
			"name": name,
			"value": _extract(stripped_line, match_persistent_variable_definition, "value")
		}
		return line
		
	if _is_match(stripped_line, match_if):
		line["type"] = "if"
		line["data"] = {
			"condition": _extract(stripped_line, match_if, "condition")
		}
		return line
		
	if _is_match(stripped_line, match_else):
		line["type"] = "else"
		return line
		
	if _is_match(stripped_line, match_while):
		line["type"] = "while"
		line["data"] = {
			"condition": _extract(stripped_line, match_while, "condition")
		}
		return line
		
	if _is_match(stripped_line, match_assignment):
		line["type"] = "assignment"
		line["data"] = {
			"variable_name": _extract(stripped_line, match_assignment, "name"),
			"value": _extract(stripped_line, match_assignment, "value"),
		}
		return line
		
	return {
		"indents": line_of_code.length() - line_of_code.dedent().length(),
		"type": "expression",
		"data": {
			"value": stripped_line,
		}
	}
	
	return line

func extract_error(line_data):
	if line_data and typeof(line_data) == TYPE_DICTIONARY:
		for key in line_data:
			if key == "type" and line_data[key] == "error":
				return line_data
			if key in ["data", "value", "value_1", "value_2", "condition", "parameter"] and key in line_data:
				return extract_error(line_data[key])
	return null

func find_errors(program):
	var errors = []
	
	for line in program:
		var evaluated_line_data = evaluate_line(line)
		
		var error = extract_error(evaluated_line_data)
		
		if error:
			errors.append(error)
			
	return errors
	
func has_errors(program) -> bool:
	var errors = find_errors(program)
	return errors.size() != 0
