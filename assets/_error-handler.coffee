###*
 * Show info about errors
###
errorHandler = (err)->
	# get error line
	if err.stack and expr= /:(\d+):(\d+):/.exec err.stack
		line = parseInt expr[1]
		col = parseInt expr[2]
		code = err.code?.split("\n")[line-3 ... line + 3].join("\n")
	else
		code = line = col = '??'
	# Render
	table = new cliTable()
	table.push {Plugin: err.plugin || '-'},
		{Name: err.name || ''},
		{Filename: err.filename || err.fileName || ''},
		{Message: err.message|| ''},
		{Line: line},
		{Col: col}
	console.log """\x1b[41mError:\x1b[0m
	#{table.toString()}
	\x1b[41mStack:\x1b[0m
	┌─────────────────────────────────────────────────────────────────────────────────────────┐
	#{err.stack}
	└─────────────────────────────────────────────────────────────────────────────────────────┘
	\x1b[41mCode:\x1b[0m
	┌─────────────────────────────────────────────────────────────────────────────────────────┐
	#{code}
	└─────────────────────────────────────────────────────────────────────────────────────────┘
	"""
	return