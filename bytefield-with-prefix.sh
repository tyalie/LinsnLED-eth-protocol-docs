#!/usr/bin/env bash
PREFIX=$(cat << END
(defattrs :plain {:font-family "B612"})
END
)
DIAGRAM=$(cat -)
bytefield-svg $@ <(echo $PREFIX $DIAGRAM)
exit $?
