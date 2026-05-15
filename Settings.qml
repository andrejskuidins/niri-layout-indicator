import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Widgets

ColumnLayout {
  id: root

  property var pluginApi: null

  // Local state — follows docs pattern exactly
  property string editDisplayMode:
    pluginApi?.pluginSettings?.displayMode ||
    pluginApi?.manifest?.metadata?.defaultSettings?.displayMode ||
    "text"

  property string editMiddleClickAction:
    pluginApi?.pluginSettings?.middleClickAction ||
    pluginApi?.manifest?.metadata?.defaultSettings?.middleClickAction ||
    "previous"

  property int editPollIntervalMs:
    pluginApi?.pluginSettings?.pollIntervalMs ||
    pluginApi?.manifest?.metadata?.defaultSettings?.pollIntervalMs ||
    750

  spacing: Style.marginM

  // Required: Save function called by the settings dialog
  function saveSettings() {
    Logger.i("NiriLayoutIndicator", "saveSettings called: " + root.editDisplayMode)
    if (!pluginApi) {
      Logger.w("NiriLayoutIndicator", "saveSettings: pluginApi is null")
      return
    }
    pluginApi.pluginSettings.displayMode = root.editDisplayMode
    pluginApi.pluginSettings.middleClickAction = root.editMiddleClickAction
    pluginApi.pluginSettings.pollIntervalMs = root.editPollIntervalMs
    pluginApi.saveSettings()

    var mi = pluginApi.mainInstance
    if (mi && typeof mi.onSettingsChanged === "function") {
      mi.onSettingsChanged()
    }
  }

  // Header
  NText {
    Layout.fillWidth: true
    text: pluginApi?.tr("settings.title")
    pointSize: Style.fontSizeXXL
    font.weight: Style.fontWeightBold
    color: Color.mOnSurface
  }

  NText {
    Layout.fillWidth: true
    text: pluginApi?.tr("settings.description")
    color: Color.mOnSurfaceVariant
    pointSize: Style.fontSizeM
    wrapMode: Text.WordWrap
  }

  // Display Mode
  NBox {
    Layout.fillWidth: true
    Layout.preferredHeight: displayContent.implicitHeight + Style.marginM * 2
    color: Color.mSurfaceVariant

    ColumnLayout {
      id: displayContent
      anchors.fill: parent
      anchors.margins: Style.marginM
      spacing: Style.marginS

      NText {
        Layout.fillWidth: true
        text: pluginApi?.tr("settings.display.title")
        pointSize: Style.fontSizeL
        font.weight: Style.fontWeightBold
        color: Color.mOnSurface
      }

      NText {
        Layout.fillWidth: true
        text: pluginApi?.tr("settings.display.description")
        color: Color.mOnSurfaceVariant
        pointSize: Style.fontSizeM
        wrapMode: Text.WordWrap
      }

      RowLayout {
        spacing: Style.marginM

        NRadioButton {
          id: displayTextRadio
          text: pluginApi?.tr("settings.display.text")
          checked: root.editDisplayMode === "text"
          onToggled: function(checked) {
            if (checked) {
              root.editDisplayMode = "text"
            }
          }
        }

        NRadioButton {
          id: displayFlagRadio
          text: pluginApi?.tr("settings.display.flag")
          checked: root.editDisplayMode === "flag"
          onToggled: function(checked) {
            if (checked) {
              root.editDisplayMode = "flag"
            }
          }
        }
      }
    }
  }

  // Middle Click Action
  NBox {
    Layout.fillWidth: true
    Layout.preferredHeight: middleContent.implicitHeight + Style.marginM * 2
    color: Color.mSurfaceVariant

    ColumnLayout {
      id: middleContent
      anchors.fill: parent
      anchors.margins: Style.marginM
      spacing: Style.marginS

      NText {
        Layout.fillWidth: true
        text: pluginApi?.tr("settings.middle.title")
        pointSize: Style.fontSizeL
        font.weight: Style.fontWeightBold
        color: Color.mOnSurface
      }

      NText {
        Layout.fillWidth: true
        text: pluginApi?.tr("settings.middle.description")
        color: Color.mOnSurfaceVariant
        pointSize: Style.fontSizeM
        wrapMode: Text.WordWrap
      }

      RowLayout {
        spacing: Style.marginM

        NRadioButton {
          id: middlePrevRadio
          text: pluginApi?.tr("settings.middle.previous")
          checked: root.editMiddleClickAction === "previous"
          onToggled: function(checked) {
            if (checked) {
              root.editMiddleClickAction = "previous"
            }
          }
        }

        NRadioButton {
          id: middleToggleRadio
          text: pluginApi?.tr("settings.middle.toggle_display")
          checked: root.editMiddleClickAction === "toggle-mode"
          onToggled: function(checked) {
            if (checked) {
              root.editMiddleClickAction = "toggle-mode"
            }
          }
        }
      }
    }
  }

  // Poll Interval
  NBox {
    Layout.fillWidth: true
    Layout.preferredHeight: pollContent.implicitHeight + Style.marginM * 2
    color: Color.mSurfaceVariant

    ColumnLayout {
      id: pollContent
      anchors.fill: parent
      anchors.margins: Style.marginM
      spacing: Style.marginS

      NText {
        Layout.fillWidth: true
        text: pluginApi?.tr("settings.update.title")
        pointSize: Style.fontSizeL
        font.weight: Style.fontWeightBold
        color: Color.mOnSurface
      }

      NText {
        Layout.fillWidth: true
        text: pluginApi?.tr("settings.update.description")
        color: Color.mOnSurfaceVariant
        pointSize: Style.fontSizeM
        wrapMode: Text.WordWrap
      }

      RowLayout {
        spacing: Style.marginM

        NText {
          text: pluginApi?.tr("settings.update.interval_label") || "Interval (ms):"
          color: Color.mOnSurface
          pointSize: Style.fontSizeM
        }

        NTextInput {
          id: pollInput
          Layout.preferredWidth: 100 * Style.uiScaleRatio
          Layout.preferredHeight: Style.baseWidgetSize
          text: root.editPollIntervalMs.toString()

          onTextChanged: {
            var val = parseInt(text);
            if (!isNaN(val) && val >= 200 && val <= 30000) {
              root.editPollIntervalMs = val;
            }
          }
        }

        NText {
          text: pluginApi?.tr("settings.update.interval_hint") || "200 – 30000"
          color: Color.mOnSurfaceVariant
          pointSize: Style.fontSizeS
        }
      }
    }
  }

  // Actions
  NBox {
    Layout.fillWidth: true
    Layout.preferredHeight: actionsContent.implicitHeight + Style.marginM * 2
    color: Color.mSurfaceVariant

    ColumnLayout {
      id: actionsContent
      anchors.fill: parent
      anchors.margins: Style.marginM
      spacing: Style.marginM

      NText {
        Layout.fillWidth: true
        text: pluginApi?.tr("settings.actions") || "Actions"
        pointSize: Style.fontSizeL
        font.weight: Style.fontWeightBold
        color: Color.mOnSurface
      }

      RowLayout {
        spacing: Style.marginM

        NButton {
          text: pluginApi?.tr("settings.refresh-layouts") || "Refresh layouts"
          icon: "refresh"
          onClicked: {
            var mi = pluginApi?.mainInstance;
            if (mi && typeof mi.refresh === "function") {
              mi.refresh();
            }
          }
        }

        NButton {
          text: pluginApi?.tr("settings.reset-defaults") || "Reset to defaults"
          icon: "rotate"
          onClicked: {
            var defs = pluginApi?.manifest?.metadata?.defaultSettings || {}
            root.editDisplayMode = defs.displayMode ?? "text"
            root.editMiddleClickAction = defs.middleClickAction ?? "previous"
            root.editPollIntervalMs = defs.pollIntervalMs ?? 750
          }
        }
      }
    }
  }

  // Bottom spacing
  Item {
    Layout.preferredHeight: Style.marginL
  }
}
