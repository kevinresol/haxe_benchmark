package ;

import js.jquery.Helper.*;

class Chart extends coconut.ui.View {
	@:attr var config:{};
	@:attr var width:String = null;
	@:attr var height:String = null;
	
	var chart:Chartjs;
	
	function render() '
		<div data-hack=${{config; '';}}>
			<canvas width=${width} height=${height} key=${this}/>
		</div>
	';
	
	override function afterInit(e) {
		chart = new Chartjs(J(e).find('canvas'), config);
	}
	
	override function afterPatching(e) {
		for(field in Reflect.fields(config)) 
			Reflect.setField(chart, field, Reflect.field(config, field));
		chart.update({
			duration: 0,
		});
	}
	
	override function afterDestroy(e) {
		J(e).remove();
	}
}


@:native('Chart')
private extern class Chartjs {
	function new(e:Dynamic, config:{});
	function update(?config:{}):Void;
}