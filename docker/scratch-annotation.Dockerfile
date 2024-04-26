# Use a specific version of Ubuntu as the base image
FROM --platform=linux/x86_64 rocker/verse:latest

# Timezone settings
ENV TZ=US/Central
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone

# Install system dependencies
RUN apt-get update && apt-get install -y \
    software-properties-common \
    dirmngr \
    gnupg \
    apt-transport-https \
    ca-certificates \
    wget \
    libcurl4-gnutls-dev \
    libssl-dev \
    libxml2-dev

# Install Python3
RUN apt-get install -y \
    python3 \
    python3-pip

# Install Python packages for data science
RUN python3 -m pip install --no-cache-dir numpy pandas scikit-learn matplotlib seaborn jupyter
RUN python3 -m pip install --no-cache-dir jupyter-cache
RUN python3 -m pip install --no-cache-dir papermill

# Install fundamental R packages
ARG R_DEPS="c(\
    'tidyverse', \
    'devtools', \
    'rmarkdown', \
    'patchwork', \
    'BiocManager', \
    'remotes', \
    'optparse' \
    )"

ARG DEV_DEPS="c(\
    'bnprks/BPCells' \
    )"

ARG WEB_DEPS="c(\
    'shiny', \
    'DT', \
    'kable', \
    'kableExtra', \
    'flexdashboard', \
    'plotly' \
    )"

ARG R_BIOC_DEPS="c(\
    'Biobase', \
    'BiocGenerics', \
    'DelayedArray', \
    'DelayedMatrixStats', \
    'S4Vectors',\
    'SingleCellExperiment', \
    'SummarizedExperiment', \
    'HDF5Array', \ 
    'limma', \
    'lme4', \
    'terra', \ 
    'ggrastr' \
    )"

# Setting repository URL
ARG R_REPO='http://cran.us.r-project.org'

# Caching R-lib on the building process
RUN --mount=type=cache,target=/usr/local/lib/R Rscript -e "install.packages(${R_DEPS}, Ncpus = 8, repos = "${R_REPO}", clean = TRUE)"
RUN --mount=type=cache,target=/usr/local/lib/R Rscript -e "install.packages(${WEB_DEPS}, Ncpus = 8, repos = "${R_REPO}", clean = TRUE)"
RUN --mount=type=cache,target=/usr/local/lib/R Rscript -e "install.packages(${R_BIOC_DEPS}, Ncpus = 8, repos = "${R_REPO}", clean = TRUE)"
RUN --mount=type=cache,target=/usr/local/lib/R Rscript -e "install.packages('R.utils', Ncpus = 8, repos = "${R_REPO}", clean = TRUE)"

# Install Seurat Wrappers
RUN wget https://github.com/satijalab/seurat/archive/refs/heads/seurat5.zip -O /opt/seurat-v5.zip
RUN wget https://github.com/satijalab/seurat-data/archive/refs/heads/seurat5.zip -O /opt/seurat-data.zip
RUN wget https://github.com/satijalab/seurat-wrappers/archive/refs/heads/seurat5.zip -O /opt/seurat-wrappers.zip

RUN --mount=type=cache,target=/usr/local/lib/R Rscript -e "devtools::install_local('/opt/seurat-v5.zip')"
RUN --mount=type=cache,target=/usr/local/lib/R Rscript -e "devtools::install_local('/opt/seurat-data.zip')"
RUN --mount=type=cache,target=/usr/local/lib/R Rscript -e "devtools::install_local('/opt/seurat-wrappers.zip')"

RUN --mount=type=cache,target=/usr/local/lib/R Rscript -e "devtools::install_github(${DEV_DEPS}, repos = \"${R_REPO}\")"

# Set the working directory
WORKDIR /data

# Command to run on container start
CMD ["bash"]