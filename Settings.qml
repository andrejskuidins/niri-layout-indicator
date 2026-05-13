import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Widgets
import qs.Services.UI

ColumnLayout {
  id: root
  implicitWidth: 600
  width: Math.max(implicitWidth, parent ? parent.width : 0)

  property var pluginApi: null

  // Local state — initialized from saved settings, saved via saveSettings()
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

  Component.onCompleted: {
    Logger.d("NiriLayoutIndicator", "Settings.onCompleted: pluginApi=" + (pluginApi ? "set" : "null") + " pluginSettings=" + JSON.stringify(pluginApi?.pluginSettings))
    Logger.d("NiriLayoutIndicator", "Settings.onCompleted: editDisplayMode=" + root.editDisplayMode + " editMiddleClickAction=" + root.editMiddleClickAction + " editPollIntervalMs=" + root.editPollIntervalMs)
  }

  // Required: Save function called by the settings dialog
  function saveSettings() {
    Logger.d("NiriLayoutIndicator", "Settings.saveSettings called: displayMode=" + root.editDisplayMode + " middleClickAction=" + root.editMiddleClickAction + " pollIntervalMs=" + root.editPollIntervalMs)
    if (!pluginApi) {
      Logger.w("NiriLayoutIndicator", "Settings.saveSettings: pluginApi is null")
      return
    }
    pluginApi.pluginSettings.displayMode = root.editDisplayMode
    pluginApi.pluginSettings.middleClickAction = root.editMiddleClickAction
    pluginApi.pluginSettings.pollIntervalMs = root.editPollIntervalMs
    pluginApi.saveSettings()

    // Notify the bar widget to re-read settings
    var mi = pluginApi.mainInstance
    if (mi && typeof mi.onSettingsChanged === "function") {
      mi.onSettingsChanged()
    }

    Logger.d("NiriLayoutIndicator", "Settings.saveSettings: saved and notified")
    ToastService.showNotice(
      pluginApi?.tr("settings.saved") || "Settings saved"
    )
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
                Logger.d("NiriLayoutIndicator", "Settings: displayMode -> text")
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
                Logger.d("NiriLayoutIndicator", "Settings: displayMode -> flag")
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
                Logger.d("NiriLayoutIndicator", "Settings: middleClickAction -> previous")
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
                Logger.d("NiriLayoutIndicator", "Settings: middleClickAction -> toggle-mode")
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

    // Reset button
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
              var mainInstance = pluginApi?.mainInstance;
              if (mainInstance && typeof mainInstance.refresh === "function") {
                mainInstance.refresh();
                ToastService.showNotice(
                  pluginApi?.tr("settings.refresh-message") || "Layouts refreshed"
                );
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

              ToastService.showNotice(
                pluginApi?.tr("settings.reset-message") || "Settings reset to defaults"
              )
            }
          }
        }
      }
    }

    // Bottom spacing
    Item {
      Layout.preferredHeight: Style.marginL
    }

  }  // end ColumnLayout
