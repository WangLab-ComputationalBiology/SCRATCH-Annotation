# Use a specific version of Ubuntu as the base image
FROM --platform=linux/x86_64 rocker/verse:latest

# Set the working directory inside the container
WORKDIR /opt

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
    libxml2-dev \
    libgsl-dev \
    python3 \
    python3-pip \
    python3-venv


# Updating quarto to Quarto v1.4.553
RUN wget https://github.com/quarto-dev/quarto-cli/releases/download/v1.4.553/quarto-1.4.553-linux-amd64.deb -O quarto-1.4.553-linux-amd64.deb \
    && dpkg -i quarto-1.4.553-linux-amd64.deb \
    && rm quarto-1.4.553-linux-amd64.deb

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
    'HGNChelper', \
    'reticulate' \
    )"

ARG DEV_DEPS="c(\
    'bnprks/BPCells', \
    'cellgeni/sceasy', \
    'immunogenomics/presto', \
    'PaulingLiu/ROGUE', \
    'zhanghao-njmu/SCP', \
    'immunogenomics/presto', \
    'satijalab/azimuth' \
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
    'UCell', \
    'DropletUtils', \
    'MAST', \
    'DESeq2', \
    'batchelor', \
    'scran', \
    'DOSE', \ 
    'enrichplot', \
    'clusterProfiler', \
    'scDblFinder' \
    )"

 
# Install Seurat Wrappers
RUN wget https://github.com/satijalab/seurat/archive/refs/heads/seurat5.zip -O /tmp/seurat-v5.zip \
    && wget https://github.com/satijalab/seurat-data/archive/refs/heads/seurat5.zip -O /tmp/seurat-data.zip \
    && wget https://github.com/satijalab/seurat-wrappers/archive/refs/heads/seurat5.zip -O /tmp/seurat-wrappers.zip \
    && Rscript -e "devtools::install_local('/tmp/seurat-v5.zip')" \
    && Rscript -e "devtools::install_local('/tmp/seurat-data.zip')" \
    && Rscript -e "devtools::install_local('/tmp/seurat-wrappers.zip')" \
    && rm -rf /tmp/*.zip

# Setting repository URL
ARG R_REPO="http://cran.us.r-project.org"

# Caching R-lib on the building process
RUN Rscript -e "install.packages(${R_DEPS}, Ncpus = 8, repos = '${R_REPO}', clean = TRUE)" \
    && Rscript -e "install.packages(${WEB_DEPS}, Ncpus = 8, repos = '${R_REPO}', clean = TRUE)" \
    && Rscript -e "BiocManager::install(${R_BIOC_DEPS})" \
    && Rscript -e "devtools::install_github(${DEV_DEPS})"


# Install Python packages for data science
RUN python3 -m venv /opt/venv \
    && /opt/venv/bin/pip install --no-cache-dir --upgrade pip \
    && /opt/venv/bin/pip install --no-cache-dir \
      numpy pandas scikit-learn matplotlib seaborn jupyter jupyter-cache \
      papermill scSpectra celltypist metatime session_info \
    && ln -s /opt/venv/bin/python /usr/local/bin/python \
    && ln -s /opt/venv/bin/pip /usr/local/bin/pip

# Set the working directory
WORKDIR /data

# Command to run on container start
CMD ["bash"]
