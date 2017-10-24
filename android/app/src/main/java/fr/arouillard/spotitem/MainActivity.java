package fr.arouillard.spotitem;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.view.WindowManager.LayoutParams;

import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.view.FlutterView;
import io.flutter.plugin.common.MethodChannel;

import java.util.HashMap;
import android.util.Log;

public class MainActivity extends FlutterActivity {
  private static final String CHANNEL = "channel:fr.arouillard.spotitem/deeplink";
  private MethodChannel deepLinkChannel;

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);
    deepLinkChannel = new MethodChannel(getFlutterView(), CHANNEL);
  }

  @Override
  public FlutterView createFlutterView(Context context) {
    final FlutterView view = new FlutterView(this);
    view.setLayoutParams(new LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT));
    setContentView(view);
    final String route = getRouteFromIntent();
    if (route != null) {
      view.setInitialRoute(route);
    }
    return view;
  }

  @Override
  protected void onResume() {
    super.onResume();
    final String route = getRouteFromIntent();
    HashMap loc = new HashMap();
    loc.put("path", route);
    deepLinkChannel.invokeMethod("linkReceived", loc);
  }

  private String getRouteFromIntent() {
    final Intent intent = getIntent();
    if (Intent.ACTION_VIEW.equals(intent.getAction()) && intent.getData() != null) {
      return intent.getData().getPath();
    }
    return null;
  }
}