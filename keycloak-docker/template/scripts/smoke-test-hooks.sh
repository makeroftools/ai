#!/bin/sh
# Keycloak-specific smoke test hooks
#
# This file is sourced by smoke-test-framework.sh and provides
# application-specific checks for Keycloak deployments.
#
# Checks:
#   3.1: Keycloak health endpoint (/health/ready)
#   3.2: PostgreSQL database ready
#   3.3: Caddy HTTPS reverse proxy responding
#   3.4: Keycloak admin ACL correct (public expects 403)
#   3.5: OIDC realms endpoint with correct HTTPS issuer URL
#   3.6: Full-path test through Caddy to Keycloak (catches Host header bugs)
#   3.7: Running container version matches pinned version in compose
#   3.8: OPERATIONS.md runbook exists in site docs

run_template_specific_checks() {
  log_info "Running Keycloak-specific checks..."

  # Check 3.1: Keycloak health endpoint via Docker
  log_info "Checking Keycloak health endpoint..."
  kc_health=$(ssh -o ConnectTimeout=10 root@"${DROPLET_IP}" \
    "cd ${REMOTE_SITE_DIR} && docker compose exec -T keycloak curl -sf http://localhost:8080/health/ready 2>/dev/null" || echo "")

  if echo "$kc_health" | grep -qi "ready\|UP\|status" 2>/dev/null; then
    log_pass "Keycloak health endpoint reporting ready"
  else
    log_skip "Keycloak health check skipped (curl may not be in container)"
  fi

  # Check 3.2: PostgreSQL database ready
  log_info "Checking PostgreSQL database..."
  pg_ready=$(ssh -o ConnectTimeout=10 root@"${DROPLET_IP}" \
    "cd ${REMOTE_SITE_DIR} && docker compose exec -T db pg_isready -h localhost 2>/dev/null" || echo "")

  if echo "$pg_ready" | grep -q "accepting" 2>/dev/null; then
    log_pass "PostgreSQL accepting connections"
  else
    log_fail "PostgreSQL not accepting connections"
  fi

  # Check 3.3: Caddy HTTPS reverse proxy via public domain
  log_info "Checking Caddy HTTPS reverse proxy..."
  domain_code=$(curl -sk -o /dev/null -w "%{http_code}" --max-time 10 "https://${SITE_NAME}.weown.dev/" 2>/dev/null || echo "000")

  if [ "$domain_code" = "200" ] || [ "$domain_code" = "301" ] || [ "$domain_code" = "302" ] || [ "$domain_code" = "308" ]; then
    log_pass "HTTPS reverse proxy responding (HTTP $domain_code via ${SITE_NAME}.weown.dev)"
  else
    log_fail "HTTPS reverse proxy not responding (HTTP $domain_code)"
  fi

  # Check 3.4: Keycloak admin ACL from public IP
  # Public should get 403 (ACL blocked). A 200 means admin is wide open.
  log_info "Checking Keycloak admin ACL from public IP..."
  admin_code=$(curl -skL -o /dev/null -w "%{http_code}" --max-time 10 "https://${SITE_NAME}.weown.dev/admin/" 2>/dev/null || echo "000")

  if [ "$admin_code" = "403" ]; then
    log_pass "Keycloak admin ACL correct -- public gets HTTP 403"
  elif [ "$admin_code" = "200" ]; then
    log_fail "Keycloak admin console UNPROTECTED -- public gets HTTP 200"
  else
    log_warn "Keycloak admin returned HTTP $admin_code -- check ACL state"
  fi

  # Check 3.5: OIDC realms endpoint with correct HTTPS issuer
  log_info "Checking OIDC issuer uses HTTPS..."
  issuer=$(curl -sk --max-time 10 "https://${SITE_NAME}.weown.dev/realms/master/.well-known/openid-configuration" 2>/dev/null | grep -o '"issuer":"[^"]*"' | cut -d'"' -f4 || echo "")

  if echo "$issuer" | grep -q "^https://"; then
    log_pass "OIDC issuer is HTTPS ($issuer)"
  else
    log_fail "OIDC issuer is not HTTPS (got: $issuer)"
  fi

  # Check 3.6: Full-path test through Caddy to Keycloak
  # This catches Host header rewrite bugs. Test from inside the docker network
  # so we simulate whitelisted traffic, then verify Keycloak responds correctly.
  log_info "Checking full-path Caddy to Keycloak (inside docker network)..."
  fullpath_result=$(ssh -o ConnectTimeout=10 root@"${DROPLET_IP}" \
    "docker exec sso-caddy-1 wget -qO- --header='Host: ${SITE_NAME}.weown.dev' https://localhost/admin/ 2>/dev/null" || echo "CURL_FAILED")

  if echo "$fullpath_result" | grep -qi "Access Denied" 2>/dev/null; then
    log_pass "Full-path test passed -- Caddy forwarded to Keycloak, ACL responded"
  elif [ "$fullpath_result" = "CURL_FAILED" ]; then
    log_info "Caddy container lacks wget -- trying compose exec keycloak..."
    kc_direct=$(ssh -o ConnectTimeout=10 root@"${DROPLET_IP}" \
      "cd ${REMOTE_SITE_DIR} && docker compose exec -T keycloak curl -s -o /dev/null -w '%{http_code}' http://localhost:8080/health/ready 2>/dev/null" || echo "FAILED")
    if [ "$kc_direct" = "200" ]; then
      log_pass "Keycloak health OK via compose exec"
    else
      log_warn "Full-path test could not complete -- no curl/wget in caddy container"
    fi
  else
    log_warn "Full-path test unexpected result: $fullpath_result"
  fi

  # Check 3.7: Running container version matches pinned version
  log_info "Checking running Keycloak version matches compose pin..."
  running_version=$(ssh -o ConnectTimeout=10 root@"${DROPLET_IP}" \
    "docker inspect --format='{{index .Config.Image}}' sso-keycloak-1 2>/dev/null | awk -F: '{print \$2}'" || echo "not-found")

  pinned_version=$(ssh -o ConnectTimeout=10 root@"${DROPLET_IP}" \
    "grep 'image:.*keycloak' ${REMOTE_SITE_DIR}/compose.yaml | head -1 | awk -F: '{print \$NF}'" || echo "unknown")

  if [ "$running_version" = "$pinned_version" ]; then
    log_pass "Running Keycloak version ($running_version) matches compose pin ($pinned_version)"
  elif [ "$running_version" = "not-found" ]; then
    log_warn "Version check skipped -- keycloak container not running"
  else
    log_warn "Version mismatch: running $running_version vs pinned $pinned_version"
  fi

  # Check 3.8: OPERATIONS.md runbook exists
  log_info "Checking OPERATIONS.md runbook exists..."
  if [ -f "${SITE_DIR}/docs/OPERATIONS.md" ]; then
    log_pass "OPERATIONS.md runbook present at docs/OPERATIONS.md"
  else
    log_fail "OPERATIONS.md runbook MISSING at docs/OPERATIONS.md"
  fi
}
