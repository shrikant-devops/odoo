FROM python:3.12-slim

ENV PYTHONUNBUFFERED=1
ENV ODOO_HOME=/opt/odoo
ENV ODOO_CONFIG=/opt/odoo/odoo.conf
ENV ODOO_VERSION=17.0

RUN mkdir -p $ODOO_HOME
WORKDIR $ODOO_HOME

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    python3-dev \
    python3-venv \
    libsasl2-dev \
    libldap2-dev \
    libssl-dev \
    libxml2-dev \
    libxslt1-dev \
    libjpeg-dev \
    libpng-dev \
    libfreetype6-dev \
    liblcms2-dev \
    libwebp-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libxcb1-dev \
    wget \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

RUN git clone --depth 1 --branch $ODOO_VERSION https://github.com/odoo/odoo.git $ODOO_HOME/odoo

RUN python3 -m venv odoo-venv

RUN odoo-venv/bin/pip install --upgrade pip

COPY requirements.txt $ODOO_HOME/requirements.txt

RUN if [ -f requirements.txt ]; then \
        odoo-venv/bin/pip install -r requirements.txt; \
    else \
        echo "No custom requirements.txt found"; \
    fi


RUN echo "[options]" > $ODOO_CONFIG && \
    echo "addons_path = /opt/odoo/odoo/addons" >> $ODOO_CONFIG && \
    echo "data_dir = /opt/odoo/data" >> $ODOO_CONFIG && \
    echo "db_host = database-2.czc46mgoexep.ap-south-1.rds.amazonaws.com" >> $ODOO_CONFIG && \
    echo "db_port = 5432" >> $ODOO_CONFIG && \
    echo "db_user = shrikant" >> $ODOO_CONFIG && \
    echo "db_password = shrikant123" >> $ODOO_CONFIG && \
    echo "db_name = database-2">> $ODOO_CONFIG

RUN mkdir -p /opt/odoo/data

EXPOSE 8069

CMD ["odoo-venv/bin/python", "odoo/odoo-bin", "-c", "/opt/odoo/odoo.conf"]
