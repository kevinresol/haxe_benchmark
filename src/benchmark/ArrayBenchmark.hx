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
	@:variant(this)
	public function push<T>(v:T):Assertions {
		var array = [];
		return benchmark(1000000, array.push(v));
	}
	
	@:generic
	@:variant(0)
	@:variant(0.1)
	@:variant('0')
	@:variant(true)
	@:variant(this)
	public function iterate<T>(v:T):Assertions {
		var array = [for(_ in 0...1000000) v];
		return benchmark(100, {
			var count = 0;
			for(i in array) count++;
		});
	}
	
	@:generic
	@:variant(0)
	@:variant(0.1)
	@:variant('0')
	@:variant(true)
	@:variant(this)
	public function getFirst<T>(v:T):Assertions {
		var array = [for(_ in 0...1000000) v];
		return benchmark(100, array[0]);
	}
	
	@:generic
	@:variant(0)
	@:variant(0.1)
	@:variant('0')
	@:variant(true)
	@:variant(this)
	public function getLast<T>(v:T):Assertions {
		var array = [for(_ in 0...1000000) v];
		return benchmark(1000000, array[1000000 - 1]);
	}
	
	@:generic
	@:variant(0)
	@:variant(0.1)
	@:variant('0')
	@:variant(true)
	@:variant(this)
	public function copy<T>(v:T):Assertions {
		var array = [for(_ in 0...1000000) v];
		return benchmark(100, array.copy());
	}
	
	@:generic
	@:variant(0)
	@:variant(0.1)
	@:variant('0')
	@:variant(true)
	@:variant(this)
	public function splice<T>(v:T):Assertions {
		var array = [for(_ in 0...100000) v];
		return benchmark(1, {
			for(i in 0...array.length) array.splice(i, 1);
		});
	}
}