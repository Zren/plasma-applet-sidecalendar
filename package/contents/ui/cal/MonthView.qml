/*
 * Copyright 2013  Heena Mahour <heena393@gmail.com>
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
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1

import org.kde.plasma.calendar 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

PinchArea {
	id: monthView

	property alias selectedMonth: calendarBackend.monthName
	property alias selectedYear: calendarBackend.year
	property alias displayedDate: calendarBackend.displayedDate
	property bool showTooltips: true
	property bool showTodaysDate: true

	property QtObject date
	property date currentDate

	property date showDate: new Date()

	property bool showBorders: true
	property bool showOutlines: true
	property int borderWidth: 1
	property real borderOpacity: showBorders ? 0.4 : 0

	property int columns: calendarBackend.days
	property int rows: calendarBackend.weeks

	property Item selectedItem
	property int week
	property int firstDay: new Date(showDate.getFullYear(), showDate.getMonth(), 1).getDay()

	readonly property int systemFirstDayOfWeek: Qt.locale().firstDayOfWeek
	property int firstDayOfWeek: systemFirstDayOfWeek
	property alias today: calendarBackend.today
	property bool showWeekNumbers: false

	property real cellRadius: 0.5
	property bool using24hClock: false

	property alias cellHeight: mainDaysCalendar.cellHeight
	// property QtObject daysModel: calendarBackend.daysModel
	property alias daysModel : daysModel

	signal dateSelected(date selectedDate)
	signal dayDoubleClicked(var dayData)

	property QtObject calendarBackend: calendarBackend

	// Size calculations
	readonly property int numCols: showWeekNumbers ? 8 : 7
	readonly property int numRows: 6
	readonly property int minCellSize: 22
	readonly property int prefCellSize: 44

	readonly property int _minimumWidth: Math.round(numCols * prefCellSize * units.devicePixelRatio)
	readonly property int _minimumHeight: Math.round(calendar.topAreaHeight + numRows * prefCellSize * units.devicePixelRatio)

	// implicitWidth: _minimumWidth
	// Layout.minimumWidth: implicitWidth
	// Layout.preferredWidth: implicitWidth
	// implicitHeight: _minimumHeight
	// Layout.minimumHeight: _minimumHeight
	// Layout.maximumHeight: Layout.minimumHeight

	onPinchStarted: stack.currentItem.transformOrigin = pinch.center
	onPinchUpdated: {
		var item = stack.currentItem
		if (stack.depth < 3 && pinch.scale < 1) {
			item.transformScale = pinch.scale
			item.opacity = pinch.scale
		} else if (stack.depth > 1 && pinch.scale > 1) {
			item.transformScale = pinch.scale
			item.opacity = (2 - pinch.scale / 2)
		}
	}
	onPinchFinished: {
		var item = stack.currentItem
		if (item.transformScale < 0.7) {
			item.headerClicked()
		} else if (item.transformScale > 1.4) {
			item.activateHighlightedItem()
		} else {
			item.transformScale = 1
			item.opacity = 1
		}
	}

	function isToday(date) {
		if (date.toDateString() == new Date().toDateString()) {
			return true
		}

		return false
	}

	function eventDate(yearNumber,monthNumber,dayNumber) {
		var d = new Date(yearNumber, monthNumber-1, dayNumber)
		return Qt.formatDate(d, "dddd dd MMM yyyy")
	}

	function setSelectedDate(d) {
		currentDate = d
		dateSelected(currentDate)
	}

	function resetToToday() {
		calendarBackend.resetToToday()
		setSelectedDate(calendarBackend.today)
		stack.pop(null)
	}

	// http://stackoverflow.com/questions/1184334/get-number-days-in-a-specified-month-using-javascript
	function daysInMonth(year, month) {
		return new Date(year, month+1, 0).getDate()
	}

	// Implement Calendar.updateData()
	// https://github.com/KDE/plasma-framework/blob/master/src/declarativeimports/calendar/calendar.cpp#L215
	function updateMonthOverview() {
		var date = calendarBackend.displayedDate
		var day = date.getDate()
		var month = date.getMonth() // 0-11
		var year = date.getFullYear()
		// console.log('displayedDate', date)
		// console.log(day, month+1, year)

		daysModel.clear()
		var totalDays = calendarBackend.days * calendarBackend.weeks
		var daysBeforeCurrentMonth = 0
		var daysAfterCurrentMonth = 0
		var firstDay = new Date(year, month, 1)
		var firstDayOfWeek = firstDay.getDay() == 0 ? 7 : firstDay.getDay()
		if (calendarBackend.firstDayOfWeek < firstDayOfWeek) {
			daysBeforeCurrentMonth = firstDayOfWeek - calendarBackend.firstDayOfWeek
		} else {
			daysBeforeCurrentMonth = calendarBackend.days - (calendarBackend.firstDayOfWeek - firstDayOfWeek)
		}

		var daysInCurrentMonth = daysInMonth(year, month)
		var daysThusFar = daysBeforeCurrentMonth + daysInCurrentMonth
		if (daysThusFar < totalDays) {
			daysAfterCurrentMonth = totalDays - daysThusFar
		}
		// console.log(daysBeforeCurrentMonth, daysInCurrentMonth, daysAfterCurrentMonth)
		// console.log(totalDays, daysThusFar)

		if (daysBeforeCurrentMonth > 0) {
			var previousMonth = new Date(year, month-1, 1)
			var daysInPreviousMonth = daysInMonth(year, month-1)
			for (var i = 0; i < daysBeforeCurrentMonth; i++) {
				var dayData = {}
				dayData.isCurrent = false
				dayData.dayNumber = daysInPreviousMonth - (daysBeforeCurrentMonth - (i + 1))
				dayData.monthNumber = previousMonth.getMonth() + 1
				dayData.yearNumber = previousMonth.getFullYear()
				dayData.showEventBadge = false
				dayData.events = []
				daysModel.append(dayData)
			}
		}

		for (var i = 0; i < daysInCurrentMonth; i++) {
			var dayData = {}
			dayData.isCurrent = true
			dayData.dayNumber = i + 1
			dayData.monthNumber = month + 1
			dayData.yearNumber = year
			dayData.showEventBadge = false
			dayData.events = []
			daysModel.append(dayData)
		}

		if (daysAfterCurrentMonth > 0) {
			var nextMonth = new Date(year, month+1, 1)
			for (var i = 0; i < daysAfterCurrentMonth; i++) {
				var dayData = {}
				dayData.isCurrent = false
				dayData.dayNumber = i + 1
				dayData.monthNumber = nextMonth.getMonth() + 1
				dayData.yearNumber = nextMonth.getFullYear()
				dayData.showEventBadge = false
				dayData.events = []
				daysModel.append(dayData)
			}
		}
	}

	function updateYearOverview() {
		var date = calendarBackend.displayedDate
		var day = date.getDate()
		var year = date.getFullYear()

		for (var i = 0, j = monthModel.count; i < j; ++i) {
			monthModel.setProperty(i, "yearNumber", year)
		}
	}

	function updateDecadeOverview() {
		var date = calendarBackend.displayedDate
		var day = date.getDate()
		var month = date.getMonth() + 1
		var year = date.getFullYear()
		var decade = year - year % 10

		for (var i = 0, j = yearModel.count; i < j; ++i) {
			var label = decade - 1 + i
			yearModel.setProperty(i, "yearNumber", label)
			yearModel.setProperty(i, "label", label)
		}
	}


	// https://github.com/KDE/plasma-framework/blob/master/src/declarativeimports/calendar/calendar.cpp
	Calendar {
		id: calendarBackend

		days: 7
		weeks: 6
		firstDayOfWeek: monthView.firstDayOfWeek

		Component.onCompleted: {
			// daysModel.setPluginsManager(EventPluginsManager)

			// Bind after configuration is loaded to prevent calling updateMonthOverview a 3rd time.
			calendarBackend.firstDayOfWeekChanged.connect(function(){
				updateMonthOverview()
				// TODO: Note, this resets the MonthView event badges, the user needs to manually update.
			})
		}

		onTodayChanged: {
			displayedDate = today
		}

		onDisplayedDateChanged: {
			updateMonthOverview()
		}

		onYearChanged: {
			updateMonthOverview()
			updateYearOverview()
			updateDecadeOverview()
		}
	}

	ListModel {
		id: daysModel
		dynamicRoles: true

		Component.onCompleted: {
			updateMonthOverview()
		}
	}

	function firstDisplayedDate() {
		var day = daysModel.get(0)
		if (!day) return null
		return new Date(day.yearNumber, day.monthNumber-1, day.dayNumber)
	}

	function lastDisplayedDate() {
		var day = daysModel.get(daysModel.count - 1)
		if (!day) return null
		return new Date(day.yearNumber, day.monthNumber-1, day.dayNumber)
	}

	ListModel {
		id: monthModel

		Component.onCompleted: {
			for (var i = 0; i < 12; ++i) {
				append({
					label: Qt.locale().standaloneMonthName(i, Locale.LongFormat),
					monthNumber: i + 1,
					isCurrent: true
				})
			}
			updateYearOverview()
		}
	}

	ListModel {
		id: yearModel

		Component.onCompleted: {
			for (var i = 0; i < 12; ++i) {
				append({
					isCurrent: (i > 0 && i < 11) // first and last year are outside the decade
				})
			}
			updateDecadeOverview()
		}
	}

	function even(x) {
		var y = Math.round(x)
		return y + y%2
	}

	readonly property int row1Height: Math.ceil(stack.currentItem.heading.font.pixelSize)
	readonly property int row2Height: prefCellSize/3 // Math.ceil(stack.currentItem.headerFontPixelSize)
	readonly property int topAreaHeight: row1Height + row2Height

	StackView {
		id: stack

		anchors.fill: parent

		delegate: StackViewDelegate {
			pushTransition: StackViewTransition {
				NumberAnimation {
					target: exitItem
					duration: units.longDuration
					property: "opacity"
					from: 1
					to: 0
				}
				NumberAnimation {
					target: enterItem
					duration: units.longDuration
					property: "opacity"
					from: 0
					to: 1
				}
				NumberAnimation {
					target: enterItem
					duration: units.longDuration
					property: "transformScale"
					from: 1.5
					to: 1
				}
			}
			popTransition: StackViewTransition {
				NumberAnimation {
					target: exitItem
					duration: units.longDuration
					property: "opacity"
					from: 1
					to: 0
				}
				NumberAnimation {
					target: exitItem
					duration: units.longDuration
					property: "transformScale"
					// so no matter how much you scaled, it would still fly towards you
					to: exitItem.transformScale * 1.5
				}
				NumberAnimation {
					target: enterItem
					duration: units.longDuration
					property: "opacity"
					from: 0
					to: 1
				}
			}
		}

		initialItem: DaysCalendar {
			id: mainDaysCalendar
			// title: {
			// 	var dateFormat, text
			// 	if (calendarBackend.displayedDate.getFullYear() == today.getFullYear()) {
			// 		if (showTodaysDate && calendarBackend.displayedDate.getMonth() == today.getMonth()) {
			// 			dateFormat = i18nc("calendar title format for current month", "MMMM d, yyyy")
			// 			text = Qt.formatDateTime(today, dateFormat)
			// 			return text
			// 		} else {
			// 			dateFormat = i18nc("calendar title format for other months of current year", "MMMM")
			// 		}
			// 	} else {
			// 		dateFormat = i18nc("calendar title format for months not from current year", "MMMM, yyyy")
			// 	}
			// 	text = Qt.formatDateTime(calendarBackend.displayedDate, dateFormat)
			// 	return text
			// }
			title: {
				var dateFormat = 'MMMM \'<font color="' + theme.highlightColor + '">\' yyyy\'</font>\''
				return Qt.formatDateTime(calendarBackend.displayedDate, dateFormat)
			}
			heading.font.weight: Font.Bold

			columns: calendarBackend.days
			rows: calendarBackend.weeks

			showWeekNumbers: monthView.showWeekNumbers
			eventBadgeType: monthView.eventBadgeType
			todayStyle: monthView.todayStyle
			cellRadius: monthView.showBorders ? 0 : monthView.cellRadius

			headerModel: calendarBackend.days
			// gridModel: calendarBackend.daysModel
			gridModel: daysModel

			dateMatchingPrecision: Calendar.MatchYearMonthAndDay

			previousLabel: i18nd("libplasma5", "Previous Month")
			nextLabel: i18nd("libplasma5", "Next Month")

			onPrevious: calendarBackend.previousMonth()
			onNext: calendarBackend.nextMonth()
			onHeaderClicked:  {
				stack.push(yearOverview)
			}
			onActivated: {
				var rowNumber = Math.floor(index / columns)
				week = 1 + calendarBackend.weeksModel[rowNumber]
				monthView.date = date
				monthView.setSelectedDate(new Date(date.yearNumber, date.monthNumber - 1, date.dayNumber))
			}
			onDoubleClicked: {
				monthView.dayDoubleClicked(date)
			}
		}
	}

	Component {
		id: yearOverview

		DaysCalendar {
			title: calendarBackend.displayedDate.getFullYear()
			columns: 3
			rows: 4

			dateMatchingPrecision: Calendar.MatchYearAndMonth

			cellRadius: monthView.showBorders ? 0 : 0.15

			gridModel: monthModel

			previousLabel: i18nd("libplasma5", "Previous Year")
			nextLabel: i18nd("libplasma5", "Next Year")


			onPrevious: calendarBackend.previousYear()
			onNext: calendarBackend.nextYear()
			onHeaderClicked: {
				updateDecadeOverview()
				stack.push(decadeOverview)
			}
			onActivated: {
				calendarBackend.goToMonth(date.monthNumber)
				stack.pop()
			}
		}
	}

	Component {
		id: decadeOverview

		DaysCalendar {
			readonly property int decade: {
				var year = calendarBackend.displayedDate.getFullYear()
				return year - year % 10
			}

			title: decade + " – " + (decade + 9)
			columns: 3
			rows: 4

			dateMatchingPrecision: Calendar.MatchYear

			cellRadius: monthView.showBorders ? 0 : 0.15

			gridModel: yearModel

			previousLabel: i18nd("libplasma5", "Previous Decade")
			nextLabel: i18nd("libplasma5", "Next Decade")

			onPrevious: calendarBackend.previousDecade()
			onNext: calendarBackend.nextDecade()
			onActivated: {
				calendarBackend.goToYear(date.yearNumber)
				stack.pop()
			}
		}
	}

	Component.onCompleted: {
		setSelectedDate(calendarBackend.today)
	}

}
