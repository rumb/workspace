#!/bin/bash

export DEBUG_MARK_COUNT=0

header_mark() {
  echo "########## $1"
}

debug_mark() {
  echo "# # # # # # # # # # DEBUG ${DEBUG_MARK_COUNT} # # # # # # # # # #"
  export DEBUG_MARK_COUNT=$(( DEBUG_MARK_COUNT + 1 ))
}
