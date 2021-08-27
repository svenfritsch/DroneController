extends TextEdit

class_name ScriptEdit

func _ready():
	self.connect("text_changed", self, "_on_text_changed")
	
	self.syntax_highlighting = true
	self.show_line_numbers = true
	self.draw_tabs = true
	self.draw_spaces = true
	self.highlight_all_occurrences = true
	self.minimap_draw = true
	self.caret_blink = true
	
	$"../ErrorLabel".hide()
	
	ScriptParser.add_syntax_highlighting(self)
	
func _on_text_changed():
	$"../ErrorLabel".hide()
	self.clear_colors()
	self.remove_breakpoints()
	self.breakpoint_gutter = false
	
	for line_number in self.get_line_count():
		var line = self.get_line(line_number)
		var evaluated_line_data = ScriptParser.evaluate_line(line)
		
		var error = ScriptParser.extract_error(evaluated_line_data)
		
		if error:
			self.breakpoint_gutter = true
			self.set_line_as_breakpoint(line_number, true)

			$"../ErrorLabel".text = "[L{line_number}] SyntaxError: {message}".format({
				"line_number": line_number + 1,
				"message": error["data"]["message"]
			})
			$"../ErrorLabel".show()
		
	ScriptParser.add_syntax_highlighting(self)
