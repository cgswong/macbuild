setup_logging() {
    [[ ! -d "$LOG_DIR" ]] && mkdir -p "$LOG_DIR"
    touch "$LOG_FILE" || {
        printf "ERROR: Cannot create log file %s\n" "$LOG_FILE" >&2
        exit 1
    }
}
log_message() {
    local level="$1" message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Always log to file
    printf "%s [%s] %s\n" "$timestamp" "$level" "$message" >> "$LOG_FILE"
    
    # Console output with color coding
    case "$level" in
        ERROR)
            printf "\033[31m%s [ERROR] %s\033[0m\n" "$timestamp" "$message" >&2 ;;
        WARN)
            printf "\033[33m%s [WARN] %s\033[0m\n" "$timestamp" "$message" >&2 ;;
        INFO)
            printf "%s [INFO] %s\n" "$timestamp" "$message" ;;
        DEBUG)
            [[ "$LOG_LEVEL" == "DEBUG" ]] && printf "%s [DEBUG] %s\n" "$timestamp" "$message" ;;
    esac
}
command_exists() {
    command -v "$1" &>/dev/null
}
check_file_readable() {
    [[ -r "$1" ]] || {
        log_message "ERROR" "File not readable: $1"
        return 1
    }
}
run_with_retry() {
    local cmd="$1" max_attempts="${2:-3}"
    
    for ((attempt=1; attempt<=max_attempts; attempt++)); do
        log_message "DEBUG" "Attempt $attempt: $cmd"
        if eval "$cmd"; then
            return 0
        fi
        [[ $attempt -lt $max_attempts ]] && sleep 2
    done
    
    log_message "ERROR" "Command failed after $max_attempts attempts: $cmd"
    return 1
}
parse_ini_section() {
    local section="$1"
    local file="$2"
    
    check_file_readable "$file" || return 1
    
    awk -v section="$section" '
        /^[ \t]*#/ { next }
        /^[ \t]*$/ { next }
        /^\[.*\]$/ {
            gsub(/^\[|\]$/, "")
            current = $0
            found = (current == section)
            next
        }
        found && NF >= 1 { print $1 }
    ' "$file"
}
install_xcode_tools() {
    if [[ -f "/Library/Developer/CommandLineTools/usr/bin/clang" ]]; then
        log_message "INFO" "Xcode command line tools already installed"
        return 0
    fi
    
    log_message "INFO" "Installing Xcode command line tools"
    if xcode-select --install; then
        log_message "INFO" "Xcode command line tools installed successfully"
    else
        log_message "ERROR" "Failed to install Xcode command line tools"
        return 1
    fi
}
setup_homebrew() {
    if command_exists brew; then
        log_message "INFO" "Updating Homebrew"
        run_with_retry "brew update && brew upgrade"
    else
        log_message "INFO" "Installing Homebrew"
        run_with_retry '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
    fi
}
install_homebrew_packages() {
    local section="$1" install_cmd="$2"
    
    command_exists brew || {
        log_message "ERROR" "Homebrew not available"
        return 1
    }
    
    check_file_readable "$PKG_FILE" || return 1
    
    log_message "INFO" "Installing $section packages"
    # Use process substitution to avoid subshell variable issues
    while IFS= read -r package; do
        [[ -n "$package" ]] || continue
        log_message "DEBUG" "Installing $section package: $package"
        run_with_retry "$install_cmd $package"
    done < <(parse_ini_section "$section" "$PKG_FILE")
}
install_python_packages() {
    command_exists uv || {
        log_message "WARN" "uv not available, skipping Python packages"
        return 0
    }
    
    check_file_readable "$PKG_FILE" || return 1
    
    log_message "INFO" "Installing Python packages"
    while IFS= read -r package; do
        [[ -n "$package" ]] || continue
        log_message "DEBUG" "Installing Python package: $package"
        run_with_retry "uv tool install --upgrade $package"
    done < <(parse_ini_section "python" "$PKG_FILE")
}
install_node_packages() {
    command_exists pnpm || {
        log_message "WARN" "pnpm not available, skipping Node packages"
        return 0
    }
    
    check_file_readable "$PKG_FILE" || return 1
    
    log_message "INFO" "Installing Node packages"
    while IFS= read -r package; do
        [[ -n "$package" ]] || continue
        log_message "DEBUG" "Installing Node package: $package"
        run_with_retry "pnpm install -g $package"
    done < <(parse_ini_section "node" "$PKG_FILE")
}
install_ruby_packages() {
    command_exists gem || {
        log_message "WARN" "gem not available, skipping Ruby packages"
        return 0
    }
    
    check_file_readable "$PKG_FILE" || return 1
    
    log_message "INFO" "Installing Ruby packages"
    while IFS= read -r package; do
        [[ -n "$package" ]] || continue
        log_message "DEBUG" "Installing Ruby package: $package"
        run_with_retry "gem install $package"
    done < <(parse_ini_section "gem" "$PKG_FILE")
}
install_mise_packages() {
    command_exists mise || {
        log_message "WARN" "mise not available, skipping mise packages"
        return 0
    }
    
    check_file_readable "$PKG_FILE" || return 1
    
    log_message "INFO" "Installing mise packages"
    while IFS= read -r package; do
        [[ -n "$package" ]] || continue
        log_message "DEBUG" "Installing mise package: $package"
        run_with_retry "mise use --global $package"
    done < <(parse_ini_section "mise" "$PKG_FILE")
}
update_all_tools() {
    log_message "INFO" "Starting system updates"
    
    command_exists brew && {
        log_message "INFO" "Updating Homebrew packages"
        run_with_retry "brew update && brew upgrade"
    }
    
    command_exists pnpm && {
        log_message "INFO" "Updating Node packages"
        run_with_retry "pnpm update --global"
    }
    
    command_exists uv && {
        log_message "INFO" "Updating Python packages"
        run_with_retry "uv tool upgrade --all"
    }
    
    command_exists mise && {
        log_message "INFO" "Updating mise packages"
        run_with_retry "mise upgrade"
    }
    
    log_message "INFO" "System updates completed"
}
setup_auto_updates() {
    local plist_source="${SCRIPT_HOME}/files/${OS_UPDATE_FILE}"
    local plist_dest="${OS_UPDATE_PATH}/${OS_UPDATE_FILE}"
    
    check_file_readable "$plist_source" || {
        log_message "WARN" "Auto-update plist not found: $plist_source"
        return 1
    }
    
    log_message "INFO" "Setting up automatic updates"
    [[ ! -d "$OS_UPDATE_PATH" ]] && mkdir -p "$OS_UPDATE_PATH"
    
    cp "$plist_source" "$plist_dest" && \
    chmod 644 "$plist_dest" && \
    launchctl unload "$plist_dest" 2>/dev/null || true && \
    launchctl load "$plist_dest"
}
install_package_type() {
    case "$1" in
        brew)
            install_homebrew_packages "homebrew" "brew install"
            ;;
        apps)
            install_homebrew_packages "cask" "brew install --cask"
            ;;
        python)
            install_python_packages
            ;;
        node)
            install_node_packages
            ;;
        ruby)
            install_ruby_packages
            ;;
        mise)
            install_mise_packages
            ;;
        all)
            install_homebrew_packages "homebrew" "brew install"
            install_homebrew_packages "cask" "brew install --cask"
            install_python_packages
            install_node_packages
            install_ruby_packages
            install_mise_packages
            ;;
        *)
            log_message "ERROR" "Unknown package type: $1"
            return 1
            ;;
    esac
}
print_version() {
    printf "%s %s\n" "$SCRIPT_NAME" "$SCRIPT_VERSION"
}
print_usage() {
    cat << 'EOF'
Install tools and configure macOS using Homebrew, pnpm, uv, gem, and mise.

Usage: macbuild [options]

Options:
  -h, --help              Show this help message
  --version               Show version information
  --log-level LEVEL       Set logging level (DEBUG|INFO|WARN|ERROR)
  --update-only           Update existing tools only
  --install-only TYPE     Install specific package type only
                         (brew|apps|python|node|ruby|mise|all)

Environment Variables:
  LOG_LEVEL              Logging level (default: INFO)
  LOG_DIR                Log directory (default: ~/.macbuild/logs)
  PKG_FILE               Package configuration file

Examples:
  macbuild                        # Full installation
  macbuild --update-only          # Update existing packages
  macbuild --install-only python  # Install Python packages only
  LOG_LEVEL=DEBUG macbuild        # Enable debug logging
EOF
}
main() {
    local update_only=false install_only=""
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                print_usage; exit 0 ;;
            --version)
                print_version; exit 0 ;;
            --log-level)
                [[ -n "${2:-}" ]] || { log_message "ERROR" "--log-level requires an argument"; exit 1; }
                LOG_LEVEL="$2"; shift 2 ;;
            --log-level=*)
                LOG_LEVEL="${1#*=}"; shift ;;
            --update-only)
                update_only=true; shift ;;
            --install-only)
                [[ -n "${2:-}" ]] || { log_message "ERROR" "--install-only requires an argument"; exit 1; }
                install_only="$2"; shift 2 ;;
            --install-only=*)
                install_only="${1#*=}"; shift ;;
            -*)
                log_message "ERROR" "Unknown option: $1"; print_usage >&2; exit 1 ;;
            *)
                log_message "ERROR" "Unexpected argument: $1"; print_usage >&2; exit 1 ;;
        esac
    done
    
    # Initialize logging system
    setup_logging
    log_message "INFO" "Starting $SCRIPT_NAME v$SCRIPT_VERSION"
    
    # Handle update-only mode - skip installation, just update existing packages
    if [[ "$update_only" == true ]]; then
        log_message "INFO" "Running in update-only mode"
        update_all_tools
        log_message "INFO" "Update completed successfully"
        exit 0
    fi
    
    # Main installation workflow
    install_xcode_tools || { log_message "ERROR" "Failed to install Xcode tools"; exit 1; }
    setup_homebrew || { log_message "ERROR" "Failed to setup Homebrew"; exit 1; }
    setup_auto_updates
    
    # Install packages based on user selection or install all
    if [[ -n "$install_only" ]]; then
        log_message "INFO" "Installing package type: $install_only"
        install_package_type "$install_only"
    else
        log_message "INFO" "Installing all package types"
        install_package_type "all"
    fi
    
    log_message "INFO" "Installation completed successfully"
}
