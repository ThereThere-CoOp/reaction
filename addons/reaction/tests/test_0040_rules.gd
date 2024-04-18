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
			_global_blackboard.get_blackboard_fact(_facts["mind_type"].uid)
		)
		assert_false(
			current_result, 'Rule criteria "mindtype_is_mindundi" must test false for "volao"'
		)

		_global_blackboard.set_fact_value(_facts["mind_type"], "mindundi")
		current_result = _rules_criterias["mindtype_is_mindundi"].test(
			_global_blackboard.get_blackboard_fact(_facts["mind_type"].uid)
		)
		assert_true(
			current_result, 'Rule criteria "mindtype_is_mindundi" must test true for "mindundi"'
		)

	func test_integer_lt_criteria():
		var current_result: bool
		# testing numeric less than criteria
		_global_blackboard.set_fact_value(_facts["population_size"], 400)
		current_result = _rules_criterias["population_less_than_300"].test(
			_global_blackboard.get_blackboard_fact(_facts["population_size"].uid)
		)
		assert_false(
			current_result, 'Rule criteria "population_less_than_300" must test false for value 400'
		)

		_global_blackboard.set_fact_value(_facts["population_size"], 200)
		current_result = _rules_criterias["population_less_than_300"].test(
			_global_blackboard.get_blackboard_fact(_facts["population_size"].uid)
		)

		assert_true(
			current_result, 'Rule criteria "population_less_than_300" must test true for value 200'
		)

	func test_boolean_reversed_criteria():
		# testing boolean reversed criteria
		var current_result: bool

		_global_blackboard.set_fact_value(_facts["is_comunism"], true)
		current_result = _rules_criterias["not_comunism"].test(
			_global_blackboard.get_blackboard_fact(_facts["is_comunism"].uid)
		)
		assert_false(current_result, 'Rule criteria "not_comunism" must test false for value true')

		_global_blackboard.set_fact_value(_facts["is_comunism"], false)
		current_result = _rules_criterias["not_comunism"].test(
			_global_blackboard.get_blackboard_fact(_facts["is_comunism"].uid)
		)
		assert_true(current_result, 'Rule criteria "not_comunism" must test true for value false')

	func test_integer_between_criteria():
		var current_result: bool
		# testing numeric between criteria

		_global_blackboard.set_fact_value(_facts["population_size"], 500)
		current_result = _rules_criterias["population_between_100_400"].test(
			_global_blackboard.get_blackboard_fact(_facts["population_size"].uid)
		)
		assert_false(
			current_result,
			'Rule criteria "population_between_100_400" must test false for value 500'
		)

		_global_blackboard.set_fact_value(_facts["population_size"], 20)
		current_result = _rules_criterias["population_between_100_400"].test(
			_global_blackboard.get_blackboard_fact(_facts["population_size"].uid)
		)
		assert_false(
			current_result,
			'Rule criteria "population_between_100_400" must test false for value 20'
		)

		_global_blackboard.set_fact_value(_facts["population_size"], 245)
		current_result = _rules_criterias["population_between_100_400"].test(
			_global_blackboard.get_blackboard_fact(_facts["population_size"].uid)
		)
		assert_true(
			current_result,
			'Rule criteria "population_between_100_400" must test true for value 245'
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
