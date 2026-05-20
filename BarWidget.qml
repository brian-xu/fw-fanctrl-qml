import QtQuick
import Quickshell
import qs.Commons
import qs.Services.UI
import qs.Widgets

NIconButton {
  id: root

  property var pluginApi: null
  property ShellScreen screen
  property string widgetId: ""
  property string section: ""
  property int sectionWidgetIndex: -1
  property int sectionWidgetsCount: 0

  property string currentStrategy: ""

  icon: getIcon()
  tooltipText: getTooltipText()
  tooltipDirection: BarService.getTooltipDirection(screen?.name)
  baseSize: Style.getCapsuleHeightForScreen(screen?.name)
  applyUiScale: false
  customRadius: Style.radiusL

  colorBg: Style.capsuleColor
  colorFg: getColor()
  colorBgHover: Color.mHover
  colorFgHover: Color.mOnHover
  colorBorder: "transparent"
  colorBorderHover: "transparent"

  border.color: Style.capsuleBorderColor
  border.width: Style.capsuleBorderWidth

  Component.onCompleted: {
    if (pluginApi?.mainInstance) {
      root.currentStrategy = pluginApi.mainInstance.currentStrategy;
      pluginApi.mainInstance.pollStatus();
    }
  }

  onPluginApiChanged: {
    if (pluginApi?.mainInstance) {
      root.currentStrategy = pluginApi.mainInstance.currentStrategy;
      pluginApi.mainInstance.pollStatus();
    }
  }

  Connections {
    target: pluginApi?.mainInstance ?? null

    function onCurrentStrategyChanged() {
      if (target) {
        root.currentStrategy = target.currentStrategy;
      }
    }
  }

  function setStrategy(strategy) {
    Logger.i("fw-fanctrl", `setStrategy called with value ${strategy}, mainInstance: ${pluginApi?.mainInstance}`);
    if (pluginApi?.mainInstance) {
      pluginApi.mainInstance.setStrategy(strategy);
    }
  }

  function getTooltipText() {
    return currentStrategy;
  }

  function getIcon() {
    switch (currentStrategy) {
    case "laziest":
      return "wind-off";
    case "lazy":
      return "windmill";
    case "medium":
      return "wind";
    case "agile":
      return "wind-electricity";
    case "very-agile":
      return "building-wind-turbine";
    case "deaf":
      return "tornado";
    case "aeolus":
      return "storm";
    }
  }

  function getColor() {
    return Color.mOnSurface;
  }

  onClicked: {
    var list = pluginApi?.mainInstance?.strategyList ?? [];
    if (list.length === 0)
      return;
    var idx = list.indexOf(currentStrategy);
    var next = list[(idx + 1) % list.length];
    Logger.i("fw-fanctrl", `Clicked, current: ${currentStrategy}, next: ${next}`);
    root.currentStrategy = next;
    setStrategy(next);
  }
}
