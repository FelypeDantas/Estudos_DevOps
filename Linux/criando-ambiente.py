#!/bin/bash

import os
import subprocess
import sys

def criar_ambiente(diretorio_projeto):
    if not os.path.exists(diretorio_projeto):
        print("O diretorio informado nao existe")
        return
    venv_path = os.path.join(diretorio_projeto, 'venv')
    if os.path.exists(venv_path):
        print("O ambiente virtual ja existe")
        return
    try:
        subprocess.run(['virtualenv', venv_path], check=True)
        print("Ambiente criado com exito")
    except subprocess.CalledProcessError as e:
        print(f"Erro ao criar ambiente: {e}")

def instalar_dependencias(diretorio_projeto, requirements_file):
    if not os.path.exists(requirements_file):
        print("o Arquivo requirements.txt nao existe")
        return
    venv_path = os.path.join(diretorio_projeto, 'venv', 'bin', 'activate')
    subprocess.run(['source', venv_path], shell=True)
    try:
        subprocess.run(['pip', 'install', '-r', requirements_file], check=True)
        print("Dependencias instaladas com sucesso")
    except subprocess.CalledProcessError as e:
        print(f"Erro aao instalar as dependencias: {e}")

def main():
    diretorio_projeto = sys.argv[1]
    requirements_file = os.path.join(diretorio_projeto, 'requirements.txt')
    criar_ambiente(diretorio_projeto)
    instalar_dependencias(diretorio_projeto, requirements_file)

if __name__ == "__main__":
    main()