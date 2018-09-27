package;

import tink.pure.*;
using StringTools;

// this is insane, don't try this at home
class LogParser {
	static inline var START = '>> Haxe Benchmark Log Start <<';
	static inline var END = '>> Haxe Benchmark Log End <<';
	static inline var BUILD_FOLD = 'travis_fold:start:build-';
	static var REGEX_FORMAT = ~/\x1B\[\d*m/g;
	static var REGEX_SECTION = ~/^\x1B\[33m(\w*)\x1B\[39m$/;
	static var REGEX_TITLE = ~/ \[.*\] /g;
	static var REGEX_RESULT = ~/Benchmark: (\d*) iterations = ([\d\.]*) ms/g;
	
	public static function parse(log:String):Mapping<String, List<Result>> {
		var targets = new Map();
		var lines = log.split('\r\n');
		
		var target = null;
		var started = false;
		var current:Array<Result> = [];
		var section = null;
		
		var i = 0;
		for(i in 0...lines.length) {
			var line = lines[i];
			
			if(line == END) {
				started = false;
				targets[target] = List.fromArray(current);
				current = [];
			}
			
			if(started) {
				if(REGEX_SECTION.match(line)) {
					section = REGEX_SECTION.matched(1);
				} else {
					var sanitized = REGEX_FORMAT.replace(line, '');
					// trace(sanitized);
					if(REGEX_RESULT.match(sanitized)) {
						var iterations = Std.parseInt(REGEX_RESULT.matched(1));
						var time = Std.parseFloat(REGEX_RESULT.matched(2));
						var perSecond = iterations / (time / 1000);
						var title = REGEX_TITLE.replace(REGEX_FORMAT.replace(lines[i - 1], ''), '').trim();
						current.push({section: section, title: title, iterations: iterations, time: time, perSecond: perSecond});
					}
				}
				
			}
			
			if(line.startsWith(BUILD_FOLD)) 
				target = line.substring(BUILD_FOLD.length, line.indexOf('.'));
				
			if(line == START)
				started = true;
		}
		
		return targets;
	}
}
