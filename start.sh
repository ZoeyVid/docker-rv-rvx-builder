#!/bin/sh

if [ "$RV" = "true" ]; then
    revanced-builder --no-open
else
    rvx-builder --no-open
fi
