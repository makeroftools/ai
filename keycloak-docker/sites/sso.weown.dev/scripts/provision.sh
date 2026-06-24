#!/usr/bin/env bash
# sso — Keycloak Realm & User Provisioning Script
#
# Automates post-deployment setup: creates the team realm, admin users,
# and optionally registers an OIDC client. Designed to be re-runnable
# (idempotent) so it's safe to run again after partial failures.
#
# Secret flow (ADR-006):
#   This script does NOT contain or prompt for secrets. It authenticates
#   to Infisical using the Machine Identity that already exists on the
#   droplet's filesystem (/opt/sso/.infisical-auth.env), then fetches
#   KEYCLOAK_ADMIN_PASSWORD from Infisical at runtime. The admin password
#   lives only in process memory — never on disk.
#
# Usage:
#   ./scripts/provision.sh root@<droplet-ip>
#
#   SSH access to the droplet is required to read the Infisical auth file
#   and run `infisical` CLI commands on the host. The Keycloak Admin REST
#   API is called over HTTPS to sso.weown.id (not via SSH tunnel).
#
# Environment:
#   KEYCLOAK_URL     Keycloak base URL (default: https://sso.weown.id)
#   MOT_PASSWORD     Override mot's password (prompt if not set)
#   GTM_PASSWORD     Override GTM/yonks' password (prompt if not set)
#   ADMIN_USER       Keycloak admin username (default: mot)
#   INFISICAL_SSH    SSH target for Infisical CLI (default: first arg)
#
# Requirements:
#   - curl, jq, ssh on the operator workstation
#   - SSH key loaded in ssh-agent with access to the droplet
#   - The droplet's Infisical Machine Identity must have read access to
#     the project secrets (KEYCLOAK_ADMIN_PASSWORD)
#
# Exit codes:
#   0  — all provisioning completed successfully
#   1  — missing dependencies or invalid arguments
#   2  — authentication failure (Infisical or Keycloak)
#   3  — API error during provisioning

set -euo pipefail

# ──────────────────────────────────────────────
# Configuration
# ──────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Load site.conf for Infisical project ID / env
source "$SCRIPT_DIR/lib.sh"
load_site_conf "$PROJECT_DIR/site.conf"

: "${INFISICAL_PROJECT_ID:?INFISICAL_PROJECT_ID not set in site.conf}"
INFISICAL_ENV="${INFISICAL_ENV:-prod}"

KEYCLOAK_URL="${KEYCLOAK_URL:-https://sso.weown.id}"
ADMIN_USER="${ADMIN_USER:-mot}"
INFISICAL_SSH="${1:-}"
SSH_HOST="$INFISICAL_SSH"  # alias for clarity

REALM_NAME="weown"

# ──────────────────────────────────────────────
# Dependency Check
# ──────────────────────────────────────────────

check_deps() {
  local missing=0
  for cmd in curl jq ssh; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
      echo "ERROR: $cmd not found. Install it and try again." >&2
      missing=1
    fi
  done
  return "$missing"
}

# ──────────────────────────────────────────────
# Infisical Secret Fetcher (via SSH + Machine ID)
# ──────────────────────────────────────────────

fetch_secret() {
  local secret_name="$1"
  local result

  if [[ -z "$SSH_HOST" ]]; then
    echo "ERROR: SSH host required to fetch secrets from Infisical" >&2
    echo "       Usage: $0 root@<droplet-ip>" >&2
    exit 1
  fi

  # Fetch the secret using infisical CLI on the droplet.
  # The Machine Identity auth file is already on the droplet at
  # /opt/sso/.infisical-auth.env — infisical CLI reads it automatically.
  result=$(ssh "$SSH_HOST" \
    "infisical export --projectId=$INFISICAL_PROJECT_ID --env=$INFISICAL_ENV --format=json 2>/dev/null \
     | jq -r '.[\"$secret_name\"] // empty'" 2>/dev/null || true)

  if [[ -z "$result" ]]; then
    echo "ERROR: Secret '$secret_name' not found in Infisical project $INFISICAL_PROJECT_ID" >&2
    echo "       Verify: ssh $SSH_HOST 'infisical secrets get $secret_name --projectId=$INFISICAL_PROJECT_ID --env=$INFISICAL_ENV'" >&2
    return 1
  fi

  echo "$result"
}

# ──────────────────────────────────────────────
# Keycloak Admin API Helpers
# ──────────────────────────────────────────────

KC_BASE="$KEYCLOAK_URL/admin/realms"

# Authenticate to Keycloak as the admin user.
# Returns an access token on stdout. The token expires after
# the configured Access Token Lifespan (default 5 minutes), so
# call this once at the start and reuse the token.
get_admin_token() {
  local admin_password="$1"
  local token

  token=$(curl -sS -X POST "$KEYCLOAK_URL/realms/master/protocol/openid-connect/token" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d "client_id=admin-cli" \
    -d "username=$ADMIN_USER" \
    -d "password=$admin_password" \
    -d "grant_type=password" 2>/dev/null)

  local access_token
  access_token=$(echo "$token" | jq -r '.access_token // empty')

  if [[ -z "$access_token" ]]; then
    local error_desc
    error_desc=$(echo "$token" | jq -r '.error_description // .error // "unknown"' 2>/dev/null || echo "parse failure")
    echo "ERROR: Keycloak authentication failed for user '$ADMIN_USER': $error_desc" >&2
    return 2
  fi

  echo "$access_token"
}

# Make an authenticated Keycloak Admin API request.
# Usage: kc_api <token> <method> <endpoint> [body]
kc_api() {
  local token="$1"
  local method="$2"
  local endpoint="$3"
  local body="${4:-}"

  local url="$KEYCLOAK_URL/admin/$endpoint"
  local args=(-sS -X "$method" -H "Authorization: Bearer $token" -H "Content-Type: application/json")

  if [[ -n "$body" ]]; then
    args+=(-d "$body")
  fi

  curl "${args[@]}" "$url"
}

# Wait for Keycloak to be ready (health endpoint returns non-404).
# Keycloak with KC_HEALTH_ENABLED=true exposes /health/ready, but on
# the MinimOS image it returns 404 (known issue — see compose.prod.yaml
# healthcheck using pidof java). We use the master realm metadata endpoint
# which reliably returns 200 when Keycloak is running.
wait_for_keycloak() {
  local max_attempts=30
  local attempt=0

  echo -n "==> Waiting for Keycloak at $KEYCLOAK_URL ... "

  while [[ $attempt -lt $max_attempts ]]; do
    if curl -sf "$KEYCLOAK_URL/realms/master" >/dev/null 2>&1; then
      echo "OK"
      return 0
    fi
    attempt=$((attempt + 1))
    sleep 2
  done

  echo "TIMEOUT"
  echo "ERROR: Keycloak not reachable at $KEYCLOAK_URL after $((max_attempts * 2)) seconds" >&2
  return 1
}

# ──────────────────────────────────────────────
# Provisioning Functions
# ──────────────────────────────────────────────

create_realm() {
  local token="$1"
  local realm="$2"

  echo ""
  echo "==> Creating realm '$realm'..."

  # Check if realm already exists (idempotent)
  local existing
  existing=$(kc_api "$token" "GET" "realms/$realm" | jq -r '.realm // empty')

  if [[ "$existing" == "$realm" ]]; then
    echo "    Realm '$realm' already exists — skipping create"
    return 0
  fi

  local body
  body=$(cat <<JSON
{
  "realm": "$realm",
  "enabled": true,
  "displayName": "WeOwn",
  "displayNameHtml": "<b>WeOwn</b>",
  "loginWithEmailAllowed": false,
  "editUsernameAllowed": false,
  "registrationAllowed": false,
  "registrationEmailAsUsername": false,
  "rememberMe": false,
  "resetPasswordAllowed": true,
  "verifyEmail": false,

  "passwordPolicy": "length(8) and upperCase(1) and digits(1) and notUsername(1)",

  "accessTokenLifespan": 300,
  "ssoSessionMaxLifespan": 28800,
  "ssoSessionIdleTimeout": 14400,
  "offlineSessionMaxLifespan": 2592000,
  "accessCodeLifespan": 60,
  "accessCodeLifespanUserAction": 300,
  "actionTokenGeneratedByAdminLifespan": 7200,
  "actionTokenGeneratedByUserLifespan": 300,

  "sslRequired": "external",
  "bruteForceProtected": true,
  "maxFailureWaitSeconds": 900,
  "minimumQuickLoginWaitSeconds": 60,
  "waitIncrementSeconds": 60,
  "quickLoginCheckMilliSeconds": 1000,
  "maxDeltaTimeSeconds": 43200,
  "failureFactor": 30,

  "eventsEnabled": true,
  "eventsExpiration": 15552000,
  "adminEventsEnabled": true,
  "adminEventsDetailsEnabled": true
}
JSON
)

  local response
  response=$(kc_api "$token" "POST" "realms" "$body")
  local http_code
  http_code=$(echo "$response" | jq -r '.error // empty' 2>/dev/null || echo "")

  if [[ -n "$http_code" ]]; then
    echo "ERROR: Failed to create realm '$realm': $(echo "$response" | jq -r '.errorMessage // .error' 2>/dev/null || echo "$response")" >&2
    return 3
  fi

  echo "    Realm '$realm' created successfully"
}

create_user() {
  local token="$1"
  local realm="$2"
  local username="$3"
  local first_name="$4"
  local last_name="$5"
  local email="$6"
  local password="$7"
  local is_temporary="${8:-true}"   # default: require password change on first login

  echo ""
  echo "==> Creating user '$username'..."

  # Check if user already exists (idempotent)
  local existing_user
  existing_user=$(kc_api "$token" "GET" "realms/$realm/users?username=$username&exact=true" | jq -r '.[0].id // empty')

  if [[ -n "$existing_user" ]]; then
    echo "    User '$username' already exists (id: $existing_user) — skipping create"
    echo "$existing_user"
    return 0
  fi

  local body
  body=$(cat <<JSON
{
  "username": "$username",
  "firstName": "$first_name",
  "lastName": "$last_name",
  "email": "$email",
  "emailVerified": false,
  "enabled": true,
  "temporary": $is_temporary,
  "credentials": [
    {
      "type": "password",
      "value": "$password",
      "temporary": $is_temporary
    }
  ]
}
JSON
)

  # POST returns 201 with Location header — use -i to capture it
  local response
  response=$(curl -sS -i -X POST "$KEYCLOAK_URL/admin/realms/$realm/users" \
    -H "Authorization: Bearer $token" \
    -H "Content-Type: application/json" \
    -d "$body" 2>/dev/null)

  local status_line
  status_line=$(echo "$response" | grep -E "^HTTP/" | head -1 || true)
  local http_code
  http_code=$(echo "$status_line" | awk '{print $2}' || echo "000")

  if [[ "$http_code" != "201" ]]; then
    local error_body
    error_body=$(echo "$response" | sed -n '/^$/,//p' | tail -n +2 || echo "$response")
    echo "ERROR: Failed to create user '$username' (HTTP $http_code): $(echo "$error_body" | jq -r '.errorMessage // .error // "unknown"' 2>/dev/null || echo "$error_body")" >&2
    return 3
  fi

  # Extract user ID from Location header
  local user_id
  user_id=$(echo "$response" | grep -i "^Location:" | grep -oE '[a-f0-9-]{36}$' || echo "")

  echo "    User '$username' created with temporary password"
  echo "$user_id"
}

# Assign realm-management admin role to a user.
# This gives the user admin access to the specified realm (NOT master).
assign_realm_admin_role() {
  local token="$1"
  local realm="$2"
  local user_id="$3"

  echo ""
  echo "==> Assigning realm admin roles to user $user_id..."

  # Get the realm-management client ID
  local rm_client_id
  rm_client_id=$(kc_api "$token" "GET" "realms/$realm/clients?clientId=realm-management" | jq -r '.[0].id // empty')

  if [[ -z "$rm_client_id" ]]; then
    echo "ERROR: realm-management client not found in realm '$realm'" >&2
    return 3
  fi

  # Get available realm-management roles
  local roles
  roles=$(kc_api "$token" "GET" "realms/$realm/users/$user_id/role-mappings/clients/$rm_client_id/available" 2>/dev/null)

  # Assign the admin role (the broadest realm-management role)
  local admin_role
  admin_role=$(echo "$roles" | jq -c '[.[] | select(.name == "admin")]' 2>/dev/null || echo "[]")

  if [[ "$admin_role" == "[]" ]] || [[ -z "$admin_role" ]]; then
    echo "    WARN: 'admin' role not found in realm-management for realm '$realm'" >&2
    echo "    Available roles: $(echo "$roles" | jq -r '.[].name' 2>/dev/null | tr '\n' ', ' || echo "none")" >&2
    return 3
  fi

  local response
  response=$(kc_api "$token" "POST" "realms/$realm/users/$user_id/role-mappings/clients/$rm_client_id" "$admin_role" 2>/dev/null || true)
  local error
  error=$(echo "$response" | jq -r '.errorMessage // .error // empty' 2>/dev/null || echo "")

  if [[ -n "$error" ]]; then
    echo "    WARN: Failed to assign admin role: $error" >&2
    return 3
  fi

  echo "    Admin roles assigned for realm '$realm'"
}

# ──────────────────────────────────────────────
# Main
# ──────────────────────────────────────────────

main() {
  local ssh_host="${1:-}"

  echo "══════════════════════════════════════════════"
  echo "  sso Keycloak — Realm & User Provisioning"
  echo "══════════════════════════════════════════════"
  echo ""
  echo "  Target:  $KEYCLOAK_URL"
  echo "  Realm:   $REALM_NAME"
  echo "  Admin:   $ADMIN_USER"
  echo "  SSH:     ${ssh_host:-"(none — skipping Infisical fetch)"}"
  echo "  Project: $INFISICAL_PROJECT_ID / $INFISICAL_ENV"
  echo ""

  # Phase 0: Dependency check
  check_deps || exit 1

  # Phase 1: Wait for Keycloak
  wait_for_keycloak || exit 3

  # Phase 2: Fetch admin password from Infisical
  echo ""
  echo "==> Fetching admin credentials from Infisical..."

  local admin_password
  admin_password=$(fetch_secret "KEYCLOAK_ADMIN_PASSWORD") || exit 2

  echo "    Admin password fetched (length: ${#admin_password} chars)"

  # Phase 3: Authenticate to Keycloak
  echo ""
  echo "==> Authenticating to Keycloak as '$ADMIN_USER'..."

  local token
  token=$(get_admin_token "$admin_password") || exit 2

  # Clear admin password from this shell as soon as possible
  unset admin_password

  echo "    Authenticated successfully"

  # Phase 4: Create realm
  create_realm "$token" "$REALM_NAME" || exit 3

  # Phase 5: Create team users
  #
  # Each user's password is generated as a random string that is
  # temporary (must change on first login). The password is printed
  # to stdout once — the operator is responsible for sharing it
  # securely with the user (e.g., via Signal, encrypted email).
  #
  # For production, consider sending a "set password" email via
  # Keycloak's built-in email capabilities instead of printing
  # initial passwords.

  # mot — realm admin (already exists in master, create in weown)
  local mot_password="${MOT_PASSWORD:-}"
  if [[ -z "$mot_password" ]]; then
    mot_password=$(openssl rand -base64 24 2>/dev/null || date +%s | sha256sum | base64 | head -c 24)
  fi

  local mot_id
  mot_id=$(create_user "$token" "$REALM_NAME" "mot" "MOT" "Operator" "" "$mot_password" "true") || exit 3
  if [[ -n "$mot_id" ]]; then
    assign_realm_admin_role "$token" "$REALM_NAME" "$mot_id" || true
    echo ""
    echo "    ┌──────────────────────────────────────────────┐"
    echo "    │  mot temporary password: $mot_password"
    echo "    │  URL: $KEYCLOAK_URL/realms/$REALM_NAME/account"
    echo "    └──────────────────────────────────────────────┘"
  fi
  unset mot_password

  # GTM / Jason Yonks — realm admin
  local gtm_password="${GTM_PASSWORD:-}"
  if [[ -z "$gtm_password" ]]; then
    gtm_password=$(openssl rand -base64 24 2>/dev/null || date +%s | sha256sum | base64 | head -c 24)
  fi

  local gtm_id
  gtm_id=$(create_user "$token" "$REALM_NAME" "gtm" "Jason" "Yonks" "jason@weown.id" "$gtm_password" "true") || exit 3
  if [[ -n "$gtm_id" ]]; then
    assign_realm_admin_role "$token" "$REALM_NAME" "$gtm_id" || true
    echo ""
    echo "    ┌──────────────────────────────────────────────┐"
    echo "    │  gtm temporary password: $gtm_password"
    echo "    │  URL: $KEYCLOAK_URL/realms/$REALM_NAME/account"
    echo "    └──────────────────────────────────────────────┘"
  fi
  unset gtm_password

  # SHD / Shahid — optional, add if needed
  local shd_password="${SHD_PASSWORD:-}"
  if [[ -n "$SHD_PASSWORD" ]] || [[ -z "${SHD_SKIP:-}" ]]; then
    if [[ -z "$shd_password" ]]; then
      shd_password=$(openssl rand -base64 24 2>/dev/null || date +%s | sha256sum | base64 | head -c 24)
    fi

    local shd_id
    shd_id=$(create_user "$token" "$REALM_NAME" "shd" "Shahid" "" "shahid@weown.id" "$shd_password" "true") || true
    if [[ -n "$shd_id" ]]; then
      assign_realm_admin_role "$token" "$REALM_NAME" "$shd_id" || true
      echo ""
      echo "    ┌──────────────────────────────────────────────┐"
      echo "    │  shd temporary password: $shd_password"
      echo "    │  URL: $KEYCLOAK_URL/realms/$REALM_NAME/account"
      echo "    └──────────────────────────────────────────────┘"
    fi
    unset shd_password
  fi

  # ──────────────────────────────────────────────
  # Summary
  # ──────────────────────────────────────────────
  echo ""
  echo "══════════════════════════════════════════════"
  echo "  ✅ Provisioning Complete"
  echo "══════════════════════════════════════════════"
  echo ""
  echo "  Realm:     $REALM_NAME"
  echo "  Console:   $KEYCLOAK_URL/admin/$REALM_NAME/console/"
  echo "  Account:   $KEYCLOAK_URL/realms/$REALM_NAME/account"
  echo "  OIDC:      $KEYCLOAK_URL/realms/$REALM_NAME/.well-known/openid-configuration"
  echo ""
  echo "  Users created in realm '$REALM_NAME':"
  echo "    - mot   (realm admin)"
  echo "    - gtm   (realm admin — Jason Yonks)"
  if [[ -n "${SHD_PASSWORD:-}" ]] || [[ -z "${SHD_SKIP:-}" ]]; then
    echo "    - shd   (realm admin — Shahid)"
  fi
  echo ""
  echo "  Next steps:"
  echo "    1. Share temporary passwords securely with each user"
  echo "    2. Users must change password on first login"
  echo "    3. Register OIDC client apps in the weown realm"
  echo "    4. Configure email/verification when ready"
  echo ""
  echo "  To register a client app:"
  echo "    ./scripts/provision-client.sh <app-name> <redirect-uri>"
  echo ""

  # Security: clear token from shell
  unset token
}

main "$@"
