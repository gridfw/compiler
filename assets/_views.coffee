###*
 * Compile views
###
EJS = require 'ejs'
_DEFAULT_VIEW_SETTINGS = 
	# engines
	engines:
		# PUG
		pug: (content, options) ->
			content = Pug.compileClient content,
				pretty: options.pretty
				filename: options.filename
			# add exports
			content + "\nmodule.exports=template"
		# EJS
		ejs: (content, options)->
			# compile content
			content = EJS.compile content,
				pretty: options.pretty
				filename: options.filename
				client: true # render client function
			# export data
			"module.exports =" + content.toString()

_compileViews = (settings)->
	# init settings
	if settings
		throw new Error 'Compile-views>> Illegal settings' unless (typeof settings is 'object') and settings
		Object.setPrototypeOf settings, _DEFAULT_VIEW_SETTINGS
	else
		settings = _DEFAULT_VIEW_SETTINGS
	engines = settings.engines
	pretty = settings.pretty or false
	# return compile function
	return Through2.obj (file, enc, cb)->
		err = null
		try
			# check file
			throw new Error "Compile-views>> Stream not supported: #{file.path}" if file.isStream()
			return cb null unless file.isBuffer()
			filePath = file.path
			engine = engines[Path.extname(filePath).substr 1]
			throw new Error "Compile-views>> Unsupported file: #{file.path}" unless engine
			# compile
			content = file.contents.toString 'utf8'
			content = engine content,
				pretty: pretty
				filename: filePath
			# save
			file.contents = new Buffer content, 'utf8'
			# file ext
			i = filePath.lastIndexOf '.'
			throw new Error 'Could not found "."' if i is -1
			file.path = filePath.substr(0, i) + '.js'
		catch e
			err = e
		cb err, file
