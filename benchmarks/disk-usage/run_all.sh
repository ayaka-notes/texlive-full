#!/bin/bash
# Sequentially measure every remaining tag with STOCK Docker defaults.
# Each run wipes /var/lib/docker first, so years never contaminate each other.
SP=/tmp/claude-0/-home-user-texlive-full/c018bfa2-d7f6-5c85-a1da-c0cf68259697/scratchpad
MODE="${1:-default}"
shift
for TAG in "$@"; do
  echo "############ $TAG / $MODE  $(date -u +%H:%M:%S) ############"
  python3 $SP/measure.py "$TAG" "$MODE" "$SP/results" 2>&1
  echo
done
echo "ALL DONE $(date -u +%H:%M:%S)"
