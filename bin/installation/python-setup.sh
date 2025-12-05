#!/bin/bash
###########################################
## Tool chain install script.
##
## Written: Jordan Carlin, jcarlin@hmc.edu
## Created: May 30 2025
## Modified:
##
## Purpose: WALLY python virtual environment setup script
##
## A component of the CORE-V-WALLY configurable RISC-V project.
## https://github.com/openhwgroup/cvw
##
## Copyright (C) 2021-24 Harvey Mudd College & Oklahoma State University
##
## SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
##
## Licensed under the Solderpad Hardware License v 2.1 (the “License”); you may not use this file
## except in compliance with the License, or, at your option, the Apache License version 2.0. You
## may obtain a copy of the License at
##
## https:##solderpad.org/licenses/SHL-2.1/
##
## Unless required by applicable law or agreed to in writing, any work distributed under the
## License is distributed on an “AS IS” BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
## either express or implied. See the License for the specific language governing permissions
## and limitations under the License.
################################################################################################

# NOTE: These three tools need to be kept in sync. Update all versions simultaneously.
export RISCOF_VERSION=be84132874963e001c14d846a140a3edd9c9d48f # Last commit as May 31, 2025
export RISCV_CONFIG_VERSION=54171f205be802f9f8e0b1cf4156a6cc826fb467 # Last commit as of May 31, 2025
export RISCV_ISAC_VERSION=450de2eabfe4fcdfdf54135b5ab2dbb1d94805f8 # Last commit as of May 31, 2025 (commit hash of riscv-arch-test repo)

set -e # break on error
# If run standalone, check environment. Otherwise, use info from main install script
if [ -z "$FAMILY" ]; then
    dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    WALLY="$(dirname $(dirname "$dir"))"
    export WALLY
    source "${dir}"/../wally-environment-check.sh
fi

# Set up Python environment using uv
# uv manages the virtual environment automatically - no need to activate it manually
section_header "Setting up Python Environment with uv"
STATUS="python_environment"
cd "$WALLY"

# Sync all Python dependencies from pyproject.toml
# uv sync creates/updates a .venv in the project directory automatically
echo -e "${OK_COLOR}Installing Python packages with uv...${ENDC}"
uv sync --python "$PYTHON_VERSION"

# Install additional packages from requirements.txt that have environment variable substitutions
# These can't be in pyproject.toml directly due to the ${VARIABLE} syntax
STATUS="python_packages"
uv pip install -r "$WALLY"/bin/requirements.txt

echo -e "${SUCCESS_COLOR}Python environment successfully configured!${ENDC}"
echo -e "${OK_COLOR}Use 'uv run <script>' to run Python scripts or 'uv tool run <tool>' for standalone tools.${ENDC}"
