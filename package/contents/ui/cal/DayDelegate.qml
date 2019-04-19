/*
 * Copyright 2013 Heena Mahour <heena393@gmail.com>
 * Copyright 2013 Sebastian Kügler <sebas@kde.org>
 * Copyright 2015 Kai Uwe Broulik <kde@privat.broulik.de>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
import QtQuick 2.0
import QtQuick.Layouts 1.0
import org.kde.plasma.calendar 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as Components

import org.kde.plasma.calendar 2.0

import "LocalizedDate.js" as LocalizedDate

MouseArea {
	id: dayStyle

	readonly property string todayStyle: daysCalendar._todayStyle

	hoverEnabled: true
	readonly property real minSize: Math.min(width, height)
	readonly property real radius: minSize * daysCalendar.cellRadius

	signal activated()

	readonly property date thisDate: new Date(yearNumber, typeof monthNumber !== "undefined" ? monthNumber - 1 : 0, typeof dayNumber !== "undefined" ? dayNumber : 1)
	readonly property bool today: {
		var today = monthView.today
		var result = true
		if (dateMatchingPrecision >= Calendar.MatchYear) {
			result = result && today.getFullYear() === thisDate.getFullYear()
		}
		if (dateMatchingPrecision >= Calendar.MatchYearAndMonth) {
			result = result && today.getMonth() === thisDate.getMonth()
		}
		if (dateMatchingPrecision >= Calendar.MatchYearMonthAndDay) {
			result = result && today.getDate() === thisDate.getDate()
		}
		return result
	}
	readonly property bool selected: {
		var current = monthView.currentDate
		var result = true
		if (dateMatchingPrecision >= Calendar.MatchYear) {
			result = result && current.getFullYear() === thisDate.getFullYear()
		}
		if (dateMatchingPrecision >= Calendar.MatchYearAndMonth) {
			result = result && current.getMonth() === thisDate.getMonth()
		}
		if (dateMatchingPrecision >= Calendar.MatchYearMonthAndDay) {
			result = result && current.getDate() === thisDate.getDate()
		}
		return result
	}

	onHeightChanged: {
		// this is needed here as the text is first rendered, counting with the default monthView.cellHeight
		// then monthView.cellHeight actually changes to whatever it should be, but the Label does not pick
		// it up after that, so we need to change it explicitly after the cell size changes
		// label.font.pixelSize = Math.max(theme.smallestFont.pixelSize, Math.floor(daysCalendar.cellHeight / 3))
	}

	Item {
		anchors.fill: daysCalendar.squareCells ? undefined : parent
		anchors.centerIn: daysCalendar.squareCells ? parent : undefined
		width: daysCalendar.squareCells ? parent.minSize : undefined
		height: daysCalendar.squareCells ? parent.minSize : undefined

		Rectangle {
			id: highlightDate
			anchors.fill: parent
			radius: dayStyle.radius

			opacity: {
				if (selected) {
					0.6
				} else if (dayStyle.containsMouse) {
					0.4
				} else {
					0
				}
			}
			Behavior on opacity { NumberAnimation { duration: units.longDuration } }
			color: theme.highlightColor
		}

	}
	

	property int eventCount: model.events ? model.events.count : 0
	property var eventColors: []
	property bool useHightlightColor: eventColors.length === 0

	onEventCountChanged: updateEventColors()
	function updateEventColors() {
		var set = {}
		for (var i = 0; i < eventCount; i++) {
			var eventItem = model.events.get(i)
			if (eventItem.backgroundColor) {
				set[eventItem.backgroundColor] = true
			}
		}
		eventColors = Object.keys(set)
	}

	Text {
		id: label
		anchors {
			fill: parent
			margins: units.smallSpacing
		}
		horizontalAlignment: Text.AlignHCenter
		verticalAlignment: Text.AlignVCenter
		text: model.label || dayNumber
		opacity: isCurrent ? 1.0 : 0.5
		wrapMode: Text.NoWrap
		elide: Text.ElideRight
		fontSizeMode: Text.HorizontalFit
		font.weight: today ? Font.Bold : Font.Normal
		font.pixelSize: {
			return Math.max(theme.smallestFont.pixelSize, Math.min(Math.floor(dayStyle.height / 2), Math.floor(dayStyle.width * 7/8)))

			// return Math.max(theme.smallestFont.pixelSize, Math.min(Math.floor(dayStyle.height / 3), Math.floor(dayStyle.width * 5/8)))

			// if (today && todayStyle == "bigNumber") {
			// 	return Math.max(theme.smallestFont.pixelSize, Math.min(Math.floor(dayStyle.height / 2), Math.floor(dayStyle.width * 7/8)))
			// } else {
			// 	return Math.max(theme.smallestFont.pixelSize, Math.min(Math.floor(dayStyle.height / 3), Math.floor(dayStyle.width * 5/8)))
			// }
		}
		// This is to avoid the "Both point size and
		// pixel size set. Using pixel size" warnings
		font.pointSize: -1
		color: {
			if (today) {
				if (dayStyle.containsMouse || dayStyle.selected) {
					return theme.textColor
				} else {
					return theme.highlightColor
				}
			} else {
				return theme.textColor
			}
		}
		Behavior on color {
			ColorAnimation { duration: units.shortDuration * 2 }
		}
	}

	PlasmaCore.ToolTipArea {
		anchors.fill: parent
		active: monthView.showTooltips
		visible: monthView.showTooltips // Needed with active=false to make sure the ToolTipArea doesn't close a parent ToolTipArea. Eg: DateSelector.
		mainText: containsMouse ? Qt.formatDate(thisDate, Locale.LongFormat) : ""
		subText: containsMouse ? tooltipBody() : ""
		function tooltipBody() {
			if (!model.events) {
				return ''
			}
			var lines = []
			for (var i = 0; i < model.events.count; i++) {
				var eventItem = model.events.get(i)
				var line = ''
				line += '<font color="' + eventItem.backgroundColor + '">■</font> '
				line += '<b>' + eventItem.summary + ':</b> '
				line += LocalizedDate.formatEventDuration(eventItem, {
					relativeDate: thisDate,
					clock24h: monthView.using24hClock,
				})
				lines.push(line)
			}
			return lines.join('<br>')
		}
	}

	Component.onCompleted: {
		if (stack.depth === 1 && today) {
			monthView.date = model
		}
	}
}
