/// Runtime configuration via --dart-define / --dart-define-from-file.
/// Real values live in gitignored env.*.json (template: env.example.json).
/// No credential is ever hardcoded here.
enum BackendMode { demo, supabase }

abstract final class Env {
  static const _backendMode =
      String.fromEnvironment('BACKEND_MODE', defaultValue: 'demo');
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static BackendMode get backendMode => switch (_backendMode) {
        'supabase' => BackendMode.supabase,
        _ => BackendMode.demo,
      };

  static bool get isDemo => backendMode == BackendMode.demo;
}
