#!/bin/bash
# Patch ImmortalWrt frpc: add LuCI enable switch, default disabled.
# Safe to run after feeds install; keeps official packages, only small hooks.

set -e

FRP_FILES="${1:-feeds/packages/net/frp/files}"
FRPC_JS="${2:-feeds/luci/applications/luci-app-frpc/htdocs/luci-static/resources/view/frpc.js}"

FRPC_INIT="$FRP_FILES/frpc.init"
FRPC_CONF="$FRP_FILES/frpc.config"
FRPC_DEFAULTS="$FRP_FILES/frpc.uci-defaults"

if [ ! -f "$FRPC_INIT" ] || [ ! -f "$FRPC_CONF" ]; then
  echo "ERROR: frpc package files not found under $FRP_FILES" >&2
  exit 1
fi

# --- init: skip start when UCI init.enabled != 1 ---
if ! grep -q "config_get_bool enabled \"\$init_cfg\" enabled" "$FRPC_INIT"; then
  # Insert right after: config_foreach _find_init_section init
  awk '
    { print }
    /config_foreach _find_init_section init/ && !done {
      print ""
      print "\tlocal enabled=0"
      print "\t[ -n \"$init_cfg\" ] && config_get_bool enabled \"$init_cfg\" enabled 0"
      print "\t[ \"$enabled\" -eq 1 ] || return 0"
      done=1
    }
  ' "$FRPC_INIT" > "$FRPC_INIT.tmp"
  mv "$FRPC_INIT.tmp" "$FRPC_INIT"
  echo "frpc: patched init enabled-gate"
else
  echo "frpc: init enabled-gate already present"
fi

if ! grep -q "config_get_bool enabled \"\$init_cfg\" enabled" "$FRPC_INIT"; then
  echo "ERROR: frpc.init enabled-gate missing (upstream init layout changed?)" >&2
  exit 1
fi

# --- default config: enabled off (only under "config init", not proxy enabled) ---
# Proxy sections also have "option enabled 'true'" — do not match those.
if ! awk '
  /^config init$/ { in_init=1; next }
  /^config / { in_init=0 }
  in_init && /^[[:space:]]*option[[:space:]]+enabled[[:space:]]/ { found=1 }
  END { exit found ? 0 : 1 }
' "$FRPC_CONF"; then
  awk '
    { print }
    /^config init$/ && !done {
      print "\toption enabled '\''0'\''"
      done=1
    }
  ' "$FRPC_CONF" > "$FRPC_CONF.tmp"
  mv "$FRPC_CONF.tmp" "$FRPC_CONF"
  echo "frpc: default config enabled=0"
else
  # Keep init.enabled as 0 if someone left it as 1 in the package default
  awk '
    /^config init$/ { in_init=1 }
    /^config / && !/^config init$/ { in_init=0 }
    in_init && /^[[:space:]]*option[[:space:]]+enabled[[:space:]]+'\''1'\''/ {
      sub(/'\''1'\''/, "'\''0'\''")
    }
    { print }
  ' "$FRPC_CONF" > "$FRPC_CONF.tmp"
  mv "$FRPC_CONF.tmp" "$FRPC_CONF"
  echo "frpc: default config init.enabled already present"
fi

# --- default config must expose init.enabled ---
if ! awk '
  /^config init$/ { in_init=1; next }
  /^config / { in_init=0 }
  in_init && /^[[:space:]]*option[[:space:]]+enabled[[:space:]]/ { found=1 }
  END { exit found ? 0 : 1 }
' "$FRPC_CONF"; then
  echo "ERROR: frpc.config missing init.enabled after patch" >&2
  exit 1
fi

# --- uci-defaults: ensure enabled=0 on upgrade/first boot ---
if [ -f "$FRPC_DEFAULTS" ]; then
  if ! grep -q 'set_if_empty "$init_section" enabled' "$FRPC_DEFAULTS"; then
    awk '
      { print }
      /set_if_empty "\$init_section" respawn/ && !done {
        print "\tset_if_empty \"$init_section\" enabled 0"
        done=1
      }
    ' "$FRPC_DEFAULTS" > "$FRPC_DEFAULTS.tmp"
    mv "$FRPC_DEFAULTS.tmp" "$FRPC_DEFAULTS"
    echo "frpc: uci-defaults set enabled=0"
  fi
  if ! grep -q 'set_if_empty "$init_section" enabled' "$FRPC_DEFAULTS"; then
    echo "ERROR: frpc.uci-defaults missing enabled (upstream layout changed?)" >&2
    exit 1
  fi
else
  echo "WARNING: frpc.uci-defaults not found; fresh default config still has enabled=0" >&2
fi

# --- LuCI: enable switch on Startup Settings tab ---
if [ ! -f "$FRPC_JS" ]; then
  echo "ERROR: luci-app-frpc view not found ($FRPC_JS)" >&2
  exit 1
fi

if grep -q "form.Flag, 'enabled', _('Enable')" "$FRPC_JS"; then
  echo "frpc: LuCI Enable flag already present"
  exit 0
fi

if ! grep -q "const startupConf = \[" "$FRPC_JS"; then
  echo "ERROR: luci-app-frpc missing startupConf (upstream JS layout changed?)" >&2
  exit 1
fi

if grep -q "writeFlagDisabled" "$FRPC_JS"; then
  # Newer Imm JS style
  awk '
    { print }
    /const startupConf = \[/ && !done {
      print "\t[form.Flag, '\''enabled'\'', _('\''Enable'\''), null,"
      print "\t{"
      print "\t\tenabled: '\''1'\'',"
      print "\t\tdisabled: '\''0'\'',"
      print "\t\tdefault: '\''0'\'',"
      print "\t\trmempty: false,"
      print "\t\tretain: true,"
      print "\t\tremove: writeFlagDisabled"
      print "\t}],"
      print ""
      done=1
    }
  ' "$FRPC_JS" > "$FRPC_JS.tmp"
else
  # Older Imm JS style
  awk '
    { print }
    /const startupConf = \[/ && !done {
      print "\t[form.Flag, '\''enabled'\'', _('\''Enable'\'')],"
      print ""
      done=1
    }
  ' "$FRPC_JS" > "$FRPC_JS.tmp"
fi
mv "$FRPC_JS.tmp" "$FRPC_JS"

if ! grep -q "form.Flag, 'enabled', _('Enable')" "$FRPC_JS"; then
  echo "ERROR: failed to insert LuCI Enable flag" >&2
  exit 1
fi
echo "frpc: LuCI Enable flag added to Startup Settings"
