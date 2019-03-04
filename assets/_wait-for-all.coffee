###*
 * Wait for all streams to finish
###
_waitForAll= ->
	files = []
	_prp= (file, enc,cb)->
		files.push file
		do cb
		return
	_acc= (cb)->
		@push file for file in files
		do cb
		return
	Through2.obj _prp, _acc