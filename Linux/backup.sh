#!/bin/bash

echo "Digite o diretorio de Backup: "
read diretorio_bkc

cp -rv $diretorio_bkc ~/Backup
echo ""
echo "Backup concluido com sucesso!"