USING: accessors concurrency.flags discord mirth-bot environment kernel namespaces ;
IN: runbot

MAIN: [
    discord-bot-config new
    "APPLICATION_ID" os-env >>application-id
    "TOKEN" os-env >>token
    [ mirth-bot ] >>user-callback
    discord-bot-config set

    mirth-bot-command discord-bot-config get application-id>> set-discord-application-command drop

    discord-bot-config get discord-connect

    <flag> wait-for-flag ! just sleep the main thread while the discord threads work
]
