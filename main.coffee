#!/usr/bin/env coffee

nconf = require 'nconf'
Discord = require 'discord.js'

secrets = nconf.argv().env().file(process.env.SECRETS_PATH or "./secrets.json")

client = new Discord.Client
  intents: [
    Discord.GatewayIntentBits.Guilds
    Discord.GatewayIntentBits.GuildMessages
    Discord.GatewayIntentBits.MessageContent
  ]

client.on 'ready', () ->
  console.log "Logged in as #{client.user.tag}!"

allowed_channel = (ch) ->
  switch ch.name
    when 'fifteens-channel', 'channel-with-twenty-ones'
      false
    else
      true

non_letters = /[^\p{L}]/gu
num_letters = (s) ->
  s.replace(non_letters, '').length

emoji =
  fifteen: '744272457111961630'
  twentyone: '790653146149814283'

get_reaction = (msg) ->
  return null unless allowed_channel msg.channel
  switch num_letters msg.cleanContent
    when 15
      emoji.fifteen
    when 21
      emoji.twentyone
    else
      null

logmsg = (action, msg) ->
  console.log "#{action} ##{msg.channel.name}: #{msg.author.username}> #{msg.cleanContent}"

add_reaction = (msg, reaction) ->
  console.log '+ adding reaction', msg, reaction
  msg.react reaction
    .then (r) -> logmsg 'reacted to', r.message
    .catch console.error

remove_reaction = (msg, reaction) ->
  console.log '+ removing reaction', msg, reaction
  msg.reactions.cache
    .filter (r) -> r.me and r.emoji.id == reaction
    .each (r) ->
      r.users.remove client.user.id
        .then (res) -> logmsg 'removed from', res.message
        .catch console.error

client.on 'messageCreate', (msg) ->
  try
    return unless reaction = get_reaction msg
    add_reaction msg, reaction
  catch error
    console.log 'messageCreate error', error

client.on 'messageUpdate', (old, msg) ->
  try
    oldreaction = get_reaction old
    newreaction = get_reaction msg
    if not oldreaction and newreaction
      add_reaction msg, newreaction
    if oldreaction and not newreaction
      remove_reaction msg, oldreaction
    if oldreaction and newreaction and oldreaction != newreaction
      remove_reaction msg, oldreaction
      add_reaction msg, newreaction
  catch error
    console.log 'messageUpdate error', error

client.login secrets.get 'discord:token'

