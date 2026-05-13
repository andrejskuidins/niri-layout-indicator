import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Widgets
import qs.Services.UI

Item {
  id: rootItem
  implicitWidth: 600
  implicitHeight: root.implicitHeight
  width: Math.max(implicitWidth, parent ? parent.width : 0)

  property var pluginApi: null

  Timer {
    id: resizeTimer
    interval: 10
    repeat: false
    running: false
    onTriggered: {
      var obj = rootItem.parent;
      var depth = 0;
      while (obj && depth < 10) {
        if (typeof obj.modal === "boolean") {
          obj.width = 640; // 600px content + 2*20px padding
          break;
        }
        obj = obj.parent;
        depth++;
      }
    }
  }

  Component.onCompleted: {
    resizeTimer.start();
  }

  Component.onDestruction: {
    resizeTimer.stop();
  }

  ColumnLayout {
    id: root
    implicitWidth: 600
    width: parent.width
    spacing: Style.marginM

    // Configuration — read from saved settings, fall back to manifest defaults
    property var cfg: rootItem.pluginApi?.pluginSettings || ({})
    property var defaults: rootItem.pluginApi?.manifest?.metadata?.defaultSettings || ({})

    // Edit-copy properties — initialized from saved settings, saved only via saveSettings()
    property string editDisplayMode: cfg.displayMode ?? defaults.displayMode ?? "text"
    property string editMiddleClickAction: cfg.middleClickAction ?? defaults.middleClickAction ?? "previous"
    property int editPollIntervalMs: cfg.pollIntervalMs ?? defaults.pollIntervalMs ?? 750

    // Header
    NText {
      Layout.fillWidth: true
      text: rootItem.pluginApi?.tr("settings.title")
      pointSize: Style.fontSizeXXL
      font.weight: Style.fontWeightBold
      color: Color.mOnSurface
    }

    NText {
      Layout.fillWidth: true
      text: rootItem.pluginApi?.tr("settings.description")
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
          text: rootItem.pluginApi?.tr("settings.display.title")
          pointSize: Style.fontSizeL
          font.weight: Style.fontWeightBold
          color: Color.mOnSurface
        }

        NText {
          Layout.fillWidth: true
          text: rootItem.pluginApi?.tr("settings.display.description")
          color: Color.mOnSurfaceVariant
          pointSize: Style.fontSizeM
          wrapMode: Text.WordWrap
        }

        RowLayout {
          spacing: Style.marginM

          NRadioButton {
            id: displayTextRadio
            text: rootItem.pluginApi?.tr("settings.display.text")
            checked: root.editDisplayMode === "text"
            onToggled: function(checked) {
              if (checked) root.editDisplayMode = "text";
            }
          }

          NRadioButton {
            id: displayFlagRadio
            text: rootItem.pluginApi?.tr("settings.display.flag")
            checked: root.editDisplayMode === "flag"
            onToggled: function(checked) {
              if (checked) root.editDisplayMode = "flag";
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
          text: rootItem.pluginApi?.tr("settings.middle.title")
          pointSize: Style.fontSizeL
          font.weight: Style.fontWeightBold
          color: Color.mOnSurface
        }

        NText {
          Layout.fillWidth: true
          text: rootItem.pluginApi?.tr("settings.middle.description")
          color: Color.mOnSurfaceVariant
          pointSize: Style.fontSizeM
          wrapMode: Text.WordWrap
        }

        RowLayout {
          spacing: Style.marginM

          NRadioButton {
            id: middlePrevRadio
            text: rootItem.pluginApi?.tr("settings.middle.previous")
            checked: root.editMiddleClickAction === "previous"
            onToggled: function(checked) {
              if (checked) root.editMiddleClickAction = "previous";
            }
          }

          NRadioButton {
            id: middleToggleRadio
            text: rootItem.pluginApi?.tr("settings.middle.toggle_display")
            checked: root.editMiddleClickAction === "toggle-mode"
            onToggled: function(checked) {
              if (checked) root.editMiddleClickAction = "toggle-mode";
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
          text: rootItem.pluginApi?.tr("settings.update.title")
          pointSize: Style.fontSizeL
          font.weight: Style.fontWeightBold
          color: Color.mOnSurface
        }

        NText {
          Layout.fillWidth: true
          text: rootItem.pluginApi?.tr("settings.update.description")
          color: Color.mOnSurfaceVariant
          pointSize: Style.fontSizeM
          wrapMode: Text.WordWrap
        }

        RowLayout {
          spacing: Style.marginM

          NText {
            text: rootItem.pluginApi?.tr("settings.update.interval_label") || "Interval (ms):"
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
            text: rootItem.pluginApi?.tr("settings.update.interval_hint") || "200 – 30000"
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
          text: rootItem.pluginApi?.tr("settings.actions") || "Actions"
          pointSize: Style.fontSizeL
          font.weight: Style.fontWeightBold
          color: Color.mOnSurface
        }

        RowLayout {
          spacing: Style.marginM

          NButton {
            text: rootItem.pluginApi?.tr("settings.refresh-layouts") || "Refresh layouts"
            icon: "refresh"
            onClicked: {
              var mainInstance = rootItem.pluginApi?.mainInstance;
              if (mainInstance && typeof mainInstance.refresh === "function") {
                mainInstance.refresh();
                ToastService.showNotice(
                  rootItem.pluginApi?.tr("settings.refresh-message") || "Layouts refreshed"
                );
              }
            }
          }

          NButton {
            text: rootItem.pluginApi?.tr("settings.reset-defaults") || "Reset to defaults"
            icon: "rotate"
            onClicked: {
              root.editDisplayMode = root.defaults.displayMode ?? "text";
              root.editMiddleClickAction = root.defaults.middleClickAction ?? "previous";
              root.editPollIntervalMs = root.defaults.pollIntervalMs ?? 750;

              displayTextRadio.checked = (root.editDisplayMode === "text");
              displayFlagRadio.checked = (root.editDisplayMode === "flag");
              middlePrevRadio.checked = (root.editMiddleClickAction === "previous");
              middleToggleRadio.checked = (root.editMiddleClickAction === "toggle-mode");
              pollInput.text = root.editPollIntervalMs.toString();

              if (rootItem.pluginApi && rootItem.pluginApi.pluginSettings) {
                rootItem.pluginApi.pluginSettings.displayMode = root.editDisplayMode;
                rootItem.pluginApi.pluginSettings.middleClickAction = root.editMiddleClickAction;
                rootItem.pluginApi.pluginSettings.pollIntervalMs = root.editPollIntervalMs;
                rootItem.pluginApi.saveSettings();

                // Notify the bar widget instance
                var mi = rootItem.pluginApi.mainInstance;
                if (mi && typeof mi.onSettingsChanged === "function") {
                  mi.onSettingsChanged();
                }
              }

              ToastService.showNotice(
                rootItem.pluginApi?.tr("settings.reset-message") || "Settings reset to defaults"
              );
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

  // Notify the bar widget instance that settings have changed
  function notifyBarWidget() {
    var mainInstance = pluginApi?.mainInstance;
    if (mainInstance && typeof mainInstance.onSettingsChanged === "function") {
      mainInstance.onSettingsChanged();
    }
  }

  // Save function on rootItem so the shell can call component.saveSettings()
  function saveSettings() {
    if (!pluginApi) return;
    pluginApi.pluginSettings.displayMode = root.editDisplayMode;
    pluginApi.pluginSettings.middleClickAction = root.editMiddleClickAction;
    pluginApi.pluginSettings.pollIntervalMs = root.editPollIntervalMs;
    pluginApi.saveSettings();
    notifyBarWidget();
    ToastService.showNotice(
      pluginApi?.tr("settings.saved") || "Settings saved"
    );
  }
}
