#!/bin/bash

desired_bundler=$(grep -A 1 -i 'bundled with' Gemfile.lock 2>/dev/null | tail -n 1 | awk '{print $1}')

if [ -n "${desired_bundler}" ]
then
  echo "desired bundler detected: ${desired_bundler}"
  gem install bundler -v "= ${desired_bundler}"
else
  echo "no desired bundler detected; rolling with default"
fi