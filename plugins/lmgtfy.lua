local PLUGIN = {}

PLUGIN.triggers = {
	'^' .. config.command_start .. config.locale.plugins.lmgtfy.command,
}

function PLUGIN.action(msg)

	if not msg.reply_to_message then return end
	msg = msg.reply_to_message

	local message = 'http://lmgtfy.com/?q=' .. URL.escape(msg.text)

	send_msg(msg, message)

end

return PLUGIN
