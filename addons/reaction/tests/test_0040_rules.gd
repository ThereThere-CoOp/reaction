class_name TestRulesParent
extends TestGeneralReactionGut


func before_each():
	super()


class TestRules:
	extends TestRulesParent

	func test_enum_eq_criteria():
		var current_result: bool
		# testing numeric less than criteria
		_global_blackboard.set_fact_value(_facts["mind_type"], "volao")
		current_result = _rules_criterias["mindtype_is_mindundi"].test(
			_global_blackboard
		)
		assert_false(
			current_result, 'Rule criteria "mindtype_is_mindundi" must test false for "volao"'
		)

		_global_blackboard.set_fact_value(_facts["mind_type"], "mindundi")
		current_result = _rules_criterias["mindtype_is_mindundi"].test(
			_global_blackboard
		)
		assert_true(
			current_result, 'Rule criteria "mindtype_is_mindundi" must test true for "mindundi"'
		)

	func test_integer_lt_criteria():
		var current_result: bool
		# testing numeric less than criteria
		_global_blackboard.set_fact_value(_facts["population_size"], 400)
		current_result = _rules_criterias["population_less_than_300"].test(
			_global_blackboard
		)
		assert_false(
			current_result, 'Rule criteria "population_less_than_300" must test false for value 400'
		)

		_global_blackboard.set_fact_value(_facts["population_size"], 200)
		current_result = _rules_criterias["population_less_than_300"].test(
			_global_blackboard
		)

		assert_true(
			current_result, 'Rule criteria "population_less_than_300" must test true for value 200'
		)

	func test_boolean_reversed_criteria():
		# testing boolean reversed criteria
		var current_result: bool

		_global_blackboard.set_fact_value(_facts["is_comunism"], true)
		current_result = _rules_criterias["not_comunism"].test(
			_global_blackboard
		)
		assert_false(current_result, 'Rule criteria "not_comunism" must test false for value true')

		_global_blackboard.set_fact_value(_facts["is_comunism"], false)
		current_result = _rules_criterias["not_comunism"].test(
			_global_blackboard
		)
		assert_true(current_result, 'Rule criteria "not_comunism" must test true for value false')

	func test_integer_between_criteria():
		var current_result: bool
		# testing numeric between criteria

		_global_blackboard.set_fact_value(_facts["population_size"], 500)
		current_result = _rules_criterias["population_between_100_400"].test(
			_global_blackboard
		)
		assert_false(
			current_result,
			'Rule criteria "population_between_100_400" must test false for value 500'
		)

		_global_blackboard.set_fact_value(_facts["population_size"], 20)
		current_result = _rules_criterias["population_between_100_400"].test(
			_global_blackboard
		)
		assert_false(
			current_result,
			'Rule criteria "population_between_100_400" must test false for value 20'
		)

		_global_blackboard.set_fact_value(_facts["population_size"], 245)
		current_result = _rules_criterias["population_between_100_400"].test(
			_global_blackboard
		)
		assert_true(
			current_result,
			'Rule criteria "population_between_100_400" must test true for value 245'
		)
		
	func test_function_criteria_sum():
		var current_result: bool
		var criteria_function_result_value: int
		
		_global_blackboard.set_fact_value(_facts["population_size"], 100)
		_global_blackboard.set_fact_value(_facts["extra_population_size"], 500)
		_global_blackboard.set_fact_value(_facts["extra_small_population_size"], 50)
		
		current_result = _rules_criterias["pop_sum_less_500"].test(
			_global_blackboard
		)
		
		assert_false(
			current_result,
			'Rule function criteria "pop_sum_less_500" must test false for value 100, 500 and 50'
		)
		
		criteria_function_result_value = _rules_criterias["pop_sum_less_500"].get_function_result(
			_global_blackboard
		)
		
		assert_eq(
			criteria_function_result_value,
			650,
			'Rule function criteria "pop_sum_less_500" result value must be 650'
		)
		
		_global_blackboard.set_fact_value(_facts["population_size"], 100)
		_global_blackboard.set_fact_value(_facts["extra_population_size"], 200)
		
		current_result = _rules_criterias["pop_sum_less_500"].test(
			_global_blackboard
		)
		
		assert_true(
			current_result,
			'Rule function criteria "pop_sum_less_500" must test true for value 100, 200 y 50'
		)
		
		criteria_function_result_value = _rules_criterias["pop_sum_less_500"].get_function_result(
			_global_blackboard
		)
		
		assert_eq(
			criteria_function_result_value,
			350,
			'Rule function criteria "pop_sum_less_500" result value must be 350'
		)
		
	func test_function_criteria_sus():
		var current_result: bool
		var criteria_function_result_value: int
		
		_global_blackboard.set_fact_value(_facts["population_size"], 500)
		_global_blackboard.set_fact_value(_facts["extra_population_size"], 100)
		_global_blackboard.set_fact_value(_facts["extra_small_population_size"], 50)
		
		current_result = _rules_criterias["pop_sus_more_500"].test(
			_global_blackboard
		)
		
		assert_false(
			current_result,
			'Rule function criteria "pop_sus_more_500" must test false for value 500, 100 and 50'
		)
		
		criteria_function_result_value = _rules_criterias["pop_sus_more_500"].get_function_result(
			_global_blackboard
		)
		
		assert_eq(
			criteria_function_result_value,
			350,
			'Rule function criteria "pop_sus_more_500" result value must be 350'
		)
		
		_global_blackboard.set_fact_value(_facts["population_size"], 1000)
		_global_blackboard.set_fact_value(_facts["extra_population_size"], 200)
		
		current_result = _rules_criterias["pop_sus_more_500"].test(
			_global_blackboard
		)
		
		assert_true(
			current_result,
			'Rule function criteria "pop_sus_more_500" must test true for value 1000, 200 y 50'
		)
		
		criteria_function_result_value = _rules_criterias["pop_sus_more_500"].get_function_result(
			_global_blackboard
		)
		
		assert_eq(
			criteria_function_result_value,
			750,
			'Rule function criteria "pop_sus_more_500" result value must be 750'
		)
		
	func test_function_criteria_mult():
		var current_result: bool
		var criteria_function_result_value: int
		
		_global_blackboard.set_fact_value(_facts["population_size"], 10)
		_global_blackboard.set_fact_value(_facts["extra_population_size"], 1)
		_global_blackboard.set_fact_value(_facts["extra_small_population_size"], 10)
		
		current_result = _rules_criterias["pop_mult_more_500"].test(
			_global_blackboard
		)
		
		assert_false(
			current_result,
			'Rule function criteria "pop_mult_more_500" must test false for value 10, 1 and 10'
		)
		
		criteria_function_result_value = _rules_criterias["pop_mult_more_500"].get_function_result(
			_global_blackboard
		)
		
		assert_eq(
			criteria_function_result_value,
			100,
			'Rule function criteria "pop_mult_more_500" result value must be 100'
		)
		
		_global_blackboard.set_fact_value(_facts["population_size"], 500)
		_global_blackboard.set_fact_value(_facts["extra_population_size"], 100)
		
		current_result = _rules_criterias["pop_mult_more_500"].test(
			_global_blackboard
		)
		
		assert_true(
			current_result,
			'Rule function criteria "pop_mult_more_500" must test true for value 500, 100 y 10'
		)
		
		criteria_function_result_value = _rules_criterias["pop_mult_more_500"].get_function_result(
			_global_blackboard
		)
		
		assert_eq(
			criteria_function_result_value,
			500000,
			'Rule function criteria "pop_mult_more_500" result value must be 500000'
		)
		
	func test_not_matching_rule():
		_global_blackboard.set_fact_value(_facts["population_size"], 500)
		_global_blackboard.set_fact_value(_facts["is_comunism"], false)
		_global_blackboard.set_fact_value(_facts["mind_type"], "mindundi")

		assert_false(
			_rules["mindundi_not_comunism_pop_between_100_400"].test(_global_blackboard),
			"Rule must not match cause do not fulfill population in 100-400 range criteria"
		)

		_global_blackboard.set_fact_value(_facts["population_size"], 125)
		_global_blackboard.set_fact_value(_facts["is_comunism"], true)
		_global_blackboard.set_fact_value(_facts["mind_type"], "mindundi")

		assert_false(
			_rules["mindundi_not_comunism_pop_between_100_400"].test(_global_blackboard),
			"Rule must not match cause do not fulfill not_comunism criteria"
		)

		_global_blackboard.set_fact_value(_facts["population_size"], 125)
		_global_blackboard.set_fact_value(_facts["is_comunism"], false)
		_global_blackboard.set_fact_value(_facts["mind_type"], "volao")

		assert_false(
			_rules["mindundi_not_comunism_pop_between_100_400"].test(_global_blackboard),
			"Rule must not match cause do not fulfill mind_type mindundi criteria"
		)

	func test_match_rule():
		_global_blackboard.set_fact_value(_facts["population_size"], 200)
		_global_blackboard.set_fact_value(_facts["is_comunism"], false)
		_global_blackboard.set_fact_value(_facts["mind_type"], "mindundi")

		assert_true(
			_rules["mindundi_not_comunism_pop_between_100_400"].test(_global_blackboard),
			"Rule must match cause met all criterias"
		)

	func test_modifications_execution():
		_global_blackboard.set_fact_value(_facts["population_size"], 200)
		_global_blackboard.set_fact_value(_facts["is_comunism"], false)

		_rules["is_mindundi"].execute_modifications(_global_blackboard)

		assert_eq(
			_global_blackboard.get_fact_value(_facts["is_comunism"].uid), 1, "Must be comunism"
		)

		assert_eq(
			_global_blackboard.get_fact_value(_facts["population_size"].uid),
			100,
			"Population must be decreased in 100 (origianl 200)"
		)
