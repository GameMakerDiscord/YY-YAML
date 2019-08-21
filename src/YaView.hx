package;
import yy.YyGUID;

/**
 * ...
 * @author YellowAfterlife
 */
class YaView {
	public var id:YyGUID;
	public var name:String;
	public var children:Array<YyGUID>;
	public function new(id:YyGUID, name:String, children:Array<YyGUID>) {
		this.id = id;
		this.name = name;
		this.children = children;
	}
	
}
