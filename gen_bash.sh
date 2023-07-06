#!/bin/bash

# Versions of postgres to install
pg_versions=("11" "12" "13" "14" "15")

# Directory to store generated scripts
script_dir="${HOME}/pg_scripts"

# Ensure script directory exists
mkdir -p "${script_dir}"

for pg_version in "${pg_versions[@]}"; do
    # Uncomment the line below to install PostgreSQL versions
    # sudo apt install "postgresql-${pg_version}"

    # Script content generation
    script_content='
        #!/bin/bash

        tmpdir=$(mktemp -d)
        export PATH="/usr/lib/postgresql/'${pg_version}'/bin:${PATH}"
        export PGDATA="${tmpdir}"
        export PGHOST="${tmpdir}"
        export PGUSER=postgres
        export PGDATABASE=postgres

        trap "pg_ctlcluster '${pg_version}' main stop && rm -rf ${tmpdir}" EXIT

        initdb --no-locale --encoding=UTF8 --nosync -D "${PGDATA}"
        pg_ctlcluster '${pg_version}' main start

        createdb contrib_regression
        psql -v ON_ERROR_STOP=1 -f test/fixtures.sql -d contrib_regression
        "$@"
    '

    # Write script to file
    echo "${script_content}" > "${script_dir}/pg_${pg_version}_supa_audit.sh"

    # Make the script executable
    chmod +x "${script_dir}/pg_${pg_version}_supa_audit.sh"
done
