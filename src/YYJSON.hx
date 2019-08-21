package;
import haxe.Json;

/**
 * Forcies JSON output into GMS2-looking format, inc. field order.
 * Known issues: GMS2 escapes forward slash, but this doesn't.
 * But also I don't want to include a custom string encoder just for that.
 * @author YellowAfterlife
 */
class YYJSON {
	private static var orderMap:Map<Array<String>, Map<String, Bool>> = new Map();
	public static var mvcOrder = ["configDeltas", "id", "modelName", "mvc"];
	private static function encode_rec(b:StringBuf, obj:Dynamic, indent:Int) {
		var _nl:Int;
		inline function nl(n:Int):Void {
			_nl = n;
			b.add("\r\n");
			while (--_nl >= 0) b.add("    ");
		}
		if (Std.is(obj, String)) {
			b.add(Json.stringify(obj));
		}
		else if (Std.is(obj, Array)) {
			var arr:Array<Dynamic> = obj;
			b.addChar("[".code);
			nl(++indent);
			for (i in 0 ... arr.length) {
				if (i > 0) {
					b.addChar(",".code);
					nl(indent);
				}
				encode_rec(b, arr[i], indent);
			}
			nl(--indent);
			b.addChar("]".code);
		}
		else if (Reflect.isObject(obj)) {
			b.addChar("{".code);
			nl(++indent);
			//
			var order:Array<String> = Reflect.field(obj, "hxOrder");
			var found = 0, sep = false;
			if (order == null) {
				order = mvcOrder;
			} else found++;
			//
			var hasOrder:Map<String, Bool> = orderMap[order];
			if (hasOrder == null) {
				hasOrder = new Map();
				hasOrder["hxOrder"] = true;
				for (field in order) hasOrder[field] = true;
				orderMap[order] = hasOrder;
			}
			//
			inline function addField(field:String):Void {
				if (sep) { b.addChar(",".code); nl(indent); } else sep = true;
				found++;
				b.add(Json.stringify(field));
				b.add(": ");
				encode_rec(b, Reflect.field(obj, field), indent);
			}
			//
			for (field in order) {
				if (!Reflect.hasField(obj, field)) continue;
				addField(field);
			}
			//
			var fields = Reflect.fields(obj);
			if (fields.length > found) {
				fields.sort(StringToolsEx.compare);
				for (field in fields) {
					if (hasOrder.exists(field)) continue;
					addField(field);
				}
			}
			//
			nl(--indent);
			b.addChar("}".code);
		}
		else {
			b.add(Json.stringify(obj));
		}
	}
	public static function encode(obj:Dynamic):String {
		var b = new StringBuf();
		encode_rec(b, obj, 0);
		return b.toString();
	}
}
