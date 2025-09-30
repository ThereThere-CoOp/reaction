class_name TestResponseParent
extends TestGeneralReactionGut


func before_each():
	super()
	var response_group_order: ReactionResponseGroupItem = _responses_groups["group_execution_order"]
	response_group_order.order_current_index = 0
	response_group_order.executed_responses = {}
	
	var return_once_response = _dialog_responses["response_conditional_texts_choices"]	
	response_group_order.responses_settings[return_once_response.uid]["return_once"] = false

class TestResponses:
	extends TestResponseParent

	func test_response_group_return_by_order():
		var response_group_order: ReactionResponseGroupItem = _responses_groups["group_execution_order"]
		
		var returned_response = response_group_order.get_response_by_method(_global_blackboard)[0]
		
		assert_not_null(returned_response, "Returned response not must be null")
		
		gut.p(response_group_order.responses_settings)
		
		assert_eq(
			returned_response.label ,
			"response_conditional_texts_choices",
			"Wrong response returned by order the first response"
		)
		
		returned_response = response_group_order.get_response_by_method(_global_blackboard)[0]
		
		assert_not_null(returned_response, "Returned response not must be null")
		assert_eq(
			returned_response.label ,
			"mindundi_not_comunism_pop_100_400",
			"Wrong response returned by order must return second response cause oreder responses must cycle"
		)
		
		returned_response = response_group_order.get_response_by_method(_global_blackboard)[0]
		
		assert_not_null(returned_response, "Returned response not must be null")
		assert_eq(
			returned_response.label ,
			"live_not_comunism_low_pop",
			"Wrong response returned by order must return third response cause oreder responses must cycle"
		)
		
		returned_response = response_group_order.get_response_by_method(_global_blackboard)[0]
		
		assert_not_null(returned_response, "Returned response must not be null")
		assert_eq(
			returned_response.label ,
			"response_conditional_texts_choices",
			"Wrong response returned by order must return first response cause oreder responses must cycle"
		)
	
	func test_response_group_return_by_order_with_match_once():
		var response_group_order: ReactionResponseGroupItem = _responses_groups["group_execution_order"]
		
		var return_once_response = _dialog_responses["response_conditional_texts_choices"]
		
		response_group_order.responses_settings[return_once_response.uid]["return_once"] = true
		
		var returned_response = response_group_order.get_response_by_method(_global_blackboard)[0]
		
		#gut.p(response_group_order.responses_settings)
		#gut.p(response_group_order.order_current_index)
		#gut.p(response_group_order.executed_responses.size())
		
		assert_not_null(returned_response, "Returned response not must be null")
		assert_eq(
			returned_response.label ,
			"response_conditional_texts_choices",
			"Wrong response returned by order the first response"
		)
		
		returned_response = response_group_order.get_response_by_method(_global_blackboard)[0]
		#gut.p(response_group_order.order_current_index)
		#gut.p(response_group_order.executed_responses.size())
		
		assert_not_null(returned_response, "Returned response not must be null")
		assert_eq(
			returned_response.label ,
			"mindundi_not_comunism_pop_100_400",
			"Wrong response returned by order must return second response cause oreder responses must cycle"
		)
		
		returned_response = response_group_order.get_response_by_method(_global_blackboard)[0]
		#gut.p(response_group_order.order_current_index)
		#gut.p(response_group_order.executed_responses.size())
		
		assert_not_null(returned_response, "Returned response not must be null")
		assert_eq(
			returned_response.label ,
			"live_not_comunism_low_pop",
			"Wrong response returned by order must return third response cause oreder responses must cycle"
		)
		
		returned_response = response_group_order.get_response_by_method(_global_blackboard)[0]
		#gut.p(response_group_order.order_current_index)
		#gut.p(response_group_order.executed_responses.size())
		
		assert_not_null(returned_response, "Returned response must not be null")
		assert_eq(
			returned_response.label,
			"mindundi_not_comunism_pop_100_400",
			"Wrong response returned by order must return second response cause order responses must cycle including return once"
		)
	
	
	func test_response_group_return_random():
		var response_group_random: ReactionResponseGroupItem = _responses_groups["group_execution_random"]
		var return_once_response = _dialog_responses["response_conditional_texts_choices"]
		response_group_random.responses_settings[return_once_response.uid] = {"return_once": true }
		
		
		var custom_randomizer = RandomNumberGenerator.new()
		custom_randomizer.seed = 11111999
		
		var returned_response = null
		var returned_count = 0
		for n in range(0, 100):
			returned_response = response_group_random.get_response_by_method(_global_blackboard, custom_randomizer)[0]
			# gut.p(returned_response.label)
			
			if returned_response.label == "response_conditional_texts_choices":
				returned_count += 1
				
			# gut.p(returned_count)
				
		assert_lt(
			returned_count,
			2,
			"Return once response must returned max one"
		)
		
	func test_response_group_return_weight_random():
		var response_group_random_weight: ReactionResponseGroupItem = _responses_groups["group_execution_random_weight"]
		var return_once_response = _dialog_responses["response_conditional_texts_choices"]
		response_group_random_weight.responses_settings[return_once_response.uid]["return_once"] = true
		
		# gut.p(response_group_random_weight.responses_settings)
				
		var custom_randomizer = RandomNumberGenerator.new()
		custom_randomizer.randomize()
		
		var returned_response = null
		var returned_count = 0
		for n in range(0, 100):
			returned_response = response_group_random_weight.get_response_by_method(_global_blackboard, custom_randomizer)[0]
			# gut.p(returned_response.label)
			
			if returned_response.label == "response_conditional_texts_choices":
				returned_count += 1
				
			# gut.p(returned_count)
				
		assert_lt(
			returned_count,
			2,
			"Return once response must returned max one"
		)
	
