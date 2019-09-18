package;

import haxe.DynamicAccess;
import haxe.Json;
import haxe.Timer;
import haxe.ds.Map;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;
import yaml.Parser;
import yaml.Yaml;
import yaml.util.ObjectMap.AnyObjectMap;
import yy.YyGUID;
import yy.YyProject;
import yy.YyProjectResource;
import yy.YyView;
import YaMacro.*;
import YaProject;
import oj.*;
using StringTools;
using StringToolsEx;

/**
 * ...
 * @author YellowAfterlife
 */
class YYYAML {
	private static var yyJson_1 = new EReg('([ \t]+)(".*": )\\[\\]', 'g');
	private static var yyJson_2 = new EReg('\\n', 'g');
	/** Stringifes a value while matching output format to that of GMS2 */
	@:noUsing public static function yyJson(value:Dynamic):String {
		var s = haxe.Json.stringify(value, null, "    ");
		s = yyJson_1.replace(s, '$1$2[\n$1    \n$1]');
		s = StringTools.replace(s, "\n", "\r\n");
		//s = yyJson_2.replace(s, '\r\n');
		return s;
	}
	
	private static inline var sep:String = " | ";
	private static inline var sepl:Int = 3;
	
	private static var shortenPrefix:Map<String, String> = [
		"GMSprite" => "sprites",
		"GMSound" => "sounds",
		"GMScript" => "scripts",
		"GMShader" => "shaders",
		"GMPath" => "paths",
		"GMFont" => "fonts",
		"GMTimeline" => "timelines",
		"GMObject" => "objects",
		"GMRoom" => "rooms",
		"GMExtension" => "extensions",
	];
	static function shortenPath(path:String, type:String):String {
		var pre:String = shortenPrefix[type];
		if (pre == null) return path;
		if (!path.startsWith(pre)) return path;
		if (!path.endsWith(".yy")) return path;
		//
		var c = path.pureCodeAt(pre.length);
		var fwd = c == "/".code;
		if (!fwd && c != "\\".code) return path;
		// if (path.pureCodeAt(pre.length) != "\\".code) return path;
		var p = path.indexOf(fwd ? "/" : "\\", pre.length + 1);
		if (p < 0) return path;
		var name = path.substring(pre.length + 1, p);
		if (name == "") return path;
		if (path.substring(p + 1, path.length - 3) != name) return path;
		return "?" + name;
	}
	static function longenPath(path:String, type:String):String {
		if (path == "" || path.pureCodeAt(0) != "?".code) return path;
		var pre = shortenPrefix[type];
		if (pre == null) return path;
		var name = path.substring(1);
		return pre + "\\" + name + "\\" + name + ".yy";
	}
	
	static function yyp2yaml(yypPath:String, yamlPath:String) {
		var dir = Path.directory(yypPath);
		if (dir == "") dir = ".";
		Sys.print("Reading..."); var t = Timer.stamp();
		var yyp:YyProject = Json.parse(File.getContent(yypPath));
		var views:Map<YyGUID, YaView> = new Map();
		var lookup:Map<YyGUID, YyProjectResourceValue> = new Map();
		var root:YaView = null;
		var resourceIDs:DynamicAccess<String> = {};
		var viewExtras:DynamicAccess<YyView> = {};
		var viewMVC:String = "1.1";
		for (res in yyp.resources) {
			var id = res.Key;
			lookup[id] = res.Value;
			if (res.Value.resourceType == "GMFolder") {
				var viewPath = Path.join([dir, res.Value.resourcePath]);
				var view:YyView = Json.parse(File.getContent(viewPath));
				//
				var yav = new YaView(id, view.folderName, view.children);
				views[id] = yav;
				//
				if (view.isDefaultView) root = yav;
				removeField(view.isDefaultView);
				if (view.localisedFolderName == "") removeField(view.localisedFolderName);
				//
				removeField(view.folderName);
				removeField(view.children);
				//
				viewMVC = view.mvc;
				removeField(view.mvc);
				removeField(view.id);
				removeField(view.modelName);
				if (view.name.toString().toLowerCase() == id.toString().toLowerCase()) {
					removeField(view.name);
				}
				//
				if (view.filterType != "") {
					res.Value.resourceType = view.filterType;
				}
				removeField(view.filterType);
				//
				if (Reflect.fields(view).length != 0) {
					viewExtras[res.Key] = view;
				}
			}
		}
		function view2yaml(view:YaView):Dynamic {
			var arr = [];
			for (guid in view.children) {
				var val:Dynamic;
				var v1 = views[guid];
				if (v1 != null) {
					val = view2yaml(v1);
				} else {
					var res:YyProjectResourceValue = lookup[guid];
					if (res != null) {
						val = shortenPath(res.resourcePath, res.resourceType)
							+ sep + res.resourceType
							+ sep + guid
							+ sep + res.id;
					} else continue;
				}
				arr.push(val);
			}
			var out = {};
			var vr = lookup[view.id];
			Reflect.setField(out, view.name
				+ sep + vr.resourceType
				+ sep + view.id
				+ sep + vr.id
				, arr);
			return out;
		}
		Sys.println(" OK! (" + Std.int((Timer.stamp() - t) * 1000) + "ms)");
		//
		if (root == null) {
			Sys.println("The project has no top-level view..?");
			return;
		}
		Sys.print("Building..."); t = Timer.stamp();
		var rootYaml = view2yaml(root);
		Reflect.deleteField(yyp, "resources");
		Reflect.deleteField(yyp, "script_order");
		var out:YaProject = {
			assets: Reflect.field(rootYaml, Reflect.fields(rootYaml)[0]),
			viewExtras: viewExtras,
			viewRoot: {
				id: root.id,
				resourceID: lookup[root.id].id,
				mvc: viewMVC,
			},
			projectExtras: yyp,
		};
		Sys.println(" OK! (" + Std.int((Timer.stamp() - t) * 1000) + "ms)");
		//
		Sys.print("Writing..."); t = Timer.stamp();
		var yamlText = Yaml.render(out);
		yamlText = yamlText.replace("\n", "\r\n"); // >:c
		File.saveContent(yamlPath, yamlText);
		Sys.println(" OK! (" + Std.int((Timer.stamp() - t) * 1000) + "ms)");
	}
	static function yaml2yyp(yamlPath:String, yypPath:String):Void {
		var dir = Path.directory(yypPath);
		if (dir == "") dir = ".";
		Sys.print("Reading..."); var t = Timer.stamp();
		var yaml:YaProject = Yaml.read(yamlPath, Parser.options().useObjects());
		Sys.println(" OK! (" + Std.int((Timer.stamp() - t) * 1000) + "ms)");
		//
		var foundViews = new Map<String, Bool>();
		var viewExtras = yaml.viewExtras;
		var viewDir = dir + "/views";
		var viewMVC = yaml.viewRoot.mvc;
		//
		var yyp:YyProject = yaml.projectExtras;
		var yypResources:Array<YyProjectResource> = [];
		yyp.resources = yypResources;
		var scriptOrder:Array<YyGUID> = [];
		yyp.script_order = scriptOrder;
		//
		var viewOrder = YYJSON.mvcOrder.concat(["name"]);
		function proc(obj:Dynamic):YyGUID {
			if (obj == null) return null;
			var isDir = !Std.is(obj, String);
			var arr:Array<Dynamic>, str:String;
			if (isDir) {
				str = Reflect.fields(obj)[0];
				arr = Reflect.field(obj, str);
			} else {
				str = obj;
				arr = null;
			}
			//trace(str);
			var sep3 = str.lastIndexOf("|");
			var sep2 = str.lastIndexOf("|", sep3 - 1);
			var sep1 = str.lastIndexOf("|", sep2 - 1);
			if (sep1 < 0 || sep2 < 0 || sep3 < 0) {
				Sys.println('Incorrect format for `$str` - should be `name | kind | id1 | id2`');
				return null;
			}
			var id:YyGUID = cast str.substringTrim(sep2 + 1, sep3);
			var r_id:YyGUID = cast str.substringTrim(sep3 + 1, str.length);
			var r_type = str.substringTrim(sep1 + 1, sep2);
			var sep0 = sep1;
			if (sep0 > 0 && str.pureCodeAt(sep0 - 1) == " ".code) sep0--;
			var r_path = str.substring(0, sep0);
			
			//
			var view:YyView = null;
			if (isDir) {
				var r_filter:String;
				//
				view = viewExtras[id];
				if (view == null) view = cast {};
				view.filterType = r_type;
				view.mvc = viewMVC;
				r_type = view.modelName = "GMFolder";
				view.id = id;
				if (view.name == null) view.name = id;
				view.children = [];
				view.folderName = r_path;
				if (hasField(view.isDefaultView)) {
					view.folderName = "Default";
				} else view.isDefaultView = false;
				if (view.localisedFolderName == null) view.localisedFolderName = "";
				r_path = "views\\" + id + ".yy";
			} else {
				r_path = longenPath(r_path, r_type);
				if (r_type == "GMScript") scriptOrder.push(id);
			}
			//
			var r_json:YyProjectResource = {
				Key: id,
				Value: {
					id: r_id,
					resourcePath: r_path,
					resourceType: r_type,
				}
			};
			yypResources.push(r_json);
			//
			if (isDir) {
				for (item in arr) {
					var c_id = proc(item);
					if (c_id == null) continue;
					view.children.push(c_id);
				}
				var rel = id + ".yy";
				foundViews[rel.toLowerCase()] = true;
				view.hxOrder = viewOrder;
				var viewText = YYJSON.encode(view);
				File.saveContent(viewDir + "/" + rel, viewText);
			}
			//
			return id;
		}
		//
		Sys.print("Building YYP and making views..."); t = Timer.stamp();
		var root = new DynamicAccess();
		root["Default | root | " + yaml.viewRoot.id + " | " + yaml.viewRoot.resourceID] = yaml.assets;
		var rootExtras = yaml.viewExtras[yaml.viewRoot.id];
		if (rootExtras == null) rootExtras = yaml.viewExtras[yaml.viewRoot.id] = cast {};
		rootExtras.isDefaultView = true;
		proc(root);
		if (yyp.resources.length <= 1) {
			Sys.println("");
			Sys.println("YAML doesn't contain any resources.");
			Sys.exit(1);
		}
		
		yyp.resources.sort(function(a, b) return a.Key.toString() > b.Key.toString() ? 1 : -1);
		Sys.println(" OK! (" + Std.int((Timer.stamp() - t) * 1000) + "ms)");
		
		//
		Sys.print("Cleaning up views..."); t = Timer.stamp();
		for (viewRel in FileSystem.readDirectory(viewDir)) {
			if (Path.extension(viewRel).toLowerCase() != "yy") continue;
			if (foundViews[viewRel.toLowerCase()]) continue;
			var viewFull = viewDir + "/" + viewRel;
			//FileSystem.deleteFile(viewFull);
		}
		Sys.println(" OK! (" + Std.int((Timer.stamp() - t) * 1000) + "ms)");
		
		//
		Sys.print("Writing YYP..."); t = Timer.stamp();
		File.saveContent(yypPath, YYJSON.encode(yyp));
		Sys.println(" OK! (" + Std.int((Timer.stamp() - t) * 1000) + "ms)");
	}
	static function main() {
		var args = Sys.args();
		var noWait = args.remove("--nowait");
		var path = args.shift();
		if (path == null) {
			Sys.println("How to use:");
			Sys.println("`YYYAML some.yyp` - generates a YAML file for YYP+views");
			Sys.println("`YYYAML some.yyp.yaml` - updates YYP+views to match YAML");
			Sys.println("For same reason, you can also drag & drop files onto the executable.");
			Sys.println("Add --nowait if you don't want a 'press any key' prompt in the end.");
		} else try {
			if (Path.extension(path).toLowerCase() == "yaml") {
				yaml2yyp(path, Path.withoutExtension(path));
			} else {
				yyp2yaml(path, path + ".yaml");
			}
		} catch (x:Dynamic) {
			Sys.println("An error occurred: " + x);
			Sys.exit(1);
		}
		if (!noWait) {
			Sys.println("Press any key to exit!");
			Sys.getChar(false);
		}
	}
	
}
