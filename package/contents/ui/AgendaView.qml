import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import QtQuick.Window 2.2

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

ScrollView {
	id: agendaView

	readonly property int contentWidth: contentItem ? contentItem.width : width
	readonly property int contentHeight: contentItem ? contentItem.height : 0 // Warning: Binding loop
	readonly property int viewportWidth: viewport ? viewport.width : width
	readonly property int viewportHeight: viewport ? viewport.height : height
	readonly property int scrollY: flickableItem ? flickableItem.contentY : 0

	ColumnLayout {
		id: dayColumn
		spacing: units.largeSpacing
		width: agendaView.viewportWidth


		Repeater {
			id: dayRepeater
			model: agendaModel.data

			delegate: AgendaDayItem {}
		}
	}

	property var eventDialog: EventDialog {}
	property var newEventDialog: NewEventDialog {}

	function toggleEventDialog(eventItem) {
		if (newEventDialog.visible) {
			newEventDialog.visible = false
		}
		if (eventDialog.visible && eventDialog.eventItem == eventItem) {
			eventDialog.visible = false
		} else {
			eventDialog.eventItem = eventItem
			eventDialog.visible = true
		}
	}

	function toggleNewEventDialog(agendaItem) {
		if (eventDialog.visible) {
			eventDialog.visible = false
		}
		if (newEventDialog.visible && newEventDialog.agendaItem == agendaItem) {
			newEventDialog.visible = false
		} else {
			newEventDialog.agendaItem = agendaItem
			newEventDialog.visible = true
		}
	}
}
