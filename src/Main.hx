package;

import travix.*;
import benchmark.*;
import tink.unit.*;
import tink.testrunner.*;

class Main {
	
	static inline var START = '>> Haxe Benchmark Log Start <<';
	static inline var END = '>> Haxe Benchmark Log End <<';
	
	static function main() {
		
		#if php untyped __call__('ini_set', 'memory_limit', '2048M'); #end
		
		Logger.println(START);
		Runner.run(TestBatch.make([
			new ArrayBenchmark(),
			new StringBenchmark(),
		])).handle(function(result) {
			Logger.println(END);
			Runner.exit(result);
		});
	}
}