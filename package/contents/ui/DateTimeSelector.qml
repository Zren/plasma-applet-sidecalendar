import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import QtQuick.Window 2.2

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.components 3.0 as PlasmaComponents3

import "zstyle2" as ZStyle2

RowLayout {
	id: dateTimeSelector
	property var dateTime: new Date()
	property bool enabled: true
	property bool showTime: true

	PlasmaComponents.TextField {
		text: Qt.formatDateTime(dateTimeSelector.dateTime, "MM/dd/yyyy")
		enabled: dateTimeSelector.enabled
	}
	PlasmaComponents.TextField {
		text: Qt.formatDateTime(dateTimeSelector.dateTime, "HH:mm AP")
		enabled: dateTimeSelector.enabled && !dateTimeSelector.showTime
		opacity: dateTimeSelector.showTime ? 0 : 1
	}
}
