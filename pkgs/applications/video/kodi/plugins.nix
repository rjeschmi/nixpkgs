{ stdenv, fetchFromGitHub, cmake, kodi, steam, libcec_platform, tinyxml }:

let

  pluginDir = "/share/kodi/addons";

  kodi-platform = stdenv.mkDerivation rec {
    project = "kodi-platform";
    version = "15.2";
    name = "${project}-${version}";

    src = fetchFromGitHub {
      owner = "xbmc";
      repo = project;
      rev = "45d6ad1984fdb1dc855076ff18484dbec33939d1";
      sha256 = "1fai33mwyv5ab47b16i692g7a3vcnmxavx13xin2gh16y0qm62hi";
    };

    buildInputs = [ cmake kodi libcec_platform tinyxml ];
  };

  mkKodiPlugin = { plugin, namespace, version, src, meta, ... }:
  stdenv.lib.makeOverridable stdenv.mkDerivation rec {
    inherit src meta;
    name = "kodi-plugin-${plugin}-${version}";
    passthru = {
      kodiPlugin = pluginDir;
      namespace = namespace;
    };
    dontStrip = true;
    installPhase = ''
      d=$out${pluginDir}/${namespace}
      mkdir -p $d
      sauce="."
      [ -d ${namespace} ] && sauce=${namespace}
      cp -R "$sauce/"* $d
    '';
  };

in
{

  advanced-launcher = mkKodiPlugin rec {

    plugin = "advanced-launcher";
    namespace = "plugin.program.advanced.launcher";
    version = "2.5.8";

    src = fetchFromGitHub {
      owner = "edwtjo";
      repo = plugin;
      rev = version;
      sha256 = "142vvgs37asq5m54xqhjzqvgmb0xlirvm0kz6lxaqynp0vvgrkx2";
    };

    meta = with stdenv.lib; {
      homepage = "http://forum.kodi.tv/showthread.php?tid=85724";
      description = "A program launcher for Kodi";
      longDescription = ''
        Advanced Launcher allows you to start any Linux, Windows and
        OS X external applications (with command line support or not)
        directly from the Kodi GUI. Advanced Launcher also give you
        the possibility to edit, download (from Internet resources)
        and manage all the meta-data (informations and images) related
        to these applications.
      '';
      platforms = platforms.all;
      maintainers = with maintainers; [ edwtjo ];
    };

  };

  genesis = mkKodiPlugin rec {

    plugin = "genesis";
    namespace = "plugin.video.genesis";
    version = "5.1.3";

    src = fetchFromGitHub {
      owner = "lambda81";
      repo = "lambda-addons";
      rev = "f2cd04f33af88d60e1330573bbf2ef9cee7f0a56";
      sha256 = "0z0ldckqqif9v5nhnjr5n2495cm3z9grjmrh7czl4xlnq4bvviqq";
    };

    meta = with stdenv.lib; {
      homepage = "http://forums.tvaddons.ag/forums/148-lambda-s-kodi-addons";
      description = "The origins of streaming";
      platforms = platforms.all;
      maintainers = with maintainers; [ edwtjo ];
    };

  };

  svtplay = mkKodiPlugin rec {

    plugin = "svtplay";
    namespace = "plugin.video.svtplay";
    version = "4.0.18";

    src = fetchFromGitHub {
      owner = "nilzen";
      repo = "xbmc-" + plugin;
      rev = "b60cc1164d0077451be935d0d1a26f2d29b0f589";
      sha256 = "0rdmrgjlzhnrpmhgqvf2947i98s51r0pjbnwrhw67nnqkylss5dj";
    };

    meta = with stdenv.lib; {
      homepage = "http://forum.kodi.tv/showthread.php?tid=67110";
      description = "Watch content from SVT Play";
      longDescription = ''
        With this addon you can stream content from SVT Play
        (svtplay.se). The plugin fetches the video URL from the SVT
        Play website and feeds it to the Kodi video player. HLS (m3u8)
        is the preferred video format by the plugin.
      '';
      platforms = platforms.all;
      maintainers = with maintainers; [ edwtjo ];
    };

  };

  steam-launcher = (mkKodiPlugin rec {
  
    plugin = "steam-launcher";
    namespace = "script.steam.launcher";
    version = "3.1.1";

    src = fetchFromGitHub rec {
      owner = "teeedubb";
      repo = owner + "-xbmc-repo";
      rev = "bb66db7c4927619485373699ff865a9b00e253bb";
      sha256 = "1skjkz0h6nkg04vylhl4zzavf5lba75j0qbgdhb9g7h0a98jz7s4";
    };

    meta = with stdenv.lib; {
      homepage = "http://forum.kodi.tv/showthread.php?tid=157499";
      description = "Launch Steam in Big Picture Mode from Kodi";
      longDescription = ''
        This add-on will close/minimise Kodi, launch Steam in Big
        Picture Mode and when Steam BPM is exited (either by quitting
        Steam or returning to the desktop) Kodi will
        restart/maximise. Running pre/post Steam scripts can be
        configured via the addon.
      '';
      maintainers = with maintainers; [ edwtjo ];
    };
  }).override {
    propagatedBuildinputs = [ steam ];
  };

  pvr-hts = (mkKodiPlugin rec {
    plugin = "pvr-hts";
    namespace = "pvr.hts";
    version = "2.1.18";

    src = fetchFromGitHub {
      owner = "kodi-pvr";
      repo = "pvr.hts";
      rev = "016b0b3251d6d5bffaf68baf59010e4347759c4a";
      sha256 = "03lhxipz03r516pycabqc9b89kd7wih3c2dr4p602bk64bsmpi0j";
    };

    meta = with stdenv.lib; {
      homepage = https://github.com/kodi-pvr/pvr.hts;
      description = "Kodi's Tvheadend HTSP client addon";
      platforms = platforms.all;
      maintainers = with maintainers; [ page ];
    };
  }).override {
    buildInputs = [ cmake kodi libcec_platform kodi-platform ];

    # disables check ensuring install prefix is that of kodi
    cmakeFlags = [ "-DOVERRIDE_PATHS=1" ];

    # kodi checks for plugin .so libs existance in the addon folder (share/...)
    # and the non-wrapped kodi lib/... folder before even trying to dlopen
    # them. Symlinking .so, as setting LD_LIBRARY_PATH is of no use
    installPhase = ''
      make install
      ln -s $out/lib/kodi/addons/pvr.hts/pvr.hts.so $out/share/kodi/addons/pvr.hts
    '';
  };
}
