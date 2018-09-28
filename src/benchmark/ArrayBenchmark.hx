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
		var result = benchmark(1000000, array.push(v));
		ensure(array.length);
		return result;
	}
	
	@:generic
	@:variant(0)
	@:variant(0.1)
	@:variant('0')
	@:variant(true)
	@:variant(this)
	public function iterate<T>(v:T):Assertions {
		var array = [for(_ in 0...10000) v];
		var temp = 0;
		var result = benchmark(#if (php || python || lua || neko) 100 #elseif cpp 1000000000 #else 10000 #end, {
			temp = 0;
			for(i in array) temp++;
		});
		ensure(temp);
		return result;
	}
	
	@:generic
	@:variant(0)
	@:variant(0.1)
	@:variant('0')
	@:variant(true)
	@:variant(this)
	public function getFirst<T>(v:T):Assertions {
		var array = [for(_ in 0...10000000) v];
		var temp = array[0];
		var result = benchmark(#if cpp 1000000000 #else 1000000 #end, temp = array[0]);
		ensure(temp);
		return result;
	}
	
	@:generic
	@:variant(0)
	@:variant(0.1)
	@:variant('0')
	@:variant(true)
	@:variant(this)
	public function getLast<T>(v:T):Assertions {
		var array = [for(_ in 0...10000000) v];
		var temp = array[0];
		var result = benchmark(#if cpp 1000000000 #else 1000000 #end, temp = array[10000000 - 1]);
		ensure(temp);
		return result;
	}
	
	@:generic
	@:variant(0)
	@:variant(0.1)
	@:variant('0')
	@:variant(true)
	@:variant(this)
	public function copy<T>(v:T):Assertions {
		var array = [for(_ in 0...1000000) v];
		var cloned = array;
		var result =  benchmark(#if php 10000 #elseif lua 1 #else 100 #end, cloned = array.copy());
		ensure(cloned);
		return result;
	}
	
	@:generic
	@:variant(0)
	@:variant(0.1)
	@:variant('0')
	@:variant(true)
	@:variant(this)
	public function spliceHead<T>(v:T):Assertions {
		var array = [for(_ in 0...100000) v];
		var result = benchmark(#if (php || lua) 100 #elseif js 10000 #else 100000 #end, array.splice(0, 1));
		ensure(array.length);
		return result;
	}
	
	@:generic
	@:variant(0)
	@:variant(0.1)
	@:variant('0')
	@:variant(true)
	@:variant(this)
	public function spliceTail<T>(v:T):Assertions {
		var array = [for(_ in 0...100000) v];
		var result = benchmark(#if php 100 #else 100000 #end, array.splice(array.length - 1, 1));
		ensure(array.length);
		return result;
	}
	
	@:generic
	@:variant(0, 1)
	@:variant(0.1, 0.2)
	@:variant('0', '1')
	@:variant(true, false)
	@:variant(this, new benchmark.ArrayBenchmark())
	public function indexOfHead<T>(v:T, i:T):Assertions {
		var array = [for(_ in 0...1000) v];
		array[0] = i;
		var temp = 0;
		var result = benchmark(#if (php || js || cpp || neko || node || cs || java) 100000 #else 1000 #end, temp += array.indexOf(i));
		ensure(temp);
		return result;
	}
	
	@:generic
	@:variant(0, 1)
	@:variant(0.1, 0.2)
	@:variant('0', '1')
	@:variant(true, false)
	@:variant(this, new benchmark.ArrayBenchmark())
	public function indexOfTail<T>(v:T, i:T):Assertions {
		var array = [for(_ in 0...1000) v];
		array[array.length - 1] = i;
		var temp = 0;
		var result = benchmark(#if (js || cpp || cs || java) 100000 #else 1000 #end, temp += array.indexOf(i));
		ensure(temp);
		return result;
	}
	
	@:keep
	function ensure<T>(v:T) {}
}