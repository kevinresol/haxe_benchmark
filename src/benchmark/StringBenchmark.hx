package benchmark;

import tink.unit.Assert.*;
import tink.testrunner.*;

class StringBenchmark {
	
	static var LONG_STRING = {
		var buf = new StringBuf();
		for(i in 0...1000) buf.add('0000000000');
		buf.toString();
	}
	
	public function new() {}
	
	public function add():Assertions {
		var s = 'a';
		var result = benchmark(#if (nodejs || python) 1000000 #elseif php 100000 #else 10000 #end, s += 'a');
		ensure(s.length);
		return result;
	}
	
	public function charCodeAt():Assertions {
		var s = LONG_STRING;
		var temp = 0;
		var result = benchmark(#if (python || hl) 100 #else 1000 #end, for(i in 0...s.length) temp = s.charCodeAt(i));
		ensure(temp);
		return result;
	}
	
	public function charAt():Assertions {
		var s = LONG_STRING;
		var temp = null;
		var result = benchmark(#if (php || hl) 100 #else 1000 #end, for(i in 0...s.length) temp = s.charAt(i));
		ensure(temp);
		return result;
	}
	
	@:variant('1')
	@:variant('1111111111')
	@:variant('1111111111111111111111111111111111111111')
	public function indexOfHead(v:String):Assertions {
		var s = v + LONG_STRING;
		var temp = 0;
		var result = benchmark(1000000, temp = s.indexOf(v));
		ensure(temp);
		return result;
	}
	
	@:variant('1')
	@:variant('1111111111')
	@:variant('1111111111111111111111111111111111111111')
	public function indexOfTail(v:String):Assertions {
		var s = LONG_STRING + v;
		var temp = 0;
		var result = benchmark(#if (php || lua || python || java || cs) 100000 #elseif (nodejs || hl) 10000 #else 100 #end, temp = s.indexOf(v));
		ensure(temp);
		return result;
	}
	
	@:variant('1')
	@:variant('1111111111')
	@:variant('1111111111111111111111111111111111111111')
	public function lastIndexOfHead(v:String):Assertions {
		var s = v + LONG_STRING;
		var temp = 0;
		var result = benchmark(100000, temp = s.lastIndexOf(v));
		ensure(temp);
		return result;
	}
	
	@:variant('1')
	@:variant('1111111111')
	@:variant('1111111111111111111111111111111111111111')
	public function lastIndexOfTail(v:String):Assertions {
		var s = LONG_STRING + v;
		var temp = 0;
		var result = benchmark(#if hl 100000 #else 1000000 #end, temp = s.lastIndexOf(v));
		ensure(temp);
		return result;
	}
	
	@:variant(0, 1000)
	@:variant(9000, 1000)
	public function substr(start:Int, length:Int) {
		var s = LONG_STRING;
		var temp = null;
		var result = benchmark(100000, temp = s.substr(start, length));
		ensure(temp);
		return result;
	}
	
	@:variant(0, 1000)
	@:variant(9000, 10000)
	public function substring(start:Int, end:Int) {
		var s = LONG_STRING;
		var temp = null;
		var result = benchmark(100000, temp = s.substring(start, end));
		ensure(temp);
		return result;
	}
	
	@:keep
	function ensure<T>(v:T) {}
}