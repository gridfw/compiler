###*
 * @private
 * Gridfw general settings
 * We use an array to map settings for performance purpose
 * This includes only kies
 * The check and values are available in each module
 * "count" is a reserved keyword
 * <!> Append only is supported, otherwise you will need to recompile all modules
###

GFW_SETTINGS_ARR = [
	###*
	 * GRIDFW CORE
	###
	'mode' # app mode
	'name' # app name
	'author' # the app author
	'email' # the app admin or webmaster email
	'enableDefaultPlugins' # enable or disable default plugins when not overrided
	# LOG
	'logLevel'
	# listening
	'port'
	'protocol'
	# PROXY
	'baseURL'
	'trustProxy'
	# ROUTER
	'trailingSlash'
	'routeIgnoreCase'
	'_router1' # reserved for future use
	'_router2' # reserved for future use
	'_router3' # reserved for future use
	# Errors
	'errors'
	# reserved for future use
	'jsCacheMaxSize'
	'jsCacheMaxSteps'
	'_core2'
	'_core3'
	'_core4'
	'_core5'
	'_core6'
	'_core7'
	'_core8'
	'_core9'
	# send data
	'pretty'
	'etag'
	'jsonp'
	'acceptRanges'
	# upload
	'timeout'
	'limits'
	'tmpDir' # tmp upload dir
	# views
	'views'
]

# check all keys are not the same
for v, k in GFW_SETTINGS_ARR
	if v in ['count', 'toJSON']
		throw new Error "Use of reserved keyword: #{v}"
	else if GFW_SETTINGS_ARR.indexOf(v) isnt k
		throw new Error "Dupplicated setting key: #{v}"

# create map
gfwSettings = _create null,
	count: value: GFW_SETTINGS_ARR.length
for v, k in GFW_SETTINGS_ARR
	gfwSettings[v] = k
# toJSON
gfwSettings.toJSON = -> Object.assign {}, gfwSettings
# detect inavailable settings
Object.setPrototypeOf gfwSettings, new Proxy {},
	get: (obj, prop)->
		if typeof prop is 'string'
			throw new Error "Unknown setting: #{prop}"
		else # Symbol
			return undefined
	set: (obj, prop, vl)-> throw new Error "Could not set: #{prop.toString()}"
###*
 * set checkers and default values
 * @example
 * settingsInit = <%= initSettings %>
 * 		mode:
 * 			default: 'dev'
 * 			check: (value) -> value
###
initSettings = """
((settings)->
	mapper = #{JSON.stringify gfwSettings}
	# check settings
	for k,v of settings
		throw new Error "Key required: \#{k}" unless k of mapper
		throw new Error "Missing: settings.\#{k}.default" unless 'default' of v
		throw new Error "Expected function: settings.\#{k}.check" unless typeof v.check is 'function'
		v.i= mapper[k] # index of this key
	mapper = null

	# return setter function
	(app, options)->
		s = app.s
		# set default values
		for k,v of settings
			s[v.i] = v.default
		# set options
		unless options
		else if typeof options is 'object'
			for k,v of options
				op = settings[k]
				if op
					try
						# check options
						v = (op.check v) or v
						# set as value
						s[op.i] = v
					catch err
						err = err.message if err instanceof Error
						throw new Error "settings.\#{k}>> \#{err}"
					
				else if k not in ['require', 'plugins']
					throw new Error "Unknown option: \#{k}"
		else
			throw new Error "Illegal arguments"
		return
)
"""

