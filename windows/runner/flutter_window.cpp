#include "flutter_window.h"

#include <optional>

#include "flutter/generated_plugin_registrant.h"
#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>
#include <memory>
#include <variant>

FlutterWindow::FlutterWindow(const flutter::DartProject& project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  RECT frame = GetClientArea();
  int width = frame.right - frame.left;
  int height = frame.bottom - frame.top;

  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      width, height, project_);
  // Ensure that basic setup of the controller was successful.
  if (!flutter_controller_->engine() ||
      !flutter_controller_->view()) {
    return false;
  }
  SetChildContent(flutter_controller_->view()->GetNativeWindow());

  flutter_controller_->engine()->SetNextFrameCallback([&]() {
    this->Show();
  });

  // Flutter can complete the first frame before the "show window" callback is
  // registered. The following call ensures a frame is pending to ensure the
  // window is shown. It is a no-op if the frame is already complete.
  flutter_controller_->ForceRedraw();

  // Setup MethodChannel for always-on-top
  auto messenger = flutter_controller_->engine()->messenger();
  auto channel = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
      messenger, "multi_calculator/always_on_top",
      &flutter::StandardMethodCodec::GetInstance());
  channel->SetMethodCallHandler(
      [this](const auto& call, auto result) {
        if (call.method_name() == "setAlwaysOnTop") {
          const auto* args = std::get_if<flutter::EncodableMap>(call.arguments());
          if (args) {
            auto it = args->find(flutter::EncodableValue("value"));
            if (it != args->end() && std::holds_alternative<bool>(it->second)) {
              bool value = std::get<bool>(it->second);
              SetAlwaysOnTop(value);
              result->Success();
              return;
            }
          }
          result->Error("bad_args", "Missing or invalid arguments");
        } else {
          result->NotImplemented();
        }
      });
  // Keep channel alive
  static auto* channel_ptr = channel.release();

  return true;
}

void FlutterWindow::OnDestroy() {
  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {
  // Give Flutter, including plugins, an opportunity to handle window messages.
  if (flutter_controller_) {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result) {
      return *result;
    }
  }

  switch (message) {
    case WM_FONTCHANGE:
      flutter_controller_->engine()->ReloadSystemFonts();
      break;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}
