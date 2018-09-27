
@:native('Chart')
extern class Chartjs {
	function new(e:Dynamic, config:{});
	function update(?config:{}):Void;
	static var plugins:{register:{}->Void};
	static var helpers:{fontString:Int->String->String->String};
}