local PLUGIN = {}

PLUGIN.triggers = {
	'^' .. config.command_start .. config.locale.plugins.admin.command .. ' '
}

PLUGIN.no_typing = true

function PLUGIN.action(msg)

	if msg.date < os.time() - 1 then return end

	local input = get_input(msg.text)

	local message = config.locale.errors.argument

	if not config.admins[msg.from.id] then
		return send_msg(msg, config.locale.errors.permission)
	end

	if string.lower(first_word(input)) == 'run' then

		local output = get_input(input)
		if not output then
			return send_msg(msg, config.locale.errors.argument)
		end
		local output = io.popen(output)
		message = output:read('*all')
		output:close()

	elseif string.lower(first_word(input)) == 'reload' then

		bot_init()
		message = config.locale.plugins.admin.reload

	elseif string.lower(first_word(input)) == 'halt' then

		is_started = false
		message = config.locale.plugins.admin.halt

	elseif string.lower(first_word(input)) == 'msg' then

		if not get_input(input) then
			return send_msg(msg, config.locale.errors.argument)
		end

		message = first_word(get_input(input)) .. ': ' .. get_input(input):gsub(first_word(get_input(input)), "")

		return send_message(first_word(get_input(input)), get_input(input):gsub(first_word(get_input(input)), ""))

	end

	send_msg(msg, message)

end

return PLUGIN
