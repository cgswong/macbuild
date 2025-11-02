# MacBuild

**MacBuild** is a comprehensive macOS system configuration and package management tool that automates the installation and management of development tools, applications, and packages across multiple package managers.

## Features

- **Multi-Package Manager Support**: Homebrew, Python (uv), Node.js (pnpm), Ruby (gem), and mise
- **Automated Installation**: Xcode Command Line Tools, Homebrew, and all configured packages
- **Update Management**: Automated updates via launchd scheduling
- **Comprehensive Logging**: Structured logging with multiple levels and file output
- **Error Handling**: Robust retry mechanisms and graceful failure handling
- **Configuration-Driven**: INI-based package configuration with section support
- **Testing Infrastructure**: Complete test suite with coverage reporting

## Supported Package Managers

| Manager | Purpose | Tool Used |
|---------|---------|-----------|
| **Homebrew** | macOS packages and formulae | `brew` |
| **Homebrew Cask** | macOS applications | `brew --cask` |
| **Python** | Python tools and applications | `uv` |
| **Node.js** | JavaScript packages and tools | `pnpm` |
| **Ruby** | Ruby gems | `gem` |
| **Development Tools** | Runtime version management | `mise` |

## Quick Start

### Installation

```bash
# Direct execution (recommended for first-time setup)
curl -sSL https://raw.githubusercontent.com/cgswong/macbuild/main/macbuild | bash

# Or clone and run locally
git clone https://github.com/cgswong/macbuild.git
cd macbuild
./macbuild
```

### Basic Usage

```bash
# Full installation (all package types)
./macbuild

# Update existing packages only
./macbuild --update-only

# Install specific package type
./macbuild --install python
./macbuild --install apps

# Enable debug logging
LOG_LEVEL=DEBUG ./macbuild

# Custom configuration file
PKG_FILE=/path/to/custom/packages.ini ./macbuild
```

## Command Line Options

```text
Usage: macbuild [options]

Options:
  -h, --help              Show help message
  --version               Show version information
  --log-level LEVEL       Set logging level (DEBUG|INFO|WARN|ERROR)
  --update-only           Update existing tools only
  --install TYPE          Install specific package type
                         (brew | apps | python | node | ruby | mise | all)

Environment Variables:
  LOG_LEVEL              Logging level (default: INFO)
  LOG_DIR                Log directory (default: ~/.macbuild/logs)
  PKG_FILE               Package configuration file
```

## Configuration

### Package Configuration (`files/packages.ini`)

The package configuration uses INI format with sections for each package manager:

```ini
[homebrew]
git
curl
wget
jq

[cask]
visual-studio-code
firefox
iterm2

[python]
black
flake8
pytest

[node]
eslint
prettier

[gem]
bundler

[mise]
node@22
python@3.11
terraform@latest
```

### Auto-Update Configuration

MacBuild sets up automatic updates via launchd. The configuration file `files/com.user.macbuild_update.plist` schedules weekly updates:

- **Schedule**: Every Saturday at 9:00 AM
- **Action**: Runs `macbuild --update-only`
- **Location**: `~/Library/LaunchAgents/`

## Architecture

### Core Functions

#### Configuration and Setup

- `setup_logging()` - Initialize logging system
- `setup_homebrew()` - Install/update Homebrew
- `install_xcode_tools()` - Install Xcode Command Line Tools
- `setup_auto_updates()` - Configure launchd for automatic updates

#### Package Management

- `parse_ini_section(section, file)` - Extract packages from INI sections
- `install_homebrew_packages(section, cmd)` - Install Homebrew packages/casks
- `install_python_packages()` - Install Python tools via uv
- `install_node_packages()` - Install Node.js packages via pnpm
- `install_ruby_packages()` - Install Ruby gems
- `install_mise_packages()` - Install development tools via mise

#### Utilities

- `command_exists(cmd)` - Check if command is available
- `check_file_readable(file)` - Validate file accessibility
- `run_with_retry(cmd, attempts)` - Execute commands with retry logic
- `log_message(level, message)` - Structured logging with color coding

#### Update Management

- `update_all_tools()` - Update all installed package managers
- `install_package_type(type)` - Route installation by package type

### Logging System

MacBuild implements a comprehensive logging system:

```bash
# Log levels: DEBUG, INFO, WARN, ERROR
# Default location: ~/.macbuild/logs/macbuild.log
# Console output: Color-coded by level
# File output: All messages with timestamps
```

### Error Handling

- **Retry Logic**: Network operations retry up to 3 times with delays
- **Graceful Degradation**: Missing package managers are skipped with warnings
- **Input Validation**: File existence and readability checks
- **Exit Codes**: Proper status codes for different failure scenarios

## Testing

MacBuild includes a comprehensive test suite with coverage reporting.

### Running Tests

```bash
# Run complete test suite
make test

# Run tests directly
./run_tests.sh

# Run simple test suite
./test_macbuild_simple.sh

# Check syntax only
make check

# Run linting (requires shellcheck)
make lint
```

### Test Coverage

The test suite covers:

- **INI Parsing**: Section extraction and package listing
- **Package Installation**: Function presence and logic validation
- **Update Functionality**: Update command execution
- **Error Handling**: Error checking and logging mechanisms
- **User Interface**: Help and version option functionality
- **File Operations**: Script executability and file access

### Test Output

```text
Test Results Summary
==========================================
Tests Run: 15
Tests Passed: 15
Tests Failed: 0
Success Rate: 100%

Function Coverage: 65% (11/17 functions)
```

## Development

### Project Structure

```text
macbuild/
├── macbuild                    # Main executable script
├── macbuild_optimized         # Optimized version
├── files/
│   ├── packages.ini           # Package configuration
│   └── com.user.macbuild_update.plist  # Auto-update config
├── test_macbuild.sh          # Comprehensive test suite
├── test_macbuild_simple.sh   # Simplified test suite
├── run_tests.sh              # Test runner
├── Makefile                  # Build and test automation
├── coverage/                 # Test coverage reports
└── test_files/              # Test fixtures

```

### Available Make Targets

```bash
make help           # Show available targets
make test           # Run complete test suite
make check          # Syntax validation
make lint           # Run shellcheck linting
make coverage       # Display coverage report
make clean          # Clean test artifacts
make debug          # Run with debug logging
make validate-config # Validate packages.ini
```

### Code Style

- **Shell**: Bash with `set -euo pipefail`
- **Functions**: `snake_case` naming with descriptive verbs
- **Variables**: `UPPER_CASE` constants, `lower_case` locals
- **Error Handling**: Comprehensive with retry logic
- **Logging**: Structured with levels and timestamps

## Version Management

MacBuild uses semantic versioning with automated bumping:

```bash
# Current version: 2.0.0
# Configuration: .bumpversion.toml
# Changelog: CHANGELOG.md
```

## Requirements

### System Requirements

- **macOS**: 10.15+ (Catalina or later)
- **Shell**: Bash 4.0+ (included in macOS)
- **Network**: Internet connection for package downloads

### Automatic Dependencies

MacBuild automatically installs required dependencies:

- **Xcode Command Line Tools**: Installed automatically if missing
- **Homebrew**: Installed if not present
- **Package Managers**: Individual managers are optional (skipped if unavailable)

## Troubleshooting

### Common Issues

**Permission Errors**

```bash
# Ensure proper permissions
chmod +x macbuild
```

**Network Timeouts**

```bash
# Enable debug logging to see retry attempts
LOG_LEVEL=DEBUG ./macbuild
```

**Package Manager Not Found**

```bash
# Check if package manager is in PATH
which brew uv pnpm gem mise
```

**Log File Issues**

```bash
# Check log directory permissions
ls -la ~/.macbuild/logs/
```

### Debug Mode

Enable comprehensive debugging:

```bash
LOG_LEVEL=DEBUG ./macbuild 2>&1 | tee debug.log
```

### Log Locations

- **Main Log**: `~/.macbuild/logs/macbuild.log`
- **Test Logs**: `./test_results.log`
- **Coverage Reports**: `./coverage/coverage_report.txt`

## Contributing

1. **Fork** the repository
2. **Create** a feature branch
3. **Add** tests for new functionality
4. **Run** the test suite: `make test`
5. **Ensure** code passes linting: `make lint`
6. **Submit** a pull request

### Testing Guidelines

- Add tests for new functions in `test_macbuild_simple.sh`
- Ensure coverage remains above 60%
- Test both success and failure scenarios
- Validate INI parsing for new package sections

## License

This project is open source. See the repository for license details.

## Links

- **Homebrew**: https://brew.sh/
- **uv (Python)**: https://github.com/astral-sh/uv
- **pnpm (Node.js)**: https://pnpm.io/
- **mise (Dev Tools)**: https://mise.jdx.dev/
