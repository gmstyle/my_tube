#!/usr/bin/env bash
set -e

WORKFLOW_FILE=".github/workflows/main.yaml"

echo "▶ flutter upgrade..."
flutter upgrade --force

NEW_VERSION=$(flutter --version | grep -oP 'Flutter \K[0-9]+\.[0-9]+\.[0-9]+' | head -1)

if [ -z "$NEW_VERSION" ]; then
  echo "❌ Impossibile leggere la versione Flutter. Aggiorna manualmente $WORKFLOW_FILE."
  exit 1
fi

echo "✅ Versione rilevata: $NEW_VERSION"

# Aggiorna tutte le occorrenze di flutter-version nel workflow
sed -i "s/flutter-version: '[0-9]*\.[0-9]*\.[0-9]*'/flutter-version: '$NEW_VERSION'/" "$WORKFLOW_FILE"

echo "✅ $WORKFLOW_FILE aggiornato con flutter-version: '$NEW_VERSION'"
