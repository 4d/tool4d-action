tool4d_is_macos() {
    if [[ "${RUNNER_OS:-}" == "macOS" ]]; then
        return 0
    fi

    [[ "${OSTYPE:-}" == darwin* ]]
}

tool4d_capture_crash_reports() {
    if ! tool4d_is_macos; then
        return 0
    fi

    local diag_user="$HOME/Library/Logs/DiagnosticReports"
    local diag_sys="/Library/Logs/DiagnosticReports"

    TOOL4D_CRASH_SNAPSHOT=$(mktemp "${TMPDIR:-/tmp}/tool4d-crash-reports.XXXXXX")
    find "$diag_user" "$diag_sys" -type f \( -name '*.crash' -o -name '*.ips' \) -print 2>/dev/null | sort > "$TOOL4D_CRASH_SNAPSHOT" || true
}

tool4d_cleanup_crash_reports() {
    if [[ -n "${TOOL4D_CRASH_SNAPSHOT:-}" && -f "${TOOL4D_CRASH_SNAPSHOT}" ]]; then
        rm -f "$TOOL4D_CRASH_SNAPSHOT"
    fi
}

tool4d_print_segfault_diagnostics() {
    local exit_code="$1"
    local tool4d_bin="$2"
    local context="${3:-execution}"
    local diag_user="$HOME/Library/Logs/DiagnosticReports"
    local diag_sys="/Library/Logs/DiagnosticReports"

    if ! tool4d_is_macos || [[ "$exit_code" -ne 139 ]]; then
        tool4d_cleanup_crash_reports
        return 0
    fi

    echo "::error::tool4d crashed with SIGSEGV (exit 139) during $context"
    echo "=== macOS segfault diagnostics ($context) ==="
    uname -a || true
    echo "arch: $(arch || true)"
    echo "machine: $(uname -m || true)"
    echo "binary: $tool4d_bin"
    file "$tool4d_bin" || true
    otool -L "$tool4d_bin" || true
    codesign -dv --verbose=4 "$tool4d_bin" 2>&1 || true

    echo "=== macOS crash reports generated recently ==="
    local current_snapshot
    current_snapshot=$(mktemp "${TMPDIR:-/tmp}/tool4d-crash-reports-current.XXXXXX")
    find "$diag_user" "$diag_sys" -type f \( -name '*.crash' -o -name '*.ips' \) -print 2>/dev/null | sort > "$current_snapshot" || true

    local printed=0
    while IFS= read -r report; do
        [[ -n "$report" ]] || continue
        printed=1
        echo "--- $report ---"
        sed -n '1,220p' "$report" || true
    done < <(
        if [[ -n "${TOOL4D_CRASH_SNAPSHOT:-}" && -f "${TOOL4D_CRASH_SNAPSHOT}" ]]; then
            comm -13 "$TOOL4D_CRASH_SNAPSHOT" "$current_snapshot"
        fi
    )

    if [[ "$printed" -eq 0 ]]; then
        while IFS= read -r report; do
            [[ -n "$report" ]] || continue
            printed=1
            echo "--- $report ---"
            sed -n '1,220p' "$report" || true
        done < <(find "$diag_user" "$diag_sys" -type f \( -name '*.crash' -o -name '*.ips' \) -mmin -10 2>/dev/null | sort)
    fi

    if [[ "$printed" -eq 0 ]]; then
        echo "No new crash report found in the last 10 minutes."
    fi

    rm -f "$current_snapshot"

    echo "=== system log around crash ==="
    log show --last 10m --style compact --predicate 'eventMessage CONTAINS[c] "tool4d" OR process CONTAINS[c] "tool4d"' 2>/dev/null | tail -200 || true

    tool4d_cleanup_crash_reports
}
