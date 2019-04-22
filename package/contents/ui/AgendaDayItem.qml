import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import QtQuick.Window 2.2

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

ColumnLayout {
	id: agendaItem
	spacing: 0
	readonly property var dayData: modelData

	property alias dayHeading: dayHeading
	MouseArea {
		id: dayHeading

		readonly property bool isActiveDay: agendaView.newEventDialog.agendaItem == agendaItem
		property bool isHighlighted: containsMouse || isActiveDay

		readonly property color textColor: isHighlighted ? theme.highlightedTextColor : theme.textColor
		readonly property color backgroundColor: isHighlighted ? theme.highlightColor : "transparent"
		
		property int horzPadding: 2 * units.devicePixelRatio
		property int vertPadding: 2 * units.devicePixelRatio
		Layout.fillWidth: true
		implicitHeight: vertPadding + dayHeadingRow.implicitHeight + vertPadding

		hoverEnabled: true

		Rectangle {
			id: backgroundRect
			anchors.fill: parent
			color: dayHeading.backgroundColor
			opacity: dayHeading.isHighlighted ? 0.6 : 0
			Behavior on opacity { NumberAnimation { duration: units.longDuration } }
		}

		RowLayout {
			id: dayHeadingRow
			anchors.fill: parent
			anchors.leftMargin: parent.horzPadding
			anchors.rightMargin: parent.horzPadding
			anchors.topMargin: parent.vertPadding
			anchors.bottomMargin: parent.vertPadding

			PlasmaComponents.Label {
				id: dayHeadingLabel
				Layout.fillWidth: true
				text: Qt.formatDateTime(dayData.dateTime, "dddd M/d/yy").toUpperCase()
				font.weight: Font.Bold
				color: dayHeading.textColor
				opacity: dayHeading.isHighlighted ? 1 : 0.6
				Behavior on color { ColorAnimation { duration: units.longDuration } }
				Behavior on opacity { NumberAnimation { duration: units.longDuration } }
			}
			PlasmaComponents.Label {
				Layout.preferredWidth: 32 * units.devicePixelRatio
				horizontalAlignment: Text.AlignHCenter
				text: "✚"
				font.weight: Font.Bold
				color: dayHeading.textColor
				opacity: dayHeading.isHighlighted ? 1 : 0
				Behavior on color { ColorAnimation { duration: units.longDuration } }
				Behavior on opacity { NumberAnimation { duration: units.longDuration } }
			}
		}

		onClicked: {
			agendaView.toggleNewEventDialog(agendaItem)
		}
	}

	Repeater {
		id: eventRepeater
		model: dayData.events
		delegate: AgendaEventItem {}
	}
}
