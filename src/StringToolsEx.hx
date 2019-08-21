package;
using StringToolsEx;

/**
 * ...
 * @author YellowAfterlife
 */
class StringToolsEx {
	@:noUsing public static function compare(a:String, b:String):Int {
		return a > b ? 1 : -1;
	}
	public static inline function pureCodeAt(s:String, p:Int):Int {
		#if macro || display || !cpp
		return StringTools.fastCodeAt(s, p);
		#else
		return cpp.NativeString.c_str(s).at(p);
		#end
	}
	
	public static function substringTrim(s:String, pos:Int, end:Int):String {
		#if macro || display || !cpp
		return StringTools.trim(s.substring(pos, end));
		#else
		while (pos < end) {
			var c = s.pureCodeAt(pos);
			if (c == " ".code || c == "\t".code) pos++; else break;
		}
		while (end > pos) {
			var c = s.pureCodeAt(end - 1);
			if (c == " ".code || c == "\t".code) end--; else break;
		}
		return s.substring(pos, end);
		#end
	}
}
