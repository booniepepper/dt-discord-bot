! Copyright (C) 2024 Val Packett.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators continuations discord discord-patch
environment formatting hashtables io io.encodings.utf8 io.launcher
kernel make namespaces prettyprint sequences ;
IN: dt-bot

: dt-bot-command ( -- cmds )
    H{
        { "name" "dt" }
        { "type" 1 }
        { "description" "Evaluate dt code" }
        { "options" { H{ { "name" "code" } { "required" t } { "description" "the code to evaluate" } { "type" 3 } } } }
    } ;

: user-id-of ( json -- username )
    "member" of "user" of "id" of ;

: code-of ( json -- code )
    "data" of "options" of [ "name" of "code" = ] find nip "value" of ;

: respond-ack ( json -- )
    [
        code-of "Running `%s`………" sprintf
        "content" swap 2array 1array >hashtable
        "data" swap 2array "type" 4 2array 2array >hashtable
    ]
    [ "id" of ] [ "token" of ] tri
    create-interaction-response ;

: finalize-response ( json result -- )
    [ dup [ user-id-of ] [ code-of ] bi ] dip
    "<@%s> ran `%s`, result:\n```\n%s\n```" sprintf
    "content" swap 2array
    [ dup user-id-of 1array "users" swap 2array 1array >hashtable "allowed_mentions" swap 2array ] dip
    2array >hashtable
    dup unparse gprint-flush
    swap
    "token" of
    [ discord-bot-config get application-id>> ] dip
    edit-interaction-response unparse gprint-flush ;

: run-code ( expr -- res )
    [
        "FLATPAK_SANDBOX_DIR" os-env [ "flatpak-spawn" , "--host" , "--directory=/tmp" , ] [ ] if
        "DOCKER_CMD" os-env "docker" or ,
        "run" ,
        "DOCKER_IMAGE" os-env "booniepepper/dt" or ,
        "drop" , , "quote-all pls quit" ,
    ] { } make
    utf8 [ read-contents ] with-process-reader ;

: try-run-code ( expr -- res )
    [ run-code ] [ unparse "error: %s" sprintf swap drop ] recover ;

GENERIC: dt-bot ( json opcode -- )

M: object dt-bot 2drop ;

M: INTERACTION_CREATE dt-bot
    drop dup "data" of "name" of {
        { "dt" [ [ respond-ack ] [ dup code-of try-run-code finalize-response ] bi ] }
        [ "Unknown interaction received '%s'" sprintf gprint-flush drop ]
    } case ;
