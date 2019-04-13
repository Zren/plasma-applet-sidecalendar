import QtQuick 2.0

import "./lib"

QtObject {
	id: agendaModel

	function deltaDateTime(days, h, m) {
		var dt = new Date()
		dt.setDate(dt.getDate() + days)
		if (typeof h !== "undefined") { dt.setHours(h) } else { dt.setHours(0) }
		if (typeof m !== "undefined") { dt.setMinutes(m) } else { dt.setMinutes(0) }
		dt.setSeconds(0)
		return dt
	}

	function event(args) {
		if (typeof args.isAllDay === "undefined") args.isAllDay = false;
		return args
	}
	function task(args) {
		return args
	}

	property var calendarList: ({
		personal: {
			name: 'Personal',
			backgroundColor: "#1b9efb",
		},
		work: {
			name: 'Work',
			backgroundColor: "#56d72b",
		},
		family: {
			name: 'Family',
			backgroundColor: "#fec505",
		},
		friends: {
			name: 'Friends',
			backgroundColor: "#cb70e0",
		},
	})

	property var defaultData: [
		{
			dateTime: deltaDateTime(0),
			events: [
				event({
					summary: 'Lunch with Eric',
					startDateTime: deltaDateTime(0, 11, 30),
					endDateTime: deltaDateTime(0, 12, 30),
					calendar: calendarList.work,
				}),
				event({
					summary: 'Dentist',
					startDateTime: deltaDateTime(0, 15, 0),
					endDateTime: deltaDateTime(0, 16, 0),
					calendar: calendarList.family,
				}),
				event({
					summary: 'Tennis lessons',
					startDateTime: deltaDateTime(0, 18, 0),
					endDateTime: deltaDateTime(0, 19, 30),
					calendar: calendarList.personal,
				}),
			]
		},
		{
			dateTime: deltaDateTime(1),
			events: [
				event({
					summary: 'Site proofreading',
					startDateTime: deltaDateTime(1),
					endDateTime: deltaDateTime(2),
					isAllDay: true,
					calendar: calendarList.work,
				}),
				event({
					summary: 'Take out the trash',
					startDateTime: deltaDateTime(1, 6, 30),
					endDateTime: deltaDateTime(1, 7, 0),
					isTask: true,
					isCompleted: true,
					calendar: calendarList.personal,
				}),
				event({
					summary: 'Pizza party',
					startDateTime: deltaDateTime(1, 12, 30),
					endDateTime: deltaDateTime(1, 13, 30),
					calendar: calendarList.work,
				}),
				task({
					summary: 'Book hotel',
					// startDateTime: deltaDateTime(1, 18, 0),
					endDateTime: deltaDateTime(1, 18, 0),
					isTask: true,
					isCompleted: false,
					calendar: calendarList.personal,
				}),
				task({
					summary: 'Exercise',
					// startDateTime: deltaDateTime(1, 18, 0),
					endDateTime: deltaDateTime(1, 18, 0),
					isTask: true,
					isCompleted: true,
					calendar: calendarList.personal,
				}),
			]
		},
		{
			dateTime: deltaDateTime(2),
			events: [
				event({
					summary: 'Food drive',
					startDateTime: deltaDateTime(2),
					endDateTime: deltaDateTime(3),
					isAllDay: true,
					calendar: calendarList.work,
				}),
				event({
					summary: 'Office BBQ',
					startDateTime: deltaDateTime(2, 17, 0),
					endDateTime: deltaDateTime(2, 18, 0),
					calendar: calendarList.work,
				}),
				event({
					summary: 'Concert',
					startDateTime: deltaDateTime(2, 19, 30),
					endDateTime: deltaDateTime(2, 22, 0),
					calendar: calendarList.friends,
				}),
			]
		},
	]
	property var data: defaultData


	property var execUtil: ExecUtil { id: execUtil }

	function parseDateTime(obj, key) {
		obj[key] = new Date(obj[key])
	}

	function evcal(args, callback) {
		var cmd = [
			'python3',
			'/home/chris/Code/plasma-applets/[misc]/eventcalendar2/evcal.py'
		]
		cmd = cmd.concat(args)
		cmd = cmd.join(' ')
		execUtil.exec(cmd, callback)
	}

	function fetchAgenda(start, end, callback) {
		var args = [
			'agenda',
			'--start=' + start,
			'--end=' + end,
		]
		evcal(args, callback)
	}

	function updateModel() {
		var start = '2019-03-01'
		var end = '2019-03-31'
		fetchAgenda(start, end, function(cmd, exitCode, exitStatus, stdout, stderr){
			// console.log(cmd, exitCode, exitStatus, stdout, stderr)
			// console.log(stdout)
			var data = JSON.parse(stdout)
			data.forEach(function(agendaItem){
				parseDateTime(agendaItem, 'dateTime')
				// console.log(JSON.stringify(agendaItem, null, '\t'))
				agendaItem.events.forEach(function(event){
					parseDateTime(event, 'startDateTime')
					parseDateTime(event, 'endDateTime')
				})
			})
			// console.log(JSON.stringify(data, null, '\t'))

			data = [].concat(defaultData, data)
			agendaModel.data = data

		})
	}

	Component.onCompleted: {
		updateModel()
	}
}
