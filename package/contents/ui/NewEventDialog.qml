import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import QtQuick.Window 2.2

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.components 3.0 as PlasmaComponents3

import "zstyle2" as ZStyle2

PlasmaCore.Dialog {
	id: newEventDialog

	property Item agendaItem: null
	readonly property var dayData: agendaItem ? agendaItem.dayData : null
	visible: false

	onVisibleChanged: {
		if (visible) {
			quickAddTextField.focus = true
		} else {
			agendaItem = null
			main.dialog.requestActivate()
		}
	}

	visualParent: agendaItem ? agendaItem.dayHeading : null

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
						id: quickAddTextField
						Layout.fillWidth: true
						Layout.preferredWidth: 300 * units.devicePixelRatio
						text: ""
						placeholderText: i18n("Eg: 9am-5pm Work")
						font.pointSize: -1
						font.pixelSize: 16 * units.devicePixelRatio
						wrapMode: TextEdit.Wrap
						inactiveBackgroundOpacity: 1
					}
					PlasmaComponents3.ToolButton {
						Layout.alignment: Qt.AlignTop
						icon.name: "window-close-symbolic"
						onClicked: newEventDialog.close()
					}
				}
				GridLayout {
					columns: 2
					columnSpacing: units.smallSpacing

					EventDialogIcon {
						source: "view-calendar-day"
						labelFor: calendarSelector
					}
					CalendarSelector {
						id: calendarSelector
						model: agendaModel.writeableCalendarList
					}
				}

				RowLayout {
					spacing: 0

					Item {
						Layout.fillWidth: true
					}

					PlasmaComponents3.Button {
						id: saveButton
						text: i18n("Save")
						// onClicked: 
					}
				}
			}
		
		}
	}
}
