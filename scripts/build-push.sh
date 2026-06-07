#!/usr/bin/env bash
# Build all 8 Petclinic microservice Docker images for linux/arm64 (Graviton t4g nodes)
# and push them to the shared ECR registry (petclinic/{service}:{tag}).
#
# Usage:
#   ./scripts/build-push.sh --tag <commit-sha> [--app-repo /path/to/spring-petclinic-microservices]
#   ./scripts/build-push.sh --tag v1.0.0 --app-repo ../spring-petclinic-microservices 

#
# Requirements:
#   - aws CLI configured with ECR push permissions
#   - docker with buildx and QEMU (for cross-compilation on x86 hosts)
#   - Maven wrapper (./mvnw) present in the application repo

set -euo pipefail

REGION="eu-central-1"
TAG=""
APP_REPO=""
PLATFORM="linux/arm64"

while [[ $# -gt 0 ]]; do
  case $1 in
    --tag)      TAG="$2";      shift 2 ;;
    --app-repo) APP_REPO="$2"; shift 2 ;;
    --region)   REGION="$2";   shift 2 ;;
    --platform) PLATFORM="$2"; shift 2 ;;
    -h|--help)
      echo "Usage: $0 --tag <image-tag> [--app-repo <path>] [--region <region>] [--platform <platform>]"
      echo ""
      echo "  --tag        Image tag — commit SHA (7 chars) recommended, never 'latest' (required)"
      echo "  --app-repo   Path to spring-petclinic-microservices (default: ../spring-petclinic-microservices)"
      echo "  --region     AWS region (default: eu-central-1)"
      echo "  --platform   Docker target platform (default: linux/arm64)"
      exit 0
      ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

if [[ -z "$TAG" ]]; then
  echo "ERROR: --tag is required (use a 7-char commit SHA)" >&2
  exit 1
fi

if [[ "$TAG" == "latest" ]]; then
  echo "ERROR: 'latest' tag is not allowed. Use a commit SHA." >&2
  exit 1
fi

# Get absolute workspace paths so the script doesn't break after 'cd'
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLATFORM_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

if [[ -z "$APP_REPO" ]]; then
  APP_REPO="$(cd "${PLATFORM_ROOT}/../spring-petclinic-microservices" 2>/dev/null && pwd)" || true
else
  # Safely convert relative input paths to robust absolute paths immediately
  APP_REPO="$(cd "$APP_REPO" 2>/dev/null && pwd)" || true
fi

if [[ -z "$APP_REPO" || ! -d "$APP_REPO" ]]; then
  echo "ERROR: Application repo not found. Pass --app-repo /path/to/spring-petclinic-microservices" >&2
  exit 1
fi

# Format: "ecr-repo-name:maven-module-dir:port"
declare -a SERVICES=(
  "config-server:spring-petclinic-config-server:8888"
  "discovery-server:spring-petclinic-discovery-server:8761"
  "api-gateway:spring-petclinic-api-gateway:8080"
  "customers-service:spring-petclinic-customers-service:8081"
  "visits-service:spring-petclinic-visits-service:8082"
  "vets-service:spring-petclinic-vets-service:8083"
  "genai-service:spring-petclinic-genai-service:8084"
  "admin-server:spring-petclinic-admin-server:9090"
)

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGISTRY="${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"
NAMESPACE="petclinic"

echo "========================================================================="
echo " Petclinic ECR Build & Push"
echo "========================================================================="
echo " Tag         : ${TAG}"
echo " Platform    : ${PLATFORM}"
echo " Registry    : ${REGISTRY}"
echo " Namespace   : ${NAMESPACE}"
echo " App repo    : ${APP_REPO}"
echo "========================================================================="

# Step 1: ECR login
echo ""
echo "===> [1/4] Logging in to ECR..."
aws ecr get-login-password --region "${REGION}" \
  | docker login --username AWS --password-stdin "${REGISTRY}"

# Step 2: Build JARs
echo ""
echo "===> [2/4] Building JARs with Maven (skipping tests)..."
cd "${APP_REPO}"
./mvnw clean install -DskipTests --no-transfer-progress

# Step 3: Set up buildx
echo ""
echo "===> [3/4] Setting up docker buildx..."
if ! docker buildx inspect petclinic-builder &>/dev/null; then
  docker buildx create --name petclinic-builder --driver docker-container --bootstrap
fi
docker buildx use petclinic-builder

if [[ "$(uname -m)" != "arm64" ]] && [[ "$(uname -m)" != "aarch64" ]]; then
  echo "      x86 host — enabling QEMU for ARM64 cross-compilation..."
  docker run --privileged --rm tonistiigi/binfmt --install arm64 2>/dev/null || true
fi

# Step 4: Build and push each image
echo ""
echo "===> [4/4] Building and pushing ${#SERVICES[@]} images (${PLATFORM})..."

FAILED=()

for svc_def in "${SERVICES[@]}"; do
  IFS=':' read -r repo_name module_dir port <<< "${svc_def}"

  ECR_URI="${REGISTRY}/${NAMESPACE}/${repo_name}:${TAG}"
  JAR_GLOB="${APP_REPO}/${module_dir}/target/${module_dir}-*.jar"
  JAR_FILE=$(ls ${JAR_GLOB} 2>/dev/null | grep -v sources | head -1 || true)

  if [[ -z "$JAR_FILE" ]]; then
    echo "  [SKIP] ${repo_name}: JAR not found at ${JAR_GLOB}"
    FAILED+=("${repo_name}")
    continue
  fi

  # Calculate path relative to the APP_REPO build context root
  # Example: spring-petclinic-config-server/target/spring-petclinic-config-server-4.0.1.jar
  RELATIVE_JAR_PATH="${module_dir}/target/$(basename "${JAR_FILE}")"

  echo ""
  echo "  ===> ${repo_name}"
  echo "       JAR : $(basename "${JAR_FILE}")"
  echo "       URI : ${ECR_URI}"

  docker buildx build \
    --platform "${PLATFORM}" \
    --file "${APP_REPO}/docker/Dockerfile" \
    --build-arg "ARTIFACT_NAME=${RELATIVE_JAR_PATH%.jar}" \
    --build-arg "EXPOSED_PORT=${port}" \
    --tag "${ECR_URI}" \
    --push \
    "${APP_REPO}"

  echo "       [ok] pushed"
done

echo ""
echo "========================================================================="
if [[ ${#FAILED[@]} -eq 0 ]]; then
  echo " SUCCESS: All 8 images pushed."
  echo ""
  for svc_def in "${SERVICES[@]}"; do
    IFS=':' read -r repo_name _ _ <<< "${svc_def}"
    echo "   ${REGISTRY}/${NAMESPACE}/${repo_name}:${TAG}"
  done
else
  echo " PARTIAL FAILURE: ${#FAILED[@]} service(s) failed:"
  for svc in "${FAILED[@]}"; do
    echo "   - ${svc}"
  done
  exit 1
fi
echo "========================================================================="

