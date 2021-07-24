#!/bin/bash
mkdir -p "${STEAMAPPDIR}" || true  

bash "${STEAMCMDDIR}/steamcmd.sh" \
    +login anonymous \
	+force_install_dir "${STEAMAPPDIR}" \
	+app_update "${STEAMAPPID}" \
	+quit

# If TF2 Classic app does not exist, then It stops container.
if [ ! -d "${STEAMAPPDIR}/${STEAMAPP}" ]; then
    echo Installing TF2 Classic game mod
	wget -O tf2classic.zip "${TF2CLASSICDLURL}"
    7za x tf2classic.zip
    chown -R "${USER}:${USER}" tf2classic
    chmod +x tf2classic/tf2c-updater
    mv tf2classic "${STEAMAPPDIR}"
    rm tf2classic.zip
fi

if [ ! -L "${STEAMAPPDIR}/bin/vphysics.so" ]; then
    ln -sr "${STEAMAPPDIR}/bin/vphysics_srv.so" "${STEAMAPPDIR}/bin/vphysics.so"
    ln -sr "${STEAMAPPDIR}/bin/studiorender_srv.so" "${STEAMAPPDIR}/bin/studiorender.so"
    ln -sr "${STEAMAPPDIR}/bin/soundemittersystem_srv.so" "${STEAMAPPDIR}/bin/soundemittersystem.so"
    ln -sr "${STEAMAPPDIR}/bin/shaderapiempty_srv.so" "${STEAMAPPDIR}/bin/shaderapiempty.so"
    ln -sr "${STEAMAPPDIR}/bin/scenefilecache_srv.so" "${STEAMAPPDIR}/bin/scenefilecache.so"
    ln -sr "${STEAMAPPDIR}/bin/replay_srv.so" "${STEAMAPPDIR}/bin/replay.so"
    ln -sr "${STEAMAPPDIR}/bin/materialsystem_srv.so" "${STEAMAPPDIR}/bin/materialsystem.so"
fi

if [ -f "${STEAMAPPDIR}/${STEAMAPP}/tf2c-updater" ]; then
	cd "${STEAMAPPDIR}/${STEAMAPP}/"
	./tf2c-updater update
fi

# Believe it or not, if you don't do this srcds_run shits itself
cd "${STEAMAPPDIR}"

bash "${STEAMAPPDIR}/srcds_run" -game "${STEAMAPP}" -console -autoupdate \
                        -steam_dir "${STEAMCMDDIR}" \
                        -steamcmd_script "${HOMEDIR}/${STEAMAPP}_update.txt" \
                        -usercon \
                        +fps_max "${SRCDS_FPSMAX}" \
                        -tickrate "${SRCDS_TICKRATE}" \
                        -port "${SRCDS_PORT}" \
                        +tv_port "${SRCDS_TV_PORT}" \
                        +clientport "${SRCDS_CLIENT_PORT}" \
                        +maxplayers "${SRCDS_MAXPLAYERS}" \
                        +map "${SRCDS_STARTMAP}" \
                        +sv_setsteamaccount "${SRCDS_TOKEN}" \
                        +rcon_password "${SRCDS_RCONPW}" \
                        +sv_password "${SRCDS_PW}" \
                        +sv_region "${SRCDS_REGION}" \
                        -ip "${SRCDS_IP}" \
                        -authkey "${SRCDS_WORKSHOP_AUTHKEY}"
