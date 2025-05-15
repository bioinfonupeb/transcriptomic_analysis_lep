import os
import logging

def add_path(data: dict, path: str, name: str = None, overwrite: bool = False) -> dict:
    """
    Adiciona um caminho ao dicionário de dados na chave 'paths'.
    Se o caminho não existir, ele será criado. Caso já exista, o comportamento
    dependerá do parâmetro 'overwrite'.

    :param data: Dicionário contendo a chave 'paths' para armazenar os caminhos.
    :param path: Caminho a ser adicionado.
    :param name: Nome associado ao caminho no dicionário. Se não fornecido, será o nome da pasta.
    :param overwrite: Se True, sobrescreve o caminho existente.
    :return: Dicionário atualizado com o novo caminho.
    :raises ValueError: Se o dicionário 'data' não contiver a chave 'paths'.
    :raises FileNotFoundError: Se o caminho não puder ser criado.
    """
    if 'paths' not in data:
        raise ValueError("O dicionário 'data' deve conter a chave 'paths'.")

    # Define o nome padrão se não for fornecido
    name = name or os.path.basename(path)

    # Verifica se o nome já existe no dicionário
    if name in data['paths']:
        logging.warning(f"O nome '{name}' já existe no dicionário de caminhos.")
        if not overwrite:
            logging.info("Use 'overwrite=True' para sobrescrever.")
            return data

    # Trata o caso de caminho existente
    if os.path.exists(path):
        if overwrite:
            if os.path.isdir(path):
                logging.info(f"Removendo diretório existente: {path}")
                os.rmdir(path)
            elif os.path.isfile(path):
                logging.info(f"Removendo arquivo existente: {path}")
                os.remove(path)
        else:
            logging.warning(f"O caminho '{path}' já existe. Use 'overwrite=True' para sobrescrever.")
            return data

    # Cria o diretório se não existir
    try:
        os.makedirs(path, exist_ok=True)
        logging.info(f"Diretório criado: {path}")
    except OSError as e:
        raise FileNotFoundError(f"Não foi possível criar o caminho: {path}") from e

    # Atualiza o dicionário de caminhos
    data['paths'][name] = path
    return data