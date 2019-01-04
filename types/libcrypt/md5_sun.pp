# Regular expression pulled from the crypt(5) man page
type Simplib::Libcrypt::MD5_Sun = Pattern['^\$md5(,rounds=[1-9][0-9]+)?\$[./0-9A-Za-z]{8}\${1,2}[./0-9A-Za-z]{22}$']
