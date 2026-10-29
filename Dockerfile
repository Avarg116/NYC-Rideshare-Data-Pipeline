FROM astrocrpublic.azurecr.io/runtime:3.3-11

RUN python -m venv dbt_venv && source dbt_venv/bin/activate && \
    pip install --no-cache-dir "dbt-core~=1.12.0" dbt-postgres && deactivate
