class_name TestModificationsParent
extends TestGeneralReactionGut


class TestModifications:
	extends TestBlackboardParent

	func test_modification_assign():
		_global_blackboard.set_fact_value(_facts["is_comunism"], false)
		_context_modifications["declare_comunism"].execute(_global_blackboard)

		assert_eq(
			_global_blackboard.get_fact_value(_facts["is_comunism"].uid),
			1,
			"Must be declared comunism"
		)

	func test_modification_decrease():
		_global_blackboard.set_fact_value(_facts["population_size"], 200)
		_context_modifications["decrease_population_in_100"].execute(_global_blackboard)

		assert_eq(
			_global_blackboard.get_fact_value(_facts["population_size"].uid),
			100,
			"Population must be decreased in 100 (initial 200)"
		)

	func test_modification_increase():
		_global_blackboard.set_fact_value(_facts["population_size"], 200)
		_context_modifications["grow_population_in_500"].execute(_global_blackboard)

		assert_eq(
			_global_blackboard.get_fact_value(_facts["population_size"].uid),
			700,
			"Population must be increased in 500 (initial 200)"
		)

	func test_modification_erase():
		_global_blackboard.set_fact_value(_facts["mind_type"], "mindundi")
		_context_modifications["erase_mind_type"].execute(_global_blackboard)

		assert_null(
			_global_blackboard.get_fact_value(_facts["mind_type"].uid), "Mind type must not exists"
		)
		
		
	func test_modification_function_increase():
		_global_blackboard.set_fact_value(_facts["population_size"], 200)
		_global_blackboard.set_fact_value(_facts["extra_population_size"], 30)
		
		_context_modifications["function_add_population_size_plus_10_to_extra"].execute(_global_blackboard)

		assert_eq(
			_global_blackboard.get_fact_value(_facts["extra_population_size"].uid),
			240,
			"Extra Population must be increased in 210 (initial 30)"
		)

	func test_modification_modified_signal_emitted():
		_global_blackboard.set_fact_value(_facts["is_comunism"], false)
		watch_signals(ReactionSignals)

		_context_modifications["declare_comunism"].execute(_global_blackboard)

		var blackboard_fact = _global_blackboard.get_blackboard_fact(_facts["is_comunism"].uid)
		assert_signal_emitted_with_parameters(
			ReactionSignals, "blackboard_fact_modified", [blackboard_fact, true]
		)

	func test_modification_modified_signal_not_emitted():
		_global_blackboard.set_fact_value(_facts["population_size"], 200)

		watch_signals(ReactionSignals)

		_context_modifications["decrease_population_in_100"].execute(_global_blackboard)

		assert_signal_not_emitted(
			ReactionSignals,
			"blackboard_fact_modified",
			"Signal blackboard_fact_modified must not emited for fact with trigger_signal_on_modified in false"
		)
