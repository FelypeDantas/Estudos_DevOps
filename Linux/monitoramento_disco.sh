#!/bin/bash

echo "Digite um atributo para grep: "
read atributo_grep

nome_log=$(date +%F-%H:%M)

uso_disco=$(df -h | grep $atributo_grep | awk '{print $5}')
echo "Uso do disco em: $uso_disco" > $nome_log.log