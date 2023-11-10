require 'discordrb'
require 'open3'

bot = Discordrb::Bot.new(token: ENV.fetch('TOKEN', nil), intents: [:server_messages])

servers = [
    '1137157403264155719',
    '1150472957093744721',
    '1141777454164365382'
]

servers.each do |server|
    bot.register_application_command(:dt, 'Evaluate dt code', server_id:  server) do |cmd|
        cmd.string('code', 'the code to evaluate', required: true)
    end
end

bot.application_command(:dt) do |event|
    dt_code = event.options['code']

    stdout, status = Open3.capture2(
        'docker', 'run', '-i', 'booniepepper/dt',
        'drop', dt_code, 'quote-all pls quit', stdin_data: ''
    )

    event.respond(content: "```\n#{event.user.name} ran: #{dt_code}\n---\n#{stdout}\n```")
end


bot.run