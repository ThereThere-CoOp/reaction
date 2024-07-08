class_name TestEventsParent
extends TestGeneralReactionGut


func before_each():
	super()


class TestEvents:
	extends TestEventsParent

	func test_rule_ordering_without_priorities():
		assert_eq(
			_events["main_event"].rules[-1].label,
			_rules["is_mindundi"].label,
			"The last rule must be the one with less criteria"
		)
		assert_eq(
			_events["main_event"].rules[0].label,
			_rules["mindundi_not_comunism_pop_between_100_400"].label,
			"The first rule must be the one with more criteria"
		)

	func test_rule_ordering_with_priorities():
		assert_eq(
			_events["priority_rule_event"].rules[-1].label,
			_rules["is_mindundi"].label,
			"The last rule must be the one with less criteria and no priority"
		)
		assert_eq(
			_events["priority_rule_event"].rules[0].label,
			_rules["volao_priority_1"].label,
			"The first rule must be the one with higher(lower) priority"
		)

		assert_eq(
			_events["priority_rule_event"].rules[1].label,
			_rules["mindundi_priority_2"].label,
			"The first rule must be the one with the second higher(lower) priority"
		)

	func test_event_get_response():
		_global_blackboard.set_fact_value(_facts["mind_type"], "mindundi")
		_global_blackboard.set_fact_value(_facts["is_comunism"], false)
		_global_blackboard.set_fact_value(_facts["population_size"], 50)

		var dialog_returned: String = (
			_events["main_event"].get_responses(_global_blackboard)[0].dialog_text["es"]
		)

		gut.p("Returned dialog: " + dialog_returned)
		assert_eq(
			_dialog_responses["live_not_comunism_low_pop"].dialog_text["es"],
			dialog_returned,
			"Wrong dialog response returned"
		)
