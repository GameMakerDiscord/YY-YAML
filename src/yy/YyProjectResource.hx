package yy;

/**
 * ...
 * @author YellowAfterlife
 */
typedef YyProjectResource = {
	Key:YyGUID,
	Value:YyProjectResourceValue,
};
typedef YyProjectResourceValue = {
	id:YyGUID,
	resourcePath:String,
	resourceType:String,
	?hxOrder:Array<String>,
};
