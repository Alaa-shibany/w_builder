import 'package:args/args.dart';
import '../services/create_screen_service.dart';
import 'base_command.dart';

class CreateScreenCommand extends BaseCommand {
  @override
  final String name = 'create:screen';

  @override
  final String description =
      'Creates a new feature screen with a clean architecture structure.';

  @override
  final ArgParser parser = ArgParser()
    ..addOption(
      'name',
      abbr: 'n',
      help: 'The name of the screen to create.',
      mandatory: true,
    );

  final CreateScreenService _createScreenService;

  CreateScreenCommand(this._createScreenService);

  @override
  Future<void> run(ArgResults? argResults) async {
    final screenName = argResults!['name'] as String;
    await _createScreenService.handle(screenName);
  }
}
