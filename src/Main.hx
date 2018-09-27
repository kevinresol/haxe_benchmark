package;

import travix.*;
import benchmark.*;
import tink.unit.*;
import tink.testrunner.*;

class Main {
	
	static inline var START = '>> Haxe Benchmark Log Start <<';
	static inline var END = '>> Haxe Benchmark Log End <<';
	
	static function main() {
		
		#if php untyped ini_set('memory_limit', '2048M'); #end
		
		Logger.println(START);
		Runner.run(TestBatch.make([
			new ArrayBenchmark(),
		])).handle(function(result) {
			Logger.println(END);
			Runner.exit(result);
		});
	}
}