#!/bin/bash

(apt update -qq >> /dev/null 2>&1) || exit 1

(apt list -qq --upgradable 2>/dev/null) || exit 1