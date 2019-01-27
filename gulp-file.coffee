gulp			= require 'gulp'
gutil			= require 'gulp-util'
# minify		= require 'gulp-minify'
include			= require "gulp-include"
uglify			= require('gulp-uglify-es').default
rename			= require "gulp-rename"
coffeescript	= require 'gulp-coffeescript'
PluginError		= gulp.PluginError
cliTable		= require 'cli-table'

#=include assets/_error-handler.coffee

# compile final values (consts to be remplaced at compile time)
# handlers
compileCoffee = ->
	glp = gulp.src 'assets/**/[!_]*.coffee', nodir: true
		# include related files
		.pipe include hardFail: true
		# convert to js
		.pipe coffeescript(bare: true).on 'error', errorHandler
	# uglify when prod mode
	if gutil.env.mode is 'prod'
		glp = glp.pipe uglify()
	# save 
	glp.pipe gulp.dest 'build'
		.on 'error', errorHandler
# watch files
watch = ->
	gulp.watch ['assets/**/*.coffee'], compileCoffee
	return

# default task
if gutil.env.mode is 'prod'
	gulp.task 'default', gulp.series compileCoffee
else
	gulp.task 'default', gulp.series compileCoffee, watch