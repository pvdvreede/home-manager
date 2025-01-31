# Use a Debian base image
FROM debian:bullseye

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Create a non-root user
RUN useradd -ms /bin/bash janetuser

# Update system and install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    libssl-dev \
    libcurl4-openssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Download and build Janet
ENV JANET_VERSION=1.37.1
RUN curl -L https://github.com/janet-lang/janet/archive/refs/tags/v${JANET_VERSION}.tar.gz -o janet.tar.gz \
    && tar -xzf janet.tar.gz \
    && cd janet-${JANET_VERSION} \
    && make \
    && make install \
    && cd .. \
    && rm -rf janet.tar.gz janet-${JANET_VERSION}

# Set up jpm (Janet Package Manager)
ENV JPM_VERSION=1.1.0
RUN curl -L https://github.com/janet-lang/jpm/archive/refs/tags/v${JPM_VERSION}.tar.gz -o jpm.tar.gz \
    && tar -xzf jpm.tar.gz \
    && cd jpm-${JPM_VERSION} \
    && janet bootstrap.janet \
    && rm -rf jpm.tar.gz jpm-${JANET_VERSION}

# Switch to the non-root user
USER janetuser
WORKDIR /home/janetuser
ENV JANET_TREE="/home/janetuser/.local/jpm_tree"
ENV PATH="$PATH:/home/janetuser/.local/jpm_tree/bin"
RUN mkdir -p $JANET_TREE

RUN jpm install spork

