package yy;

/**
 * ...
 * @author YellowAfterlife
 */
typedef YyProject = {
	>YyBase,
	resources:Array<YyProjectResource>,
	parentProject:Dynamic,
	configs:Array<String>,
	script_order:Array<YyGUID>,
};
