import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import QtQuick.Window 2.2

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.components 3.0 as PlasmaComponents3

import "zstyle2" as ZStyle2

PlasmaCore.Dialog {
	id: eventDialog

	property Item eventItem: null
	readonly property var eventData: eventItem ? eventItem.eventData : null
	visible: false

	property bool populated: false
	property bool editing: false

	onEventDataChanged: {
		if (eventData) {
			editing = true // TODO: false
			summaryTextField.text = eventData.summary || ""
			locationTextField.text = eventData.location || ""
			isAllDayCheckBox.checked = eventData.isAllDay || false
			durationSelector.startDateTime = eventData.startDateTime || new Date()
			durationSelector.endDateTime = eventData.endDateTime || new Date()
			calendarSelector.currentIndex = calendarSelector.find(eventData.calendar.summary)
			descriptionTextField.text = eventData.description || ""
			populated = true
		}
	}

	onVisibleChanged: {
		if (!visible) {
			editing = false
			populated = false
			eventItem = null
			main.dialog.requestActivate()
		}
	}

	function logProp(key) {
		eventDialog[key + 'Changed'].connect(function(){
			console.log(key, eventDialog[key])
		})
	}
	Component.onCompleted: {
		// logProp('eventItem')
		// logProp('eventHovered')
		// logProp('dialogHovered')
		// logProp('shouldOpen')
		// logProp('visible')
	}

	visualParent: eventItem

	flags: Qt.WindowStaysOnTopHint
	location: main.dialog.location

	mainItem: Item {
		id: focusScope
		width: dialogLayout.implicitWidth
		height: dialogLayout.implicitHeight
	
		MouseArea {
			id: eventDialogMouseArea
			anchors.fill: parent

			hoverEnabled: true

			onClicked: focus = true

			ColumnLayout {
				id: dialogLayout

				RowLayout {
					ZStyle2.TextField {
						id: summaryTextField
						Layout.fillWidth: true
						// text: eventData.summary
						placeholderText: i18n("Event Summary")
						font.pointSize: -1
						font.pixelSize: 16 * units.devicePixelRatio
						enabled: eventDialog.editing
						wrapMode: TextEdit.Wrap
					}
					PlasmaComponents3.ToolButton {
						Layout.alignment: Qt.AlignTop
						icon.name: "edit-entry"
						onClicked: eventDialog.editing = !eventDialog.editing
					}
					PlasmaComponents3.ToolButton {
						Layout.alignment: Qt.AlignTop
						icon.name: "window-close-symbolic"
						onClicked: eventDialog.close()
					}
				}

				DurationSelector {
					id: durationSelector
					enabled: eventDialog.editing
					showTime: !isAllDayCheckBox.checked
				}

				RowLayout {
					PlasmaComponents3.CheckBox {
						id: isAllDayCheckBox
						text: "All day"
						enabled: eventDialog.editing
						contentItem.opacity: 1
						visible: eventDialog.editing
					}
				}

				// Rectangle {
				// 	Layout.fillWidth: true
				// 	height: 1 * units.devicePixelRatio
				// 	color: theme.textColor
				// 	opacity: 0.5
				// }

				GridLayout {
					columns: 2
					columnSpacing: units.smallSpacing

					EventDialogIcon {
						source: "mark-location-symbolic"
						labelFor: locationTextField
					}
					ZStyle2.TextField {
						id: locationTextField
						Layout.fillWidth: true
						placeholderText: i18n("Add Location")
						font.pointSize: -1
						font.pixelSize: 12 * units.devicePixelRatio
						enabled: eventDialog.editing
						visible: text || eventDialog.editing
						wrapMode: TextEdit.Wrap
					}

					EventDialogIcon {
						source: "view-calendar-day"
						labelFor: calendarSelector
					}
					CalendarSelector {
						id: calendarSelector
						// editText: eventData.calendar.summary
						enabled: eventDialog.editing
					}

					EventDialogIcon {
						source: "x-shape-text"
						labelFor: descriptionTextField
						Layout.fillHeight: false
						Layout.preferredHeight: locationTextField.implicitHeight
						Layout.alignment: Qt.AlignTop
					}
					ZStyle2.TextArea {
						id: descriptionTextField
						Layout.fillWidth: true
						placeholderText: i18n("Add description")
						font.pointSize: -1
						font.pixelSize: 12 * units.devicePixelRatio
						enabled: eventDialog.editing
						visible: text || eventDialog.editing
						implicitWidth: units.gridUnits * 8
						wrapMode: TextEdit.Wrap
					}
				}
			}
		
		}
	}
}
