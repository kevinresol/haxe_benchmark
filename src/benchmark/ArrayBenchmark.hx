package benchmark;

import tink.unit.Assert.*;
import tink.testrunner.*;

class ArrayBenchmark {
	public function new() {}
	
	@:generic
	@:variant(0)
	@:variant(0.1)
	@:variant('0')
	@:variant(true)
	public function push<T>(v:T):Assertions {
		var array = [];
		return benchmark(1000000, array.push(v));
	}
	
	@:generic
	@:variant(0)
	@:variant(0.1)
	@:variant('0')
	@:variant(true)
	public function iterate<T>(v:T):Assertions {
		var array = [for(_ in 0...1000000) v];
		return benchmark(100, {
			var count = 0;
			for(i in array) count++;
		});
	}
}