{ stdenv, easybuild, callPackage } :

let
  self = _self;
  _self = with self; {
  

  buildEasyBuildPackage = callPackage ../development/easybuild/generic easybuild;


  bzip = buildEasyBuildPackage {
	name = "bzip2-1.0.6";

  };
}; in self
