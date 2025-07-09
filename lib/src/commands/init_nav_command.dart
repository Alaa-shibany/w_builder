import 'package:args/args.dart';
import '../services/init_nav_service.dart';
import 'base_command.dart';

class InitNavCommand extends BaseCommand {
  @override
  final String name = 'init:nav';
  @override
  final String description =
      'Initializes project with go_router for navigation.';

  @override
  final ArgParser parser = ArgParser();

  final InitNavService _initNavService;

  InitNavCommand(this._initNavService);

  @override
  Future<void> run(ArgResults? argResults) async {
    await _initNavService.handle();
  }
}
