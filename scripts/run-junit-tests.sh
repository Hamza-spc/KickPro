#!/usr/bin/env bash
# Run all backend JUnit tests with JaCoCo coverage report.
# Usage: ./scripts/run-junit-tests.sh
#        ./scripts/run-junit-tests.sh "MatchServiceImplTest"
set -euo pipefail

cd "$(dirname "$0")/../backend"

if [ $# -eq 0 ]; then
  echo "Running full backend test suite + JaCoCo report..."
  ./mvnw test -B
  echo ""
  echo "Coverage report: backend/target/site/jacoco/index.html"
  exit 0
fi

TESTS="$1"
shift
echo "Running tests: $TESTS"
./mvnw test -Dtest="$TESTS" "$@"
