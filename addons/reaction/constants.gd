@tool
class_name ReactionConstants extends RefCounted


const CRITERIA_FUNCTION_OPERATOR_OPTIONS = {
	"+": "+",
	"-": "-",
	"*": "*",
	"/": "/",
	"(": "(",
	")": ")",
	"pow": "pow",
	"sqrt": "sqrt",
	",": ",",
}

const RANDOM_WEIGHT_RETURN_METHOD = 'random_weight'
const RANDOM_RETURN_METHOD = 'random'
const EXECUTION_ORDER_RETURN_METHOD = 'by_order'
const ALL_RETURN_METHOD = 'all'

enum ITEMS_TYPE_ENUM {
	BASE,
	FACT, 
	EVENT, 
	RULE, 
	CRITERIA,
	MODIFICATION,
	FUNC_CRITERIA, 
	RESPONSE_GROUP, 
	RESPONSE,
	DIALOG,
	DIALOG_TEXT,
	CHOICE,
	TAG,
}
