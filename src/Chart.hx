package ;

import js.html.*;

using tink.CoreApi;

@:native('ChartView')
class Chart extends coconut.ui.View {
	@:attr var config:{};
	@:attr var width:String = null;
	@:attr var height:String = null;
	
	var chart:Chartjs;
	
	function render() '
		<div data-hack=${{config; '';}}>
			<canvas width=${width} height=${height}/>
		</div>
	';
	
	override function afterInit(e:Element) {
		chart = new Chartjs(e.querySelector('canvas'), config);
	}
	
	override function afterPatching(e) {
		for(field in Reflect.fields(config)) 
			Reflect.setField(chart, field, Reflect.field(config, field));
		
		chart.update({duration: 0});
	}
	
	override function afterDestroy(e:Element) {
		if(e.parentNode != null) e.parentNode.removeChild(e);
	}
}

