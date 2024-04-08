! Copyright (C) 2024 Val Packett.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators continuations discord discord-patch
environment formatting hashtables io io.encodings.utf8 io.launcher
kernel make namespaces prettyprint sequences ;
IN: uxn-bot

: uxn-bot-command ( -- cmds )
    H{
        { "name" "uxn" }
        { "type" 1 }
        { "description" "evaluate uxn code" }
        { "options" { H{
            { "name" "code" }
            { "required" t }
            { "description" "uxn code to evaluate. " }
            { "type" 3 }
        } } }
    } ;

: user-id-of ( json -- username )
    "member" of "user" of "id" of ;

: code-of ( json -- code )
    "data" of "options" of [ "name" of "code" = ] find nip "value" of ;

: respond-ack ( json -- )
    [
        [
            4 "type" ,,
            [
                [ user-id-of ] [ code-of ] bi "<@%s>'s code:\n```\n%s\n```\nrunning..." sprintf
                "content" ,,
            ] H{ } make "data" ,,
        ] H{ } make
    ]
    [ "id" of ] [ "token" of ] tri
    create-interaction-response ;

: finalize-response ( json result -- )
    [
        [ dup [ user-id-of ] [ code-of ] bi ] dip
        "<@%s>'s code:\n```\n%s\n```\noutput:\n```\n%s\n```" sprintf
        "content" ,,
        [ dup user-id-of 1array "users" ,, ] H{ } make
        "allowed_mentions" ,,
    ] H{ } make
    swap
    "token" of
    [ discord-bot-config get application-id>> ] dip
    edit-interaction-response unparse gprint-flush ;

: run-code ( expr -- res )
    [
        "FLATPAK_SANDBOX_DIR" os-env [ "flatpak-spawn" , "--host" , "--directory=/tmp" , ] [ ] if
        "DOCKER_CMD" os-env "docker" or ,
        "run" ,
        "DOCKER_IMAGE" os-env "booniepepper/uxnbot-discord" or ,
        ,
    ] { } make
    utf8 [ read-contents ] with-process-reader ;

: try-run-code ( expr -- res )
    [ run-code ] [ unparse "error: %s" sprintf swap drop ] recover ;

GENERIC: uxn-bot ( json opcode -- )

M: object uxn-bot 2drop ;

M: INTERACTION_CREATE uxn-bot
    drop dup "data" of "name" of {
        { "uxn" [ [ respond-ack ] [ dup code-of try-run-code finalize-response ] bi ] }
        [ "Unknown interaction received '%s'" sprintf gprint-flush drop ]
    } case ;
