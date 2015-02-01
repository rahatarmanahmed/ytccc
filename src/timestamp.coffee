module.exports.formatSub = (sub) ->
  startTime= timestampToMillis sub.startTime
  endTime = timestampToMillis sub.endTime
  length = endTime - startTime
  return {
    id: sub.id
    text: sub.text
    startTime: millisToTimestamp startTime
    endtime: millisToTimestamp endTime
    length: millisToTimestamp length
  }

timestampToMillis = (time) ->
  millis = parseInt time.split(',')[1]
  time = time.split(':').map (i) -> parseInt i
  return millis + time[0] * 3600000 + time[1] * 60000 + time[2] * 1000

millisToTimestamp = (millis) ->
  hours = millis // 3600000
  millis -= hours * 3600000
  mins = millis // 60000
  millis -= mins * 60000
  secs = millis // 1000
  millis -= secs * 1000
  return "#{pad hours, 2}:#{pad mins, 2}:#{pad secs, 2}.#{pad millis, 3}"

pad = (n, width, z) ->
  z ||= '0'
  n += ''
  return if n.length >= width then n else new Array(width-n.length+1).join(z) + n