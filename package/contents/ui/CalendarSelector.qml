import QtQuick 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents3

PlasmaComponents3.ComboBox {
	id: control

	model: agendaModel.calendarList

	textRole: "summary"
	property string colorRole: "backgroundColor"

	editText: model && model.length >= 1 ? model[0][textRole] : ""

	readonly property var currentItem: currentIndex >= 0 ? model[currentIndex] : null

	leftPadding: control.background.margins.left + currentDot.implicitWidth
	property Item currentDot: PlasmaComponents3.Label {
		id: currentDot
		text: control.currentItem ? '<font color="' + control.currentItem[control.colorRole] + '">⬤</font>&nbsp;' : ''
		font: control.font
		color: theme.viewTextColor
		visible: control.text
		horizontalAlignment: Text.AlignLeft
		verticalAlignment: Text.AlignVCenter

		anchors.topMargin: control.background.margins.top
		anchors.leftMargin: control.background.margins.left
	}
	Component.onCompleted: {
		control.contentItem.children.push(currentDot)
		currentDot.anchors.top = control.contentItem.top
		currentDot.anchors.left = control.contentItem.left
	}

	delegate: PlasmaComponents3.ItemDelegate {
		width: control.popup.width
		text: '<font color="' + modelData[control.colorRole] + '">⬤</font>&nbsp;' + modelData[control.textRole]
		highlighted: mouseArea.pressed ? listView.currentIndex == index : control.highlightedIndex == index
		property bool separatorVisible: false


		readonly property Item mouseArea: control.contentItem
		readonly property Item listView: control.popup.contentItem
	}
}
