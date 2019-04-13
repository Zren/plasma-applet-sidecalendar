.pragma library

function isSameDate(a, b) {
	return a.getFullYear() == b.getFullYear() && a.getMonth() == b.getMonth() && a.getDate() == b.getDate()
}
function isDateEarlier(a, b) {
	var c = new Date(b.getFullYear(), b.getMonth(), b.getDate()) // midnight of date b
	return a < c;
}
function isDateAfter(a, b) {
	var c = new Date(b.getFullYear(), b.getMonth(), b.getDate() + 1) // midnight of next day after b
	return a >= c
}
