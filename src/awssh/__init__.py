"""The awssh library."""

# Standard Python Libraries
from pathlib import Path

# We disable a Flake8 check for "Module imported but unused (F401)" here because
# although this import is not directly used, it populates the value
# package_name.__version__, which is used to get version information about this
# Python package.
from ._version import __version__  # noqa: F401

CREDENTIAL_DIR = Path("~/.aws").expanduser()
DEFAULT_CREDENTIAL_FILE = Path(CREDENTIAL_DIR) / Path("credentials")

__all__ = ["CREDENTIAL_DIR"]
