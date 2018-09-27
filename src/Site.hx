package;

import js.Browser.*;
import js.html.*;
import travis.*;
import tink.http.clients.*;
import tink.web.proxy.Remote;
import tink.url.Host;

using StringTools;

class Site extends coconut.ui.View {
	public var remote =
		new Remote<Api>(
			new SecureJsClient(), 
			new RemoteEndpoint(new Host('api.travis-ci.org', 443))
				.sub({path: ['v3']})
		);
		
	static function main() {
		document.body.appendChild(new Site({}).toElement());
	}
	
	@:state var log:String = null;
	
	function render() '
		<div class="ui container">
			<h1 class="ui header">Haxe Benchmark</h1>
			<if ${log != null}>
				<Log log=${log}/>
			</if>
		</div>
	';
	
	override function afterInit(e) {
		remote.repos().ofSlug('kevinresol/haxe_benchmark').builds().list()
			.next(res -> remote.jobs().ofId(res.builds[0].jobs[0].id).log())
			.handle(function(o) switch o {
				case Success(res):
					log = res.content;
					var sections = LogParser.parse(res.content);
					for(target in sections.keys()) trace(target, sections[target].length);
				case Failure(e): trace(e);
			});
	}
}

class Log extends coconut.ui.View {
	@:attr var log:String;
	
	function render() '
		<pre>${log}</pre>
	';
}

// this is insane, don't try this at home
class LogParser {
	static inline var START = '>> Haxe Benchmark Log Start <<';
	static inline var END = '>> Haxe Benchmark Log End <<';
	static inline var BUILD_FOLD = 'travis_fold:start:build-';
	
	public static function parse(log:String) {
		var targets = new Map();
		var lines = log.split('\n');
		
		var target = null;
		var started = false;
		var current = [];
		for(line in lines) {
			if(line == END) {
				started = false;
				targets[target] = current;
				current = [];
			}
			if(started) current.push(line);
			if(line.startsWith(BUILD_FOLD))
				target = line.substring(BUILD_FOLD.length + 1, line.indexOf('.'));
			if(line == START) started = true;
		}
		
		return targets;
	}
}