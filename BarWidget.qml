import QtQuick
import Quickshell
import Quickshell.Io
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

  // Helper: read setting from pluginSettings, falling back to manifest defaults
  function getSetting(key, fallback) {
    var ps = pluginApi?.pluginSettings
    if (ps && ps[key] !== undefined)
      return ps[key]
    var defs = pluginApi?.manifest?.metadata?.defaultSettings
    if (defs && defs[key] !== undefined)
      return defs[key]
    return fallback
  }

  // These are bound to getSetting() so they react to pluginApi becoming available.
  // We use Qt.binding in Component.onCompleted so they track changes properly.
  property string displayMode: "text"
  property string middleClickAction: "previous"
  property int pollIntervalMs: 750

  property int currentIndex: -1
  property string currentName: "Unknown"
  property var layouts: []
  property var contextMenuModel: []

  // Stolen from a native-looking Noctalia plugin:
  // this is the important bit for correct bar height.
  baseSize: Style.getCapsuleHeightForScreen(screen?.name)
  applyUiScale: false

  // We draw our own text/flag label instead of a normal icon.
  icon: ""
  tooltipText: currentName
  tooltipDirection: BarService.getTooltipDirection(screen?.name)
  customRadius: Style.radiusL

  colorBg: Style.capsuleColor
  colorFg: Color.mOnSurface
  colorBgHover: Color.mHover
  colorFgHover: Color.mOnHover
  colorBorder: "transparent"
  colorBorderHover: "transparent"

  border.color: Style.capsuleBorderColor
  border.width: Style.capsuleBorderWidth

  function saveSettings() {
    Logger.d("NiriLayoutIndicator", "BarWidget.saveSettings: displayMode=" + root.displayMode + " middleClickAction=" + root.middleClickAction + " pollIntervalMs=" + root.pollIntervalMs)
    if (!pluginApi || !pluginApi.pluginSettings) {
      Logger.w("NiriLayoutIndicator", "BarWidget.saveSettings: pluginApi or pluginSettings is null")
      return
    }

    pluginApi.pluginSettings.displayMode = root.displayMode
    pluginApi.pluginSettings.middleClickAction = root.middleClickAction
    pluginApi.pluginSettings.pollIntervalMs = root.pollIntervalMs
    pluginApi.saveSettings()
    Logger.d("NiriLayoutIndicator", "BarWidget.saveSettings: saved successfully")
  }

  // Called by the shell when settings change (e.g. from the settings page).
  // Re-read settings from pluginApi.pluginSettings and update local state.
  function onSettingsChanged() {
    Logger.d("NiriLayoutIndicator", "BarWidget.onSettingsChanged: before displayMode=" + root.displayMode + " middleClickAction=" + root.middleClickAction)
    root.displayMode = root.getSetting("displayMode", "text")
    root.middleClickAction = root.getSetting("middleClickAction", "previous")
    root.pollIntervalMs = root.getSetting("pollIntervalMs", 750)
    Logger.d("NiriLayoutIndicator", "BarWidget.onSettingsChanged: after displayMode=" + root.displayMode + " middleClickAction=" + root.middleClickAction)
    root.rebuildContextMenuModel()
  }

  function codeForLayout(name) {
    var n = (name || "").toLowerCase()

    if (n.indexOf("russian") >= 0) return "ru"
    if (n.indexOf("english") >= 0) return "en"
    if (n.indexOf("french") >= 0) return "fr"
    if (n.indexOf("german") >= 0) return "de"
    if (n.indexOf("spanish") >= 0) return "es"
    if (n.indexOf("italian") >= 0) return "it"
    if (n.indexOf("portuguese") >= 0) return "pt"
    if (n.indexOf("polish") >= 0) return "pl"
    if (n.indexOf("ukrainian") >= 0) return "uk"
    if (n.indexOf("belarusian") >= 0) return "be"
    if (n.indexOf("czech") >= 0) return "cs"
    if (n.indexOf("slovak") >= 0) return "sk"
    if (n.indexOf("turkish") >= 0) return "tr"
    if (n.indexOf("greek") >= 0) return "el"
    if (n.indexOf("hebrew") >= 0) return "he"
    if (n.indexOf("arabic") >= 0) return "ar"
    if (n.indexOf("japanese") >= 0) return "ja"
    if (n.indexOf("korean") >= 0) return "ko"
    if (n.indexOf("chinese") >= 0) return "zh"

    // Fallback: extract first word and take first 2 characters
    var first = n.replace(/\(.*/, "").trim().split(/\s+/)[0]
    return first.substring(0, 2)
  }

  function flagForLayout(name) {
    var n = (name || "").toLowerCase()

    if (n.indexOf("russian") >= 0) return "🇷🇺"
    if (n.indexOf("english") >= 0 && (n.indexOf("uk") >= 0 || n.indexOf("british") >= 0)) return "🇬🇧"
    if (n.indexOf("english") >= 0) return "🇺🇸"
    if (n.indexOf("french") >= 0) return "🇫🇷"
    if (n.indexOf("german") >= 0) return "🇩🇪"
    if (n.indexOf("spanish") >= 0) return "🇪🇸"
    if (n.indexOf("italian") >= 0) return "🇮🇹"
    if (n.indexOf("portuguese") >= 0) return "🇵🇹"
    if (n.indexOf("polish") >= 0) return "🇵🇱"
    if (n.indexOf("ukrainian") >= 0) return "🇺🇦"
    if (n.indexOf("belarusian") >= 0) return "🇧🇾"
    if (n.indexOf("czech") >= 0) return "🇨🇿"
    if (n.indexOf("slovak") >= 0) return "🇸🇰"
    if (n.indexOf("turkish") >= 0) return "🇹🇷"
    if (n.indexOf("greek") >= 0) return "🇬🇷"
    if (n.indexOf("hebrew") >= 0) return "🇮🇱"
    if (n.indexOf("japanese") >= 0) return "🇯🇵"
    if (n.indexOf("korean") >= 0) return "🇰🇷"
    if (n.indexOf("chinese") >= 0) return "🇨🇳"

    return "⌨"
  }

  function indicatorText() {
    if (root.currentIndex < 0)
      return "??"

    return root.displayMode === "flag"
      ? flagForLayout(root.currentName)
      : codeForLayout(root.currentName)
  }

  function rebuildContextMenuModel() {
    var model = []

    for (var i = 0; i < root.layouts.length; i++) {
      var layout = root.layouts[i]
      model.push({
        "label": (layout.active ? "● " : "○ ") + codeForLayout(layout.name) + "  " + layout.name,
        "action": "layout:" + layout.index,
        "icon": "keyboard"
      })
    }

    model.push({
      "label": root.displayMode === "text"
          ? pluginApi?.tr("menu.display.text_to_flag")
          : pluginApi?.tr("menu.display.flag_to_text"),
      "action": "toggle-display",
      "icon": "visibility"
    })

    model.push({
      "label": root.middleClickAction === "previous"
          ? pluginApi?.tr("menu.middle.previous")
          : pluginApi?.tr("menu.middle.toggle_display"),
      "action": "toggle-middle",
      "icon": "mouse"
    })

    model.push({
      "label": pluginApi?.tr("menu.plugin_settings"),
      "action": "plugin-settings",
      "icon": "settings"
    })

    root.contextMenuModel = model
  }

  function parseLayouts(output) {
    var parsed = []
    var activeIndex = -1
    var activeName = "Unknown"

    var lines = (output || "").split("\n")
    for (var i = 0; i < lines.length; i++) {
      var line = lines[i]
      var match = line.match(/^\s*(\*)?\s*(\d+)\s+(.+?)\s*$/)
      if (!match)
        continue

      var item = {
        active: match[1] === "*",
        index: parseInt(match[2]),
        name: match[3]
      }

      parsed.push(item)

      if (item.active) {
        activeIndex = item.index
        activeName = item.name
      }
    }

    root.layouts = parsed

    if (activeIndex >= 0) {
      root.currentIndex = activeIndex
      root.currentName = activeName
    }

    root.rebuildContextMenuModel()
  }

  function refresh() {
    if (!readLayoutsProc.running)
      readLayoutsProc.exec(["niri", "msg", "keyboard-layouts"])
  }

  function switchLayout(target) {
    if (target === "next" || target === "prev") {
      if (root.layouts.length === 0) {
        Logger.w("NiriLayoutIndicator", "switchLayout: no layouts available")
        return
      }
      for (var i = 0; i < root.layouts.length; i++) {
        if (root.layouts[i].active) {
          var dir = target === "next" ? 1 : -1
          var pos = (i + dir + root.layouts.length) % root.layouts.length
          target = root.layouts[pos].index
          break
        }
      }
    }
    switchProc.exec(["niri", "msg", "action", "switch-layout", target.toString()])
    refreshDelay.restart()
  }

  function toggleDisplayMode() {
    Logger.d("NiriLayoutIndicator", "BarWidget.toggleDisplayMode: " + root.displayMode + " -> " + (root.displayMode === "text" ? "flag" : "text"))
    root.displayMode = root.displayMode === "text" ? "flag" : "text"
    root.saveSettings()
    root.rebuildContextMenuModel()
  }

  NText {
    id: label

    anchors.centerIn: parent

    text: root.indicatorText()
    color: root.hovered ? Color.mOnHover : Color.mOnSurface
    pointSize: Style.fontSizeM
    font.weight: Font.Bold
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
  }

  MouseArea {
    // NIconButton already handles left and right click.
    // This small overlay only catches the middle button.
    anchors.fill: parent
    acceptedButtons: Qt.MiddleButton
    hoverEnabled: false
    preventStealing: true

    onPressed: function(mouse) {
      if (mouse.button === Qt.MiddleButton) {
        if (root.middleClickAction === "toggle-mode")
          root.toggleDisplayMode()
        else
          root.switchLayout("prev")

        mouse.accepted = true
      }
    }
  }

  NPopupContextMenu {
    id: contextMenu

    model: root.contextMenuModel

    onTriggered: action => {
      contextMenu.close()
      PanelService.closeContextMenu(screen)

      if (action.indexOf("layout:") === 0) {
        root.switchLayout(action.substring("layout:".length))
      } else if (action === "toggle-display") {
        root.toggleDisplayMode()
      } else if (action === "toggle-middle") {
        root.middleClickAction = root.middleClickAction === "previous" ? "toggle-mode" : "previous"
        root.saveSettings()
        root.rebuildContextMenuModel()
      } else if (action === "plugin-settings") {
        if (pluginApi)
          BarService.openPluginSettings(screen, pluginApi.manifest)
      }
    }
  }

  onClicked: {
    root.switchLayout("next")
  }

  onRightClicked: {
    root.refresh()
    root.rebuildContextMenuModel()
    PanelService.showContextMenu(contextMenu, root, screen)
  }

  Process {
    id: readLayoutsProc

    stdout: StdioCollector {
      onStreamFinished: root.parseLayouts(this.text)
    }

    stderr: StdioCollector {
      onStreamFinished: {
        if (this.text.length > 0)
          Logger.w("NiriLayoutIndicator", this.text)
      }
    }
  }

  Process {
    id: switchProc

    stderr: StdioCollector {
      onStreamFinished: {
        if (this.text.length > 0)
          Logger.w("NiriLayoutIndicator", this.text)
      }
    }
  }

  Timer {
    id: pollTimer

    interval: root.pollIntervalMs
    running: true
    repeat: true
    onTriggered: root.refresh()
  }

  Timer {
    id: refreshDelay

    interval: 120
    repeat: false
    onTriggered: root.refresh()
  }

  Component.onCompleted: {
    Logger.d("NiriLayoutIndicator", "BarWidget.onCompleted: pluginApi=" + (pluginApi ? "set" : "null") + " pluginSettings=" + JSON.stringify(pluginApi?.pluginSettings))

    root.displayMode = root.getSetting("displayMode", "text")
    root.middleClickAction = root.getSetting("middleClickAction", "previous")
    root.pollIntervalMs = root.getSetting("pollIntervalMs", 750)

    Logger.d("NiriLayoutIndicator", "BarWidget.onCompleted: displayMode=" + root.displayMode + " middleClickAction=" + root.middleClickAction + " pollIntervalMs=" + root.pollIntervalMs)

    root.refresh()
    root.rebuildContextMenuModel()
    Logger.i("NiriLayoutIndicator", "Loaded")
  }
}
