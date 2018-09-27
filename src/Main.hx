package;

import travix.*;
import benchmark.*;
import tink.unit.*;
import tink.testrunner.*;

class Main {
	
	static inline var START = '>> Haxe Benchmark Log Start <<';
	static inline var END = '>> Haxe Benchmark Log End <<';
	
	static function main() {
		Logger.println(START);
		Runner.run(TestBatch.make([
			new ArrayBenchmark(),
		])).handle(function(result) {
			Logger.println(END);
			Runner.exit(result);
		});
	}
}