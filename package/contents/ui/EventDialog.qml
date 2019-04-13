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

	onEventDataChanged: {
		if (eventData) {
			summaryTextField.text = eventData.summary || ""
			locationTextField.text = eventData.location || ""
			isAllDayCheckBox.checked = eventData.isAllDay || false
			calendarSelector.currentIndex = calendarSelector.find(eventData.calendar.name)
		}
	}

	onVisibleChanged: {
		if (!visible) {
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
	location: PlasmaCore.Types.RightEdge

	mainItem: FocusScope {
		id: focusScope
		width: dialogLayout.implicitWidth
		height: dialogLayout.implicitHeight
	
		MouseArea {
			id: eventDialogMouseArea
			anchors.fill: parent

			hoverEnabled: true

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
					}
					PlasmaComponents3.ToolButton {
						Layout.alignment: Qt.AlignTop
						icon.name: "window-close-symbolic"
						onClicked: eventDialog.close()
					}
				}

				ZStyle2.TextField {
					id: locationTextField
					Layout.fillWidth: true
					// text: eventData.location
					placeholderText: i18n("Add Location")
					font.pointSize: -1
					font.pixelSize: 12 * units.devicePixelRatio
				}

				Rectangle {
					Layout.fillWidth: true
					height: 1 * units.devicePixelRatio
					color: theme.textColor
					opacity: 0.5
				}

				GridLayout {
					columns: 2
					columnSpacing: units.largeSpacing

					PlasmaComponents.Label {
						text: "all-day"
						font.weight: Font.Bold
						Layout.alignment: Qt.AlignRight
					}
					PlasmaComponents.CheckBox {
						id: isAllDayCheckBox
						// checked: eventData.isAllDay
					}
					PlasmaComponents.Label {
						text: "starts"
						font.weight: Font.Bold
						Layout.alignment: Qt.AlignRight
					}
					RowLayout {
						PlasmaComponents.TextField {
							text: Qt.formatDateTime(eventData.startDateTime, "MM/dd/yyyy")
						}
						PlasmaComponents.TextField {
							text: Qt.formatDateTime(eventData.startDateTime, "HH:mm AP")
							enabled: !isAllDayCheckBox.checked
							opacity: isAllDayCheckBox.checked ? 0 : 1
						}
					}
					PlasmaComponents.Label {
						text: "ends"
						font.weight: Font.Bold
						Layout.alignment: Qt.AlignRight
					}
					RowLayout {
						PlasmaComponents.TextField {
							text: Qt.formatDateTime(eventData.endDateTime, "MM/dd/yyyy")
						}
						PlasmaComponents.TextField {
							text: Qt.formatDateTime(eventData.endDateTime, "HH:mm AP")
							enabled: !isAllDayCheckBox.checked
							opacity: isAllDayCheckBox.checked ? 0 : 1
						}
					}
					PlasmaComponents.Label {
						text: "calendar"
						font.weight: Font.Bold
						Layout.alignment: Qt.AlignRight
					}
					CalendarSelector {
						id: calendarSelector
						// editText: eventData.calendar.name
					}
				}
			}
		
		}
	}
}
