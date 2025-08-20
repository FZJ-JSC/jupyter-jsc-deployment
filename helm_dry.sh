#!/usr/bin/env bash

if [[ -n $CI_PROJECT_DIR ]]; then
  BASE_DIR="${CI_PROJECT_DIR}"
else
  BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
fi

set -euo pipefail

# Needs yq and helm installed in the CI container
command -v yq >/dev/null || { echo "yq not found"; exit 1; }
command -v helm >/dev/null || { echo "helm not found"; exit 1; }

# Find all fleet.yaml files
find "$BASE_DIR" -type f -name "fleet.yaml" | while read -r fleet_file; do
    echo "=== Checking $fleet_file ==="

    # Skip if no top-level helm key
    if [ "$(yq eval '.helm // "null"' "$fleet_file")" = "null" ]; then
        echo "No .helm key found, skipping."
        continue
    fi
    
    if [ "$(yq eval '.doNotDeploy // "false"' "$fleet_file")" = "true" ]; then
        echo "DoNotDeploy set to True, skipping."
        continue
    fi

    bundle_dir=$(dirname "$fleet_file")

    #
    # 1. Test the main helm section
    #
    echo "--- Testing main helm section ---"
    cd $bundle_dir
    chart=$(yq eval -r '.helm.chart // ""' "$fleet_file")
    repo=$(yq eval -r '.helm.repo // ""' "$fleet_file")
    version=$(yq eval -r '.helm.version // ""' "$fleet_file")
    release_name=$(yq eval -r '.helm.releaseName // ""' "$fleet_file")
    namespace=$(yq eval -r '.defaultNamespace // "default"' "$fleet_file")

    # Create temp values file for inline values
    tmp_values_main=$(mktemp)
    yq eval '.helm.values // {}' "$fleet_file" > "$tmp_values_main"

    # Build -f args for valuesFiles (relative to bundle dir)
    values_args=()
    for vf in $(yq eval -r '.helm.valuesFiles[]? // ""' "$fleet_file"); do
        values_args+=("-f" "$bundle_dir/$vf")
    done

    if [[ -n "$repo" ]]; then
        helm repo add temp-repo "$repo"
        helm repo update
        echo "$(date) - 1 - RUN: helm template -n $namespace -f $tmp_values_main ${values_args[@]} ${version:+--version $version} $release_name temp-repo/$chart > ${tmp_values_main}_output.txt"
        helm template -n $namespace -f $tmp_values_main ${values_args[@]} ${version:+--version $version} $release_name temp-repo/$chart > ${tmp_values_main}_output.txt
        helm repo remove temp-repo
    else
        echo "$(date) - 2a - RUN: helm dependency update $chart"
        helm dependency update $chart
        # echo "$(date) - 2b - RUN: helm dependency build $chart"
        # helm dependency build $chart
        echo "$(date) - 2 - RUN: helm template -n $namespace -f $tmp_values_main ${values_args[@]} $release_name $chart > ${tmp_values_main}_output.txt"
        helm template -n $namespace -f $tmp_values_main ${values_args[@]} $release_name $chart > ${tmp_values_main}_output.txt
    fi

    #
    # 2. Test each targetCustomization helm section
    #
    echo "--- Testing targetCustomizations ---"
    tc_count=$(yq eval '.targetCustomizations | length' "$fleet_file" 2>/dev/null || echo 0)
    for ((i=0; i<tc_count; i++)); do
        if ! yq eval ".targetCustomizations[$i].helm" "$fleet_file" >/dev/null 2>&1; then
            continue
        fi
        name_tc=$(yq eval -r ".targetCustomizations[$i].name // \"Unknown\"" "$fleet_file")
        echo "Testing targetCustomizations[$i] $name_tc ..."
        do_not_deploy=$(yq eval -r ".targetCustomizations[$i].doNotDeploy // \"false\"" "$fleet_file")
        if [ "$do_not_deploy" = "true" ]; then
            echo "DoNotDeploy set to True, skipping."
            continue
        fi

        chart_tc=$(yq eval -r ".targetCustomizations[$i].helm.chart // \"$chart\"" "$fleet_file")
        repo_tc=$(yq eval -r ".targetCustomizations[$i].helm.repo // \"$repo\"" "$fleet_file")
        version_tc=$(yq eval -r ".targetCustomizations[$i].helm.version // \"$version\"" "$fleet_file")
        release_tc=$(yq eval -r ".targetCustomizations[$i].helm.releaseName // \"$release_name\"" "$fleet_file")
        namespace_tc=$(yq eval -r ".targetCustomizations[$i].namespace // \"$namespace\"" "$fleet_file")

        tmp_values_tc=$(mktemp)
        yq eval ".targetCustomizations[$i].helm.values // {}" "$fleet_file" > "$tmp_values_tc"

        values_args_tc=()
        for vf in $(yq eval -r ".targetCustomizations[$i].helm.valuesFiles[]? // \"\"" "$fleet_file"); do
            values_args_tc+=("-f" "$bundle_dir/$vf")
        done
        

        if [[ -n "$repo_tc" ]]; then
            helm repo add temp-repo "$repo_tc"
            helm repo update
            echo "$(date) - 3 - RUN: helm template -n $namespace_tc -f $tmp_values_tc ${values_args[@]} ${values_args_tc[@]} ${version_tc:+--version $version_tc} $release_tc temp-repo/$chart_tc > ${tmp_values_tc}_output.txt"
            helm template -n $namespace_tc -f $tmp_values_main -f $tmp_values_tc ${values_args[@]} ${values_args_tc[@]} ${version_tc:+--version $version_tc} $release_tc temp-repo/$chart_tc > ${tmp_values_tc}_output.txt
            helm repo remove temp-repo
        else
            echo "Using direct chart path: $chart_tc"
            echo "$(date) - 4 - RUN: helm template -n $namespace_tc -f $tmp_values_tc ${values_args_tc[@]} $release_tc $chart_tc > ${tmp_values_tc}_output.txt"
            helm template -n $namespace_tc -f $tmp_values_main -f $tmp_values_tc ${values_args[@]} ${values_args_tc[@]} $release_tc $chart_tc > ${tmp_values_tc}_output.txt
        fi

    done

    echo "=== Done with $fleet_file ==="
done

