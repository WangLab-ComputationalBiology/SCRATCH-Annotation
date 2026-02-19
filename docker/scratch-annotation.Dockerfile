# Use a specific version of Ubuntu as the base image
FROM --platform=linux/x86_64 rocker/verse:latest

# Set the working directory inside the container
WORKDIR /opt

# Timezone settings
ENV TZ=US/Central
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone
# pass your PAT at build time so remotes::install_github can auth
ARG GITHUB_PAT
ENV GITHUB_PAT=${GITHUB_PAT}

ENV R_REPOS="https://packagemanager.posit.co/cran/latest"

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
    default-jre \
    libgfortran5 \
    liblapack-dev \
    libopenblas-dev \
    libjpeg-dev \
    libpng-dev \
    libtiff5-dev \
    zlib1g-dev \
    libxt-dev


# Updating quarto to Quarto v1.4.553
RUN wget https://github.com/quarto-dev/quarto-cli/releases/download/v1.4.553/quarto-1.4.553-linux-amd64.deb -O quarto-1.4.553-linux-amd64.deb
RUN dpkg -i quarto-1.4.553-linux-amd64.deb

# # Install remotes package
# RUN R -e "install.packages('remotes')"


RUN apt-get update && apt-get install -y python3 python3-pip python3-venv

# Install core R packages
RUN Rscript -e "install.packages(c( \
  'R.utils', \
  'rmarkdown', \
  'devtools', \
  'tidyverse', \
  'readr', \
  'dplyr', \
  'ggplot2', \
  'cowplot', \
  'remotes', \
  'BiocManager',\
  'reticulate', \
  'HGNChelper', \
  'optparse'), repos='${R_REPOS}')"


RUN Rscript -e "BiocManager::install(c( \
  'S4Vectors', \
  'DelayedMatrixStats', \
  'BiocGenerics',\
  'Biobase', \
  'SummarizedExperiment', \
  'AnnotationDbi', \
  'org.Hs.eg.db'), ask=FALSE, update=TRUE)"

RUN Rscript -e "BiocManager::install(c( \
    'HDF5Array', \
    'rhdf5', \
    'rhdf5lib', \
    'SingleCellExperiment', \
    'GOSemSim', \
    'MatrixGenerics', \
    'treeio', \
    'DOSE',\
    'ggtree',\
    'enrichplot', \
    'clusterProfiler',\
    'DirichletMultinomial',\
    'rtracklayer',\
    'GenomicFeatures', \
    'BSgenome',\
    'ensembldb',\
    'TFBSTools', \
    'BSgenome.Hsapiens.UCSC.hg38'\
    ,'EnsDb.Hsapiens.v86' \
  ), ask=FALSE, update=FALSE )"


RUN Rscript -e 'remotes::install_github("ctlab/fgsea")'

# Install Seurat Wrappers
RUN wget https://github.com/satijalab/seurat/archive/refs/heads/seurat5.zip -O /opt/seurat-v5.zip
RUN wget https://github.com/satijalab/seurat-data/archive/refs/heads/seurat5.zip -O /opt/seurat-data.zip
RUN wget https://github.com/satijalab/seurat-wrappers/archive/refs/heads/seurat5.zip -O /opt/seurat-wrappers.zip

RUN Rscript -e "devtools::install_local('/opt/seurat-v5.zip')"
RUN Rscript -e "devtools::install_local('/opt/seurat-data.zip')"
RUN Rscript -e "devtools::install_local('/opt/seurat-wrappers.zip')"

# Install SCP package from GitHub
RUN Rscript -e "devtools::install_github('PaulingLiu/ROGUE', dependencies = TRUE, upgrade = 'always',force = TRUE)"
RUN Rscript -e "devtools::install_github('zhanghao-njmu/SCP', dependencies = TRUE, upgrade = 'always', force = TRUE)"
RUN Rscript -e "devtools::install_github('cellgeni/sceasy', dependencies = TRUE, upgrade = 'always', force = TRUE)"

# Create and activate virtual environment
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Create and activate a virtual environment before installing Python packages
RUN python3 -m venv /opt/venv \
    && /opt/venv/bin/pip install --no-cache-dir numpy pandas scikit-learn matplotlib seaborn jupyter jupyter-cache papermill anndata scanpy scipy session_info scSpectra metatime celltypist \
    && ln -s /opt/venv/bin/python /usr/local/bin/python \
    && ln -s /opt/venv/bin/pip /usr/local/bin/pip
# Create and activate virtual environment
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Setting celltypist variable
ENV CELLTYPIST_FOLDER=/opt/celltypist

# Installing celltypist models
# COPY setup.py /opt/
# RUN python3 /opt/setup.py

# Additional packages
RUN apt-get install -y libhdf5-dev
RUN Rscript -e "install.packages('hdf5r')"


# Java + Fortran 
RUN apt-get update && apt-get install -y default-jre libgfortran5

# JAGS
RUN apt-get install -y jags


# Install annotables
RUN Rscript -e "devtools::install_github('stephenturner/annotables')"
RUN Rscript -e "devtools::install_github('miccec/yaGST', dependencies = TRUE, upgrade = 'never')"


RUN apt-get update && \
    apt-get install -y --no-install-recommends \
       libgsl-dev \
    && rm -rf /var/lib/apt/lists/*  

# Install DirichletMultinomial + TFBSTools (and all of their R & Bioc deps)
RUN Rscript -e "install.packages(c('DirichletMultinomial','TFBSTools'), dependencies = TRUE, repos = BiocManager::repositories())"

# install Azimuth
RUN Rscript -e "devtools::install_github('satijalab/azimuth', ref = 'master', dependencies=TRUE, upgrade='never')"


# Cleaning apt-get cache
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/*


# Command to run on container start
CMD ["bash"]

