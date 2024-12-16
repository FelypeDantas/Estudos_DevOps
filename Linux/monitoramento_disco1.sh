#!/bin/bash

echo "Digite um atributo para grep: "
read atributo_grep

uso_disco=$(df -h | grep $atributo_grep | awk '{print $5}')
echo "Uso do disco em: $uso_disco"