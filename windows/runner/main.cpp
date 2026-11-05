#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>
#include <cstdlib>
#include <string>
#include <vector>
#include "flutter_window.h"
#include "utils.h"
#include <shobjidl.h>

namespace {

constexpr wchar_t kPrimaryInstanceMutex[] =
    L"Local\\PureLive_Primary_Instance_v1";

// Native title shown by the taskbar, Alt+Tab and Task Manager (the Chinese app name);
// the in-app title bar is drawn by Flutter. Escaped to keep the source ASCII.
constexpr wchar_t kWindowTitle[] = L"\u7EAF\u7CB9\u76F4\u64AD";

void BringPrimaryWindowToFront() {
  const HWND window =
      ::FindWindowW(L"FLUTTER_RUNNER_WIN32_WINDOW", kWindowTitle);
  if (window == nullptr) {
    return;
  }
  if (::IsIconic(window)) {
    ::ShowWindowAsync(window, SW_RESTORE);
  } else {
    ::ShowWindowAsync(window, SW_SHOW);
  }
  ::SetWindowPos(window, HWND_TOP, 0, 0, 0, 0,
                 SWP_NOMOVE | SWP_NOSIZE | SWP_SHOWWINDOW);
  ::SetForegroundWindow(window);
}

}  // namespace

// media_kit hands every open() a temp playlist file. When creating it is
// denied (security software blocking %TEMP% writes, tightened ACLs), open()
// throws before libmpv is ever asked and the player reports the source as
// unplayable. Keep that file in a folder this app owns: the data directory
// next to the executable, which the user installed and can write.
void UsePrivateTempDirectory() {
  wchar_t module_path[MAX_PATH];
  const DWORD length = ::GetModuleFileNameW(nullptr, module_path, MAX_PATH);
  if (length == 0 || length >= MAX_PATH) {
    return;
  }
  std::wstring directory(module_path, length);
  const std::wstring::size_type slash = directory.find_last_of(L"\\/");
  if (slash == std::wstring::npos) {
    return;
  }
  directory.erase(slash + 1);
  std::wstring root = directory + L"AppData";
  std::wstring temp = root + L"\\TEMP";
  ::CreateDirectoryW(root.c_str(), nullptr);
  ::CreateDirectoryW(temp.c_str(), nullptr);
  const DWORD attributes = ::GetFileAttributesW(temp.c_str());
  if (attributes == INVALID_FILE_ATTRIBUTES ||
      (attributes & FILE_ATTRIBUTE_DIRECTORY) == 0) {
    return;
  }
  ::SetEnvironmentVariableW(L"TEMP", temp.c_str());
  ::SetEnvironmentVariableW(L"TMP", temp.c_str());
}

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  UsePrivateTempDirectory();

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();

  // Reject a duplicate primary process before allocating a Flutter engine,
  // GPU surface, Dart isolate or plugins. The Dart single-instance channel is
  // retained for argument forwarding; this early fence prevents the brief
  // decoder/UI stall observed when users launch the installed shortcut twice.
  HANDLE primary_instance_mutex = nullptr;
  // Business arguments (shared URLs, protocol links and --instance=...) must
  // still reach the Dart single-instance channel for forwarding or intentional
  // multi-window creation. The common duplicate-shortcut case has no arguments
  // and can be rejected here without starting a second Flutter engine.
  if (command_line_arguments.empty()) {
    primary_instance_mutex =
        ::CreateMutexW(nullptr, TRUE, kPrimaryInstanceMutex);
    if (primary_instance_mutex != nullptr &&
        ::GetLastError() == ERROR_ALREADY_EXISTS) {
      BringPrimaryWindowToFront();
      ::CloseHandle(primary_instance_mutex);
      return EXIT_SUCCESS;
    }
  }

  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a debugger.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  // Initialize COM, so that it is available for use in the library and/or
  // plugins.
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  {
    flutter::DartProject project(L"data");

    project.set_dart_entrypoint_arguments(std::move(command_line_arguments));
    SetCurrentProcessExplicitAppUserModelID(L"com.mystyle.purelive");
    FlutterWindow window(project);
    Win32Window::Point origin(10, 10);
    Win32Window::Size size(1280, 720);
    if (!window.Create(kWindowTitle, origin, size)) {
      return EXIT_FAILURE;
    }
    window.SetQuitOnClose(true);

    ::MSG msg;
    while (::GetMessage(&msg, nullptr, 0, 0)) {
      ::TranslateMessage(&msg);
      ::DispatchMessage(&msg);
    }
  }

  ::CoUninitialize();
  // Flutter and plugin objects are already destroyed above. Bypass process
  // detach hooks in optional DLLs that can otherwise keep the process alive.
  ::TerminateProcess(::GetCurrentProcess(), EXIT_SUCCESS);
  return EXIT_SUCCESS;
}
