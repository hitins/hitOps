#!/bin/bash

function clean_pacman(){
	(echo y)|pacman -R $(pacman -Qdtq)
	(echo y;echo y)|pacman -Scc
}

clean_pacman
