import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'arguments.dart';
import 'exceptions.dart';

class CommandRunner {
  CommandRunner({this.onError});

  final Map<String, Command> _commands = <String, Command>{};

  UnmodifiableSetView<Command> get commands =>
      UnmodifiableSetView<Command>(<Command>{..._commands.values});

  FutureOr<void> Function(Object)? onError;

  Future<void> run(List<String> input) async {
    try {
      final ArgResults results = parse(input);
      if (results.command != null) {
        Object? output = await results.command!.run(results);
        if (output != null) {
          print(output.toString());
        }
      }
    } catch (e) {
      if (onError != null) {
        onError!(e);
      } else {
        rethrow;
      }
    }
  }

  void addCommand(Command command) {
    _commands[command.name] = command;
    command.runner = this;
  }

  ArgResults parse(List<String> input) {
    ArgResults results = ArgResults();
    if (input.isEmpty) return results;

    // Проверка: первое слово — команда?
    if (_commands.containsKey(input.first)) {
      results.command = _commands[input.first];
      input = input.sublist(1);
    } else {
      throw ArgumentException(
        'The first word of input must be a command.',
        null,
        input.first,
      );
    }

    // Проверка: только одна команда
    if (input.isNotEmpty && _commands.containsKey(input.first)) {
      throw ArgumentException(
        'Input can only contain one command. Got ${input.first} and ${results.command!.name}',
        null,
        input.first,
      );
    }

    // Парсинг опций
    Map<Option, Object?> inputOptions = {};
    int i = 0;

    while (i < input.length) {
      final current = input[i];

      if (current.startsWith('-')) {
        // Это опция (флаг или ключ-значение)
        final optionName = _removeDash(current);

        // Поиск опции среди доступных у команды
        final option = results.command!.options.firstWhere(
              (opt) => opt.name == optionName || opt.abbr == optionName,
          orElse: () {
            throw ArgumentException(
              'Unknown option $current',
              results.command!.name,
              current,
            );
          },
        );

        if (option.type == OptionType.flag) {
          // Флаг: просто устанавливаем true
          inputOptions[option] = true;
          i++;
          continue;
        }

        if (option.type == OptionType.option) {
          // Опция с аргументом
          if (i + 1 >= input.length) {
            throw ArgumentException(
              'Option ${option.name} requires an argument',
              results.command!.name,
              option.name,
            );
          }

          final next = input[i + 1];
          if (next.startsWith('-')) {
            throw ArgumentException(
              'Option ${option.name} requires an argument, but got another option $next',
              results.command!.name,
              option.name,
            );
          }

          inputOptions[option] = next;
          i += 2;  // Пропускаем и опцию, и её значение
          continue;
        }
      } else {
        // Позиционный аргумент (не опция)
        if (results.commandArg != null && results.commandArg!.isNotEmpty) {
          throw ArgumentException(
            'Commands can only have up to one argument.',
            results.command!.name,
            current,
          );
        }
        results.commandArg = current;
        i++;
      }
    }

    results.options = inputOptions;
    return results;
  }

  // Вспомогательный метод: убирает -- или - в начале
  String _removeDash(String input) {
    if (input.startsWith('--')) {
      return input.substring(2);
    }
    if (input.startsWith('-')) {
      return input.substring(1);
    }
    return input;
  }

  String get usage {
    final exeFile = Platform.script.path.split('/').last;
    return 'Usage: dart bin/$exeFile <command> [commandArg?] [...options?]';
  }
}