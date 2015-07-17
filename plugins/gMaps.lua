local PLUGIN = {}

PLUGIN.doc = config.command_start .. config.locale.plugins.gMaps.command .. ' <' .. config.locale.arguments.location .. '>\n' .. config.locale.plugins.gMaps.help

PLUGIN.triggers = {
	'^' .. config.command_start .. config.locale.plugins.gMaps.command
}

function PLUGIN.action(msg)

	local input = get_input(msg.text)
	if not input then
		if msg.reply_to_message then
			msg = msg.reply_to_message
			input = msg.text
		else
			return send_msg(msg, PLUGIN.doc)
		end
	end

	local url = 'http://maps.googleapis.com/maps/api/geocode/json?address=' .. URL.escape(input)
	local jstr, res = HTTP.request(url)

	if res ~= 200 then
		return send_msg(msg, config.locale.errors.connection)
	end

	local jdat = JSON.decode(jstr)

	if jdat.status ~= 'OK' then
		local message = config.locale.errors.results
		return send_msg(msg, message)
	end

	local lat = jdat.results[1].geometry.location.lat
	local lng = jdat.results[1].geometry.location.lng
	send_location(msg.chat.id, lat, lng, msg.message_id)

end

return PLUGIN

