// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

/// 웹용 iframe 등록
void registerIframe(String viewId, String url) {
  // ignore: undefined_prefixed_name
  ui_web.platformViewRegistry.registerViewFactory(
    viewId,
    (int id) => html.IFrameElement()
      ..src = url
      ..style.border = 'none'
      ..style.height = '100%'
      ..style.width = '100%',
  );
}
