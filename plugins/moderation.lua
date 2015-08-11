-- So this plugin is an attempt to port @CIS_Bot's Liberbot moderation capabilities to the otouto base. By the time this code is public, @CIS_Bot will be running on pure otouto code. ¡Viva la Confederación!

--[[

This works using the settings in the "moderation" section of config.lua.
"realm" should be set to the group ID of the admin group. A negative number.
"data" will be the file name of where the moderation 'database' will be stored. The file will be created if it does not exist.
"admins" is a table of administrators for the Liberbot admin group. They will have the power to add groups and moderators to the database. The value can be a nickname for the admin, but it only needs to be true for it to work.

]]--

local help = {}

help.trigger = '^' .. config.command_start .. 'modhelp'

help.action = function(msg)

	local data = load_data(config.moderation.data)

	local do_send = false
	if data[tostring(msg.chat.id)] and data[tostring(msg.chat.id)][tostring(msg.from.id)] then do_send = true end
	if config.moderation.admins[msg.from.id] then do_send = true end
	if do_send == false then return end

	local message = [[
		Moderator commands:
			/modban - Ban a user via reply or username.
			/modkick -  Kick a user via reply or username.
			/modlist - Get a list of moderators for this group.
		Administrator commands:
			/add - Add this group to the database.
			/remove - Remove this group from the database.
			/promote - Promote a user via reply.
			/demote - Demote a user via reply.
			/modcast - Send a broastcast to every group.
	]]

	send_message(msg.chat.id, message)

end


local ban = {}

ban.trigger = '^' .. config.command_start .. 'modban'

ban.action = function(msg)

	local data = load_data(config.moderation.data)

	if not data[tostring(msg.chat.id)] then return end
	if not data[tostring(msg.chat.id)][tostring(msg.from.id)] then return end

	local target = get_target(msg)
	if not target then
		return send_message(msg.chat.id, 'No one to remove.\nBots must be removed by username.')
	end

	if msg.reply_to_message and data[tostring(msg.chat.id)][tostring(msg.reply_to_message.from.id)] then
		return send_message(msg.chat.id, 'Cannot remove a moderator.')
	end

	local chat_id = math.abs(msg.chat.id)

	send_message(config.moderation.realm, config.command_start .. 'ban ' .. target .. ' from ' .. chat_id)

	if msg.reply_to_message then
		target = msg.reply_to_message.from.first_name
	end

	send_message(config.moderation.realm, target .. ' banned from ' .. msg.chat.title .. ' by ' .. msg.from.first_name .. '.')

end


local kick = {}

kick.trigger = '^' .. config.command_start .. 'modkick'

kick.action = function(msg)

	local data = load_data(config.moderation.data)

	if not data[tostring(msg.chat.id)] then return end
	if not data[tostring(msg.chat.id)][tostring(msg.from.id)] then return end

	local target = get_target(msg)
	if not target then
		return send_message(msg.chat.id, 'No one to remove.\nTip: Bots must be removed by username.')
	end

	if msg.reply_to_message and data[tostring(msg.chat.id)][tostring(msg.reply_to_message.from.id)] then
		return send_message(msg.chat.id, 'Cannot remove a moderator.')
	end

	local chat_id = math.abs(msg.chat.id)

	send_message(config.moderation.realm, config.command_start .. 'kick ' .. target .. ' from ' .. chat_id)

	if msg.reply_to_message then
		target = msg.reply_to_message.from.first_name
	end

	send_message(config.moderation.realm, target .. ' kicked from ' .. msg.chat.title .. ' by ' .. msg.from.first_name .. '.')

end


local add = {}

add.trigger = '^' .. config.command_start .. '[mod]*add$'

add.action = function(msg)

	local data = load_data(config.moderation.data)

	if not config.moderation.admins[msg.from.id] then return end

	if data[tostring(msg.chat.id)] then
		return send_message(msg.chat.id, 'Group is already added.')
	end

	data[tostring(msg.chat.id)] = {}
	save_data(config.moderation.data, data)

	send_message(msg.chat.id, 'Group has been added.')

end


local rem = {}

rem.trigger = '^' .. config.command_start .. '[mod]*rem[ove]*$'

rem.action = function(msg)

	local data = load_data(config.moderation.data)

	if not config.moderation.admins[msg.from.id] then return end

	if not data[tostring(msg.chat.id)] then
		return send_message(msg.chat.id, 'Group is not added.')
	end

	data[tostring(msg.chat.id)] = nil
	save_data(config.moderation.data, data)

	send_message(msg.chat.id, 'Group has been removed.')

end


local promote = {}

promote.trigger = '^' .. config.command_start .. '[mod]*prom[ote]*$'

promote.action = function(msg)

	local data = load_data(config.moderation.data)

	if not config.moderation.admins[msg.from.id] then return end

	if not data[tostring(msg.chat.id)] then
		return send_message(msg.chat.id, 'Group is not added.')
	end

	if not msg.reply_to_message then
		return send_message(msg.chat.id, 'Promotions must be done via reply.')
	end

	if data[tostring(msg.chat.id)][tostring(msg.reply_to_message.from.id)] then
		return send_message(msg.chat.id, msg.reply_to_message.from.first_name..' is already a moderator.')
	end

	if not msg.reply_to_message.from.username then
		msg.reply_to_message.from.username = msg.reply_to_message.from.first_name
	end

	data[tostring(msg.chat.id)][tostring(msg.reply_to_message.from.id)] = msg.reply_to_message.from.first_name
	save_data(config.moderation.data, data)

	send_message(msg.chat.id, msg.reply_to_message.from.first_name..' has been promoted.')

end


local demote = {}

demote.trigger = '^' .. config.command_start .. '[mod]*dem[ote]*'

demote.action = function(msg)

	local data = load_data(config.moderation.data)

	if not config.moderation.admins[msg.from.id] then return end

	if not data[tostring(msg.chat.id)] then
		return send_message(msg.chat.id, 'Group is not added.')
	end

	local input = get_input(msg.text)
	if not input then
		if msg.reply_to_message then
			input = msg.reply_to_message.from.id
		else
			return send_msg('Demotions must be done by reply or by specifying a moderator\'s ID.')
		end
	end

	if not data[tostring(msg.chat.id)][tostring(input)] then
		return send_message(msg.chat.id, input..' is not a moderator.')
	end

	data[tostring(msg.chat.id)][tostring(input)] = nil
	save_data(config.moderation.data, data)

	send_message(msg.chat.id, input..' has been demoted.')

end


local broadcast = {}

broadcast.trigger = '^' .. config.command_start .. 'modcast'

broadcast.action = function(msg)

	local data = load_data(config.moderation.data)

	if not config.moderation.admins[msg.from.id] then return end

	if msg.chat.id ~= config.moderation.realm then
		return send_message(msg.chat.id, 'This command must be run in the admin group.')
	end

	local message = get_input(msg.text)

	if not message then
		return send_message(msg.chat.id, 'You must specify a message to broadcast.')
	end

	for k,v in pairs(data) do
		send_message(k, message)
	end

end


local modlist = {}

modlist.trigger = '^' .. config.command_start .. 'modlist'

modlist.action = function(msg)

	local data = load_data(config.moderation.data)

	if not data[tostring(msg.chat.id)] then
		return send_message(msg.chat.id, 'Group is not added.')
	end

	local message = 'List of moderators for ' .. msg.chat.title .. ':\n'

	for k,v in pairs(data[tostring(msg.chat.id)]) do
		message = message .. v .. ' (' .. k .. ')\n'
	end

	send_message(msg.chat.id, message)

end


local modactions = {
	help,
	ban,
	kick,
	add,
	rem,
	promote,
	demote,
	broadcast,
	modlist
}


local triggers = {
	'^' .. config.command_start .. 'modhelp',
	'^' .. config.command_start .. 'modlist',
	'^' .. config.command_start .. 'modcast',
	'^' .. config.command_start .. '[mod]*add$',
	'^' .. config.command_start .. '[mod]*rem[ove]*$',
	'^' .. config.command_start .. '[mod]*prom[ote]*$',
	'^' .. config.command_start .. '[mod]*dem[ote]*',
	'^' .. config.command_start .. 'modkick',
	'^' .. config.command_start .. 'modban'
}

local action = function(msg)
	for k,v in pairs(modactions) do
		if string.match(msg.text, v.trigger) then
			return v.action(msg)
		end
	end
end

return {
	triggers = triggers,
	action = action,
	no_typing = true
}
