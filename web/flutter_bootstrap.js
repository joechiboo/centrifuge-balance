{{flutter_js}}
{{flutter_build_config}}

// Serve CanvasKit from the app itself instead of Google's CDN so the web
// build works offline and behind restrictive networks.
_flutter.loader.load({
  config: { canvasKitBaseUrl: "canvaskit/" },
});
