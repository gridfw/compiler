cliTable	= require 'cli-table'
Template	= require 'gulp-template' # compile some consts into digits

# view engines
Pug= require 'pug'
# GULP
Through2	= require 'through2'
Path		= require 'path'
Terser	= require 'terser'
Glob = require 'glob'
GlobBase= require 'glob-base'
Fs= require 'fs'
Lodash = require 'lodash'
Vinyl = require 'vinyl'
PluginError= require 'plugin-error'

plugName= 'gridfw-compiler'

#=include _utils.coffee

# error handling
#=include _error-handler.coffee
exports.logError = errorHandler

# Settings
initSettings= null
gfwSettings= null
do ->
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
do ->
	#=include _views.coffee


###*
 * Compile i18n files
###
do ->
	#=include _i18n-compile.coffee
	exports.i18n= i18nCompile

# wait for gulp.dest to finish
do ->
	#=include _wait-for-all.coffee
	exports.waitForAll= _waitForAll