cliTable		= require 'cli-table'
Template		= require 'gulp-template' # compile some consts into digits

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
