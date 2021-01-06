FROM mcr.microsoft.com/azure-cli:2.17.1

ARG TERRAFORM_VERSION=0.13.6

RUN apk update \
    && apk add --no-cache gawk ncurses \ 
    && rm -rf \
    /var/cache/apk/* \
    /var/lib/apt/lists/*

RUN curl --fail -Lo "/tmp/terraform.zip" \
    "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" \
    && unzip /tmp/terraform.zip \
    && chmod +x terraform \
    && mv terraform /usr/local/bin/terraform

RUN curl -Lo "/tmp/kubectl" \
    "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl" \
    && chmod +x "/tmp/kubectl" \
    && mv "/tmp/kubectl" /usr/local/bin/kubectl
