#!/usr/bin/env bash
set -o errexit

# Upgrade pip
pip install --upgrade pip

# Install the rest from requirements
pip install -r requirements.txt