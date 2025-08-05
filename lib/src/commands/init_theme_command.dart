import 'package:args/args.dart';
import '../services/init_theme_service.dart';
import 'base_command.dart';

class InitThemeCommand extends BaseCommand {
  @override
  final String name = 'init:theme';

  @override
  final String description =
      'Initializes a complete theme setup (light/dark) with Hydrated Cubit.';

  @override
  final ArgParser parser = ArgParser();

  final InitThemeService _initThemeService;

  InitThemeCommand(this._initThemeService);

  @override
  Future<void> run(ArgResults? argResults) async {
    await _initThemeService.handle();
  }
}
