package yy;

/**
 * ...
 * @author YellowAfterlife
 */
abstract YyGUID(String) to String {
	public static inline var zero:YyGUID = cast "00000000-0000-0000-0000-000000000000";
	public static inline var sizeof:Int = 36;
	static function create() {
		var result = "";
		for (j in 0 ... 32) {
			if (j == 8 || j == 12 || j == 16 || j == 20) {
				result += "-";
			}
			result += "0123456789abcdef".charAt(Math.floor(Math.random() * 16));
		}
		return result;
	}
	public static function createNum(count:Int, ?pj:YyProject):Array<YyGUID> {
		var out = [];
		var taken = new Map();
		if (pj != null) for (pair in pj.resources) {
			taken.set(pair.Key, true);
			taken.set(pair.Value.id, true);
		}
		for (i in 0 ... count) {
			var id:YyGUID;
			do {
				id = new YyGUID();
			} while (taken.exists(id));
			out.push(id);
		}
		return out;
	}
	public inline function new() {
		this = create();
	}
	public inline function toString() {
		return this;
	}
}
