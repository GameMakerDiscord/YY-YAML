package;
import haxe.DynamicAccess;
import yy.YyGUID;
import yy.YyView;

/**
 * ...
 * @author YellowAfterlife
 */
typedef YaProject = {
	assets:DynamicAccess<Dynamic>,
	viewExtras:DynamicAccess<YyView>,
	viewRoot:YaProjectRoot,
	projectExtras:Dynamic,
}
typedef YaProjectRoot = {
	id:YyGUID,
	resourceID:YyGUID,
	mvc:String,
}
