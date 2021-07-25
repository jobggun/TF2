###########################################################
# Dockerfile that builds a TF2 Gameserver
###########################################################
FROM cm2network/steamcmd:root

LABEL maintainer="walentinlamonos@gmail.com"

ENV STEAMAPPID 244310
ENV STEAMAPP tf2classic
ENV STEAMAPPDIR "${HOMEDIR}/${STEAMAPP}-dedicated"
ENV DLURL https://raw.githubusercontent.com/jobggun/TF2C
ENV TF2CLASSICDLURL https://files.moevsmachine.tf/tf2classic_full_2-0-3_linux.zip

# Run Steamcmd and install TF2
# Create autoupdate config
# Remove packages and tidy up
RUN set -x \
	&& apt-get update \
	&& apt-get upgrade -y \
	&& apt-get install -y --no-install-recommends --no-install-suggests \
		wget \
		ca-certificates \
		lib32z1 \
		libncurses5:i386 \
		libbz2-1.0:i386 \
		lib32gcc1 \
		lib32stdc++6 \
		libtinfo5:i386 \
		libcurl3-gnutls:i386 \
		libcurl3-gnutls \
		libarchive13 \
		p7zip-full

RUN mkdir -p "${STEAMAPPDIR}" \
	&& wget "${DLURL}/master/entry.sh" -O "${HOMEDIR}/entry.sh" \
	&& { \
		echo '@ShutdownOnFailedCommand 1'; \
		echo '@NoPromptForPassword 1'; \
		echo 'login anonymous'; \
		echo 'force_install_dir '"${STEAMAPPDIR}"''; \
		echo 'app_update '"${STEAMAPPID}"''; \
		echo 'quit'; \
	   } > "${HOMEDIR}/${STEAMAPP}_update.txt" \
	&& chmod +x "${HOMEDIR}/entry.sh" \
	&& chown -R "${USER}:${USER}" "${HOMEDIR}/entry.sh" "${STEAMAPPDIR}" "${HOMEDIR}/${STEAMAPP}_update.txt" \
	&& rm -rf /var/lib/apt/lists/*

ENV SRCDS_FPSMAX=300 \
	SRCDS_TICKRATE=66 \
	SRCDS_PORT=27015 \
	SRCDS_TV_PORT=27020 \
    SRCDS_NET_PUBLIC_ADDRESS="0" \
    SRCDS_IP="0" \
	SRCDS_MAXPLAYERS=16 \
	SRCDS_TOKEN=0 \
	SRCDS_RCONPW="changeme" \
	SRCDS_PW="" \
	SRCDS_STARTMAP="ctf_2fort" \
	SRCDS_REGION=3 \
    SRCDS_WORKSHOP_START_MAP=0 \
    SRCDS_HOST_WORKSHOP_COLLECTION=0 \
    SRCDS_WORKSHOP_AUTHKEY=""

USER ${USER}

VOLUME ${STEAMAPPDIR}

WORKDIR ${HOMEDIR}

CMD ["bash", "entry.sh"]

# Expose ports
EXPOSE 27015/tcp \
	27015/udp \
	27020/udp
