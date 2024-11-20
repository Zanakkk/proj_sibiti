//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <audioplayers_windows/audioplayers_windows_plugin.h>
#include <screen_retriever_windows/screen_retriever_windows_plugin_c_api.h>
#include <webf/webf_plugin.h>
#include <webview_cef/webview_cef_plugin_c_api.h>
#include <webview_universal/webview_universal_plugin.h>
#include <webview_windows/webview_windows_plugin.h>
#include <window_manager/window_manager_plugin.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  AudioplayersWindowsPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("AudioplayersWindowsPlugin"));
  ScreenRetrieverWindowsPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("ScreenRetrieverWindowsPluginCApi"));
  WebfPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("WebfPlugin"));
  WebviewCefPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("WebviewCefPluginCApi"));
  WebviewUniversalPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("WebviewUniversalPlugin"));
  WebviewWindowsPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("WebviewWindowsPlugin"));
  WindowManagerPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("WindowManagerPlugin"));
}
