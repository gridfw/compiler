###*
 * @private
 * Gridfw general settings
 * We use an array to map settings for performance purpose
 * This includes only kies
 * The check and values are available in each module
 * "count" is a reserved keyword
###

GFW_SETTINGS_ARR = [
	###*
	 * GRIDFW CORE
	###
	'mode' # app mode
	'name' # app name
	'author' # the app author
	'email' # the app admin or webmaster email
	# listening
	'port'
	'protocol'
	'path'
	# milicious
	'logLevel'
]

# check all keys are not the same
for v, k in GFW_SETTINGS_ARR
	if v in ['count']
		throw new Error "Use of reserved keyword: #{v}"
	else if GFW_SETTINGS_ARR.indexOf(v) isnt k
		throw new Error "Dupplicated setting key: #{v}"

# create map
gfwSettings = _create null,
	count: value: GFW_SETTINGS_ARR.length
for v, k in GFW_SETTINGS_ARR
	settings[v] = k

###*
 * set checkers and default values
 * @example
 * settingsInit = <%= initSettings %> app,
 * 		mode:
 * 			default: 'dev'
 * 			check: (value) -> value
###
initSettings = """
((settings)->
	mapper = #{JSON.serialize gfwSettings}
	# check settings
	for k,v of settings
		throw new Error "Key required: \#{k}" unless k of mapper
		v.i= mapper[k] # index of this key
	mapper = null

	# return setter function
	(app, options)->
		s = app.s
		# set default values
		for k,v of settings
			s[v.i] = v.default
		# set option
		unless option
		else if typeof option is 'object'
			for k,v of options
				op = settings[k]
				throw new Error "Unknown option: \#{k}" unless op
				# check option
				v = op.check v
				# set as value
				s[op.i] = v
		else
			throw new Error "Illegal arguments"
		return
)
"""

