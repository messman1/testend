import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';

void main() async {
  // Flutter 바인딩 초기화
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 환경 변수 로드
    await dotenv.load(fileName: '.env');

    // Supabase 초기화
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL'] ?? '',
      anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );

    // Hive 초기화 (로컬 데이터베이스)
    await Hive.initFlutter();

    // 앱 실행
    runApp(
      const ProviderScope(
        child: MyApp(),
      ),
    );
  } catch (e) {
    // 초기화 실패 시 에러 표시
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 80,
                  color: Colors.red,
                ),
                const SizedBox(height: 24),
                const Text(
                  '앱 초기화 실패',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    e.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
