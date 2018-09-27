package;

import tink.pure.*;
import js.Browser.*;
import travis.*;
import tink.http.clients.*;
import tink.web.proxy.Remote;
import tink.url.Host;
import haxe.crypto.*;

using Lambda;

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
	
	@:state var results:Mapping<String, List<Result>> = null;
	
	function render() '
		<div>
			<h1 class="ui header">
				Haxe Benchmark
				<div class="sub header">
					All charts are in "Operations per second", higher is better
				</div>
			</h1>
			
			<if ${results != null}>
				<Charts results=${results}/>
			<else>
				Loading
			</if>
		</div>
	';
	
	override function afterInit(e) {
		remote.repos().ofSlug('kevinresol/haxe_benchmark').builds().list()
			.next(res -> remote.jobs().ofId(res.builds[0].jobs[0].id).log())
			.handle(function(o) switch o {
				case Success(res): results = LogParser.parse(res.content);
				case Failure(e): trace(e);
			});
	}
}

class Charts extends coconut.ui.View {
	@:attr var results:Mapping<String, List<Result>>;
	
	function render() '
		<div>
			<let sections=${getSections()}>
				<for ${section in sections.keys()}>
					<div class="ui segment">
						<h3 class="ui header">${section}</h3>
						<div class="ui two column stackable grid">
							<for ${config in sections[section]}>
								<div class="column">
									<Chart config=${config} width="400" height="200"/>
								</div>
							</for>
						</div>
					</div>
				</for>
			</let>
		</div>
	';
	
	function getSections() {
		var targets = [];
		
		var sections = new Map();
		for(target in results.keys()) {
			targets.push(target);
			for(op in results.get(target)) {
				if(!sections.exists(op.section)) sections[op.section] = new Map();
				
				var operations = sections[op.section];
				if(!operations.exists(op.title)) operations[op.title] = [];
				operations[op.title].push({target: target, value: op.perSecond});
			}
		}
		
		var ret = new Map();
		var colors = targets.map(target -> '#' + Sha1.encode(target).substr(0, 6));
		
		for(section in sections.keys()) {
			var configs = ret[section] = [];
			var operations = sections[section];
			for(title in operations.keys()) {
				configs.push({
					type: 'bar',
					data: {
						labels: targets,
						datasets: [{
							// label: title,
							data:
								targets.map(target -> switch operations[title].find(op -> op.target == target) {
									case null: null;
									case v: v.value;
								}),
							backgroundColor: colors,
						}],
					},
					options: {
						title: {
							display: true, 
							text: title,
						},
						legend: {
							display: false
						}
					}
				});
			}
		}
		
		return ret;
	}
}