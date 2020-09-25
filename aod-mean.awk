#!/usr/bin/awk -f
function ltrim(s) { sub(/^[ \t\r\n]+/, "", s); return s }
function rtrim(s) { sub(/[ \t\r\n]+$/, "", s); return s }
function trim(s)  { return rtrim(ltrim(s)); }
BEGIN {
  #retrieve parameters
  lmax=ENVIRON["lmax"];
  #enforce defaults
  if (length(lmax)  == 0) lmax=40;
  #definitions
  type_list["atm"]="GAA"
  type_list["ocn"]="GAB"
  type_list["glo"]="GAC"
  type_list["oba"]="GAD"
  #inits
  type="none";
  oldfile="/dev/stderr";
  lmin=9999999999
  start_date=9999-99-99
  stop_date=0000-00-00
  GM=0
  A=0
  ERRORS=0
  NORMALIZED=0
}
  #load parameters
  /CONSTANT GM/ {
    split($0,line,":");
    if (GM==0) { GM=line[2] } else {
      if (GM!=line[2]) {
        printf("ERROR: 'CONSTANT GM' is inconsistent across files!");
        exit_invoked=1;
        exit 1;
      }
    }
  };
  /CONSTANT A/ {
    split($0,line,":");
    if (A==0) { A=line[2] } else {
      if (A!=line[2]) {
        printf("ERROR: 'CONSTANT A' is inconsistent across files!");
        exit_invoked=1;
        exit 1;
      }
    }
  };
  /COEFFICIENTS ERRORS/ {
    split($0,line,":");
    if (ERRORS==0) { ERRORS=line[2] } else {
      if (ERRORS!=line[2]) {
        printf("ERROR: 'COEFFICIENTS ERRORS' is inconsistent across files!");
        exit_invoked=1;
        exit 1;
      }
    }
  };
  /COEFF. NORMALIZED/ {
    split($0,line,":");
    if (NORMALIZED==0) { NORMALIZED=line[2] } else {
      if (NORMALIZED!=line[2]) {
        printf("ERROR: 'COEFF. NORMALIZED' is inconsistent across files!");
        exit_invoked=1;
        exit 1;
      }
    }
  };
  #update start/stop dates
  /TIME FIRST OBS/ {
    split($0,line,":")
    split(line[2],value,"(")
    split(value[2],date)
    if (start_date>date[1]) {
      start_date=date[1]
      print "Start date updated to",start_date
    }
  }
  /TIME LAST OBS/ {
    split($0,line,":")
    split(line[2],value,"(")
    split(value[2],date)
    if (stop_date<date[1]) {
      stop_date=date[1]
      print "Stop date updated to",stop_date
    }
  }
  #capture AOD type
  /DATA SET .* OF TYPE .*/ {
    type=$11
    c[type]++
  };
  #accumulate data
  /^[ 0-9]/ {
    if (type!="none") {
      d=$1
      if (d<=lmax) {
        if (length(d)>0 && lmin>d) {
          lmin=d
        }
        o=$2
        C[type,d,o]=C[type,d,o]+$3
        S[type,d,o]=S[type,d,o]+$4
      }
    } else {
      printf("ERROR: found data line before 'DATA SET * OF TYPE *' line");
      exit_invoked=1;
      exit 1;
    }
  }

END {

  if ( ! exit_invoked ) {
    for (type in type_list) {
      filenow=type_list[type]"_"start_date"_"stop_date".gfc"
      printf("product_type                  %s\n",trim(type_list[type])) > filenow
      printf("earth_gravity_constant        %s\n",trim(GM))              >> filenow
      printf("radius                        %s\n",trim(A))               >> filenow
      printf("max_degree                    %s\n",trim(lmax))            >> filenow
      printf("norm                          %s\n",trim(ERRORS))          >> filenow
      printf("errors                        %s\n",trim(NORMALIZED))      >> filenow
      print("key    L    M       C                   S                   sigma C            sigma S")    >> filenow
      print("end_of_head =============================================================================") >> filenow
      for (d = lmin; d <= lmax; d++) {
        for (o = 0; o <= d; o++) {
          printf("gfc %4d %4d %18.11e %18.11e +0.00000000000E+00 +0.00000000000E+00\n",d,o,C[type,d,o]/c[type],S[type,d,o]/c[type]) >> filenow
        }
      }
    }
  }
}
