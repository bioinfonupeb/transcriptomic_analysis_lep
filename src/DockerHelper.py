import os
import subprocess
import logging


class DockerHelper:
    def __init__(self, docker_prefix: str = None, log: str = "workflow-cmd.log"):
        """
        Initialize the DockerHelper class with a default Docker prefix and log file.
        :param docker_prefix: Custom Docker prefix command. If not provided, a default is generated.
        :param log: Path to the log file for history of the executed commands.
        """
        self.docker_prefix = docker_prefix or self._generate_default_prefix()
        self.tools = {}
        self.log_file = log

        # Set up logging configuration
        if os.path.exists(self.log_file):
            os.remove(self.log_file)

        # Define the logging format
        # log_fmt = '%(asctime)s - %(levelname)s - %(message)s' # Format to include timestamp and log level
        log_fmt = '%(message)s' # Format to print only the command

        # Set up logging to file
        logging.basicConfig(filename=self.log_file, level=logging.INFO, format=log_fmt)
        

    def _generate_default_prefix(self) -> str:
        """
        Generate the default Docker prefix based on the current working directory.
        :return: Default Docker prefix string.
        """
        root_path = os.path.dirname(os.path.abspath(os.getcwd()))
        return f"docker run -v {root_path}:/data"

    def add_tool(self, tool_name: str, tool_id: str) -> str:
        """
        Add a tool to the DockerHelper instance.
        :param tool_name: Name of the tool.
        :param tool_id: Docker image ID of the tool.
        :return: The Docker command for the tool.
        """
        if tool_name in self.tools:
            raise ValueError(f"Tool '{tool_name}' already exists.")
        self.tools[tool_name] = f"{self.docker_prefix} {tool_id}"
        return self.tools[tool_name]

    def get_tool(self, tool_name: str) -> str:
        """
        Retrieve the Docker command for a specific tool.
        :param tool_name: Name of the tool.
        :return: Docker command for the tool.
        """
        if tool_name not in self.tools:
            raise KeyError(f"Tool '{tool_name}' not found.")
        return self.tools[tool_name]

    def setup_command(self, tool_name: str, command: str, options: dict = None) -> str:
        """
        Create a Docker command for a specific tool with optional parameters.
        :param tool_name: Name of the tool.
        :param command: Command to execute inside the Docker container.
        :param options: Additional Docker options (e.g., environment variables, volumes).
        :return: Full Docker command string.
        """
        tool = self.get_tool(tool_name)
        docker_options = self._format_options(options)
        return f"{tool} {docker_options} {command}"

    @staticmethod
    def _format_options(options: dict) -> str:
        """
        Format additional Docker options into a string.
        :param options: Dictionary of Docker options.
        :return: Formatted Docker options string.
        """
        if not options:
            return ""
        formatted_options = []
        for key, value in options.items():
            if key == "env":
                formatted_options.extend([f"-e {k}={v}" for k, v in value.items()])
            elif key == "volumes":
                formatted_options.extend([f"-v {v}" for v in value])
            elif key == "network":
                formatted_options.append(f"--network {value}")
            else:
                formatted_options.append(f"--{key} {value}")
        return " ".join(formatted_options)

    def execute_command(self, command: str) -> None:
        """
        Execute a shell command using subprocess and log it to a file.
        :param command: The shell command to execute.
        """
        try:
            logging.info(f"Executing command: {command}")
            result = subprocess.run(command, shell=True, check=True, text=True, stdout=subprocess.PIPE,
                                    stderr=subprocess.PIPE)
            logging.info(f"Command output: {result.stdout}")
            if result.stderr:
                logging.error(f"Command error: {result.stderr}")
        except subprocess.CalledProcessError as e:
            logging.error(f"Command failed with error: {e.stderr}")
            raise
        