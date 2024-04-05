USING: accessors concurrency.flags discord modal-bot environment kernel namespaces ;
IN: runbot

MAIN: [
    discord-bot-config new
    "APPLICATION_ID" os-env >>application-id
    "TOKEN" os-env >>token
    [ modal-bot ] >>user-callback
    discord-bot-config set

    modal-bot-command discord-bot-config get application-id>> set-discord-application-command drop

    discord-bot-config get discord-connect

    <flag> wait-for-flag ! just sleep the main thread while the discord threads work
]
