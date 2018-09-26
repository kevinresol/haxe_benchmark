package;

import benchmark.*;
import tink.unit.*;
import tink.testrunner.*;

class Main {
	static function main() {
		Runner.run(TestBatch.make([
			new ArrayBenchmark(),
		])).handle(Runner.exit);
	}
}