package;

class Format {
	public static function number(value:Float) {
		
		return 
			if(value == null || Math.isNaN(value)) {
				'NaN';
			} else if(value < 10) {
				var str = Std.string(value);
				var index = str.indexOf('.');
				if(index != -1) {
					str = str.substr(0, index + 4);
				}
				str;
			} else if (value > 1000000000000) {
				Std.int(value / 100000000000) / 10 + 'T';
			} else if (value > 1000000000) {
				Std.int(value / 100000000) / 10 + 'B';
			} else if (value > 1000000) {
				Std.int(value / 100000) / 10 + 'M';
			} else if(value > 1000) {
				Std.int(value / 100) / 10 + 'K';
			} else {
				Std.string(Std.int(value));
			}	
	}
}