return {
	bot_api_key = '',
	lastfm_api_key = '',
	biblia_api_key = '',
	thecatapi_key = '',
	giphy_api_key = 'dc6zaTOxFJmzC',
	twitter = {
		consumer_key = '',
		consumer_secret = '',
		access_token = '',
		access_token_secret = ''
	},
	time_offset = 0,
	command_start = '/',
	ignore = {
		old_messages = true,
		media_messages = true,
		forwarded_messages = false
	},
	locale = dofile('loc/en.lua'),
	admins = {
		[119989724] = 'E M C Developer'
	},
	blacklist = load_data('blacklist.json'),
	plugins = {
		'about.lua',
		'help.lua',
		'admin.lua',
		'gSearch.lua',
		'gImages.lua',
		'reddit.lua',
		'giphy.lua',
		'xkcd.lua',
		'gMaps.lua',
		'wikipedia.lua',
		'imdb.lua',
		'urbandictionary.lua',
		'hackernews.lua',
		'cats.lua',
		'time.lua',
		'weather.lua',
		'calc.lua',
		'dice.lua',
		'remind.lua',
		'8ball.lua',
		'bandersnatch.lua',
		'btc.lua',
		'chatter.lua',
		'commit.lua',
		'dogify.lua',
		'echo.lua',
		'hex.lua',
		'interactions.lua',
		'pokedex.lua',
		'pun.lua',
		'reaction.lua',
		'slap.lua',
		'whoami.lua',
		'lmgtfy.lua',
		'translate.lua',
		'currency.lua',
		'blacklist.lua',
		'nick.lua'
	},
	moderation = {
		realm = 116619671,
		realmname = 'Realm E M C',
		data = 'moderation.json',
		admins = {
			['119989724'] = 'E M C Developer',
		}
	}
}
