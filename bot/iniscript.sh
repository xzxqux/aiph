#!/data/data/com.termux/files/usr/bin/sh

#
#	@utor izXquX
#	Shell Script
#
#	Esse script inicia outros
#

termux-wake-lock # Continuem rodando em segundo plano

# Inicia os script, localizado no diretório .script/
nohup python "$HOME/.script/boasvindasbot.py" > /dev/null 2>&1 &
