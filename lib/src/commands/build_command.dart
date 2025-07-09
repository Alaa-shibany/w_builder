import 'package:args/args.dart';
import '../services/build_service.dart';
import 'base_command.dart';

class BuildCommand extends BaseCommand {
  @override
  final String name = 'build';
  @override
  final String description =
      'Sets up the project with core files and dependencies.';

  @override
  final ArgParser parser = ArgParser();

  final BuildService _buildService;

  BuildCommand(this._buildService);

  @override
  Future<void> run(ArgResults? argResults) async {
    await _buildService.handleBuildCommand('.');
  }
}
