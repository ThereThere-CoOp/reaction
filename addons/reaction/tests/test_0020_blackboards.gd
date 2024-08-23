class_name TestBlackboardParent
extends TestGeneralReactionGut


class TestBlackboards:
	extends TestBlackboardParent

	func test_blackboard_set_fact_value():
		_global_blackboard.set_fact_value(_facts["population_size"], 300)
		assert_eq(
			(
				_global_blackboard
				. facts[_global_blackboard.facts_lookup[_facts["population_size"].uid]]
				. value
			),
			300,
			"Population fact must be set to 300"
		)

	func test_blackboard_set_fact_value_update():
		_global_blackboard.set_fact_value(_facts["population_size"], 300)
		_global_blackboard.set_fact_value(_facts["population_size"], 200)
		assert_eq(
			(
				_global_blackboard
				. facts[_global_blackboard.facts_lookup[_facts["population_size"].uid]]
				. value
			),
			200,
			"Population fact must be updated to 200"
		)

	func test_blackboard_set_enum_fact_value():
		_global_blackboard.set_fact_value(_facts["mind_type"], "mindundi")
		assert_eq(
			(
				_global_blackboard
				. facts[_global_blackboard.facts_lookup[_facts["mind_type"].uid]]
				. value
			),
			2,
			"Mind type fact must be set to mindundi(2)"
		)

	func test_blackboard_get_fact_value():
		_global_blackboard.set_fact_value(_facts["population_size"], 300)
		assert_eq(
			_global_blackboard.get_fact_value(_facts["population_size"].uid),
			300,
			"Population fact value returned must be 300"
		)

	func test_blackboard_get_fact_object():
		_global_blackboard.set_fact_value(_facts["population_size"], 300)
		assert_eq(
			_global_blackboard.get_blackboard_fact(_facts["population_size"].uid).value,
			300,
			"The value for population fact must be set to 300"
		)

	func test_blackboard_merge_without_overwrite():
		_global_blackboard.set_fact_value(_facts["population_size"], 300)
		# assert_eq(_global_blackboard.get_fact_value(_facts["population_size"].uid), 300)

		var blackboard2 = ReactionBlackboard.new()
		blackboard2.set_fact_value(_facts["mind_type"], "mindundi")
		# assert_eq(blackboard2._facts[blackboard2._facts_lookup[_facts["mind_type"].uid]].value, 2)

		blackboard2.set_fact_value(_facts["population_size"], 100)
		# assert_eq(blackboard2.get_fact_value(_facts["population_size"].uid), 100)

		_global_blackboard.merge([blackboard2])
		assert_eq(
			_global_blackboard.get_fact_value(_facts["population_size"].uid),
			300,
			"Merged blackboard must had population fact size value set to 300"
		)
		assert_eq(
			(
				_global_blackboard
				. facts[_global_blackboard.facts_lookup[_facts["mind_type"].uid]]
				. value
			),
			2,
			"Merged blackboard must had population fact size value set to mindundi(2)"
		)

	func test_blackboard_merge_with_overwrite():
		_global_blackboard.set_fact_value(_facts["population_size"], 300)
		# assert_eq(_global_blackboard.get_fact_value(_facts["population_size"].uid), 300)

		var blackboard2 = ReactionBlackboard.new()
		blackboard2.set_fact_value(_facts["mind_type"], "mindundi")
		# assert_eq(blackboard2._facts[blackboard2._facts_lookup[_facts["mind_type"].uid]].value, 2)

		blackboard2.set_fact_value(_facts["population_size"], 100)
		# assert_eq(blackboard2.get_fact_value(_facts["population_size"].uid), 100)

		_global_blackboard.merge([blackboard2], true)
		assert_eq(
			_global_blackboard.get_fact_value(_facts["population_size"].uid),
			100,
			"Merged blackboard must had population fact size value set to 100 cause overwrite"
		)
		assert_eq(
			(
				_global_blackboard
				. facts[_global_blackboard.facts_lookup[_facts["mind_type"].uid]]
				. value
			),
			2,
			"Merged blackboard must had population fact size value set to mindundi(2)"
		)

	func test_set_value_fact_modified_signal_emitted():
		watch_signals(ReactionSignals)

		_global_blackboard.set_fact_value(_facts["is_comunism"], false)

		var blackboard_fact = _global_blackboard.get_blackboard_fact(_facts["is_comunism"].uid)
		assert_signal_emitted_with_parameters(
			ReactionSignals, "blackboard_fact_modified", [blackboard_fact, false]
		)

	func test_set_value_fact_modified_signal_not_emitted():
		watch_signals(ReactionSignals)

		_global_blackboard.set_fact_value(_facts["population_size"], 200)

		assert_signal_not_emitted(
			ReactionSignals,
			"blackboard_fact_modified",
			"Signal blackboard_fact_modified must not emited for fact with trigger_signal_on_modified in false"
		)
