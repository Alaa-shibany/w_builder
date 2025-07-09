import 'package:args/args.dart';
import '../services/create_service.dart';
import 'base_command.dart';

class CreateCommand extends BaseCommand {
  @override
  final String name = 'create';
  @override
  final String description =
      'Creates a new feature based on a JSON config file.';

  @override
  final ArgParser parser = ArgParser()
    ..addOption(
      'file',
      abbr: 'f',
      help: 'Path to the JSON configuration file.',
      mandatory: true,
    );

  final CreateService _createService;

  CreateCommand(this._createService);

  @override
  Future<void> run(ArgResults? argResults) async {
    final filePath = argResults!['file'] as String;
    await _createService.handleCreateCommand(filePath);
  }
}
