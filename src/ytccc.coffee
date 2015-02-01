_ = require 'lodash'
Q = require 'q'
exec = require('child_process').exec
mkdirp = require 'mkdirp'
path = require 'path'
fs = require 'fs'
subParser = require 'subtitles-parser'
ytdl = require 'youtube-dl'
urlChecker = require 'valid-url'
argv = (require 'yargs')
	.demand 2
	.argv

timestamp = require './timestamp'

# Returns a promise that returns an array of caption objects
# that contain search in their text
findCaptions = (url, search) ->
	console.log "Downloading captions..."
	options =
		auto: false
		all: false
		lang: 'en'
		cwd: process.cwd()
	return Q.nfcall ytdl.getSubs, url, options
		.then (files) ->
			return Q.nfcall fs.readFile, files[0]
				.then (file) -> # Delete the .srt after we read it
					fs.unlink files[0], ->
					return file
		.then (file) ->
			console.log "Searching captions..."
			srt = subParser.fromSrt file.toString()
			return (timestamp.formatSub sub for sub in srt when sub.text.toLowerCase().indexOf(search) != -1)
		.catch (err) ->
			console.error err

# Returns a promise that resolves with the video's filename when finished downloading
downloadVideo = (url) ->
	deferred = Q.defer()
	video = ytdl url,
		['-o %(id)s - %(title)s/original.%(ext)s']
	video.on 'info', (info) ->
		filename = info.filename.trim()
		console.log "Downloading full video..."
		mkdirp.sync path.dirname filename
		writeStream = fs.createWriteStream filename
		video.pipe writeStream
		writeStream.on 'finish', ->
			console.log "Downloaded original video to\"#{filename}\""
			deferred.resolve filename	
		writeStream.on 'error', (err) -> deferred.reject err
	video.on 'error', (err) -> deferred.reject err
	return deferred.promise

cutClip = (filename, caption, i='') ->
	cmd = "ffmpeg -i \"#{filename}\" -ss #{caption.startTime} -t #{caption.length} \"#{path.join path.dirname(filename), "clip#{i}.mp4"}\""
	return Q.nfcall exec, cmd

###
Handle command arguments
###

url = argv._[0]
if not urlChecker.isWebUri url
	url = "https://www.youtube.com/watch?v=#{url}"
search = argv._[1].toLowerCase()

captions = null

findCaptions url, search
	.then (caps) ->
		if caps.length is 0
			throw "No captions found matching search query"
		captions = caps
		return downloadVideo(url)
	.then (filename) ->
		console.log "Cutting clips of matching captions..."
		infoFile = ""
		promise = Q()
		for caption, i in captions
			infoFile += """
				clip#{i}.mp4:
					#{caption.startTime} - #{caption.endTime}
					#{caption.text}

				"""
			do (caption, i) ->
				promise = promise.then ->
					cutClip filename, caption, i
				.then ->
					console.log "Created #{path.join path.dirname(filename), "clip#{i}.mp4"}"
		fs.writeFile path.join(path.dirname(filename), 'captions.txt'), infoFile
		return promise
	.then ->
		console.log "Finished creating clips of \"#{search}\" in #{url}"
	.done()