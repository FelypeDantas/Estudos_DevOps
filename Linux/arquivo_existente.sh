#!/bin/bash

echo "Digite o nome do arquivo que deseja verificar: "
read arquivo
echo ""
echo "Digite o tipo de extensao: "
read extensao

if [ -e "$arquivo.$extensao" ]; then
    echo "O arquivo existe."
else
    echo "O arquivo não existe."
fi