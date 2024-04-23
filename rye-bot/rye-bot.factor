! Copyright (C) 2024 Val Packett.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators continuations discord discord-patch
environment formatting hashtables io io.encodings.utf8 io.launcher
kernel make namespaces prettyprint sequences ;
IN: rye-bot

: rye-bot-command ( -- cmds )
    H{
        { "name" "rye" }
        { "type" 1 }
        { "description" "evaluate rye code" }
        { "options" { H{
            { "name" "code" }
            { "required" t }
            { "description" "code to evaluate. " }
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
        "run" , "--rm" ,
        "DOCKER_IMAGE" os-env "ghcr.io/refaktor/rye" or ,
        "-do" , ,
    ] { } make
    utf8 [ read-contents ] with-process-reader ;

: try-run-code ( expr -- res )
    [ run-code ] [ unparse "error: %s" sprintf swap drop ] recover ;

GENERIC: rye-bot ( json opcode -- )

M: object rye-bot 2drop ;

M: INTERACTION_CREATE rye-bot
    drop dup "data" of "name" of {
        { "rye" [ [ respond-ack ] [ dup code-of try-run-code finalize-response ] bi ] }
        [ "Unknown interaction received '%s'" sprintf gprint-flush drop ]
    } case ;
