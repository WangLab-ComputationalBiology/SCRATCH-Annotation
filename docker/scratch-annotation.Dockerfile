# Use a specific version of Ubuntu as the base image
FROM --platform=linux/x86_64 rocker/verse:4.4.0

# Set environment variable to use Docker BuildKit
ENV DOCKER_BUILDKIT=1

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

# Updating quarto to Quarto v1.4.553
RUN wget https://github.com/quarto-dev/quarto-cli/releases/download/v1.4.553/quarto-1.4.553-linux-amd64.deb -O /opt/quarto-1.4.553-linux-amd64.deb
RUN cd /opt && dpkg -i quarto-1.4.553-linux-amd64.deb

# Install Python3
RUN apt-get install -y \
    python3 \
    python3-pip

# Install Python packages for data science
RUN python3 -m pip install --no-cache-dir numpy scanpy anndata pandas scikit-learn matplotlib seaborn jupyter
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
    'optparse', \
    'R.utils', \
    'here', \
    'HGNChelper' \
    )"

ARG DEV_DEPS="c(\
    'bnprks/BPCells', \
    'cellgeni/sceasy', \
    'zhanghao-njmu/SCP' \
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
    'ggrastr', \
    'Rsamtools', \
    'UCell' \
    )"

# Setting repository URL
ARG R_REPO="http://cran.us.r-project.org"

# Caching R-lib on the building process --mount=type=cache,target=/usr/local/lib/R
RUN Rscript -e "install.packages(${R_DEPS}, Ncpus = 8, repos = '${R_REPO}', clean = TRUE)"
RUN Rscript -e "install.packages(${WEB_DEPS}, Ncpus = 8, repos = '${R_REPO}', clean = TRUE)"

# Install BiocManager
RUN Rscript -e "BiocManager::install(${R_BIOC_DEPS})"

# Install Seurat Wrappers
RUN wget https://github.com/satijalab/seurat/archive/refs/heads/seurat5.zip -O /opt/seurat-v5.zip
RUN wget https://github.com/satijalab/seurat-data/archive/refs/heads/seurat5.zip -O /opt/seurat-data.zip
RUN wget https://github.com/satijalab/seurat-wrappers/archive/refs/heads/seurat5.zip -O /opt/seurat-wrappers.zip

RUN Rscript -e "devtools::install_local('/opt/seurat-v5.zip')"
RUN Rscript -e "devtools::install_local('/opt/seurat-data.zip')"
RUN Rscript -e "devtools::install_local('/opt/seurat-wrappers.zip')"

# Install packages on Github
RUN Rscript -e "devtools::install_github(${DEV_DEPS})"

# Install R packages related to cell annotation
# ARG R_ANNOT_DEPS="c(\)"

# RUN Rscript -e "install.packages(${R_ANNOT_DEPS}, Ncpus = 8, repos = '${R_REPO}', clean = TRUE)"

# Install Python packages related to cell annotation
RUN python3 -m pip install --no-cache-dir scSpectra
RUN python3 -m pip install --no-cache-dir celltypist 
RUN python3 -m pip install --no-cache-dir metatime
RUN python3 -m pip install --no-cache-dir session_info

# Setting celltypist variable
ENV CELLTYPIST_FOLDER=/opt/celltypist

# Installing celltypist models
COPY setup.py /opt/
RUN python3 /opt/setup.py

# Install presto
RUN Rscript -e "install.packages('devtools')"
RUN Rscript -e "devtools::install_github('immunogenomics/presto')"

# Install Azimuth
RUN Rscript -e "remotes::install_github('satijalab/azimuth', ref = 'master')"

# Set the working directory
WORKDIR /data

# Command to run on container start
CMD ["bash"]
