package;

import tink.pure.*;
import js.Browser.*;
import travis.*;
import tink.http.clients.*;
import tink.web.proxy.Remote;
import tink.url.Host;
import haxe.crypto.*;

using tink.CoreApi;
using Lambda;

class Site extends coconut.ui.View {
	public var remote =
		new Remote<Api>(
			new SecureJsClient(), 
			new RemoteEndpoint(new Host('api.travis-ci.org', 443))
				.sub({path: ['v3']})
		);
		
	static function main() {
		Chartjs.plugins.register({
			afterDatasetsDraw: function(chart) {
				var ctx = chart.ctx;

				chart.data.datasets.forEach(function(dataset, i) {
					var meta = chart.getDatasetMeta(i);
					if (!meta.hidden) {
						meta.data.forEach(function(element, index) {
							// Draw the text in black, with the specified font
							ctx.fillStyle = 'rgb(0, 0, 0)';

							var fontSize = 10;
							var fontStyle = 'normal';
							var fontFamily = 'Helvetica Neue, Helvetica, Arial';
							ctx.font = Chartjs.helpers.fontString(fontSize, fontStyle, fontFamily);

							// Just naively convert to string for now
							var value = dataset.data[index];
							var str = Format.number(value);
							
							// Make sure alignment settings are correct
							ctx.textAlign = 'center';
							ctx.textBaseline = 'middle';

							var padding = 1;
							var position = element.tooltipPosition();
							var y = position.y - (fontSize / 2) - padding;
							if(y < 28) {
								y = 28;
								str = '( $str )';
							}
							ctx.fillText(str, position.x, y);
						});
					}
				});
			}
		});
		
		
		document.body.appendChild(new Site({}).toElement());
	}
	
	@:state var log:String = null;
	@:state var results:Mapping<String, List<Result>> = null;
	@:state var message:String = null;
	@:state var sha:String = null;
	@:state var jobId:Int = null;
	
	function render() '
		<div>
			<h1 class="ui header">
				Haxe Benchmark (<a href="https://github.com/kevinresol/haxe_benchmark">Github</a>)
				<div class="sub header">
					All chart values are in "operations per second", higher is better<br/>
					Data labels wrapped in parenthesis means that they exceed the chart bounds, i.e. much much faster than other targets
				</div>
			</h1>
			
			<if ${sha != null && jobId != null}>
				<div style="margin-bottom:1em">
					<strong>
						Revision: ${message} (<a href="https://github.com/kevinresol/haxe_benchmark/commit/${sha}">${sha.substr(0, 8)}</a>) - <a href="https://travis-ci.org/kevinresol/haxe_benchmark/jobs/$jobId">Raw Build Log</a>
					</strong>
				</div>
			</if>
			
			<if ${log != null}>
				<Log log=${log}/>
			</if>
			
			<if ${results != null}>
				<Charts results=${results}/>
			<else>
				<div class="ui basic segment">Loading</div>
			</if>
		</div>
	';
	
	override function afterInit(e) {
		remote.repos().ofSlug('kevinresol/haxe_benchmark').builds().list()
			.next(function(res) {
				var iter = res.builds.iterator();
				
				return Future.async(function(cb) {
					function next() {
						if(iter.hasNext()) {
							var build = iter.next();
							if(build.state == 'passed') {
								message = build.commit.message;
								sha = build.commit.sha;
								var job = build.jobs.pop();
								remote.jobs().ofId(jobId = job.id).log().next(res -> LogParser.parse(res.content))
									.handle(function(o) switch o {
										case Success(null): trace('parsed nothing'); next();
										case Success(parsed): cb(Success(parsed));
										case Failure(e): trace(e); next();
									});
							} else {
								next();
							}
						} else {
							cb(Failure(new Error('No valid builds')));
						}
					}
					next();
				});
			})
			.handle(function(o) switch o {
				case Success(parsed): results = parsed;
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

class Charts extends coconut.ui.View {
	@:attr var results:Mapping<String, List<Result>>;
	
	function render() '
		<div>
			<let sections=${getSections()}>
				<for ${section in sections.keys()}>
					<div class="ui segment">
						<h3 class="ui header">${section} (<a href="https://github.com/kevinresol/haxe_benchmark/blob/master/src/benchmark/${section}.hx">Source</a>)</h3>
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
				var data = targets.map(target -> switch operations[title].find(op -> op.target == target) {
					case null: null;
					case v if(v.value > js.Syntax.code('Number.MAX_SAFE_INTEGER')): js.Syntax.code('Number.MAX_SAFE_INTEGER');
					case v: v.value;
				});
				
				configs.push({
					type: 'bar',
					data: {
						labels: targets,
						datasets: [{
							// label: title,
							data: data,
							backgroundColor: colors,
						}],
					},
					options: {
						scales: {
							yAxes: [{
								ticks: {
									max: {
										var copy = data.filter(v -> v != null);
										copy.sort(Reflect.compare);
										copy[copy.length - 2] * 1.5; // use the second-highest value plus a margin
									},
									callback: (value, inidex, values) -> Format.number(value),
								}
							}]
						},
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