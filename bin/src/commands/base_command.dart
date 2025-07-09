import 'package:args/args.dart';

abstract class BaseCommand {
  String get name;

  String get description;

  ArgParser get parser;

  Future<void> run(ArgResults? argResults);
}
