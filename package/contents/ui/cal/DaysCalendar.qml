/*
 * Copyright 2013  Heena Mahour <heena393@gmail.com>
 * Copyright 2013 Sebastian Kügler <sebas@kde.org>
 * Copyright 2015, 2016 Kai Uwe Broulik <kde@privat.broulik.de>
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

import QtQuick 2.2
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.1

import org.kde.plasma.calendar 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as Components
import org.kde.plasma.extras 2.0 as PlasmaExtras

Item {
	id: daysCalendar

	signal headerClicked

	signal previous
	signal next

	signal activated(int index, var date, var item)
	signal doubleClicked(int index, var date, var item)
	// so it forwards it to the delegate which then emits activated with all the neccessary data
	signal activateHighlightedItem

	readonly property int gridColumns: showWeekNumbers ? calendarGrid.columns + 1 : calendarGrid.columns

	property alias previousLabel: previousButton.tooltip
	property alias nextLabel: nextButton.tooltip

	property int rows
	property int columns

	property bool showWeekNumbers
	property string eventBadgeType: "theme"
	property string todayStyle: "theme"

	property real cellRadius: 0
	readonly property bool squareCells: cellRadius >= 0.4

	readonly property string _todayStyle: {
		switch (todayStyle) {
			case 'bigNumber':
				return todayStyle

			case 'theme':
			default:
				return 'theme'
		}
	}

	onShowWeekNumbersChanged: canvas.requestPaint()

	// how precise date matching should be, 3 = day+month+year, 2 = month+year, 1 = just year
	property int dateMatchingPrecision

	property alias headerModel: days.model
	property alias gridModel: repeater.model

	property alias title: heading.text
	property alias heading: heading
	property alias headingRow: headingRow
	property int headerFontPixelSize: Math.max(theme.smallestFont.pixelSize, Math.min(daysCalendar.cellHeight / 3, daysCalendar.cellWidth * 5/8))

	readonly property int stackMinSize: Math.min(stack.width, stack.height)
	// Take the calendar width, subtract the inner and outer spacings and divide by number of columns (==days in week)
	readonly property int cellWidth: Math.floor((stackMinSize - (daysCalendar.columns + 1) * monthView.borderWidth) / (daysCalendar.columns + (showWeekNumbers ? 1 : 0)))
	// Take the calendar height, subtract the inner spacings and divide by number of rows (monthView.weeks + one row for day names)
	readonly property int cellHeight:  Math.floor((stack.height - heading.height - headerGrid.height - calendarGrid.rows * monthView.borderWidth) / calendarGrid.rows)

	property real transformScale: 1
	property point transformOrigin: Qt.point(width / 2, height / 2)

	transform: Scale {
		xScale: daysCalendar.transformScale
		yScale: xScale
		origin.x: transformOrigin.x
		origin.y: transformOrigin.y
	}

	Behavior on scale {
		id: scaleBehavior
		ScaleAnimator {
			duration: units.longDuration
		}
	}

	Stack.onStatusChanged: {
		if (Stack.status === Stack.Inactive) {
			daysCalendar.transformScale = 1
			opacity = 1
		}
	}

	RowLayout {
		id: headingRow
		anchors {
			top: parent.top
			left: parent.left
			right: parent.right
		}
		spacing: units.smallSpacing

		PlasmaExtras.Heading {
			id: heading

			Layout.fillWidth: true

			level: 1
			wrapMode: Text.NoWrap
			elide: Text.ElideRight
			font.capitalization: Font.Capitalize
			//SEE QTBUG-58307
			//try to make all heights an even number, otherwise the layout engine gets confused
			Layout.preferredHeight: implicitHeight + implicitHeight%2

			MouseArea {
				id: monthMouse
				property int previousPixelDelta

				anchors.fill: parent
				onClicked: {
					if (!stack.busy) {
						daysCalendar.headerClicked()
					}
				}
				onExited: previousPixelDelta = 0
				onWheel: {
					var delta = wheel.angleDelta.y || wheel.angleDelta.x
					var pixelDelta = wheel.pixelDelta.y || wheel.pixelDelta.x

					// For high-precision touchpad scrolling, we get a wheel event for basically every slightest
					// finger movement. To prevent the view from suddenly ending up in the next century, we
					// cumulate all the pixel deltas until they're larger than the label and then only change
					// the month. Standard mouse wheel scrolling is unaffected since it's fine.
					if (pixelDelta) {
						if (Math.abs(previousPixelDelta) < monthMouse.height) {
							previousPixelDelta += pixelDelta
							return
						}
					}

					if (delta >= 15) {
						daysCalendar.previous()
					} else if (delta <= -15) {
						daysCalendar.next()
					}
					previousPixelDelta = 0
				}
			}
		}

		Components.ToolButton {
			id: previousButton
			iconName: "go-previous"
			onClicked: daysCalendar.previous()
			Accessible.name: tooltip
			//SEE QTBUG-58307
			Layout.preferredHeight: implicitHeight + implicitHeight%2
		}

		Components.ToolButton {
			iconName: "go-jump-today"
			onClicked: monthView.resetToToday()
			tooltip: i18ndc("libplasma5", "Reset calendar to today", "Today")
			Accessible.name: tooltip
			Accessible.description: i18nd("libplasma5", "Reset calendar to today")
			//SEE QTBUG-58307
			Layout.preferredHeight: implicitHeight + implicitHeight%2
		}

		Components.ToolButton {
			id: nextButton
			iconName: "go-next"
			onClicked: daysCalendar.next()
			Accessible.name: tooltip
			//SEE QTBUG-58307
			Layout.preferredHeight: implicitHeight + implicitHeight%2
		}
	}

	// Paints the inner grid and the outer frame
	Canvas {
		id: canvas

		anchors {
			horizontalCenter: parent.horizontalCenter
			bottom: parent.bottom
		}
		width: (daysCalendar.cellWidth + monthView.borderWidth) * gridColumns + monthView.borderWidth
		height: (daysCalendar.cellHeight + monthView.borderWidth) * calendarGrid.rows + monthView.borderWidth

		opacity: monthView.borderOpacity
		antialiasing: false
		clip: false
		onPaint: {
			var ctx = getContext("2d");
			// this is needed as otherwise the canvas seems to have some sort of
			// inner clip region which does not update on size changes
			ctx.reset();
			ctx.save();
			ctx.clearRect(0, 0, canvas.width, canvas.height);
			ctx.strokeStyle = theme.textColor;
			ctx.lineWidth = monthView.borderWidth
			ctx.globalAlpha = 1.0;

			ctx.beginPath();

			// When line is more wide than 1px, it is painted with 1px line at the actual coords
			// and then 1px lines are added first to the left of the middle then right (then left again)
			// So all the lines need to be offset a bit to have their middle point in the center
			// of the grid spacing rather than on the left most pixel, otherwise they will be painted
			// over the days grid which will be visible on eg. mouse hover
			var lineBasePoint = Math.floor(monthView.borderWidth / 2)

			// horizontal lines
			for (var i = 0; i < calendarGrid.rows + 1; i++) {
				var lineY = lineBasePoint + (daysCalendar.cellHeight + monthView.borderWidth) * (i);

				if (i == 0 || i == calendarGrid.rows) {
					ctx.moveTo(0, lineY);
				} else {
					ctx.moveTo(showWeekNumbers ? daysCalendar.cellWidth + monthView.borderWidth : monthView.borderWidth, lineY);
				}
				ctx.lineTo(width, lineY);
			}

			// vertical lines
			for (var i = 0; i < gridColumns + 1; i++) {
				var lineX = lineBasePoint + (daysCalendar.cellWidth + monthView.borderWidth) * (i);

				// Draw the outer vertical lines in full height so that it closes
				// the outer rectangle
				if (i == 0 || i == gridColumns || !daysCalendar.headerModel) {
					ctx.moveTo(lineX, 0);
				} else {
					ctx.moveTo(lineX, monthView.borderWidth + daysCalendar.cellHeight);
				}
				ctx.lineTo(lineX, height);
			}

			ctx.closePath();
			ctx.stroke();
			ctx.restore();
		}
	}

	PlasmaCore.Svg {
		id: calendarSvg
		imagePath: "widgets/calendar"
	}

	Component {
		id: themeBadgeComponent
		Item {
			id: themeBadge
			PlasmaCore.SvgItem {
				id: eventsMarker
				anchors.bottom: themeBadge.bottom
				anchors.right: themeBadge.right
				height: parent.height / 3
				width: height
				svg: calendarSvg
				elementId: "event"
			}
		}
	}

	Connections {
		target: theme
		onTextColorChanged: {
			canvas.requestPaint()
		}
	}

	Rectangle {
		anchors {
			left: calendarColumn.left
			leftMargin: daysCalendar.cellWidth - monthView.borderWidth
			top: calendarColumn.top
			bottom: calendarColumn.bottom
		}
		visible: showWeekNumbers
		width: monthView.borderWidth
		color: theme.textColor
		opacity: 0.15 // monthView.borderOpacity
	}

	Column {
		id: calendarColumn

		anchors {
			horizontalCenter: parent.horizontalCenter
			bottom: parent.bottom
			bottomMargin: monthView.borderWidth
		}

		Row {
			id: headerRow
			spacing: 0 // daysCalendar.borderWidth

			Components.Label {
				visible: showWeekNumbers
				width: daysCalendar.cellWidth
				height: paintedHeight
				text: i18nc("current week number heading", "CW")
				font.pointSize: -1
				font.pixelSize: daysCalendar.headerFontPixelSize
				opacity: 0.4
				horizontalAlignment: Text.AlignHCenter
				verticalAlignment: Text.AlignVCenter
				elide: Text.ElideRight
				fontSizeMode: Text.HorizontalFit
			}
		
			Grid {
				id: headerGrid

				columns: daysCalendar.columns
				rows: 1

				spacing: monthView.borderWidth

				Repeater {
					id: days

					Components.Label {
						width: daysCalendar.cellWidth
						height: paintedHeight
						text: Qt.locale().dayName((calendarBackend.firstDayOfWeek + index) % 7, Locale.ShortFormat)
						font.pointSize: -1
						font.pixelSize: daysCalendar.headerFontPixelSize
						opacity: 0.4
						horizontalAlignment: Text.AlignHCenter
						verticalAlignment: Text.AlignVCenter
						elide: Text.ElideRight
						fontSizeMode: Text.HorizontalFit
					}
				}
			}
		}

		Row {
			id: calendarRow
			spacing: 0 // daysCalendar.borderWidth

			Column {
				id: weeksColumn
				visible: showWeekNumbers

				spacing: monthView.borderWidth

				Repeater {
					model: showWeekNumbers ? calendarBackend.weeksModel : []

					Components.Label {
						height: daysCalendar.cellHeight
						width: daysCalendar.cellWidth
						horizontalAlignment: Text.AlignHCenter
						verticalAlignment: Text.AlignVCenter
						opacity: 0.4
						text: modelData
						font.pixelSize: Math.max(theme.smallestFont.pixelSize, Math.min(daysCalendar.cellHeight / 3, daysCalendar.cellWidth * 5/8))
						font.pointSize: -1 // Ignore pixelSize warning
					}
				}
			}

			Grid {
				id: calendarGrid

				columns: daysCalendar.columns
				rows: daysCalendar.rows // + (daysCalendar.headerModel ? 1 : 0)

				spacing: monthView.borderWidth
				property Item selectedItem
				property bool containsEventItems: false // FIXME
				property bool containsTodoItems: false // FIXME

				property QtObject selectedDate: monthView.date
				onSelectedDateChanged: {
					// clear the selection if the monthView.date is null
					if (calendarGrid.selectedDate == null) {
						calendarGrid.selectedItem = null;
					}
				}

				Repeater {
					id: repeater

					DayDelegate {
						id: delegate
						width: daysCalendar.cellWidth
						height: daysCalendar.cellHeight

						onClicked: daysCalendar.activated(index, model, delegate)
						onDoubleClicked: daysCalendar.doubleClicked(index, model, delegate)

						Connections {
							target: daysCalendar
							onActivateHighlightedItem: {
								if (delegate.containsMouse) {
									delegate.clicked(null)
								}
							}
						}
					}
				}
			}
		}
	}
}
