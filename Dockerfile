#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM alpine:3.19

RUN apk add --no-cache ca-certificates

ENV PATH /usr/local/go/bin:$PATH

ENV GOLANG_VERSION 1.21.6

RUN set -eux; \
	apk add --no-cache --virtual .fetch-deps gnupg; \
	arch="$(apk --print-arch)"; \
	url=; \
	case "$arch" in \
		'x86_64') \
			url='https://dl.google.com/go/go1.21.6.linux-amd64.tar.gz'; \
			sha256='3f934f40ac360b9c01f616a9aa1796d227d8b0328bf64cb045c7b8c4ee9caea4'; \
			;; \
		'armhf') \
			url='https://dl.google.com/go/go1.21.6.linux-armv6l.tar.gz'; \
			sha256='6a8eda6cc6a799ff25e74ce0c13fdc1a76c0983a0bb07c789a2a3454bf6ec9b2'; \
			;; \
		'armv7') \
			url='https://dl.google.com/go/go1.21.6.linux-armv6l.tar.gz'; \
			sha256='6a8eda6cc6a799ff25e74ce0c13fdc1a76c0983a0bb07c789a2a3454bf6ec9b2'; \
			;; \
		'aarch64') \
			url='https://dl.google.com/go/go1.21.6.linux-arm64.tar.gz'; \
			sha256='e2e8aa88e1b5170a0d495d7d9c766af2b2b6c6925a8f8956d834ad6b4cacbd9a'; \
			;; \
		'x86') \
			url='https://dl.google.com/go/go1.21.6.linux-386.tar.gz'; \
			sha256='05d09041b5a1193c14e4b2db3f7fcc649b236c567f5eb93305c537851b72dd95'; \
			;; \
		'ppc64le') \
			url='https://dl.google.com/go/go1.21.6.linux-ppc64le.tar.gz'; \
			sha256='e872b1e9a3f2f08fd4554615a32ca9123a4ba877ab6d19d36abc3424f86bc07f'; \
			;; \
		'riscv64') \
			url='https://dl.google.com/go/go1.21.6.linux-riscv64.tar.gz'; \
			sha256='86a2fe6597af4b37d98bca632f109034b624786a8d9c1504d340661355ed31f7'; \
			;; \
		's390x') \
			url='https://dl.google.com/go/go1.21.6.linux-s390x.tar.gz'; \
			sha256='92894d0f732d3379bc414ffdd617eaadad47e1d72610e10d69a1156db03fc052'; \
			;; \
		*) echo >&2 "error: unsupported architecture '$arch' (likely packaging update needed)"; exit 1 ;; \
	esac; \
	\
	wget -O go.tgz.asc "$url.asc"; \
	wget -O go.tgz "$url"; \
	echo "$sha256 *go.tgz" | sha256sum -c -; \
	\
# https://github.com/golang/go/issues/14739#issuecomment-324767697
	GNUPGHOME="$(mktemp -d)"; export GNUPGHOME; \
# https://www.google.com/linuxrepositories/
	gpg --batch --keyserver keyserver.ubuntu.com --recv-keys 'EB4C 1BFD 4F04 2F6D DDCC  EC91 7721 F63B D38B 4796'; \
# let's also fetch the specific subkey of that key explicitly that we expect "go.tgz.asc" to be signed by, just to make sure we definitely have it
	gpg --batch --keyserver keyserver.ubuntu.com --recv-keys '2F52 8D36 D67B 69ED F998  D857 78BD 6547 3CB3 BD13'; \
	gpg --batch --verify go.tgz.asc go.tgz; \
	gpgconf --kill all; \
	rm -rf "$GNUPGHOME" go.tgz.asc; \
	\
	tar -C /usr/local -xzf go.tgz; \
	rm go.tgz; \
	\
	apk del --no-network .fetch-deps; \
	\
	go version

# don't auto-upgrade the gotoolchain
# https://github.com/docker-library/golang/issues/472
ENV GOTOOLCHAIN=local

ENV GOPATH /go
ENV PATH $GOPATH/bin:$PATH
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 1777 "$GOPATH"
WORKDIR $GOPATH