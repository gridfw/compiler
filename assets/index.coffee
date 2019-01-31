cliTable	= require 'cli-table'
Template	= require 'gulp-template' # compile some consts into digits

# view engines
Pug= require 'pug'
# GULP
Through2	= require 'through2'
Path		= require 'path'

#=include _utils.coffee

# error handling
#=include _error-handler.coffee
exports.logError = errorHandler

# Settings
#=include _settings.coffee
exports.initSettings = initSettings
exports.settings = gfwSettings

# TEMPLATE
exports.template = (data)->
	data ?= {}
	data.settings = gfwSettings
	data.initSettings = initSettings
	data.DEFAULT_ENCODING = 'utf8'
	return Template data

###*
 * compile views
 * @optional @param  {Object} settings.engines - map of used engines
###
#=include _views.coffee
exports.views = _compileViews

