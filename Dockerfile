FROM alpine:3.6
RUN apk update
RUN apk add --no-cache --update gcc musl-dev make
RUN apk add --no-cache --update bash gnupg1
RUN apk add --no-cache --update ncurses-dev gpgme-dev openssl-dev cyrus-sasl-dev gdbm-dev libidn-dev 

ENV pkg_version="1.8.3"
RUN gpg --list-keys
RUN gpg --recv-keys 0xadef768480316bda
RUN wget ftp://ftp.mutt.org/pub/mutt/mutt-${pkg_version}.tar.gz
RUN wget ftp://ftp.mutt.org/pub/mutt/mutt-${pkg_version}.tar.gz.asc
RUN gpg --verify mutt-${pkg_version}.tar.gz.asc
RUN tar xvzf mutt-${pkg_version}.tar.gz
WORKDIR mutt-${pkg_version}

RUN ./configure --prefix=/usr                           \
            --sysconfdir=/etc                       \
            --with-docdir=/usr/share/doc/mutt-1.8.3 \
            --enable-sidebar                        \
	    --with-mailpath=/var/spool/mail 	    \
 	    --enable-flock  \
 	    --enable-hcache  \
            --without-tokyocabinet  \
            --without-qdbm  \
            --with-gdbm    \
            --without-bdb   \
            --with-ssl   \
            --with-sasl  \
 	    --disable-doc   \
            --enable-pgp    \
	    --enable-gpgme  \
	    --enable-imap  \
	    --enable-nls  \
	    --enable-pop  \
	    --enable-smime  \
	    --enable-smtp  \
	    --with-idn  \
	    --without-gss  \
	    --enable-compressed  \
	    --enable-external-dotlock  \
	    --with-curses
RUN make
RUN make install

RUN addgroup -g 500 user \
    && adduser -D -h /home/user -G user -u 500 user
ENV HOME /home/user
WORKDIR $HOME
COPY muttrc .mutt
RUN chown -R user: .mutt
USER user

RUN mkdir -p $HOME/.mutt/cache/headers $HOME/.mutt/cache/bodies \
	&& touch $HOME/.mutt/certificates

ENV LANG C.UTF-8
ENV TERM xterm-256color

COPY run.sh .
CMD ["./run.sh"]
