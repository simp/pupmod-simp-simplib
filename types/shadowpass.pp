# /etc/shadow password allowed values
type Simplib::ShadowPass = Pattern['(^\*$|^!{1,2}.?|^\$([156]|2[ay]){1}\$.+)']
