easybuild:

{ buildInputs ? [], ... } @ attrs:

easybuild.stdenv.mkDerivation ( { 

    buildInputs = [ pythonPackages.easybuild-framework pythonPackages.easybuild-easyblocks pythonPackages.easybuild-easyconfigs ];


    
    installPhase = ''
	export PYTHONPATH="$pythonPackages.easybuild-framework/lib/python2.7/site-packages"
	eb --modules-tool=Lmod --prefix=$out
    '';
    }
    { 
      name = "eb-" + attrs.name;
    }
}
)
