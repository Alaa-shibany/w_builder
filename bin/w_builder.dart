import 'dart:io';
import 'package:w_builder/src/commands/base_command.dart';
import 'package:w_builder/src/di_container.dart';
import 'package:args/args.dart';

void main(List<String> arguments) async {
  setupDependencies();
  final parser = ArgParser();
  final commands = <String, BaseCommand>{
    'init': sl.get<BaseCommand>(instanceName: 'init'),
    'create': sl.get<BaseCommand>(instanceName: 'create'),
    'init:nav': sl.get<BaseCommand>(instanceName: 'init:nav'),
  };
  commands.forEach((name, command) {
    parser.addCommand(name, command.parser);
  });
  try {
    final argResults = parser.parse(arguments);
    final commandName = argResults.command?.name;

    if (commandName == null) {
      print('Please specify a command: ${commands.keys.join(', ')}');
      print('Usage:\n${parser.usage}');
      exit(1);
    }

    final command = commands[commandName];
    if (command != null) {
      await command.run(argResults.command);
    }
  } on FormatException catch (e) {
    print('Error: ${e.message}');
    print('Usage:\n${parser.usage}');
    exit(1);
  } catch (e) {
    print('An unexpected error occurred: $e');
    exit(1);
  }
}
