#!/bin/bash

# mark all duplicate pages with a rel="canonical" link element
set -e

consolidate_tidb_versions=(dev v2.1 v3.0 v3.1 v5.0)
consolidate_dm_versions=(dev v1.0)
consolidate_operator_versions=(dev v1.0)

consolidate_duplicate_urls() {
    local doc_temp_path=$1
    local doc_version=$2

    echo "doc_temp_path" $doc_temp_path

    if [ -d $doc_temp_path ]; then
        for html in $doc_temp_path/*
        do
            if [ -d $html ]; then
                consolidate_duplicate_urls $html $doc_version
            elif [[ ! -d $html ]] && [[ $html == *html ]] && $(grep -q "<\/head>" $html) && ! $(grep -q "rel=\"canonical\"" $html); then
                file_path_in_stable=$(echo $html | sed -E "s/\/v[1-9]\.[0-9]\/|\/dev\//\/stable\//g")
                echo "file path in stable" $file_path_in_stable

                if [ -f $file_path_in_stable ]; then
                    echo "html" $html
                    sed -i "s@<\/head>@<link rel=\"canonical\" href=\"https:\/\/docs.pingcap.com\/$file_path_in_stable\" \/><\/head>@g" $html
                fi
            fi
        done
    fi
}

for v in ${consolidate_dm_versions[@]}
do
{
    consolidate_duplicate_urls zh/tidb-data-migration/$v $v
    consolidate_duplicate_urls tidb-data-migration/$v $v
}
done

for v in ${consolidate_operator_versions[@]}
do
{
    consolidate_duplicate_urls zh/tidb-in-kubernetes/$v $v
    consolidate_duplicate_urls tidb-in-kubnernetes/$v $v
}
done

for v in ${consolidate_tidb_versions[@]}
do
{
    consolidate_duplicate_urls zh/tidb/$v $v
    consolidate_duplicate_urls tidb/$v $v
}
done
