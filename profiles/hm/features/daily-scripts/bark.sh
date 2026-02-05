#!/usr/bin/env bash
# Bark notification script for sending push notifications to iOS devices
# Dependencies: curl, jq

set -eEuo pipefail
shopt -s failglob

# Global constants
declare -r SCRIPT_NAME="$(basename "$0")"
declare -r API_BASE_URL="${BARK_API_URL:-https://bark.pippaye.top}"
declare -r DEFAULT_KEY="${BARK_KEY:-ATZ7Ss3zz6iWagZynwLjmf}"

# Global variables for cleanup
declare -g TEMP_DIR=""

# ============================================================================
# Cleanup Function
# ============================================================================
cleanup() {
    local exit_code=$?
    # Clean up temporary files and directories
    if [[ -n "${TEMP_DIR}" && -d "${TEMP_DIR}" ]]; then
        rm -rf "${TEMP_DIR}"
    fi
    return "${exit_code}"
}

trap cleanup EXIT INT TERM

# ============================================================================
# Error Handling and Logging
# ============================================================================
error() {
    local message="$1"
    echo "ERROR: ${message}" >&2
    return 1
}

warn() {
    local message="$1"
    echo "WARN: ${message}" >&2
}

info() {
    local message="$1"
    echo "INFO: ${message}" >&2
}

# ============================================================================
# Dependencies Check
# ============================================================================
check_dependencies() {
    local missing_deps=()
    
    # Check for required commands
    for cmd in curl jq; do
        if ! command -v "${cmd}" &> /dev/null; then
            missing_deps+=("${cmd}")
        fi
    done
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        error "Missing required dependencies: ${missing_deps[*]}"
        return 1
    fi
}

# ============================================================================
# URL Encoding Function
# ============================================================================
url_encode() {
    local string="$1"
    jq -Rr @uri <<< "$(printf '%s' "${string}")"
}

# ============================================================================
# Usage Function
# ============================================================================
usage() {
    cat << EOF
${SCRIPT_NAME} - Send push notifications via Bark

USAGE:
    ${SCRIPT_NAME} [OPTIONS] [POSITIONAL_ARGS]

POSITIONAL ARGUMENTS:
    The script supports three URL format patterns (key is required via -k/--key):
    
    1. /:body
       Send a simple notification with just body content
    
    2. /:title/:body
       Send a notification with title and body
    
    3. /:title/:subtitle/:body
       Send a notification with title, subtitle, and body
    
    Positional arguments are provided directly without flags.
    Note: API key must be provided via -k/--key option or BARK_KEY environment variable.

OPTIONS:
    -k, --key KEY              API key for Bark service (default: \$BARK_KEY)
    -t, --title TITLE          Notification title
    -s, --subtitle SUBTITLE    Notification subtitle
    -b, --body BODY            Notification body content
    -g, --group GROUP          Group name for organizing notifications
    -l, --level LEVEL          Interrupt level: critical|active|timeSensitive|passive
    --sound SOUND              Custom sound for notification
    --icon ICON_URL            Custom icon URL
    --image IMAGE_URL          Image URL to attach
    --url URL                  URL to open when notification is tapped
    --copy TEXT                Text to copy when notification is tapped
    --badge BADGE              Badge number
    --call CALL                "1" to repeat call sound
    --autoCopy AUTOCOPY        "1" for auto-copy (iOS <14.5)
    --markdown MARKDOWN        Markdown content (overrides body)
    --id ID                    Notification ID for updating
    --delete DELETE            "1" to delete notification
    --isArchive ARCHIVE        "1" to save, "0" to not save
    --request-type TYPE        "GET" or "POST" (default: GET)
    --json                     Use JSON POST request format
    --device-keys KEYS         Comma-separated device keys for bulk push
    -h, --help                 Show this help message

EXAMPLES:
    # Simple notification with body (key via environment variable)
    BARK_KEY=mykey ${SCRIPT_NAME} "Hello World"
    
    # With title and body (key via -k)
    ${SCRIPT_NAME} -k mykey "Welcome" "Hello World"
    
    # With title, subtitle, and body
    ${SCRIPT_NAME} -k mykey "Welcome" "Greeting" "Hello World"
    
    # Using --key option
    ${SCRIPT_NAME} --key mykey "Message content"

ENVIRONMENT VARIABLES:
    BARK_KEY               Default API key
    BARK_API_URL           Custom API base URL (default: https://api.day.app)

EXIT CODES:
    0                      Success
    1                      Error (missing dependencies, invalid arguments, API error)
    2                      Usage error (invalid options or arguments)

EOF
}

# ============================================================================
# Argument Parsing
# ============================================================================
parse_arguments() {
    local key="${DEFAULT_KEY}"
    local title=""
    local subtitle=""
    local body=""
    local request_type="GET"
    local use_json=false
    local device_keys=""
    
    # Associative array for query parameters
    declare -A query_params=()
    
    local positional_args=()
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                usage
                exit 0
                ;;
            -k|--key)
                key="$2"
                shift 2
                ;;
            -t|--title)
                title="$2"
                shift 2
                ;;
            -s|--subtitle)
                subtitle="$2"
                shift 2
                ;;
            -b|--body)
                body="$2"
                shift 2
                ;;
            --request-type)
                request_type="${2^^}"  # Convert to uppercase
                shift 2
                ;;
            --json)
                use_json=true
                shift
                ;;
            --device-keys)
                device_keys="$2"
                shift 2
                ;;
            --*)
                # Any other --param automatically becomes a query parameter
                local param_name="${1#--}"  # Remove --
                query_params["${param_name}"]="$2"
                shift 2
                ;;
            -*)
                error "Unknown option: $1"
                usage >&2
                return 2
                ;;
            *)
                positional_args+=("$1")
                shift
                ;;
        esac
    done
    
    # Process positional arguments
    # Format: /:body or /:title/:body or /:title/:subtitle/:body
    # NOTE: key is NOT a positional argument, must be passed via -k/--key or BARK_KEY env var
    case ${#positional_args[@]} in
        1)
            # /:body
            body="${positional_args[0]}"
            ;;
        2)
            # /:title/:body
            title="${positional_args[0]}"
            body="${positional_args[1]}"
            ;;
        3)
            # /:title/:subtitle/:body
            title="${positional_args[0]}"
            subtitle="${positional_args[1]}"
            body="${positional_args[2]}"
            ;;
        *)
            if [[ ${#positional_args[@]} -gt 0 ]]; then
                error "Invalid number of positional arguments: ${#positional_args[@]}"
                usage >&2
                return 2
            fi
            ;;
    esac
    
    # Validate required parameters
    if [[ -z "${key}" ]]; then
        error "API key is required. Provide via -k/--key option or BARK_KEY environment variable"
        usage >&2
        return 2
    fi
    
    # Check if body or markdown query param is provided
    if [[ -z "${body}" && -z "${query_params[markdown]}" ]]; then
        error "Either --body or --markdown must be provided"
        usage >&2
        return 2
    fi
    
    # Validate request type
    if [[ "${request_type}" != "GET" && "${request_type}" != "POST" ]]; then
        error "Invalid request-type: ${request_type}. Must be GET or POST"
        return 2
    fi
    
    # Serialize query_params array to pass to function
    local query_params_str=""
    for param_key in "${!query_params[@]}"; do
        query_params_str+="${param_key}=${query_params[${param_key}]}"$'\n'
    done
    
    # Call the send function with parsed arguments
    send_notification \
        "${key}" \
        "${title}" \
        "${subtitle}" \
        "${body}" \
        "${request_type}" \
        "${use_json}" \
        "${device_keys}" \
        "${query_params_str}"
}

# ============================================================================
# Send Notification Function
# ============================================================================
send_notification() {
    local key="$1"
    local title="$2"
    local subtitle="$3"
    local body="$4"
    local request_type="$5"
    local use_json="$6"
    local device_keys="$7"
    local query_params_str="$8"
    
    # Reconstruct query_params associative array
    declare -A query_params=()
    while IFS='=' read -r param_key param_value; do
        [[ -n "${param_key}" ]] && query_params["${param_key}"]="${param_value}"
    done <<< "${query_params_str}"
    
    local api_url curl_opts query_string
    
    # Build API URL based on request type and format
    if [[ "${use_json}" == true || "${request_type}" == "POST" && -n "${device_keys}" ]]; then
        # Use /push endpoint for JSON requests with device_keys or JSON format
        api_url="${API_BASE_URL}/push"
    else
        # Build traditional URL with key and positional parameters
        api_url="${API_BASE_URL}/${key}"
        
        # Add positional parameters to URL if provided
        if [[ -n "${title}" || -n "${subtitle}" ]]; then
            if [[ -n "${title}" ]]; then
                api_url+="/$(url_encode "${title}")"
                if [[ -n "${subtitle}" ]]; then
                    api_url+="/$(url_encode "${subtitle}")"
                fi
            fi
        fi
        
        # Add body to URL path (only if markdown is not in query params)
        if [[ -n "${body}" && -z "${query_params[markdown]:-}" ]]; then
            api_url+="/$(url_encode "${body}")"
        fi
    fi
    
    # Prepare curl options
    curl_opts=("-s" "-X" "${request_type}")
    
    if [[ "${use_json}" == true || -n "${device_keys}" ]]; then
        # JSON request
        curl_opts+=("-H" "Content-Type: application/json; charset=utf-8")
        
        # Build JSON payload
        local json_payload="{"
        local first_field=true
        
        # Add key if using /push endpoint
        if [[ "${api_url}" == *"/push" ]]; then
            if [[ -n "${device_keys}" ]]; then
                # Bulk push with device_keys
                json_payload+=$'\n  "device_keys": ['
                local first=true
                while IFS=',' read -r dev_key; do
                    dev_key=$(echo "${dev_key}" | xargs)  # Trim whitespace
                    if [[ "${first}" == true ]]; then
                        json_payload+="\"${dev_key}\""
                        first=false
                    else
                        json_payload+=", \"${dev_key}\""
                    fi
                done <<< "${device_keys}"
                json_payload+=$'\n  ]'
                first_field=false
            else
                json_payload+=$'\n  "device_key": "'"${key}"'"'
                first_field=false
            fi
        fi
        
        # Add notification content
        [[ -n "${title}" ]] && { [[ "${first_field}" == false ]] && json_payload+=","; json_payload+=$'\n  "title": "'"${title}"'"'; first_field=false; }
        [[ -n "${subtitle}" ]] && { [[ "${first_field}" == false ]] && json_payload+=","; json_payload+=$'\n  "subtitle": "'"${subtitle}"'"'; first_field=false; }
        [[ -n "${body}" ]] && { [[ "${first_field}" == false ]] && json_payload+=","; json_payload+=$'\n  "body": "'"${body}"'"'; first_field=false; }
        
        # Add all query parameters from associative array
        for param_key in "${!query_params[@]}"; do
            local param_value="${query_params[${param_key}]}"
            [[ "${first_field}" == false ]] && json_payload+=","
            json_payload+=$'\n  "'"${param_key}"'": "'"${param_value}"'"'
            first_field=false
        done
        
        json_payload+=$'\n}'
        
        # Execute JSON request
        echo "🚀 Sending JSON request..."
        echo "📡 curl ${curl_opts[*]} '${api_url}' -d '${json_payload}'"
        local response
        response=$(curl "${curl_opts[@]}" "${api_url}" -d "${json_payload}" 2>&1) || true
        if [[ -z "${response}" ]]; then
            error "Failed to send notification: no response from server"
            return 1
        fi
    else
        # Form-encoded or query-string request
        query_string=""
        
        # Build query string from associative array
        for param_key in "${!query_params[@]}"; do
            local param_value="${query_params[${param_key}]}"
            query_string+="&${param_key}=$(url_encode "${param_value}")"
        done
        
        # Remove leading ampersand
        query_string="${query_string#&}"
        
        if [[ "${request_type}" == "GET" ]]; then
            # Add query parameters to URL for GET request
            if [[ -n "${query_string}" ]]; then
                api_url+="?${query_string}"
            fi
            
            echo "🚀 Sending GET request..."
            echo "📡 curl ${curl_opts[*]} '${api_url}'"
            local response
            response=$(curl "${curl_opts[@]}" "${api_url}" 2>&1) || true
            if [[ -z "${response}" ]]; then
                error "Failed to send notification: no response from server"
                return 1
            fi
        else
            # POST request with form data
            curl_opts+=("-H" "Content-Type: application/x-www-form-urlencoded")
            
            # Build POST data (HTTP body) from all parameters
            # Title, subtitle, body are also query params in POST, not special
            local post_data=""
            
            [[ -n "${title}" ]] && post_data+="title=$(url_encode "${title}")&"
            [[ -n "${subtitle}" ]] && post_data+="subtitle=$(url_encode "${subtitle}")&"
            [[ -n "${body}" ]] && post_data+="body=$(url_encode "${body}")&"
            
            # Add query string
            post_data+="${query_string}"
            
            # Remove trailing ampersand
            post_data="${post_data%&}"
            
            echo "🚀 Sending POST request..."
            echo "📡 curl ${curl_opts[*]} '${api_url}' -d '${post_data}'"
            local response
            response=$(curl "${curl_opts[@]}" "${api_url}" -d "${post_data}" 2>&1) || true
            if [[ -z "${response}" ]]; then
                error "Failed to send notification: no response from server"
                return 1
            fi
        fi
    fi
    
    # Check response
    if echo "${response}" | grep -q '"code":200'; then
        info "✅ Notification sent successfully"
        return 0
    else
        error "❌ API returned error response: ${response}"
        return 1
    fi
}

# ============================================================================
# Main Entry Point
# ============================================================================
main() {
    check_dependencies || return $?
    parse_arguments "$@" || return $?
}

main "$@"
