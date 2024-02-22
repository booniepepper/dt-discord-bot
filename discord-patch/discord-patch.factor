! Copyright (C) 2024 Val Packett.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors discord formatting http.client json kernel
multiline namespaces ;
IN: discord-patch
IN: discord

! These could be defined in the bot vocabulary, but since we have to do an override below anyway…

: discord-post-json-no-resp ( payload route -- )
    [ >json ] dip discord-post-request add-json-header http-request 2drop ;
: discord-patch-request ( payload route -- request )
    >discord-url <patch-request> add-discord-auth-header ;
: discord-patch-json ( payload route -- json )
    [ >json ] dip discord-patch-request add-json-header json-request ;
: set-discord-application-command ( json application-id -- json )
    "/applications/%s/commands" sprintf discord-post-json ;
: create-interaction-response ( json interaction-id interaction-token -- )
    "/interactions/%s/%s/callback" sprintf discord-post-json-no-resp ;
: edit-interaction-response ( json application-id interaction-token -- json )
    "/webhooks/%s/%s/messages/@original" sprintf discord-patch-json ;

! Compared to what was there originally, we have to reduce intents.
! Otherwise if we request all the intents that discord.factor originally wanted,
! and we don't have the permissions necessary for those, the gateway would not like that.

: gateway-identify-json ( -- json )
    \ discord-bot-config get token>> [[ {
        "op": 2,
        "d": {
            "token": "%s",
            "properties": {
                "os": "linux",
                "browser": "discord.factor",
                "device": "discord.factor"
            },
            "intents": 1
        }
    }]] sprintf json> >json ;

SINGLETONS: INTERACTION_CREATE ;

M: INTERACTION_CREATE dispatch-message 2drop ;
