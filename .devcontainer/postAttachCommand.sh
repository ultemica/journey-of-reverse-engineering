#!/bin/zsh

git branch --merged|egrep -v '\*|develop|main|master'|xargs git branch -d