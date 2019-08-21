package;
import haxe.macro.Context;
import haxe.macro.Expr;

/**
 * ...
 * @author YellowAfterlife
 */
class YaMacro {
	public static macro function hasField(fa:Expr):Expr {
		#if !display
		switch (fa.expr) {
			case EField(obj, fd): {
				return macro @:pos(fa.pos) Reflect.hasField($obj, $v{fd});
			};
			default: {
				Context.error('Want a field', fa.pos);
				return macro {};
			}
		}
		#else
		return macro fa != null;
		#end
	}
	public static macro function removeField(fa:Expr):Expr {
		#if !display
		switch (fa.expr) {
			case EField(obj, fd): {
				return macro @:pos(fa.pos) Reflect.deleteField($obj, $v{fd});
			};
			default: {
				Context.error('Want a field', fa.pos);
				return macro {};
			}
		}
		#else
		return macro $fa = null;
		#end
	}
}
