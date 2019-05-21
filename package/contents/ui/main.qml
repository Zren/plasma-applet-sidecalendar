import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import QtQuick.Window 2.2

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.plasmoid 2.0

import "lib"
import "cal"

DialogApplet {
	id: main

	QtObject {
		id: config
		property bool wrapEventSummary: true
	}

	PlasmaCore.DataSource {
		id: dataSource
		engine: "time"
		connectedSources: ["Local"]
		interval: 60000
		intervalAlignment: PlasmaCore.Types.AlignToMinute
	}

	dialogContents: ColumnLayout {
		id: dialogContents

		height: Screen.desktopAvailableHeight

		Item {
			readonly property int numCols: calendar.showWeekNumbers ? 8 : 7
			readonly property int numRows: 6
			readonly property int minCellSize: 22
			readonly property int prefCellSize: 44
			readonly property int _minimumWidth: Math.round(numCols * prefCellSize * units.devicePixelRatio)
			readonly property int _minimumHeight: Math.round(calendar.topAreaHeight + numRows * prefCellSize * units.devicePixelRatio)

			Layout.minimumWidth: _minimumWidth
			Layout.preferredWidth: _minimumWidth
			Layout.fillWidth: true
			Layout.minimumHeight: _minimumHeight
			Layout.maximumHeight: Layout.minimumHeight

			MonthView {
				id: calendar
				today: dataSource.data["Local"]["DateTime"]
				// showWeekNumbers: plasmoid.configuration.showWeekNumbers
				firstDayOfWeek: {
					if (plasmoid.configuration.firstDayOfWeek == -1) {
						return Qt.locale().firstDayOfWeek
					} else {
						return plasmoid.configuration.firstDayOfWeek
					}
				}

				// borderOpacity: plasmoid.configuration.month_show_border ? 0.25 : 0
				showBorders: false
				// cellRadius: 0
				showWeekNumbers: true

				// showOutlines: false

				anchors.fill: parent
			}
		}

		AgendaView {
			id: agendaView
			Layout.fillWidth: true
			Layout.fillHeight: true
		}

	}

	AgendaModel { id: agendaModel }

	Component.onCompleted: {
		if (plasmoid.hasOwnProperty("activationTogglesExpanded")) {
			plasmoid.activationTogglesExpanded = true
		}

		// [Testing] Open config on run
		// plasmoid.action("configure").trigger()
	}

	// [Testing] Open popup on run
	// Timer { onTriggered: plasmoid.activated(); interval: 0; running: true }

	onCompactItemClicked: {
		if (mouse.button == Qt.LeftButton) {
			main.toggleDialog(false)
		}
	}

	dialog.visualParent: null
	// dialog.height: Screen.desktopAvailableHeight
	dialog.location: PlasmaCore.Types.RightEdge
	// dialog.location: PlasmaCore.Types.LeftEdge
	dialog.x: {
		if (dialog.location == PlasmaCore.Types.LeftEdge) {
			return 0
		} else if (dialog.location == PlasmaCore.Types.RightEdge) {
			return Screen.desktopAvailableWidth - dialog.width
		} else {
			return 0
		}
	}

	Binding {
		target: plasmoid
		property: "hideOnWindowDeactivate"
		value: !plasmoid.configuration.pin
	}
}
