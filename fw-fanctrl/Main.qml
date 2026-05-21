import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons

Item {
  id: root

  property var pluginApi: null

  property string currentStrategy: ""
  property var strategyList: ["laziest", "lazy", "medium", "agile", "very-agile", "deaf", "aeolus"]

  Process {
    id: statusProcess
    command: ["fw-fanctrl", "--output-format", "JSON", "print", "all"]
    running: false

    stdout: StdioCollector {
      id: stdoutCollector
    }

    onExited: function(exitCode, exitStatus) {
      if (exitCode === 0) {
        try {
          var result = JSON.parse(stdoutCollector.text.trim());
          if (result && result.strategy) {
            root.currentStrategy = result.strategy;
          } else {
            Logger.e("fw-fanctrl", "Unexpected JSON structure");
          }
        } catch (e) {
          Logger.e("fw-fanctrl", "Failed to parse JSON: " + e);
        }
      } else {
        Logger.e("fw-fanctrl", "Failed to get fan status");
      }
    }
  }

  Component.onCompleted: {
    statusProcess.running = true;
  }

  function pollStatus() {
    if (statusProcess.running)
      return;
    statusProcess.running = true;
  }

  function setStrategy(strategy) {
    Quickshell.execDetached(["fw-fanctrl", "use", strategy]);
  }

  function resetStrategy() {
    Quickshell.execDetached(["fw-fanctrl", "reset"]);
  }
}
