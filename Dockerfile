ARG DISTRO=ubuntu:latest
FROM ${DISTRO}

# Common packages to install
ENV COMMON_PACKAGES="zsh sudo curl wget git stow vim tmux ca-certificates ssh"

RUN set -eux; \
    if [ -f /etc/debian_version ]; then \
        echo "Detected Debian-based system"; \
        apt-get update && \
        DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
            $COMMON_PACKAGES \
            locales \
        && apt-get clean && rm -rf /var/lib/apt/lists/*; \
    elif [ -f /etc/redhat-release ]; then \
        echo "Detected RHEL-based system"; \
        yum install -y \
            $COMMON_PACKAGES \
            glibc-langpack-en \
        && localedef -i en_US -f UTF-8 en_US.UTF-8 || true \
        && yum clean all && rm -rf /var/cache/yum; \
    else \
        echo "Unsupported distribution" && exit 1; \
    fi

# Set the locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

RUN useradd -ms /bin/bash ricky
# Set the user's password
RUN echo ricky:ricky | chpasswd
RUN echo '%ricky ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
USER ricky:ricky
COPY --chown=ricky . /home/ricky/.dotfiles
WORKDIR /home/ricky/.dotfiles
CMD ["/bin/bash"]
