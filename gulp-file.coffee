gulp			= require 'gulp'
gutil			= require 'gulp-util'
# minify		= require 'gulp-minify'
include			= require "gulp-include"
uglify			= require('gulp-uglify-es').default
rename			= require "gulp-rename"
coffeescript	= require 'gulp-coffeescript'

try
	GfwCompiler		= require 'gridfw-compiler'
catch e
	GfwCompiler		= require '../gridfw/node_modules/gridfw-compiler'

#=include assets/_error-handler.coffee
settings = 
	isProd: gutil.env.hasOwnProperty('prod')
# compile final values (consts to be remplaced at compile time)
# handlers
compileCoffee = ->
	glp = gulp.src 'assets/**/[!_]*.coffee', nodir: true
		# include related files
		.pipe include hardFail: true
		# template
		.pipe GfwCompiler.template().on 'error', GfwCompiler.logError
		# convert to js
		.pipe coffeescript(bare: true).on 'error', GfwCompiler.logError
	# uglify when prod mode
	if settings.isProd
		glp = glp.pipe uglify()
	# save 
	glp.pipe gulp.dest 'build'
		.on 'error', GfwCompiler.logError
# watch files
watch = (cb)->
	unless settings.isProd
		gulp.watch ['assets/**/*.coffee'], compileCoffee
	cb()
	return

# default task
gulp.task 'default', gulp.series compileCoffee, watch