###
UTILS
###

_create = Object.create
_defineProperty = Object.defineProperty
_defineProperties = Object.defineProperties


_isEmpty = (obj)->
	for k of obj
		return false
	true