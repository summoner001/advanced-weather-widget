#!/bin/sh
# Build .mo files from translate/*.po
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TRANSLATE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PACKAGE_ROOT="$(cd "$TRANSLATE_DIR/.." && pwd)"
DOMAIN="plasma_applet_org.kde.plasma.advanced-weather-widget"

for POFILE in "$TRANSLATE_DIR"/*.po; do
  [ -f "$POFILE" ] || continue
  LOCALE="$(basename "$POFILE" .po)"
  OUTDIR="$PACKAGE_ROOT/contents/locale/$LOCALE/LC_MESSAGES"
  mkdir -p "$OUTDIR"
  msgfmt "$POFILE" -o "$OUTDIR/$DOMAIN.mo"
  echo "Built $OUTDIR/$DOMAIN.mo"

  # Also install under the bare language code (e.g. uk_UA -> uk) when this is
  # the only regional variant of that language. KDE's LANGUAGE often uses the
  # bare code (uk, cs, hu, it, pl, tr); gettext strips a territory suffix but
  # never adds one, so a "uk" UI cannot find a "uk_UA"-only catalog and falls
  # back to English. Languages with multiple variants (zh_CN/zh_TW) are left
  # untouched so they don't collide.
  LANG_BASE="${LOCALE%%_*}"
  if [ "$LANG_BASE" != "$LOCALE" ]; then
    variants=0
    for other in "$TRANSLATE_DIR/$LANG_BASE"*.po; do
      [ -f "$other" ] && variants=$((variants + 1))
    done
    if [ "$variants" -le 1 ]; then
      BAREDIR="$PACKAGE_ROOT/contents/locale/$LANG_BASE/LC_MESSAGES"
      mkdir -p "$BAREDIR"
      msgfmt "$POFILE" -o "$BAREDIR/$DOMAIN.mo"
      echo "Built (bare-code alias) $BAREDIR/$DOMAIN.mo"
    fi
  fi
done
