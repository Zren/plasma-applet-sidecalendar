import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import QtQuick.Shapes 1.11

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

import "cal/LocalizedDate.js" as LocalizedDate

MouseArea {
	id: eventItem
	readonly property var eventData: modelData
	readonly property var eventColor: eventData.backgroundColor || eventData.calendar.backgroundColor

	readonly property bool isActiveEvent: agendaView.eventDialog.eventItem == eventItem
	property bool isHighlighted: containsMouse || isActiveEvent

	readonly property color textColor: isHighlighted ? theme.highlightedTextColor : theme.textColor
	readonly property color backgroundColor: isHighlighted ? theme.highlightColor : "transparent"

	property int horzPadding: units.smallSpacing * 2
	property int vertPadding: units.smallSpacing
	Layout.fillWidth: true
	implicitHeight: vertPadding + eventRow.implicitHeight + vertPadding

	hoverEnabled: true
	Rectangle {
		id: backgroundRect
		anchors.fill: parent
		color: eventItem.backgroundColor
		opacity: eventItem.isHighlighted ? 0.6 : 0
		Behavior on opacity { NumberAnimation { duration: units.longDuration } }
	}

	RowLayout {
		id: eventRow
		anchors.fill: parent
		anchors.leftMargin: parent.horzPadding
		anchors.rightMargin: parent.horzPadding
		anchors.topMargin: parent.vertPadding
		anchors.bottomMargin: parent.vertPadding

		ColumnLayout {
			Layout.preferredHeight: eventTimestamp.implicitHeight
			Layout.alignment: Qt.AlignTop

			MouseArea {
				id: taskButton
				property int size: 12 * units.devicePixelRatio
				implicitWidth: size
				implicitHeight: size
				Layout.alignment: Qt.AlignVCenter
				hoverEnabled: true

				property color currentColor: isHighlighted ? Qt.tint(eventColor, "#80FFFFFF") : eventColor

				onClicked: {
					eventData.isCompleted = !eventData.isCompleted
					eventItem.eventDataChanged()
				}

				Rectangle {
					id: outerRect
					anchors.fill: parent
					color: taskButton.currentColor

					Shape {
						id: checkShape
						anchors.fill: parent
						visible: opacity > 0
						opacity: eventData.isCompleted ? 1 : 0
						ShapePath {
							id: p
							readonly property int w: outerRect.width
							readonly property int h: outerRect.height

							fillColor: "transparent"
							strokeColor: theme.highlightColor
							strokeWidth: 2 * units.devicePixelRatio

							startX: p.w * 0.25
							startY: p.h * 0.5
							PathLine { x: p.w * 0.5; y: p.h * 0.75 }
							PathLine { x: p.w * 1; y: p.h * 0 }
						}

					}
				}
			}
		}

		PlasmaComponents.Label {
			text: eventData.summary
			Layout.fillWidth: true
			wrapMode: config.wrapEventSummary ? Text.Wrap : Text.NoWrap
			elide: Text.ElideRight
			color: eventItem.textColor
			Behavior on color { ColorAnimation { duration: units.longDuration } }
		}

		PlasmaComponents.Label {
			id: eventTimestamp
			Layout.alignment: Qt.AlignTop
			color: eventItem.textColor
			opacity: eventItem.isHighlighted ? 1 : 0.6
			Behavior on color { ColorAnimation { duration: units.longDuration } }
			Behavior on opacity { NumberAnimation { duration: units.longDuration } }
		}
	}

	state: eventData.isTask ? 'task' : 'event'
	states: [
		State {
			name: 'event'
			PropertyChanges {
				target: taskButton
				enabled: false
			}
			PropertyChanges {
				target: outerRect
				radius: outerRect.height * 0.5
			}
			PropertyChanges {
				target: eventTimestamp
				text: {
					var e = {
						start: {},
						end: {},
					}
					e.start.dateTime = eventData.startDateTime
					e.end.dateTime = eventData.endDateTime
					if (eventData.isAllDay) {
						e.start.date = eventData.startDateTime
						e.end.date = eventData.endDateTime
					}
					// console.log('eventTimestamp', eventData.summary)
					// console.log('\t relativeDate', dayData.dateTime)
					// console.log('\t', eventData.isAllDay)
					// var a = eventData.startDateTime
					// var b = eventData.endDateTime
					// console.log('\t', a, a.getFullYear(), a.getMonth(), a.getDate())
					// console.log('\t', b, b.getFullYear(), b.getMonth(), b.getDate())
					return LocalizedDate.formatEventDuration(e, {
						relativeDate: dayData.dateTime,
						clock24h: false,
						hourlyShortForm: false,
					})
				}
			}
		},
		State {
			name: 'task'
			PropertyChanges {
				target: taskButton
				enabled: true
			}
			PropertyChanges {
				target: outerRect
				radius: 3 * units.devicePixelRatio
				color: theme.backgroundColor
				border.width: 1 * units.devicePixelRatio
				border.color: taskButton.currentColor
			}
			PropertyChanges {
				target: eventTimestamp
				text: {
					return LocalizedDate.formatEventTime(eventData.endDateTime, {
						relativeDate: dayData.dateTime,
						clock24h: false,
						hourlyShortForm: false,
					})
				}
			}
		}
	]

	onClicked: {
		agendaView.toggleEventDialog(eventItem)
	}
}
