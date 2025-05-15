import os
import logging
from lightflow.models import Dag
from lightflow.tasks import PythonTask, BashTask


from DockerHelper import DockerHelper
# Import utils.py
from utils import *

# Configuração do logger
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


# Função para inicializar o workflow
def init_workflow(data: dict, store: dict, signal: dict, context: dict):

    logger.info("Iniciando o workflow de transcriptômica.")
    data['paths'] = {
        'raw_reads': '/path/to/raw_reads',
        'output': '/path/to/output',
        'fastqc_output': '/path/to/output/fastqc',
        'trimmed_reads': '/path/to/output/trimmed_reads'
    }
    os.makedirs(data['paths']['fastqc_output'], exist_ok=True)
    os.makedirs(data['paths']['trimmed_reads'], exist_ok=True)

    data['docker_helper'] = DockerHelper()

# Função para executar o FastQC
def run_fastqc(data, store, signal, context):
    docker_helper = data['docker_helper']
    docker_helper.add_tool('fastqc', 'biocontainers/fastqc:v0.11.9_cv1')
    fastqc_command = docker_helper.setup_command(
        'fastqc',
        f"--outdir {data['paths']['fastqc_output']} {data['paths']['raw_reads']}/*.fastq"
    )
    logger.info(f"Executando FastQC: {fastqc_command}")
    os.system(fastqc_command)

# Função para executar o Trimmomatic
def run_trimmomatic(data, store, signal, context):
    docker_helper = data['docker_helper']
    docker_helper.add_tool('trimmomatic', 'biocontainers/trimmomatic:v0.39-1-deb_cv1')
    trimmomatic_command = docker_helper.setup_command(
        'trimmomatic',
        f"PE -threads 4 {data['paths']['raw_reads']}/*.fastq "
        f"{data['paths']['trimmed_reads']}/output_forward_paired.fq.gz "
        f"{data['paths']['trimmed_reads']}/output_forward_unpaired.fq.gz "
        f"{data['paths']['trimmed_reads']}/output_reverse_paired.fq.gz "
        f"{data['paths']['trimmed_reads']}/output_reverse_unpaired.fq.gz "
        "ILLUMINACLIP:TruSeq3-PE.fa:2:30:10"
    )
    logger.info(f"Executando Trimmomatic: {trimmomatic_command}")
    os.system(trimmomatic_command)

# Definição do DAG
dag = Dag('transcriptome_workflow')

# Tarefas
task_init = PythonTask(name='init_workflow', callback=init_workflow)
task_fastqc = PythonTask(name='run_fastqc', callback=run_fastqc)
task_trimmomatic = PythonTask(name='run_trimmomatic', callback=run_trimmomatic)

# Definição do fluxo de tarefas
dag.define({
    task_init: [task_fastqc],
    task_fastqc: [task_trimmomatic]
})