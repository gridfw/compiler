
###*
 * Normalize i18n object
 * @input { key: 'value1', key2:{fr: 'value', 'en': 'value'} }
 * @output { en: {key:'value1', key2: 'value'}, fr: {key: 'value1', key2: 'value'} }
###
I18N_SYMBOL = Symbol 'i18n module'

# normalize i18n
_normalize = (data)->
	throw new Error "Normalize: Illegal input" unless typeof data is 'object' and data

	# look for all used locals
	usedLocals = []
	result = Object.create null
	for k,v of data
		if typeof v is 'object'
			throw new Error "Normalize: Illegal value at: #{k}" unless v
			# add language
			unless I18N_SYMBOL of v
				for lg of v
					unless lg in usedLocals
						usedLocals.push lg
						result[lg] = Object.create null
	throw new Error "Unless one key with all used languages mast be specified!" if usedLocals.length is 0
	# normalize
	requiredLocalMsgs = Object.create null
	for k,v of data
		# general value
		if typeof v is 'string'
			result[lg][k] = v for lg in usedLocals
		# object
		else if typeof v is 'object'
			# general value
			if I18N_SYMBOL of v
				result[lg][k] = v for lg in usedLocals
			# locals
			else
				for lg in usedLocals
					if lg of v
						result[lg][k] = v[lg]
					else
						(requiredLocalMsgs[k] ?= []).push lg
		else
			throw new Error "Normalize:: Illegal type at: #{k}"
	# throw required languages on fields
	for k in requiredLocalMsgs
		throw new Error "Required locals:\n #{JSON.stringify requiredLocalMsgs, null, "\t"}"
	# return result
	result


###*
 * This contains methods used inside i18n source locals
###
i18n = 
	switch: (attr, cases)->
		throw new Error "Illegal switch arg" unless typeof attr is 'string' or Array.isArray(attr) and attr.every (el)-> typeof el is 'string'
		throw new Error "Illegal switch cases" unless typeof cases is 'object' and cases
		throw new Error '"else" options is required on switch cases' unless 'else' of cases
		# convert attr into path
		attr = attr.split '.' if typeof attr is 'string'
		# return
		[I18N_SYMBOL]: 'switch'
		m: 'switch'
		s: attr # switch attribute or path
		c: cases # cases

	###*
	 * Compile expression (module or pug)
	###
	compile: (expr)->
		throw new Error 'Illegal arguments' if arguments.length isnt 1
		if typeof expr is 'object'
			throw new Error "Illegal module" unless typeof expr.m is 'string'
			fx= _i18nCompileModules[expr.m]
			throw new Error "Unknown module: #{expr.m}" unless fx
			expr = fx expr
		else if typeof expr is 'string'
			expr = _compileStr expr
		else 
			throw new Error "Unsupported expression"
		return expr

###*
 * Compile strings
 * @return {String | function} - compiled string or function compiler (case of arguments)
###
_compileStr = (expr)->
	expr = '|' + expr.replace /\n/g, "\n|"
	if /[#!]\{/.test expr
		expr = Pug.compileClient expr,
			# self:on
			compileDebug: off
			globals: ['i18n']
			inlineRuntimeFunctions: false
			name: 'ts'
		# uglify and remove unused vars
		mnfy = Terser.minify expr
		throw mnfy if mnfy.error
		expr = mnfy.code
		expr = expr.replace /^function ts/, 'function '
	else
		expr = JSON.stringify Pug.render expr
	return expr
###*
 * Compile modules
###
_i18nCompileModules=
	###
	{
		s: ['path'] # switch path
		c: {} # cases
	}
	###
	switch: (obj)->
		# compile
		cases= []
		for k,v of obj.c
			cases.push "#{JSON.stringify k}:#{_compileStr v}"
		# options
		fx= ["(function(){var c= {#{cases.join ','}};"]
		# local function
		fx.push 'return function(l){'
		# get attribute to switch
		fx.push 'var sw;try{sw = l'
		for v,k in obj.s # attr to get
			if /^[a-zA-Z_][a-zA-Z0-9_]+$/i.test v
				fx.push '.', v
			else
				fx.push "[#{JSON.stringify v}]"
		fx.push ';sw=c[sw] || c.else;'
		fx.push ';}catch(err){sw=c.else}'
		# return value
		fx.push "if(typeof sw === 'function') return sw(l);"
		fx.push "else return sw;"
		# end fx
		fx.push "}"
		fx.push '})()'
		# return
		# compile
		return fx.join ''

###*
 * Convert i18n to JS files
###
_convertDataToJSONFiles=(data, cwd)->
	# separate into multiple locals
	for k,v of data
		new Vinyl
			cwd: cwd
			path: k + '.json'
			contents: Buffer.from JSON.stringify v

_convertDataToJSFiles= (data, cwd, browserFx)->
	# separate into multiple locals
	for k,v of data
		content = []
		for a,b of v
			content.push "#{JSON.stringify a}:#{(i18n.compile b).toString()}"
		# create table for fast access
		if browserFx
			content = "#{browserFx}= {#{content.join ','}};"
		else
			content = "module.exports= {#{content.join ','}};"
		# content = """
		# var msgs= exports.messages= {#{content.join ','}};
		# var arr= exports.arr= [];
		# var map= exports.map= Object.create(null);
		# var i=0, k;
		# for(k in msgs){ arr.push(msgs[k]); map[k] = i++; }
		# """
		# create file
		new Vinyl
			cwd: cwd
			path: k + '.js'
			contents: Buffer.from content
# convert inside views
_convertToViews= (data, options, cwd)->
	globbasePath= options.base or GlobBase(options.views).base
	opData= options.data || {}
	# resolve views
	LTemptate = Lodash.template
	results = []
	for filePath in Glob.sync options.views, nodir:on
		# load file data
		content = Fs.readFileSync filePath, encoding: 'utf8'
		tpl= LTemptate content # template
		# file relative path
		fileRelPath= Path.relative globbasePath, filePath
		# translate
		for k,v of data
			results.push new Vinyl
				cwd: globbasePath
				path: Path.join globbasePath, k, fileRelPath #, Path.basename filePath
				contents: Buffer.from tpl {i18n: v , ...opData, htmlBaseURL: opData.baseURL.concat(k, '/')}
	results

###*
 * Compile i18n files
 * @param {[type]} options.switch - 
###
i18nCompile = (options)->
	bufferedI18n = _create null
	# options
	options ?= _create null
	toJson = options.json is true
	browserFx= options.browser or false
	cwd  = null
	# compile each file
	bufferContents = (file, end, cb)->
		# ignore incorrect files
		return cb() if file.isNull()
		return cb new Error "i18n-compiler>> Streaming isn't supported" if file.isStream()
		# process
		err = null
		try
			# compile file and buffer data
			Object.assign bufferedI18n, eval file.contents.toString 'utf8'
			# base dir
			cwd= file._cwd
		catch e
			err = new PluginError plugName, e
		cb err
		return
	# concat all files
	concatAll = (cb)->
		err= null
		languages= []
		try
			# base path
			cwd= options.base or cwd
			# check file not empty
			unless _isEmpty bufferedI18n
				# normalize 18n: convert into separated locals
				data = _normalize bufferedI18n
				# reserved attributes
				for k,v of data
					v.local = k
					if v.lang
						languages.push
							local: k
							title: v.lang
				# sort languages
				languages= languages.sort (a, b)-> a.local.localeCompare b.local
				# replace inside views
				if 'views' of options
					files= _convertToViews data, options, cwd
				# compile to json files
				else if toJson
					files= _convertDataToJSONFiles data, cwd
					# add mapper file
					if languages.length
						files.push new Vinyl
							cwd: cwd
							path: 'mapper.json'
							contents: Buffer.from JSON.stringify locals: languages
				# compile to JS files
				else
					files= _convertDataToJSFiles data, cwd, browserFx
					# add mapper file
					if languages.length
						files.push new Vinyl
							cwd: cwd
							path: 'mapper.js'
							contents: Buffer.from 'module.exports=' + JSON.stringify locals: languages
				# push files
				for file in files
					@push file
		catch e
			err = new PluginError plugName, e
		cb err
		return
	# return
	Through2.obj bufferContents, concatAll