import 'package:command_runner/command_runner.dart';
import 'package:test/test.dart';

void main() {
  group('A group of tests', () {
    final awesome = CommandRunner();

    setUp(() {
      // Additional setup goes here.
    });

    test('First Test', () {
      expect(awesome, isTrue);
    });
  });
}
