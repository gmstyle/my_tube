#!/bin/bash

# Android Auto Testing Script for My Tube App
# This script helps test the Android Auto fixes

# Sullo smartphone cercare android auto nelle impostazioni
# Cliccare 10 volte su "Versione" per abilitare le opzioni sviluppatore di android auto
# Cliccare sui tre puntini in alto a destra e selezionare "Avvia server unita principale"
# Avviare l'app sullo smartphone
# lanciare questo script

adb forward tcp:5277 tcp:5277

../../Android/Sdk/extras/google/auto/desktop-head-unit