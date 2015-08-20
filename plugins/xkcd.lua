local PLUGIN = {}

PLUGIN.doc = config.command_start .. config.locale.plugins.xkcd.command .. ' [' .. config.locale.arguments.search .. ']\n' .. config.locale.plugins.xkcd.help

PLUGIN.triggers = {
	'^' .. config.command_start .. config.locale.plugins.xkcd.command
}

function PLUGIN.action(msg)

	local input = get_input(msg.text)
	local url = 'http://xkcd.com/info.0.json'
	local jstr, res = HTTP.request(url)
	if res ~= 200 then
		return send_msg(msg, config.locale.errors.connection)
	end
	local latest = JSON.decode(jstr).num

	if input then
		url = 'http://ajax.googleapis.com/ajax/services/search/web?v=1.0&safe=active&q=site%3axkcd%2ecom%20' .. URL.escape(input)
		local jstr, res = HTTP.request(url)
		if res ~= 200 then
			print('here')
			return send_msg(msg, config.locale.errors.connection)
		end
		url = JSON.decode(jstr).responseData.results[1].url .. 'info.0.json'
	else
		math.randomseed(os.time())
		url = 'http://xkcd.com/' .. math.random(latest) .. '/info.0.json'
	end

	local jstr, res = HTTP.request(url)
	if res ~= 200 then
		return send_msg(msg, config.locale.errors.connection)
	end
	local jdat = JSON.decode(jstr)

	local message = '[' .. jdat.num .. '] ' .. jdat.alt .. '\n' .. jdat.img

	send_message(msg.chat.id, message, false, msg.message_id)

end

return PLUGIN
