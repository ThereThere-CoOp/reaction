class_name TestGeneralReactionGut
extends GutTest

var _global_blackboard: ReactionBlackboard = null
var _facts: Dictionary = {}
var _responses_groups: Dictionary = {}
var _dialog_responses: Dictionary = {}
var _dialog_texts: Dictionary = {}
var _dialog_choices: Dictionary = {}
var _rules: Dictionary = {}
var _rules_criterias: Dictionary = {}
var _context_modifications: Dictionary = {}
var _events: Dictionary = {}


func before_all():
	# declaring fact of type enum
	var fact_mind_type = ReactionFactItem.new()
	fact_mind_type.type = TYPE_STRING
	fact_mind_type.label = "mind_type"
	fact_mind_type.is_enum = true
	fact_mind_type.hint_string = "volao,socotroco,mindundi"

	# declaring fact of type integer
	var fact_population_size = ReactionFactItem.new()
	fact_population_size.label = "population_size"
	fact_population_size.type = TYPE_INT
	
	# declaring fact of type integer
	var fact_extra_population_size = ReactionFactItem.new()
	fact_extra_population_size.label = "extra_population_size"
	fact_extra_population_size.type = TYPE_INT
	
	# declaring fact of type integer
	var fact_extra_small_population_size = ReactionFactItem.new()
	fact_extra_small_population_size.label = "extra_small_population_size"
	fact_extra_small_population_size.type = TYPE_INT

	# declaring fact of type boolean
	var fact_is_comunism = ReactionFactItem.new()
	fact_is_comunism.label = "is_comunism"
	fact_is_comunism.type = TYPE_BOOL
	fact_is_comunism.trigger_signal_on_modified = true

	_facts[fact_mind_type.label] = fact_mind_type
	_facts[fact_population_size.label] = fact_population_size
	_facts[fact_is_comunism.label] = fact_is_comunism
	_facts[fact_extra_population_size.label] = fact_extra_population_size
	_facts[fact_extra_small_population_size.label] = fact_extra_small_population_size

	# init rules criterias
	var criteria_is_mindundi = ReactionCriteriaItem.new()
	criteria_is_mindundi.label = "mindtype_is_mindundi"
	criteria_is_mindundi.fact = _facts["mind_type"]
	
	criteria_is_mindundi.value_a = '2'
	criteria_is_mindundi.operation = "="

	var criteria_population_lt_300 = ReactionCriteriaItem.new()
	criteria_population_lt_300.label = "population_less_than_300"
	criteria_population_lt_300.fact = _facts["population_size"]

	criteria_population_lt_300.value_a = '300'
	criteria_population_lt_300.operation = "<"

	var criteria_not_comunism = ReactionCriteriaItem.new()
	criteria_not_comunism.label = "not_comunism"
	criteria_not_comunism.fact = _facts["is_comunism"]

	criteria_not_comunism.value_a = '1'
	criteria_not_comunism.operation = "="
	criteria_not_comunism.is_reverse = true

	var criteria_population_b_100_400 = ReactionCriteriaItem.new()
	criteria_population_b_100_400.label = "population_between_100_400"
	criteria_population_b_100_400.fact = _facts["population_size"]

	criteria_population_b_100_400.value_a = '100'
	criteria_population_b_100_400.value_b = '400'
	criteria_population_b_100_400.operation = "a<=x<=b"

	var criteria_is_volao = ReactionCriteriaItem.new()
	criteria_is_volao.label = "mindtype_is_volao"
	criteria_is_volao.fact = _facts["mind_type"]

	criteria_is_volao.value_a = '0'
	criteria_is_volao.operation = "="
	
	# function criteria item init 
	var criteria_function_string = "%s;+;%s;-;%s" % [fact_population_size.uid, fact_extra_population_size.uid, fact_extra_small_population_size.uid]
	
	var function_criteria_population_sum_less_500 = ReactionFunctionCriteriaItem.new()
	function_criteria_population_sum_less_500.label = "pop_sum_less_500"
	function_criteria_population_sum_less_500.value_a = '500'
	function_criteria_population_sum_less_500.operation = "<"
	function_criteria_population_sum_less_500.function = criteria_function_string
	
	var function_criteria_population_sus_greater_500 = ReactionFunctionCriteriaItem.new()
	function_criteria_population_sus_greater_500.label = "pop_sus_more_500"
	function_criteria_population_sus_greater_500.value_a = '500'
	function_criteria_population_sus_greater_500.operation = ">"
	function_criteria_population_sus_greater_500.function = criteria_function_string
	
	var function_criteria_population_mult_greater_500 = ReactionFunctionCriteriaItem.new()
	function_criteria_population_mult_greater_500.label = "pop_mult_more_500"
	function_criteria_population_mult_greater_500.value_a = '500'
	function_criteria_population_mult_greater_500.operation = ">"
	function_criteria_population_mult_greater_500.function = criteria_function_string
	
	# adding criteria to global dict
	_rules_criterias[criteria_is_mindundi.label] = criteria_is_mindundi
	_rules_criterias[criteria_population_lt_300.label] = criteria_population_lt_300
	_rules_criterias[criteria_not_comunism.label] = criteria_not_comunism
	_rules_criterias[criteria_population_b_100_400.label] = criteria_population_b_100_400
	_rules_criterias[criteria_is_volao.label] = criteria_is_volao
	_rules_criterias[function_criteria_population_sum_less_500.label] = function_criteria_population_sum_less_500
	_rules_criterias[function_criteria_population_sus_greater_500.label] = function_criteria_population_sus_greater_500
	_rules_criterias[function_criteria_population_mult_greater_500.label] = function_criteria_population_mult_greater_500

	# init modifications
	var modification_declare_comunism = ReactionContextModificationItem.new()
	modification_declare_comunism.label = "declare_comunism"
	modification_declare_comunism.fact = _facts["is_comunism"]
	modification_declare_comunism.modification_value = "1"
	modification_declare_comunism.operation = "="

	var modification_grow_population = ReactionContextModificationItem.new()
	modification_grow_population.label = "grow_population_in_500"
	modification_grow_population.fact = _facts["population_size"]
	modification_grow_population.modification_value = "500"
	modification_grow_population.operation = "+"

	var modification_decrease_population = ReactionContextModificationItem.new()
	modification_decrease_population.label = "decrease_population_in_100"
	modification_decrease_population.fact = _facts["population_size"]
	modification_decrease_population.modification_value = "100"
	modification_decrease_population.operation = "-"

	var modification_erase_mindtype = ReactionContextModificationItem.new()
	modification_erase_mindtype.label = "erase_mind_type"
	modification_erase_mindtype.fact = _facts["mind_type"]
	modification_erase_mindtype.operation = "erase"

	_context_modifications[modification_declare_comunism.label] = modification_declare_comunism
	_context_modifications[modification_decrease_population.label] = modification_decrease_population
	_context_modifications[modification_grow_population.label] = modification_grow_population
	_context_modifications[modification_erase_mindtype.label] = modification_erase_mindtype

	# init responses
	# init dialog responses
	var response_your_a_mindundi = ReactionResponseDialogItem.new()
	
	var response_your_a_mindundi_text = ReactionDialogTextItem.new()
	response_your_a_mindundi_text.label = "response_your_a_mindundi_text"
	response_your_a_mindundi_text.text = { "es": "Tu lo que eres un mindundi."}
	
	response_your_a_mindundi.label = "you_are_a_mindundi"
	response_your_a_mindundi.texts = [response_your_a_mindundi_text] as Array[ReactionDialogTextItem]

	var response_not_comunism_low_pop = ReactionResponseDialogItem.new()
	
	var response_not_comunism_low_pop_text = ReactionDialogTextItem.new()
	response_not_comunism_low_pop_text.label = "response_not_comunism_low_pop_text"
	response_not_comunism_low_pop_text.text = { "es": "Vives en un pais capitalista con poca gente."}
	
	response_not_comunism_low_pop.label = "live_not_comunism_low_pop"
	response_not_comunism_low_pop.texts =  [response_not_comunism_low_pop_text] as Array[ReactionDialogTextItem]

	var response_mindundi_not_comunism_pop_100_400 = (
		ReactionResponseDialogItem.new()
	)
	
	var response_mindundi_not_comunism_pop_100_400_text = ReactionDialogTextItem.new()
	response_mindundi_not_comunism_pop_100_400_text.label = "response_mindundi_not_comunism_pop_100_400_text"
	response_mindundi_not_comunism_pop_100_400_text.text = { "es": "Eres un mindundi en un pais capitalista, en el que viven entre 100 y 400 personas."}
	
	response_mindundi_not_comunism_pop_100_400.label = "mindundi_not_comunism_pop_100_400"
	response_mindundi_not_comunism_pop_100_400.texts = [response_mindundi_not_comunism_pop_100_400_text] as Array[ReactionDialogTextItem]
	
	# response to text criteria 
	var response_conditional_texts_choices = ReactionResponseDialogItem.new()
	
	var text_response_conditional_texts_choices_1 = ReactionDialogTextItem.new()
	text_response_conditional_texts_choices_1.label = "text_response_conditional_texts_choices_1"
	text_response_conditional_texts_choices_1.text = { "es": "Texto variante 1."}
	text_response_conditional_texts_choices_1.criterias = [criteria_is_mindundi]  as Array[ReactionCriteriaItem]
	
	var text_response_conditional_texts_choices_2 = ReactionDialogTextItem.new()
	text_response_conditional_texts_choices_2.label = "text_response_conditional_texts_choices_2"
	text_response_conditional_texts_choices_2.text = { "es": "Texto variante 2."}
	text_response_conditional_texts_choices_2.criterias = [criteria_population_lt_300, criteria_is_mindundi] as Array[ReactionCriteriaItem]
	
	var choice_response_conditional_texts_choices_1: ReactionDialogChoiceItem = ReactionDialogChoiceItem.new()
	choice_response_conditional_texts_choices_1.label = "choice_response_conditional_texts_choices_1"
	choice_response_conditional_texts_choices_1.text =  { "es": "Choice 1."}
	choice_response_conditional_texts_choices_1.criterias = [criteria_is_mindundi] as Array[ReactionCriteriaItem]
	
	var choice_response_conditional_texts_choices_2: ReactionDialogChoiceItem = ReactionDialogChoiceItem.new()
	choice_response_conditional_texts_choices_2.label = "choice_response_conditional_texts_choices_2"
	choice_response_conditional_texts_choices_2.text =  { "es": "Choice 2."}
	choice_response_conditional_texts_choices_2.criterias = [criteria_is_volao] as Array[ReactionCriteriaItem]
	
	var choice_response_conditional_texts_choices_3: ReactionDialogChoiceItem = ReactionDialogChoiceItem.new()
	choice_response_conditional_texts_choices_3.label = "choice_response_conditional_texts_choices_3"
	choice_response_conditional_texts_choices_3.text =  { "es": "Choice 3."}
	choice_response_conditional_texts_choices_3.criterias = [criteria_is_mindundi, criteria_population_lt_300] as Array[ReactionCriteriaItem]
	
	response_conditional_texts_choices.label = "response_conditional_texts_choices"
	response_conditional_texts_choices.texts = [text_response_conditional_texts_choices_1, text_response_conditional_texts_choices_2] as Array[ReactionDialogTextItem]
	response_conditional_texts_choices.choices = [choice_response_conditional_texts_choices_1, choice_response_conditional_texts_choices_2, choice_response_conditional_texts_choices_3] as Array[ReactionDialogChoiceItem]
	response_conditional_texts_choices.have_choices = true
	
	_dialog_responses[response_your_a_mindundi.label] = response_your_a_mindundi
	_dialog_responses[response_not_comunism_low_pop.label] = response_not_comunism_low_pop
	_dialog_responses[response_mindundi_not_comunism_pop_100_400.label] = response_mindundi_not_comunism_pop_100_400
	_dialog_responses[response_conditional_texts_choices.label] = response_conditional_texts_choices
	
	_dialog_texts[response_your_a_mindundi_text.label] = response_your_a_mindundi_text
	_dialog_texts[response_not_comunism_low_pop_text.label] = response_not_comunism_low_pop_text
	_dialog_texts[response_mindundi_not_comunism_pop_100_400_text.label] = response_mindundi_not_comunism_pop_100_400_text
	_dialog_texts[text_response_conditional_texts_choices_1.label] = text_response_conditional_texts_choices_1
	_dialog_texts[text_response_conditional_texts_choices_2.label] = text_response_conditional_texts_choices_2
	
	_dialog_choices[choice_response_conditional_texts_choices_1.label] = choice_response_conditional_texts_choices_1
	_dialog_choices[choice_response_conditional_texts_choices_2.label] = choice_response_conditional_texts_choices_2
	_dialog_choices[choice_response_conditional_texts_choices_3.label] = choice_response_conditional_texts_choices_3

	# init responses groups
	var response_group_your_a_mindundi = ReactionResponseGroupItem.new()
	response_group_your_a_mindundi.label = "group_you_are_a_mindundi"
	response_group_your_a_mindundi.responses[response_your_a_mindundi] = response_your_a_mindundi
	

	var response_group_not_comunism_low_pop = ReactionResponseGroupItem.new()
	response_group_not_comunism_low_pop.label = "group_not_comunism_low_pop"
	response_group_not_comunism_low_pop.responses[response_not_comunism_low_pop] = response_not_comunism_low_pop

	var response_group_mindundi_not_comunism_pop_100_400 = (
		ReactionResponseGroupItem.new()
	)
	
	response_group_mindundi_not_comunism_pop_100_400.label = "group_you_are_a_mindundi"
	response_group_mindundi_not_comunism_pop_100_400.responses[response_mindundi_not_comunism_pop_100_400] = response_mindundi_not_comunism_pop_100_400
	
	_responses_groups[response_group_your_a_mindundi.label] = response_group_your_a_mindundi
	_responses_groups[response_group_not_comunism_low_pop.label] = response_group_not_comunism_low_pop
	_responses_groups[response_group_mindundi_not_comunism_pop_100_400.label] = response_group_mindundi_not_comunism_pop_100_400

	# init rules
	var rule_is_mindundi = ReactionRuleItem.new()
	rule_is_mindundi.label = "is_mindundi"
	rule_is_mindundi.criterias.append_array([criteria_is_mindundi])

	rule_is_mindundi.modifications.append_array(
		[modification_declare_comunism, modification_decrease_population]
	)

	rule_is_mindundi.response_group = response_group_your_a_mindundi

	var rule_not_comunism_and_low_population = ReactionRuleItem.new()
	rule_not_comunism_and_low_population.label = "not_comunism_low_population"
	rule_not_comunism_and_low_population.criterias.append_array(
		[criteria_not_comunism, criteria_population_lt_300]
	)
	rule_not_comunism_and_low_population.response_group = response_group_not_comunism_low_pop

	var rule_mindundi_n_comunism_pop_b_100_400 = ReactionRuleItem.new()
	rule_mindundi_n_comunism_pop_b_100_400.label = "mindundi_not_comunism_pop_between_100_400"
	rule_mindundi_n_comunism_pop_b_100_400.criterias.append_array(
		[
			criteria_not_comunism,
			criteria_population_b_100_400,
			criteria_is_mindundi
		]
	)
	rule_mindundi_n_comunism_pop_b_100_400.response_group = response_group_mindundi_not_comunism_pop_100_400

	var rule_is_volao_p_1 = ReactionRuleItem.new()
	rule_is_volao_p_1.label = "volao_priority_1"
	rule_is_volao_p_1.criterias.append_array(
		[criteria_is_volao]
	)
	rule_is_volao_p_1.priority = 1

	var rule_is_mindundi_p_2 = ReactionRuleItem.new()
	rule_is_mindundi_p_2.label = "mindundi_priority_2"
	rule_is_mindundi_p_2.criterias.append_array(
		[criteria_is_mindundi]
	)
	rule_is_mindundi_p_2.priority = 2

	_rules[rule_is_mindundi.label] = rule_is_mindundi
	_rules[rule_not_comunism_and_low_population.label] = rule_not_comunism_and_low_population
	_rules[rule_mindundi_n_comunism_pop_b_100_400.label] = rule_mindundi_n_comunism_pop_b_100_400
	_rules[rule_is_volao_p_1.label] = rule_is_volao_p_1
	_rules[rule_is_mindundi_p_2.label] = rule_is_mindundi_p_2

	# init events
	var main_event = ReactionEventItem.new()
	var main_event_rules: Array[ReactionRuleItem] = [
		rule_is_mindundi,
		rule_not_comunism_and_low_population,
		rule_mindundi_n_comunism_pop_b_100_400
	]
	main_event.rules = main_event_rules

	main_event.label = "main_event"

	var priority_rule_event = ReactionEventItem.new()
	var priority_rule_event_rules: Array[ReactionRuleItem] = [
		rule_is_mindundi,
		rule_is_mindundi_p_2,
		rule_not_comunism_and_low_population,
		rule_is_volao_p_1,
		rule_mindundi_n_comunism_pop_b_100_400
	]
	priority_rule_event.rules = priority_rule_event_rules

	priority_rule_event.label = "priority_rule_event"

	_events[main_event.label] = main_event
	_events[priority_rule_event.label] = priority_rule_event


func before_each():
	_global_blackboard = ReactionBlackboard.new()
